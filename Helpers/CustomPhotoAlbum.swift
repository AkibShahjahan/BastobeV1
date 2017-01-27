//
//  CustomPhotoAlbum.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-12-24.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import Foundation

import Photos

class CustomPhotoAlbum {
    
    static let albumName = "Bastobe"
    static let sharedInstance = CustomPhotoAlbum()
    
    var assetCollection: PHAssetCollection!
    
    init() {
        
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
            
            if let _: AnyObject = collection.firstObject {
                return collection.firstObject as! PHAssetCollection
            }
            
            return nil
        }
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(CustomPhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }
    
    func saveImage(image: UIImage) {
        
        if assetCollection == nil {
            return   // If there was an error upstream, skip the save.
        }
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image);
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset;
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection);
            albumChangeRequest!.addAssets(NSArray(array: [assetPlaceholder!] as [PHObjectPlaceholder]));
            }, completionHandler: nil)
    }
    
    func saveVideo(url: NSURL) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(url);
            let assetPlaceHolder = assetChangeRequest!.placeholderForCreatedAsset;
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceHolder!])
            }, completionHandler: nil)
    }
}