//
//  FeedViewController.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-10-23.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit
import CoreLocation
class FeedViewController: UIPageViewController, NVActivityIndicatorViewable, CLLocationManagerDelegate {

    // Need to provide these
    var feedType: String = String();
    var mediaFeed: [Medias] = [Medias]();
    var latitude: Double = Double(); // optional
    var longitude: Double = Double(); // optional
    
    var userLatitude: Double = Double();
    var userLongitude: Double = Double();
    
    var activityIndicatorView: NVActivityIndicatorView!
    
    static var mainIndex: Int = 0;

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var locationManager: CLLocationManager = CLLocationManager();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization()
        if(locationManager.location == nil) {
            userLatitude = config.defaultLocation.latitude;
            userLongitude = config.defaultLocation.longitude;
        } else {
            userLatitude = getLatitude(locationManager);
            userLongitude = getLongitude(locationManager);
        }
        
        // Set the dataSource and delegate in code.
        dataSource = self
        delegate = self
        
        // this sets the background color of the built-in paging dots
        view.backgroundColor = UIColor.blackColor();

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(FeedViewController.closeAction));
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down;
        view.addGestureRecognizer(swipeDown);
        
        // initialize the feed array
        initializeFeed(latitude, long: longitude);
    }
    
    func initializeFeed(lat: Double, long: Double) {
        FeedViewController.mainIndex = 0;
        
        self.startActivityIndicator();

        switch (feedType){
        case strings.feed.localStream:
            getLocalStream(lat, yCord: long, callback: {(mediaList: [Medias]) -> Void in
                self.setup(mediaList);
            })
        case strings.feed.localRank:
            getLocalRank(lat, yCord: long, callback: {(mediaList: [Medias]) -> Void in
                self.setup(mediaList);
            })
        case strings.feed.globalRank:
            getGlobalRank({(mediaList: [Medias]) -> Void in
                self.setup(mediaList);
            })
        case strings.feed.commentStream:
            getUserComments({(mediaList: [Medias]) -> Void in
                self.setup(mediaList);
            })
        case strings.feed.spreadStream:
            getUserSpreads({(mediaList: [Medias]) -> Void in
                self.setup(mediaList);
            })
        case strings.feed.likeStream:
            getUserLikes({(mediaList: [Medias]) -> Void in
                self.setup(mediaList);
            })
        default:
            closeAction();
        }
        
    }
    
    func setup(mediaList: [Medias]) {
        if(mediaList.count == 0) {
            statusNotification(strings.status.noMedia, duration: 2.0, type: "negative");
            closeAction();
            return;
        }
        self.stopActivityIndicator();
        self.mediaFeed = mediaList;
        // TODO check when the below returns nil what to do cuz now it crashes
        // Not sure what to do about this...
        self.setViewControllers([self.getNext(FeedViewController.mainIndex)!], direction: .Forward, animated: false, completion: nil)
    }
    
    func closeAction() {
        self.dismissViewControllerAnimated(false, completion: nil);
    }

    func getNext(index: Int) -> MediaViewController? {
        print("MediaFeed");
        print(mediaFeed);
        if(index < 0 || index >= mediaFeed.count) {
            return nil
        }
        if(Users.sharedInstance.points <= 0) {
            noPointsStatus();
            closeAction();
        }
        
        let controller: MediaViewController = storyboard!.instantiateViewControllerWithIdentifier("MediaView") as! MediaViewController
        controller.theMedia = mediaFeed[index];
        controller.currentIndex = index;
        controller.userLatitude = userLatitude;
        controller.userLongitude = userLongitude;
        return controller;
    }
    
    
    func getPrevious(index: Int) -> MediaViewController? {
        if(index < 0 || index >= mediaFeed.count) {
            return nil;
        }
        let controller: MediaViewController = storyboard!.instantiateViewControllerWithIdentifier("MediaView") as! MediaViewController
        controller.theMedia = mediaFeed[index];
        controller.currentIndex = index;
        controller.userLatitude = userLatitude;
        controller.userLongitude = userLongitude;
        return controller;
    }
    
    
    func startActivityIndicator() {
        activityIndicatorView = makeActivityIndicator(self);
        activityIndicatorView.startAnimation();
    }
    
    func stopActivityIndicator() {
        activityIndicatorView.stopAnimation();
    }
    
}

// MARK: - UIPageViewControllerDataSource methods

extension FeedViewController : UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return getPrevious(FeedViewController.mainIndex - 1);
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return getNext(FeedViewController.mainIndex + 1);
    }
}

// MARK: - UIPageViewControllerDelegate methods

extension FeedViewController : UIPageViewControllerDelegate {
    
}


