//
//  ScrollMainViewController.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-10-02.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit

class ScrollMainViewController: UIViewController {
    
    var startPage = String();
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let scrollView = UIScrollView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height));
        scrollView.translatesAutoresizingMaskIntoConstraints = true;
        scrollView.pagingEnabled=true;
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.bounces = false;

        self.view.addSubview(scrollView);
        self.automaticallyAdjustsScrollViewInsets = false;
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let mainController = storyboard.instantiateViewControllerWithIdentifier("MainView") as! MainViewController;
        let personalController = storyboard.instantiateViewControllerWithIdentifier("PersonalView") as! ProfileViewController;
        let cameraControllers = storyboard.instantiateViewControllerWithIdentifier("CameraView") as! CameraViewController;
        let viewControllers = [cameraControllers, mainController, personalController];

        
        let bounds = UIScreen.mainScreen().bounds;
        let width = bounds.size.width;
        let height = bounds.size.height;
        scrollView.contentSize = CGSizeMake(width*CGFloat(viewControllers.count), height);
        

        var index:Int = 0;
        for viewController in viewControllers {
            let originX:CGFloat = CGFloat(index) * width;
            viewController.view.frame = CGRectMake(originX, 0, width, height);
            scrollView.addSubview(viewController.view);
            viewController.didMoveToParentViewController(self);
            addChildViewController(viewController);
            index += 1;
        }
        
        if(startPage == strings.pages.camera) {
            let point: CGPoint = CGPointMake(0, 0);
            scrollView.setContentOffset(point, animated: false);
        } else if(startPage == strings.pages.main) {
            let point: CGPoint = CGPointMake(scrollView.frame.size.width,0);
            scrollView.setContentOffset(point, animated: false);
        } else if(startPage == strings.pages.personal) {
            let point: CGPoint = CGPointMake(scrollView.frame.size.width*2,0);
            scrollView.setContentOffset(point, animated: false);
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
