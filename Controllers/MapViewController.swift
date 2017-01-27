//
//  MapViewController.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-12-22.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet var playStreamButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var mapView:GMSMapView?
    
    var latitude: Double = Double();
    var longitude: Double = Double();
    
    var updateButton: UIButton = UIButton();
    
    var mediaList: [Medias] = [Medias]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: 13.0)
        
        mapView = GMSMapView.mapWithFrame(CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height), camera: camera)
        
        
        setMediaPins(latitude, long: longitude);
        
        mapView?.delegate = self;
    
        self.view.addSubview(mapView!);
        self.view.bringSubviewToFront(closeButton);
        self.view.bringSubviewToFront(playStreamButton);
        design();// has to be below those

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRectMake(20, 50, UIScreen.mainScreen().bounds.width-40, 65.0))
        
        subView.addSubview((searchController?.searchBar)!)
        self.view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        
        searchController?.searchBar.barTintColor = designs.colors.theme;
        searchController?.searchBar.tintColor = UIColor.whiteColor();
        searchController?.searchBar.placeholder = "Explore";
    }
    
    func setMediaPins(lat: Double, long: Double) {
        getMapFeed(lat, yCord: long, callback: {(mediaList: [Medias]) -> Void in
            if(mediaList.count > 25) {
                self.mediaList = Array(mediaList[0...24]);
            } else {
                self.mediaList = mediaList;
            }
            self.mapView?.clear();
            var ref: Int = 0;
            for media in self.mediaList {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: media.coordinate.x, longitude: media.coordinate.y);
                marker.icon = UIImage(data: UIImagePNGRepresentation(UIImage(named: "pinFilled")!)!, scale: 3.0);
                marker.userData = ref;
                ref = ref + 1;
                marker.map = self.mapView;
            }
            
        })
    }
    
    func design() {
        closeButton.layer.shadowRadius = designs.button.shadowRadius;
        closeButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        closeButton.layer.shadowOffset = CGSizeZero;
        closeButton.layer.masksToBounds = false;

        let updateButtonImage: UIImage = UIImage(named: "mainLogo")!;
        updateButton = UIButton(type: UIButtonType.Custom) as UIButton;
        updateButton.frame = CGRect(x: UIScreen.mainScreen().bounds.midX-20, y: UIScreen.mainScreen().bounds.midY-60, width: 40, height: 60)
        updateButton.setImage(updateButtonImage, forState: .Normal)
        updateButton.addTarget(self, action: #selector(MapViewController.updateAction), forControlEvents:.TouchUpInside)
        self.view.addSubview(updateButton)
        self.view.bringSubviewToFront(updateButton);

    }
    
    func updateAction() {
        setMediaPins((mapView?.camera.target.latitude)!, long: (mapView?.camera.target.longitude)!);
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        let controller: MediaViewController = storyboard!.instantiateViewControllerWithIdentifier("MediaView") as! MediaViewController
        controller.theMedia = mediaList[marker.userData as! Int];
        controller.userLatitude = latitude;
        controller.userLongitude = longitude;
        self.presentViewController(controller, animated: false, completion: nil);
        return true;
    }

    @IBAction func closeAction(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil);
    }
    
    @IBAction func playStreamAction(sender: UIButton) {
        let controller: FeedViewController = storyboard!.instantiateViewControllerWithIdentifier("FeedView") as! FeedViewController;
        controller.feedType = strings.feed.localRank;
        controller.latitude = (mapView?.camera.target.latitude)!;
        controller.longitude = (mapView?.camera.target.longitude)!;
        self.presentViewController(controller, animated: false, completion: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// Handle the user's selection.
extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        // Do something with the selected place.
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.coordinate.latitude)
        
        let camera = GMSCameraPosition.cameraWithLatitude(place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 13.0)
        mapView!.camera = camera;
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: NSError){
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
