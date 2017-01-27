//
//  MainViewController.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-06-16.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import CoreLocation

var profileImg: UIImage = UIImage();
class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var localStreamButton: UIButton!;
    @IBOutlet var localRankButton: UIButton!;
    @IBOutlet var pinStreamButton: UIButton!
    @IBOutlet var globalRankButton: UIButton!;
    
    @IBOutlet var localRankIcon: UIImageView!
    @IBOutlet var globalRankIcon: UIImageView!
    @IBOutlet var localStreamLabel: UILabel!;
    @IBOutlet var pinStreamIcon: UIImageView!
    
    @IBOutlet var localStreamPreview: UIImageView!
    @IBOutlet var localRankPreview: UIImageView!
    @IBOutlet var globalStreamPreview: UIImageView!
    @IBOutlet var globalRankPreview: UIImageView!
    
    var locationManager: CLLocationManager = CLLocationManager();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization()
        
        localStreamLabel.text = "Local";
        
        setPreviews();
        print(config.headers);
       
        // Design the labels, images and buttons
        design();
//
        
    }
    
    func design() {
        // Label Shadows
        
        pinStreamIcon.layer.shadowRadius = designs.label.shadowRadius;
        pinStreamIcon.layer.shadowOpacity = designs.label.shadowOpactiyLabels;
        pinStreamIcon.layer.shadowOffset = CGSizeZero;
        pinStreamIcon.layer.masksToBounds = false;
        
        globalRankIcon.layer.shadowRadius = designs.label.shadowRadius;
        globalRankIcon.layer.shadowOpacity = designs.label.shadowOpactiyLabels;
        globalRankIcon.layer.shadowOffset = CGSizeZero;
        globalRankIcon.layer.masksToBounds = false;
        
        localStreamLabel.layer.shadowRadius = designs.label.shadowRadius;
        localStreamLabel.layer.shadowOpacity = designs.label.shadowOpactiyLabels;
        localStreamLabel.layer.shadowOffset = CGSizeZero;
        localStreamLabel.layer.masksToBounds = false;
        
        localRankIcon.layer.shadowRadius = designs.label.shadowRadius;
        localRankIcon.layer.shadowOpacity = designs.label.shadowOpactiyLabels;
        localRankIcon.layer.shadowOffset = CGSizeZero;
        localRankIcon.layer.masksToBounds = false;
        
        // Button Shade
        localStreamButton.backgroundColor = UIColor.blackColor()
        localStreamButton.alpha = designs.button.shadeAlpha;
        localRankButton.backgroundColor = UIColor.blackColor();
        localRankButton.alpha = designs.button.shadeAlpha;
        pinStreamButton.backgroundColor = UIColor.blackColor();
        pinStreamButton.alpha = designs.button.shadeAlpha;
        globalRankButton.backgroundColor = UIColor.blackColor()
        globalRankButton.alpha = designs.button.shadeAlpha;
        
    }
    
    // These actions are used only for graphical purposes
    // No real action is taking place
    @IBAction func buttonTouchDownAction(sender: UIButton) {
        sender.backgroundColor = UIColor.blackColor();
        sender.alpha = designs.button.shadeTouchDownAlpha;
    }
    
    @IBAction func buttonTouchUpAction(sender: UIButton) {
        sender.alpha = designs.button.shadeAlpha;
    }
    
    @IBAction func buttonTouchUpInsideAction(sender: UIButton) {
        if (Users.sharedInstance.points! <= 0) {
            noPointsStatus();
            return;
        }
        if(!checkLocationSetting(locationManager)) {
            return;
        }
        if(sender == pinStreamButton) {
            let controller: MapViewController = storyboard!.instantiateViewControllerWithIdentifier("MapView") as! MapViewController;
            controller.latitude = getLatitude(locationManager);
            controller.longitude = getLongitude(locationManager);
            self.presentViewController(controller, animated: false, completion: nil);
        } else {
            let controller: FeedViewController = storyboard!.instantiateViewControllerWithIdentifier("FeedView") as! FeedViewController;
            if(sender == localRankButton) {
                controller.feedType = strings.feed.localRank;
            } else if (sender == globalRankButton) {
                controller.feedType = strings.feed.globalRank;
            } else if (sender == localStreamButton) {
                controller.feedType = strings.feed.localStream;
            }
            controller.latitude = getLatitude(locationManager);
            controller.longitude = getLongitude(locationManager);
            self.presentViewController(controller, animated: false, completion: nil);
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
    
  
    @IBAction func cameraAction(sender: AnyObject) {
        changeView(self, viewStoryboardID: "CameraView", animation: false);

    }
    
    func getPreviewImageThenSet(imageName: String) {
        if(!isImageStored(imageName)) { print("NAAAA"); return; }
        
        let imagePath = fileInDocumentsDirectory(FBSDKAccessToken.currentAccessToken().userID + "_" + imageName + ".png");
        if let loadedImage = loadImageFromPath(imagePath) {
            if(imageName == strings.file.preview.localStream) {
                self.localStreamPreview.image = loadedImage;
                
            } else if(imageName == strings.file.preview.localRank) {
                self.localRankPreview.image = loadedImage;
            } else if(imageName == strings.file.preview.globalRank) {
                self.globalRankPreview.image = loadedImage;
            } else if(imageName == strings.file.preview.globalStream) {
                self.globalStreamPreview.image = loadedImage;
            }
            print("it worked!!!");
        } else {
            print("it did not work!!");
        }
    }
    
    func setPreviews() {
        getPreviewImageThenSet(strings.file.preview.localStream);
        getPreviewImageThenSet(strings.file.preview.localRank);
        getPreviewImageThenSet(strings.file.preview.globalRank);
        getPreviewImageThenSet(strings.file.preview.globalStream);
        localStreamLabel.text = getLocalUserLastLocation();
        
        if(checkLocationSetting(locationManager)) {
            let latitude: Double = getLatitude(locationManager);
            let longitude: Double = getLongitude(locationManager);
            getLocalStreamPreview(latitude, yCord: longitude, callback: { (preview) in
                if(preview.count > 0) {
                    setImageById(preview[0], photoView: self.localStreamPreview, callback: {
                        storeImage(strings.file.preview.localStream, image: self.localStreamPreview.image!);
                    });
                }
            });
            getLocalRankPreview(latitude, yCord: longitude, callback: { (preview) in
                if(preview.count > 0) {
                    setImageById(preview[0], photoView: self.localRankPreview, callback: {
                        self.localRankPreview.backgroundColor = UIColor.blackColor();
                        storeImage(strings.file.preview.localRank, image: self.localRankPreview.image!);
                    });
                }
            });
            
            // set city name
            let geoCoder = CLGeocoder();
            let location = CLLocation(latitude: latitude, longitude: longitude)
            geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if(error != nil) {
                    self.localStreamLabel.text = "Local"
                } else {
                    let placeArray = placemarks as [CLPlacemark]!
                    let placeMark: CLPlacemark = (placeArray?[0])!
                    
                    if let city = placeMark.addressDictionary!["City"] as? String {
                        self.localStreamLabel.text = city;
                        setLocalUserLastLocation(city);
                    }
                }
            }
            
        }
        
        getGlobalRankPreview { (preview) in
            if(preview.count > 0) {
                setImageById(preview[0], photoView: self.globalRankPreview, callback: {
                    storeImage(strings.file.preview.globalRank, image: self.globalRankPreview.image!);
                    
                })
            }
        }
    
        getGlobalStreamPreview { (preview) in
            if(preview.count > 0) {
                setImageById(preview[0], photoView: self.globalStreamPreview, callback: {
                    storeImage(strings.file.preview.globalStream, image: self.globalStreamPreview.image!);

                })
            }
        }

        
    }

}
