//
//  Comments.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-07-16.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import Foundation

class Comments {

    private(set) var commentContent: String?;
    private(set) var mediaId: String?;
    private(set) var creatorName: String?;
    private(set) var id: String?;
    private(set) var creatorId: String?;
    private(set) var creatorFbId: String?;
    private(set) var time: NSDate = NSDate();
    
    init(id: String, creatorId: String, creatorFbId: String, creatorName: String, mediaId: String, commentContent: String, time: NSDate) {
        self.id = id;
        self.creatorId = creatorId;
        self.creatorFbId = creatorFbId;
        self.creatorName = creatorName;
        self.mediaId = mediaId;
        self.commentContent = commentContent;
        self.time = time;
    }
    
    func getProfilePic(callback:(image: UIImage)->Void){
        let urlPath: String = "https://graph.facebook.com/\(creatorFbId! as String)/picture?type=normal"
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