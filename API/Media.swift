//
//  Media.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-05-23.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import Foundation
import Alamofire

// TODO: ELSE ERROR CASE FOR EVERY BACKEND CALL

func postMedia(caption: String, xCord: Double, yCord: Double, type: String, pinned: Bool, callback:(String) -> Void) {
    Alamofire.request(.POST, "\(config.server.url)/\(config.server.apiCode)/medias", parameters: ["creator_id": Users.sharedInstance.nodeId!, "creator_fb_id": FBSDKAccessToken.currentAccessToken().userID, "caption_label": caption, "author": Users.sharedInstance.firstName! + " " + Users.sharedInstance.lastName!, "cord_x": xCord, "cord_y": yCord, "media_type": type, "pinned": pinned], headers: config.headers).responseString { response in
        if let mediaId = response.result.value {
            postComment(mediaId, userLat: xCord, userLong: yCord, mediaLat: xCord, mediaLong: yCord, commentContent: caption, callback:{()})
            callback(mediaId);
        }
    }
}

func putActivateMedia(mediaId: String, mediaCreatorId: String, callback:() -> Void){
    Alamofire.request(.PUT, "\(config.server.url)/\(config.server.apiCode)/medias/activate", parameters: ["creator_id": Users.sharedInstance.nodeId!, "media_id": mediaId], headers: config.headers);
}

func deleteMedia(mediaId: String, callback: () -> Void) {
    Alamofire.request(.DELETE, "\(config.server.url)/\(config.server.apiCode)/medias/\(mediaId)/\(Users.sharedInstance.nodeId!)", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode == 200) {
            callback();
        }
    }
}

//func getMedia(mediaId: String, callback:(media: Medias)->Void) {
//    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/medias/\(mediaId)").responseJSON { response in
//        if let json = response.result.value as? Dictionary<String, AnyObject> {
//            callback(media: mediaToObject(json));
//        }
//    }
//}

// Feeds
func getLocalStream(xCord: Double, yCord: Double, callback:(mediaList: [Medias])->Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/medias/stream/\(xCord)/\(yCord)/\(Users.sharedInstance.nodeId!)", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(mediaList: []);
            return;
        }
        if let json = response.result.value as? [Dictionary<String, AnyObject>] {
            callback(mediaList: toMediaObjs(json));
        } else {
            callback(mediaList: []);
        }
    }
}

func getLocalRank(xCord: Double, yCord: Double, callback:(mediaList: [Medias])->Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/medias/rank/\(xCord)/\(yCord)/\(Users.sharedInstance.nodeId!)", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(mediaList: []);
            return;
        }
        if let json  = response.result.value as? Array<Dictionary<String, AnyObject>> {
            callback(mediaList: toMediaObjs(json));
        } else {
            callback(mediaList: []);
        }
    }
}
func getMapFeed(xCord: Double, yCord: Double, callback:(mediaList: [Medias])->Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/medias/rank/\(xCord)/\(yCord)/\(Users.sharedInstance.nodeId!)/map", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(mediaList: []);
            return;
        }
        if let json  = response.result.value as? Array<Dictionary<String, AnyObject>> {
            callback(mediaList: toMediaObjs(json));
        } else {
            callback(mediaList: []);
        }
    }
}

func getGlobalStream(callback:(mediaList: [Medias])->Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/medias/stream/global/\(Users.sharedInstance.nodeId!)", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(mediaList: []);
            return;
        }
        if let json  = response.result.value as? Array<Dictionary<String, AnyObject>> {
            callback(mediaList: toMediaObjs(json));
        } else {
            callback(mediaList: []);
        }
    }
}

func getGlobalRank(callback:(mediaList: [Medias])->Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/medias/rank/global/\(Users.sharedInstance.nodeId!)", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(mediaList: []);
            return;
        }
        if let json  = response.result.value as? Array<Dictionary<String, AnyObject>> {
            callback(mediaList: toMediaObjs(json));
        } else {
            callback(mediaList: []);
        }
    }
}

func putViewMedia(mediaId: String, callback:() -> Void) {
    Alamofire.request(.PUT, "\(config.server.url)/\(config.server.apiCode)/medias/view", parameters: ["viewer_id": Users.sharedInstance.nodeId!, "media_id": mediaId], headers: config.headers);
}

func putLikeMedia(mediaId: String, mediaCreatorId: String, callback:() -> Void){
    Alamofire.request(.PUT, "\(config.server.url)/\(config.server.apiCode)/medias/like", parameters: ["liker_id": Users.sharedInstance.nodeId!, "media_id": mediaId], headers: config.headers);
}

func putUnlikeMedia(mediaId: String, mediaCreatorId: String, callback:() -> Void){
    Alamofire.request(.PUT, "\(config.server.url)/\(config.server.apiCode)/medias/unlike", parameters: ["unliker_id": Users.sharedInstance.nodeId!, "media_id": mediaId], headers: config.headers)
}

func putSpreadMedia(mediaId: String, mediaCreatorId: String, callback:() -> Void) {
    // Do stuff here
    var friendsIDs = [String]();
    let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: ["fields": "id"]);
    fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
        if error == nil {
            if let userNameArray : NSArray = result.valueForKey("data") as? NSArray {
                for i in 0 ..< userNameArray.count {
                    friendsIDs.append(userNameArray[i].valueForKey("id") as! String)
                }
                Alamofire.request(.PUT, "\(config.server.url)/\(config.server.apiCode)/medias/spread", parameters: ["spreader_id": Users.sharedInstance.nodeId!, "media_id": mediaId, "friends_list": "\(friendsIDs)"], headers: config.headers).responseString { response in
                    
                    if response.result.value != nil{
                        print("Success")
                    } else {
                        print("Error with putSpreadMedia.");
                    }
                }
            } else {
                print("Error Getting Friends \(error)");
            }
        }
    }
}

// Cannot use a common helper because its asynchornous 

func isMediaViewed(mediaId: String, callback:(viewed: Bool) -> Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/mediaRecords/\(mediaId)/viewed/\(Users.sharedInstance.nodeId!)", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(viewed: false);
            return;
        }
        if let json = response.result.value {
            let response = json["response"] as! Bool;
            callback(viewed: response);
        } else {
            callback(viewed: false);
        }
    }
}

func isMediaLiked(mediaId: String, callback:(response: Bool) -> Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/mediaRecords/\(mediaId)/liked/\(Users.sharedInstance.nodeId!)", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(response: false);
            return;
        }
        if let json = response.result.value {
            let response = json["response"] as! Bool;
            callback(response: response);
        } else {
            callback(response: false);
        }
    }
}

func isMediaSpreaded(mediaId: String, callback:(response: Bool) -> Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/mediaRecords/\(mediaId)/spreaded/\(Users.sharedInstance.nodeId!)", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(response: false);
            return;
        }
        if let json = response.result.value {
            let response = json["response"] as! Bool;
            callback(response: response);
        } else {
            callback(response: false);
        }
    }
}

func getCommentsByMediaId(mediaId: String, callback:(commentsList: [Comments]) -> Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/medias/comments/\(mediaId)", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(commentsList: []);
            return;
        }
        if let json  = response.result.value as? Array<Dictionary<String, AnyObject>> {
            callback(commentsList : toCommentObjs(json));
        } else {
            callback(commentsList: []);
        }
    }
}

func postComment(mediaId: String, userLat: Double, userLong: Double, mediaLat: Double, mediaLong: Double, commentContent: String, callback:() -> Void) {
    let fullName = "\(Users.sharedInstance.firstName!) \(Users.sharedInstance.lastName!)"
    Alamofire.request(.POST, "\(config.server.url)/\(config.server.apiCode)/medias/comments", parameters: ["creator_id": Users.sharedInstance.nodeId!, "creator_fbid": FBSDKAccessToken.currentAccessToken().userID, "creator_name": fullName, "media_id": mediaId, "comment_content": commentContent, "user_lat": userLat, "user_long": userLong, "media_lat": mediaLat, "media_long": mediaLong], headers: config.headers).responseJSON { response in
        callback()
    }
}

func putFlagMedia(mediaId: String, mediaCreatorId: String, callback:() -> Void) {
    Alamofire.request(.PUT, "\(config.server.url)/\(config.server.apiCode)/mediaRecords/flag", parameters: ["flagger_id": Users.sharedInstance.nodeId!, "media_id": mediaId, "creator_id": mediaCreatorId], headers: config.headers).responseJSON { response in
        callback()
    }

}

// Get Previews
func getLocalStreamPreview(xCord: Double, yCord: Double, callback:(preview: [String])->Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/medias/stream/\(xCord)/\(yCord)/\(Users.sharedInstance.nodeId!)/preview", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(preview: []);
            return;
        }
        if let json = response.result.value as? [String] {
            callback(preview: json);
        } else {
            callback(preview: []);
        }
    }
}
func getLocalRankPreview(xCord: Double, yCord: Double, callback:(preview: [String])->Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/medias/rank/\(xCord)/\(yCord)/\(Users.sharedInstance.nodeId!)/preview", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(preview: []);
            return;
        }
        if let json = response.result.value as? [String] {
            callback(preview: json);
        } else {
            callback(preview: []);
        }
    }
}
func getGlobalStreamPreview(callback:(preview: [String])->Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/medias/stream/global/\(Users.sharedInstance.nodeId!)/preview", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(preview: []);
            return;
        }
        if let json = response.result.value as? [String] {
            callback(preview: json);
        } else {
            callback(preview: []);
        }
    }
}
func getGlobalRankPreview(callback:(preview: [String])->Void) {
    print("There we start");
    print(Users.sharedInstance.nodeId!);
    print("There we end");
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/medias/rank/global/\(Users.sharedInstance.nodeId!)/preview", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            print(response.response);
            callback(preview: []);
            return;
        }
        if let json = response.result.value as? [String] {
            callback(preview: json);
        } else {
            callback(preview: []);
        }
    }
}


