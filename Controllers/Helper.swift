//
//  Helper.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-05-13.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import Foundation
import CoreLocation


let config = Configuration();
let strings = Strings();
let designs = Designs();

extension String
{
    func myTrim() -> String
    {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

func changeView(currentView: UIViewController, viewStoryboardID: String, animation: Bool) {
    currentView.presentViewController((currentView.storyboard?.instantiateViewControllerWithIdentifier(viewStoryboardID))!, animated: animation, completion: nil);
}

// CONDITION: User location MUST be turned on (TODO?)
func getLatitude(locationManager:CLLocationManager) -> Double {
    return locationManager.location!.coordinate.latitude;
}

func getLongitude(locationManager:CLLocationManager) -> Double {
    return locationManager.location!.coordinate.longitude;
}

func fixImageOrientation(image: UIImage) -> UIImage {
    if(image.size.height < image.size.width){
        return UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: .Right);
    }
    return image;
}

func toMediaObjs(mediaJSON: [Dictionary<String, AnyObject>]) -> [Medias] {
    var mediaObjs = [Medias]();
    for i in 0 ..< mediaJSON.count {
        if let _ = mediaJSON[i]["creatorId"] {
            mediaToObject(mediaJSON[i]);
            mediaObjs.append(mediaToObject(mediaJSON[i]));
        } else {
            return [];
        }
    }
    return mediaObjs;
}

func mediaToObject(mediaJSON: Dictionary<String, AnyObject>) -> Medias{

    let id: String = mediaJSON["_id"] as! String;
    let type: String = mediaJSON["mediaType"] as! String;
    let creatorId: String = mediaJSON["creatorId"] as! String;
    
    let creatorFbId: String;
    if let temp = mediaJSON["creatorFbId"] as? String {
        creatorFbId = temp;
    } else {
        creatorFbId = "";
    }
        
    let creatorName: String = mediaJSON["generalInfo"]!["author"] as! String!;
    let caption: String = mediaJSON["generalInfo"]!["caption"] as! String!;
    let x: Double = mediaJSON["coordinate"]!["x"] as! Double!;
    let y: Double = mediaJSON["coordinate"]!["y"] as! Double!;
    let views: Int = mediaJSON["views"] as! Int;
    let likes: Int = mediaJSON["generalInfo"]!["likes"] as! Int!;
    let spreads: Int = mediaJSON["generalInfo"]!["spreads"] as! Int!;
    let locationName: String = "";
    
    let pinned: Bool;
    if let temp = mediaJSON["pinned"] as? Bool {
        pinned = temp;
    } else {
        pinned = false;
    }
    
    let timeS: String = mediaJSON["time"] as! String;
    let formatter = NSDateFormatter();
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    let localDate: NSDate = formatter.dateFromString(timeS)!;
    
    let media: Medias = Medias(id: id, type: type, creatorId: creatorId, creatorFbId: creatorFbId, creatorName: creatorName, caption: caption, x: x, y: y, views: views, likes: likes, spreads: spreads, locationName: locationName, pinned: pinned, time: localDate)
    
    return media;
    
}

func toCommentObjs(commentsJSON: [Dictionary<String, AnyObject>]) -> [Comments] {
    var commentObjs = [Comments]();
    
    
    for i in 0 ..< commentsJSON.count {
        if let _ = commentsJSON[i]["creatorId"] {
            let id: String = commentsJSON[i]["_id"] as! String;
            let creatorId: String = commentsJSON[i]["creatorId"] as! String;
            let creatorFbId: String = commentsJSON[i]["creatorFbId"] as! String;
            let creatorName: String = commentsJSON[i]["creatorName"] as! String;
            let mediaId: String = commentsJSON[i]["mediaId"] as! String;
            let commentContent: String = commentsJSON[i]["commentContent"] as! String;
            
            let timeS: String = commentsJSON[i]["time"] as! String;
            let formatter = NSDateFormatter();
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            let localDate: NSDate = formatter.dateFromString(timeS)!;

            
            commentObjs.append(Comments(id: id, creatorId: creatorId, creatorFbId: creatorFbId, creatorName: creatorName, mediaId: mediaId, commentContent: commentContent, time: localDate));
        } else {
            return [];
        }
    }
    return commentObjs;
}

let notification = CWStatusBarNotification()

func statusNotification(message: String, duration: NSTimeInterval, type: String) {


    notification.notificationLabelBackgroundColor = UIColor.whiteColor();
    
    if (type == "positive") {
        notification.notificationLabelTextColor = UIColor(red: 89/255, green: 206/255, blue: 15/255, alpha: 1.0)
    } else if (type == "negative") {
        notification.notificationLabelTextColor = UIColor.redColor();
    }
    else {
        notification.notificationLabelTextColor = UIColor(red:0.05, green: 0.37, blue: 0.98, alpha: 1.0);
    }

    notification.notificationAnimationInStyle = .Top
    notification.notificationAnimationOutStyle = .Top
    notification.notificationStyle = .StatusBarNotification
    notification.notificationLabelFont = UIFont.boldSystemFontOfSize(14)
    notification.displayNotificationWithMessage(message, forDuration: duration);
}

func checkInternet() -> Bool {
    if(!Reachability.isConnectedToNetwork()) {
        performClosureAfterDelay(0.5, closure: {
            statusNotification(strings.error.noInternet, duration: 2.0, type: "negative");
        });
        return false;
    }
    return true;
}

func checkLocationSetting(locationManager: CLLocationManager) -> Bool {
    if(locationManager.location == nil) {
        performClosureAfterDelay(0.5, closure: {
            statusNotification(strings.error.noLocation, duration: 2.0, type: "negative");
            performClosureAfterDelay(2.5, closure: {
                statusNotification(strings.status.enableLocation, duration: 2.5, type: "neutral")
            });
        });
        return false;
    }
    return true;
}

func updateUserInfo(callback:()->Void) {
    getUserByFbId(FBSDKAccessToken.currentAccessToken().userID) {
        setLocalUserPoints(Users.sharedInstance.points!);
        callback();
    }
}

func confirmationAlert(vc: UIViewController, title: String, message: String, yes: () -> Void, no: () -> Void) {
    let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    
    refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
        yes()
    }))
    
    refreshAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (action: UIAlertAction!) in
        no();
    }))
    
    vc.presentViewController(refreshAlert, animated: true, completion: nil)
}

func messageAlert(vc: UIViewController, title: String, message: String) {
    let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { (action: UIAlertAction!) in }))
    vc.presentViewController(refreshAlert, animated: true, completion: nil)
}

func isWithinAccessRadius(mediaLat: Double, mediaLong: Double, userLat: Double, userLong: Double) -> Bool {
    let accessRadius = config.media.accessRadius;
    if(userLat > mediaLat - accessRadius && userLat < mediaLat + accessRadius && userLong > mediaLong - accessRadius && userLong < mediaLong + accessRadius) {
        return true;
    }
    return false;
}

