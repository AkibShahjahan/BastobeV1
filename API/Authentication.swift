//
//  Authentication.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-05-13.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import Alamofire

func fbLogin(currentView: UIViewController, callback:() -> Void) {
    let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, email, picture.type(large)"])
    graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
        if error != nil { // This case shouldn't happen
        } else if result != nil {
            Alamofire.request(.POST, "\(config.server.url)/login/facebook", parameters: ["access_token": FBSDKAccessToken.currentAccessToken().tokenString]).responseJSON { response in
                if let json  = response.result.value{
                    let firstName = json["facebook"]!!["firstName"] as! String;
                    let lastName = json["facebook"]!!["lastName"] as! String;
                    let points = json["points"] as! Int;
                    let nodeId = json["_id"] as! String;
                    let accessToken = json["facebook"]!!["token"] as! String;
                    Users.sharedInstance.initialize(firstName, lastName: lastName, points: points, nodeId: nodeId, accessToken: accessToken)
                    config.headers = ["access_token": Users.sharedInstance.accessToken! as String];
                    callback();
                }
                else {
                    print("nooooo");
                }
            }
        }
    }
    
}

func fbLogout(currentView: UIViewController) {
    let loginManager = FBSDKLoginManager();
    loginManager.logOut();
    Users.sharedInstance.deleteKeychainInfo();
    changeView(currentView, viewStoryboardID: "LoginView", animation: false);
    
}
