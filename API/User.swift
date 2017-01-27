//
//  User.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-05-12.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import Foundation
import Alamofire

// TODO: ELSE ERROR CASE FOR EVERY BACKEND CALL
// TODO: add failure callback

func getUserByFbId(fbId: String, callback:() -> Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/users/\(fbId)/user", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            return;
        }
        if let json  = response.result.value {
            let firstName = json["facebook"]!!["firstName"] as! String;
            let lastName = json["facebook"]!!["lastName"] as! String;
            let points = json["points"] as! Int;
            let nodeId = json["_id"] as! String;
            let accessToken = json["facebook"]!!["token"] as! String;
            Users.sharedInstance.initialize(firstName, lastName: lastName, points: points, nodeId: nodeId, accessToken: accessToken)
            callback();
        }
    }
}

func getUserLikes(callback:(mediaList: [Medias]) -> Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/userRecords/\(Users.sharedInstance.nodeId!)/likes", headers: config.headers).responseJSON { response in
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

func getUserSpreads(callback:(mediaList: [Medias]) -> Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/userRecords/\(Users.sharedInstance.nodeId!)/spreads", headers: config.headers).responseJSON { response in
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

func getUserComments(callback:(mediaList: [Medias]) -> Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/userRecords/\(Users.sharedInstance.nodeId!)/comments", headers: config.headers).responseJSON { response in
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

func putBlockUser(blockedId: String,  callback:() -> Void) {
    Alamofire.request(.PUT, "\(config.server.url)/\(config.server.apiCode)/users/block", parameters: ["blocker_id": Users.sharedInstance.nodeId!, "blocked_id": blockedId], headers: config.headers).responseJSON { response in
        callback()
    }
}

func getUserLikesPreview(callback:(preview: [String]) -> Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/userRecords/\(Users.sharedInstance.nodeId!)/likes/preview", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(preview: []);
            return;
        }
        if let json  = response.result.value as? [String] {
            callback(preview: json);
        } else {
            callback(preview: []);
        }
    }
}

func getUserSpreadsPreview(callback:(preview: [String]) -> Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/userRecords/\(Users.sharedInstance.nodeId!)/spreads/preview", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(preview: []);
            return;
        }
        if let json  = response.result.value as? [String] {
            callback(preview: json);
        } else {
            callback(preview: []);
        }
    }
}

func getUserCommentsPreview(callback:(preview: [String]) -> Void) {
    Alamofire.request(.GET, "\(config.server.url)/\(config.server.apiCode)/userRecords/\(Users.sharedInstance.nodeId!)/comments/preview", headers: config.headers).responseJSON { response in
        if(response.response?.statusCode != 200) {
            callback(preview: []);
            return;
        }
        if let json  = response.result.value as? [String] {
            callback(preview: json);
        } else {
            callback(preview: []);
        }
    }
}




