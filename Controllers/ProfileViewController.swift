//
//  ProfileViewController.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-06-17.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileViewController: UIViewController, CLLocationManagerDelegate {
    
    // All the IBOutlet connections
    
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var spreadButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    
    @IBOutlet var commentImage: UIImageView!
    @IBOutlet var spreadImage: UIImageView!
    @IBOutlet var likeImage: UIImageView!
    
    
    @IBOutlet var commentPreview: UIImageView!
    @IBOutlet var spreadPreview: UIImageView!
    @IBOutlet var likePreview: UIImageView!
    
    @IBOutlet var userFbImage: UIImageView!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var pointsButton: UIButton!
    @IBOutlet var logoutLabel: UILabel!
    @IBOutlet var logoutButton: UIButton!
    
    var locationManager: CLLocationManager = CLLocationManager();

    override func viewDidLoad() {
        super.viewDidLoad();
        
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization()
        
        // Design the labels, images and buttons
        design();
        
        // Set user points and the previews
        updatePointsFromLocal();
        setPreviews();
    }
    
    // TODO: Update points regularly and efficiently
    
    func design() {
        // Image shadows
        commentImage.layer.shadowRadius = designs.image.shadowRadius;
        commentImage.layer.shadowOpacity = designs.image.shadowOpactiyLabels;
        commentImage.layer.shadowOffset = CGSizeZero;
        commentImage.layer.masksToBounds = false;
        
        spreadImage.layer.shadowRadius = designs.image.shadowRadius;
        spreadImage.layer.shadowOpacity = designs.image.shadowOpactiyLabels;
        spreadImage.layer.shadowOffset = CGSizeZero;
        spreadImage.layer.masksToBounds = false;
        
        likeImage.layer.shadowRadius = designs.image.shadowRadius;
        likeImage.layer.shadowOpacity = designs.image.shadowOpactiyLabels;
        likeImage.layer.shadowOffset = CGSizeZero;
        likeImage.layer.masksToBounds = false;
        
        // Label shadows
        pointsLabel.layer.shadowRadius = designs.label.shadowRadius;
        pointsLabel.layer.shadowOpacity = designs.label.shadowOpactiyLabels;
        pointsLabel.layer.shadowOffset = CGSizeZero;
        pointsLabel.layer.masksToBounds = false;
        
        logoutLabel.layer.shadowRadius = designs.label.shadowRadius;
        logoutLabel.layer.shadowOpacity = designs.label.shadowOpactiyLabels;
        logoutLabel.layer.shadowOffset = CGSizeZero;
        logoutLabel.layer.masksToBounds = false;
        
        // Button Shade
        commentButton.backgroundColor = UIColor.blackColor();
        commentButton.alpha = designs.button.shadeAlpha;
        spreadButton.backgroundColor = UIColor.blackColor();
        spreadButton.alpha = designs.button.shadeAlpha;
        likeButton.backgroundColor = UIColor.blackColor();
        likeButton.alpha = designs.button.shadeAlpha;
        pointsButton.backgroundColor = UIColor.blackColor()
        pointsButton.alpha = designs.button.shadeAlpha;
        logoutButton.backgroundColor = UIColor.blackColor();
        logoutButton.alpha = designs.button.shadeAlpha;
    }
 
    // These actions are used on for graphical purposes
    // No real action is taking place
    @IBAction func touchDownAction(sender: UIButton) {
        sender.backgroundColor = UIColor.blackColor();
        sender.alpha = designs.button.shadeTouchDownAlpha;
        if(sender == pointsButton) {
            updatePointsFromLocal();
        }
    }
    @IBAction func buttonTouchUpAction(sender: UIButton) {
        sender.alpha = designs.button.shadeAlpha;
    }

    @IBAction func buttonTouchUpInsideAction(sender: UIButton) {
        let controller:FeedViewController = storyboard!.instantiateViewControllerWithIdentifier("FeedView") as! FeedViewController
        if(sender == commentButton) {
            controller.feedType = strings.feed.commentStream;
        } else if (sender == spreadButton) {
            controller.feedType = strings.feed.spreadStream;
        } else if (sender == likeButton) {
            controller.feedType = strings.feed.likeStream;
        }
        
        if(locationManager.location == nil) {
            controller.latitude = config.defaultLocation.latitude;
            controller.longitude = config.defaultLocation.longitude;
        } else {
            controller.latitude = getLatitude(locationManager);
            controller.longitude = getLongitude(locationManager);
        }
        self.presentViewController(controller, animated: false, completion: nil);
        
    }
    
    @IBAction func pointsAction(sender: UIButton) {
        let controller: ListViewController = storyboard!.instantiateViewControllerWithIdentifier("FriendsView") as! ListViewController;
        controller.listType = strings.listType.friends;
        self.presentViewController(controller, animated: false, completion: nil);
    }
    
    
    @IBAction func logoutAction(sender: UIButton) {
        if(checkInternet()) {
            fbLogout(self);
        }
    }
    
    // Only Potrait orientation allowed
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.PortraitUpsideDown];
        return orientation;
    }
    
    func getPreviewImageThenSet(imageName: String) {
        if(!isImageStored(imageName)) { print("looma");return; }
        
        let imagePath =  fileInDocumentsDirectory(FBSDKAccessToken.currentAccessToken().userID + "_" + imageName + ".png");
        if let loadedImage = loadImageFromPath(imagePath) {
            if(imageName == strings.file.preview.like) {
                self.likePreview.image = loadedImage
            } else if(imageName == strings.file.preview.spread) {
                self.spreadPreview.image = loadedImage;
            } else if(imageName == strings.file.preview.comment) {
                self.commentPreview.image = loadedImage;
            } else if(imageName == strings.file.preview.profile) {
                self.userFbImage.image = loadedImage;
            }
        } else {
            print("it did not work");
        }
    }
    
    func setPreviews() {
        getPreviewImageThenSet(strings.file.preview.comment);
        getPreviewImageThenSet(strings.file.preview.spread);
        getPreviewImageThenSet(strings.file.preview.like);
        getPreviewImageThenSet(strings.file.preview.profile);
        
        // Profile pic
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "picture.type(large)"])
        graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            if error != nil {
                // This case shouldn't happen
                // TODO: ERROR MESSAGE
            } else if result != nil {
                let data = result["picture"] as? NSDictionary
                let dataDict = data!["data"] as? NSDictionary
                let imageStringUrl = dataDict!["url"] as? String
                let imageUrl = NSURL(string: imageStringUrl!)
                let imageData = NSData(contentsOfURL: imageUrl!)
                
                profileImg = UIImage(data: imageData!)!;
                self.userFbImage.image = profileImg;
                storeImage(strings.file.preview.profile, image: self.userFbImage.image!);
                
            }
        }
        getUserLikesPreview { (preview) in
            if(preview.count > 0) {
                setImageById(preview[0], photoView: self.likePreview, callback: {
                    storeImage(strings.file.preview.like, image: self.likePreview.image!)
                })
            }
        }
        
        getUserSpreadsPreview { (preview) in
            if(preview.count > 0) {
                setImageById(preview[0], photoView: self.spreadPreview, callback: {
                    storeImage(strings.file.preview.spread, image: self.spreadPreview.image!)
                })
            }
        }
        
        getUserCommentsPreview { (preview) in
            if(preview.count > 0) {
                setImageById(preview[0], photoView: self.commentPreview, callback: {
                    storeImage(strings.file.preview.comment, image: self.commentPreview.image!);
                })
            }
        }
    }
    
    func updatePointsFromLocal() {
        pointsLabel.text = String(Users.sharedInstance.points!);
        updateUserInfo {
            self.pointsLabel.text = String(Users.sharedInstance.points!);
        }
    }
    
}
