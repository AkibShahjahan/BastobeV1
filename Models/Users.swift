//
//  Users.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-05-14.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//
//
//  Users.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-05-13.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import Foundation


var USER_FIRST_NAME: String = "";
var USER_LAST_NAME: String = "";
var USER_POINTS: Int = 0;
var USER_NODE_ID: String = "";
var USER_FB_ID: String = "";
var USER_ACCESS_TOKEN: String = "";

class Users {
    private(set) var firstName: String?;
    private(set) var lastName: String?;
    private(set) var points: Int?;
    private(set) var nodeId: String?;
    private(set) var accessToken: String? = "";
    
    
    static let sharedInstance = Users();
    
    private init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        self.firstName = defaults.objectForKey("firstName") as? String;
        self.lastName = defaults.objectForKey("lastName") as? String;
        self.points = defaults.objectForKey("points") as? Int;
        self.nodeId = defaults.objectForKey("nodeId") as? String;
        self.accessToken = KeychainWrapper.stringForKey("accessToken");
    }
    
    func initialize(firstName: String, lastName: String, points: Int, nodeId: String, accessToken: String) {
        KeychainWrapper.setString(accessToken, forKey: "accessToken")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(firstName, forKey: "firstName")
        defaults.setObject(lastName, forKey: "lastName")
        defaults.setObject(points, forKey: "points")
        defaults.setObject(nodeId, forKey: "nodeId")
        
        self.firstName = firstName;
        self.lastName = lastName;
        self.points = points;
        self.nodeId = nodeId;
        self.accessToken = accessToken;

    }
    
    func deleteKeychainInfo() {
        KeychainWrapper.removeObjectForKey("accessToken")
    }
    
    func setPoints(points: Int) {
        self.points = points;
    }

    
}


