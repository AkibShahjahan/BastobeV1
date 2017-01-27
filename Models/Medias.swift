//
//  Medias.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-06-26.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import Foundation

class Medias {
    
    private(set) var caption: String = String();
    private(set) var type: String = String();
    private(set) var locationName: String = String();
    private(set) var id: String = String();
    private(set) var creatorId: String = String();
    private(set) var creatorFbId: String = String();
    private(set) var creatorName: String = String();
    private(set) var pinned: Bool = Bool();
    private(set) var time: NSDate = NSDate();
        
    struct mediaInfo {
        var views: Int = Int();
        var likes: Int = Int();
        var spreads: Int = Int();
    }
    private(set) var info: mediaInfo = mediaInfo();

    
    struct mediaCoordinate {
        var x = Double();
        var y = Double();
    }
    private(set) var coordinate = mediaCoordinate();

    init() {}
    
    init(id: String, type: String, creatorId: String, creatorFbId: String, creatorName: String, caption: String, x: Double, y: Double,
         views: Int, likes: Int, spreads: Int, locationName: String, pinned: Bool, time: NSDate) {
        
        self.id = id;
        self.type = type;
        self.creatorId = creatorId;
        self.creatorFbId = creatorFbId;
        self.creatorName = creatorName;
        self.caption = caption;
        
        let coordinate = mediaCoordinate(x: x, y: y);
        self.coordinate = coordinate;
        
        let info = mediaInfo(views: views, likes: likes, spreads: spreads);
        self.info = info;

        self.locationName = locationName;
        self.pinned = pinned;
        self.time = time;
    }

    func incrementLikes() {
        info.likes += 1;
    }
    func decrementLikes() {
        info.likes -= 1;
    }
    func incrementSpreads() {
        info.spreads += 1;
    }
    func incrementViews() {
        info.views += 1;
    }
    
    
    func mediaViewSetup(callback:()->Void) {
        isMediaViewed(id, callback: {(viewed: Bool) -> Void in
            if(!viewed) {
                self.incrementViews();
                Users.sharedInstance.setPoints(Users.sharedInstance.points! - 1);
                putViewMedia(self.id, callback:{() -> Void in});
                callback(); // self.viewCountLabel.text = "\(Int(self.viewCountLabel.text!)!+1)"
            } else {
                callback();
            }
        })
    }
    
    
    func applyLikeChange(initial: Bool, final: Bool) {
        let mediaId: String = id;
        let mediaCreatorId: String = creatorId;
        
        if(initial != final) {
            if(final) {
                incrementLikes();
                putLikeMedia(mediaId, mediaCreatorId: mediaCreatorId, callback: {() -> Void in});
            } else {
                decrementLikes();
                putUnlikeMedia(mediaId, mediaCreatorId: mediaCreatorId, callback: {() -> Void in});
            }
        }
    }
    
    func getCreatorPic(callback:(image: UIImage)->Void){
        let urlPath: String = "https://graph.facebook.com/\(creatorFbId)/picture?type=normal"
        print(urlPath);
        let profilePicUrl: NSURL = NSURL(string: urlPath)!;
        
        let task: NSURLSessionTask = NSURLSession.sharedSession().dataTaskWithURL(profilePicUrl) { (data, response, error) in
            if((data) != nil) {
                let image = UIImage(data: data!)
                if((image) != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        callback(image: image!);
                    })
                }
            }
        }
        task.resume()
    }
    
}
