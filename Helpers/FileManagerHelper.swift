//
//  FileManagerHelper.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-10-19.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import Foundation


func saveImage (image: UIImage, path: String ) -> Bool{
    let jpgImageData = UIImageJPEGRepresentation(image, 1.0);
    let result = jpgImageData!.writeToFile(path, atomically: true);
    return result;
}

func getDocumentsURL() -> NSURL {
    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0];
    return documentsURL;
}

func fileInDocumentsDirectory(filename: String) -> String {
    let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename);
    return fileURL.path!;
}

func loadImageFromPath(path: String) -> UIImage? {
    let image = UIImage(contentsOfFile: path);
    if image == nil {
        print("missing image at: \(path)");
    }
    print("Loading image from path: \(path)"); // this is just for you to see the path in case you want to go to the directory, using Finder.
    return image;
}

// creator a directory with fb id

func storeImage(imageName: String, image: UIImage) {
    print("storeImage");
    print(FBSDKAccessToken.currentAccessToken().userID + "_" + imageName + ".png");
    let imagePath = fileInDocumentsDirectory(FBSDKAccessToken.currentAccessToken().userID + "_" + imageName + ".png");
    saveImage(image, path: imagePath)
}

func isImageStored(imageName: String) -> Bool {
    let imagePath = fileInDocumentsDirectory(FBSDKAccessToken.currentAccessToken().userID + "_" + imageName + ".png");
    let fileManager = NSFileManager.defaultManager()
    if fileManager.fileExistsAtPath(imagePath) {
        return true;
    }
    return false;
}

func deleteStoredImage(imageName: String) {
    let imagePath = fileInDocumentsDirectory(imageName + ".png");
    let fileManager = NSFileManager.defaultManager()
    do {
        try fileManager.removeItemAtPath(imagePath)
    }
    catch let error as NSError {
        print("Ooops! Something went wrong: \(error)")
    }
}

func deleteAllImages() {
    deleteStoredImage(strings.file.preview.localStream);
    deleteStoredImage(strings.file.preview.localRank);
    deleteStoredImage(strings.file.preview.globalStream);
    deleteStoredImage(strings.file.preview.globalRank);
    deleteStoredImage(strings.file.preview.like)
    deleteStoredImage(strings.file.preview.comment)
    deleteStoredImage(strings.file.preview.spread)
}