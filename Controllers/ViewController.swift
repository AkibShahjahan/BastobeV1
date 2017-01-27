//
//  ViewController.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-05-07.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKLoginKit

class ViewController: UIViewController {
    
    @IBOutlet var coverView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view, typically from a nib.
        coverView.hidden = true;
    }
    
    override func viewDidAppear(animated: Bool) {
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            print("Now Iam here");
            
            
            // cover screen
            // show loader
            coverView.backgroundColor = designs.colors.theme
            coverView.hidden = false;
            startActivityIndicator();
            fbLogin(self, callback: {
                // stop loader
                self.stopActivityIndicator();
                Users.sharedInstance.setPoints(getLocalUserPoints());
                let controller: ScrollMainViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ScrollMainView") as! ScrollMainViewController;
                controller.startPage = strings.pages.main;
                self.presentViewController(controller, animated: false, completion: nil);
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
    
    // Login Button Action
    @IBAction func fbLoginAction(sender: AnyObject) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager();
        
        // Allow the warning
        fbLoginManager.logInWithReadPermissions(["public_profile", "email", "user_friends"]) { (result, error) in
            if (error == nil){
                print("NOW");
//                fbLogin(self);
            } else {
                print(error);
            }
        }
    }
    
    var activityIndicatorView: NVActivityIndicatorView!
    
    func startActivityIndicator() {
        activityIndicatorView = makeActivityIndicator(self);
        activityIndicatorView.startAnimation();
    }
    
    func stopActivityIndicator() {
        activityIndicatorView.stopAnimation();
    }


}

