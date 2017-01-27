//
//  UIHelper.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-08-20.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import Foundation

func makeActivityIndicator(viewController: UIViewController) -> NVActivityIndicatorView{
    let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    let activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                        type: .BallClipRotate);
    activityIndicatorView.center = viewController.view.center;
    activityIndicatorView.padding = 10
    viewController.view.addSubview(activityIndicatorView);
    return activityIndicatorView
}

func noPointsStatus() {
    updateUserInfo {};
    performClosureAfterDelay(0.5, closure: {
        statusNotification(strings.error.noCredit, duration: 2.0, type: "negative");
        performClosureAfterDelay(2.5, closure: {
            statusNotification(strings.status.earnCredit, duration: 3.0, type: "neutral")
        });
    });
    
    
}

func setImageById(photoID: String, photoView: UIImageView, callback:() -> Void) {
    let ext = "png";
    //        let urlPath: String = config.aws.url + "/" + config.aws.bucket + "/" + config.aws.password + "/" + photoID + "." + ext;
    let urlPath: String = "\(config.aws.cloudfrontURL)/"+photoID+"."+ext;
    let url: NSURL = NSURL(string: urlPath)!;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        if let data = NSData(contentsOfURL: url) {
            
            dispatch_async(dispatch_get_main_queue(), {
                let downloadedImage = UIImage(data: data);
                photoView.image = fixImageOrientation(downloadedImage!);
                callback();
            });
        } else {
            // TODO: Show error message
        }
    }
    
}