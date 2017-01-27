//
//  OnePinMapViewController.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-12-22.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class OnePinMapViewController: UIViewController {

    var mapView:GMSMapView?
    @IBOutlet var closeButton: UIButton!
    var latitude: Double = Double();
    var longitude: Double = Double();

    override func viewDidLoad() {
        super.viewDidLoad()

        design();
        
        // Do any additional setup after loading the view.
        
        let camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: 13.0)
        
        mapView = GMSMapView.mapWithFrame(CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height), camera: camera)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude);
        marker.icon = UIImage(data: UIImagePNGRepresentation(UIImage(named: "pinFilled")!)!, scale: 2.0);
        
        marker.map = mapView;
        mapView?.myLocationEnabled = true;

        
        self.view.addSubview(mapView!);
        self.view.bringSubviewToFront(closeButton);

    }
    
    func design() {
        closeButton.layer.shadowRadius = designs.button.shadowRadius;
        closeButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        closeButton.layer.shadowOffset = CGSizeZero;
        closeButton.layer.masksToBounds = false;

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeAction(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil);
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
