//
//  CameraViewController.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-05-30.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit
import AVFoundation
import SCRecorder

class CameraViewController: UIViewController, SCRecorderDelegate {
    
    let session = SCRecordSession()
    let recorder = SCRecorder()
    var photo: UIImage = UIImage();
    var playing: Bool = false;
    
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var flashButton: UIButton!;
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var cameraFlipButton: UIButton!
    
    var frontCamera: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = UIColor.blackColor();
        self.automaticallyAdjustsScrollViewInsets = false;

        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(CameraViewController.pressed));
        captureButton.addGestureRecognizer(longPressGesture);
        
        recorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices();
        recorder.delegate = self;
        recorder.autoSetVideoOrientation = false;
        recorder.previewView = self.view;
        recorder.mirrorOnFrontCamera = true;
        recorder.initializeSessionLazily = false;
        
        // zoom
        let focusView = SCRecorderToolsView(frame: recorder.previewView!.bounds);
        focusView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleHeight, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleWidth];
        focusView.recorder = recorder;
        self.view.addSubview(focusView);
        self.view.sendSubviewToBack(focusView);
        
        design()
    }
    
    func design() {
        
        // shadows
        flashButton.layer.shadowRadius = designs.button.shadowRadius;
        flashButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        flashButton.layer.shadowOffset = CGSizeZero;
        flashButton.layer.masksToBounds = false;
        
        timerLabel.layer.shadowRadius = designs.button.shadowRadius;
        timerLabel.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        timerLabel.layer.shadowOffset = CGSizeZero;
        timerLabel.layer.masksToBounds = false;
        
        cameraFlipButton.layer.shadowRadius = designs.button.shadowRadius;
        cameraFlipButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        cameraFlipButton.layer.shadowOffset = CGSizeZero;
        cameraFlipButton.layer.masksToBounds = false;
        
        captureButton.layer.shadowRadius = designs.button.shadowRadius;
        captureButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        captureButton.layer.shadowOffset = CGSizeZero;
        captureButton.layer.masksToBounds = false;
        
        
        timerLabel.hidden = true;
        //        timerLabel.layer.borderWidth = 0;
        //        timerLabel.layer.borderColor = UIColor.whiteColor().CGColor
        //        timerLabel.layer.cornerRadius = 5;
        timerLabel.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        captureButton.layer.borderWidth = 5;
        captureButton.layer.cornerRadius = captureButton.frame.height/2;
        captureButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        prepareSession();
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        recorder.previewViewFrameChanged();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        recorder.startRunning();
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        recorder.stopRunning();
    }
    
    func prepareSession() {
        if(recorder.session == nil) {
            session.fileType = AVFileTypeMPEG4;
            recorder.session = session;
        }
    }
    
    
    func captureVideoAnimation() {
        captureButton.layer.borderColor = designs.colors.theme.CGColor;
        captureButton.backgroundColor = designs.colors.theme;
        UIView.animateWithDuration(0.4 ,
                                   animations: {
                                    self.captureButton.transform = CGAffineTransformMakeScale(1.3, 1.3)
            },
                                   completion: { finish in
                                    UIView.animateWithDuration(0.4){
                                        self.captureButton.transform = CGAffineTransformIdentity
                                    }
        })
    }
    
    
    
    func pressed(longPress: UILongPressGestureRecognizer) {
        if (longPress.state == UIGestureRecognizerState.Began) {
            captureVideoAnimation()
            timerLabel.hidden = false;
            flashButton.hidden = true;
            cameraFlipButton.hidden = true;
            
            if(recorder.flashMode == SCFlashMode.On) {
                recorder.flashMode = SCFlashMode.Light;
            }
            
            recorder.session?.removeLastSegment();
            recorder.record();
            playing = true;
        }
        if(longPress.state == UIGestureRecognizerState.Ended || longPress.state == UIGestureRecognizerState.Cancelled){
            stopVideo();
            captureButton.layer.borderColor = UIColor.whiteColor().CGColor;
            captureButton.backgroundColor = UIColor.clearColor();
            timerLabel.hidden = true;
            flashButton.hidden = false;
            cameraFlipButton.hidden = false;
            
        }
    }
    
    @IBAction func changeFlashMode(sender: AnyObject) {
        switch(recorder.flashMode){
        case SCFlashMode.Auto:
            recorder.flashMode = SCFlashMode.On;
            flashButton.setImage(UIImage(named: "flashOnIcon"), forState: UIControlState.Normal);
            break;
        case SCFlashMode.Off:
            recorder.flashMode = SCFlashMode.Auto;
            flashButton.setImage(UIImage(named: "flashAutoIcon"), forState: UIControlState.Normal);
            break;
        case SCFlashMode.On, SCFlashMode.Light:
            recorder.flashMode = SCFlashMode.Off;
            flashButton.setImage(UIImage(named: "flashOffIcon"), forState: UIControlState.Normal);
            break;
        }
    }
    
    private func capturePhoto() {
        recorder.capturePhoto { (err, image) in
            if let image = image {
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MediaPreview");
                if(self.frontCamera) {
                    (controller as! MediaPreviewController).media = Media.Photo(image: UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: .LeftMirrored));
                } else {
                    (controller as! MediaPreviewController).media = Media.Photo(image: image);
                }
                self.presentViewController(controller, animated: false, completion: nil);
            }
        }
    }
    
    @IBAction func mediaCaptureAction(sender: UIButton) {
        self.capturePhoto();
    }
    
    func recorder(recorder: SCRecorder, didAppendVideoSampleBufferInSession session: SCRecordSession) {
        let progress = CMTimeGetSeconds((recorder.session?.duration)!);
        self.timerLabel.text = String(Int(progress));
        if(progress >= config.media.videoMaxLimit) {
            stopVideo();
        }
    }
    
    func stopVideo() {
        print(CMTimeGetSeconds((recorder.session?.duration)!));
        recorder.pause({
            self.session.mergeSegmentsUsingPreset(AVAssetExportPresetHighestQuality) { (url, error) in
                if (error == nil) {
                    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MediaPreview");
                    (controller as! MediaPreviewController).media = Media.Video(url: url!);
                    self.presentViewController(controller, animated: false, completion: nil);
                } else {
                    debugPrint(error)
                }
            }
            
        })
        playing = false;
    }
    
    @IBAction func switchCamera(sender: AnyObject) {
        recorder.switchCaptureDevices();
        frontCamera = !frontCamera;
        
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.PortraitUpsideDown];
        return orientation;
    }
    
    
}