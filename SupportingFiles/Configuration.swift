//
//  Configuration.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-05-23.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit

class Configuration {
    
    // AWS
    struct awsConfig {
        let bucket: String = "bastobe";
        let password: String = "sample";
        let cognitoPoolID: String = "us-east-1:d42ba087-51cc-4a3b-b524-04bf99747172";
        let url: String = "https://s3.amazonaws.com";
        // cloudfront does have a slightly faster download speed, especially for images
        let cloudfrontURL: String = "https://d3ioqn3ss6kd49.cloudfront.net";
    }
    let aws = awsConfig();
    
    // HEROKU
    struct herokuConfig {
        let url: String = "https://arcane-hamlet-49596.herokuapp.com";
        let apiCode: String = "api";
    }
    let server = herokuConfig();
    
    // MEDIA
    struct mediaConfig {
        let captionLimit: Int = 35;
        let videoMaxLimit: Double = 10;
        let videoMinLimit: Double = 1.5;
        let accessRadius: Double = 0.07;
    }
    let media = mediaConfig();
    
    // COMMENT
    struct commentConfig {
        let commentLimit: Int = 80;
    };
    let comment = commentConfig();
    
    // DEFAULT LOCATION
    struct defaultLocationConfig {
        let latitude: Double = 10000;
        let longitude: Double = 10000;
    }
    let defaultLocation = defaultLocationConfig();
    
    // HTTP HEADER
    var headers = ["access_token": ""]//["access_token": Users.sharedInstance.accessToken! as String];
    
    
}
