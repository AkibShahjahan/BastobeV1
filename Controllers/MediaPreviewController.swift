//
//  MediaPreviewController.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-05-30.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//


// TODO: FIGURE OUT IF SUPPORTEDINTERFACEORIENTATION FUNCTION IS NEEDED OR NOT

import UIKit
import CoreLocation
import AWSS3
import AWSCore
import AVFoundation

enum Media {
    case Photo(image: UIImage)
    case Video(url: NSURL)
}

class MediaPreviewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, NVActivityIndicatorViewable {
    
    @IBOutlet var imageView: UIImageView!;
    @IBOutlet var postButton: UIButton!;
    @IBOutlet var captionButton: UIButton!
    @IBOutlet var pinButton: UIButton!
    @IBOutlet var downloadButton: UIButton!
    
    @IBOutlet var captionView: UIView!
    @IBOutlet var captionTextfield: UITextField!;
    
    var videoView: UIView!
    
    var activityIndicatorView: NVActivityIndicatorView!
    var activityIndicating: Bool = false;
    
    var locationManager = CLLocationManager();
    var media: Media!;
    var videoPlayer = AVPlayer();
    
    var pinned: Bool = false;
    
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0
    var keyboardHeight = CGFloat();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        self.view.backgroundColor = UIColor.blackColor();
        hideCaption();
        captionTextfield.delegate = self;
        
        design();
        checkInternet();
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(MediaPreviewController.closeAction));
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down;
        view.addGestureRecognizer(swipeDown);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MediaPreviewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MediaPreviewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func appWillGoToBackground() {
        videoPlayer.pause();
    }
    
    func appWillComeToForeground() {
        videoPlayer.play();
    }

    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification)
            view.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted == true {
            view.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func hideCaption() {
        captionView.hidden = true;
        captionTextfield.hidden = true;
    }
    
    func design() {
        postButton.layer.shadowRadius = designs.button.shadowRadius;
        postButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        postButton.layer.shadowOffset = CGSizeZero;
        postButton.layer.masksToBounds = false;
        
        pinButton.layer.shadowRadius = designs.button.shadowRadius;
        pinButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        pinButton.layer.shadowOffset = CGSizeZero;
        pinButton.layer.masksToBounds = false;
        
        downloadButton.layer.shadowRadius = designs.button.shadowRadius;
        downloadButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        downloadButton.layer.shadowOffset = CGSizeZero;
        downloadButton.layer.masksToBounds = false;
        
        captionButton.layer.shadowRadius = designs.button.shadowRadius;
        captionButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        captionButton.layer.shadowOffset = CGSizeZero;
        captionButton.layer.masksToBounds = false;
        
        captionView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6);
    }
    
    @IBAction func useMediaAction(sender: AnyObject) {
        if(!checkInternet()) { return; }
        if(!checkLocationSetting(locationManager)) { return; }
        //        postButton.enabled = false;
        
        let lat = getLatitude(locationManager);
        let long = getLongitude(locationManager);
        
        var caption = "";
        if(captionTextfield.hidden == false) {
            caption = captionTextfield.text!;
            captionTextfield.resignFirstResponder();
        }
        startActivityIndicator();
        print("useMediaAction()");
        switch self.media!{
        case .Photo(let image): postMedia(caption.myTrim(), xCord: lat, yCord: long, type: "Photo", pinned: pinned, callback: {(mediaID: String) -> Void in
            self.uploadPhotoToAWS(image, imageID: mediaID);
            self.stopActivityIndicator();
            self.closeAction();
        });
        case .Video(let url): postMedia(caption.myTrim(), xCord: lat, yCord: long, type: "Video", pinned: pinned, callback: {(mediaID: String) -> Void in
            self.uploadVideoToAWS(url, videoID: mediaID);
            self.stopActivityIndicator();
            self.closeAction();
        });
        }
    }
    
    @IBAction func pinAction(sender: UIButton) {
        if(pinned) {
            pinButton.setImage(UIImage(named: "unpinIcon"), forState: UIControlState.Normal);
        } else {
            pinButton.setImage(UIImage(named: "pinIcon"), forState:
                UIControlState.Normal);
        }
        pinned = !pinned;
    }
    
    @IBAction func downloadAction(sender: UIButton) {
        switch self.media! {
        case .Photo(let image):
            CustomPhotoAlbum.sharedInstance.saveImage(image);
            // don't do onCompletion because it's too slow
        case .Video(let url):
            CustomPhotoAlbum.sharedInstance.saveVideo(url);
        }
        downloadButton.layer.shadowColor = UIColor.greenColor().CGColor;
    }
    
    
    func startActivityIndicator() {
        activityIndicatorView = makeActivityIndicator(self);
        activityIndicatorView.startAnimation();
        postButton.enabled = false;
        captionButton.enabled = false;
        pinButton.enabled = false;
        activityIndicating = true;
    }
    
    func stopActivityIndicator() {
        postButton.enabled = true;
        captionButton.enabled = true;
        activityIndicatorView.stopAnimation();
        activityIndicating = false;
        
    }
    
    func cleanUpMedia() {
        videoPlayer.pause();
        videoPlayer.replaceCurrentItemWithPlayerItem(nil);
    }
    
    func closeAction() {
        if(activityIndicating) {
            stopActivityIndicator();
        }
        cleanUpMedia();
        self.dismissViewControllerAnimated(false, completion: nil);
    }
    
    func thumbnail(sourceURL sourceURL:NSURL) -> UIImage {
        let asset = AVAsset(URL: sourceURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        let time = CMTime(seconds: 1, preferredTimescale: 1)
        
        do {
            let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
            return  fixImageOrientation(UIImage(CGImage: imageRef));
        } catch {
            return UIImage(named: "some generic thumbnail")!
        }
    }
    
    private func playVideo(url: NSURL) {
        
        videoView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        //        videoView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
        videoView.frame.size.height = self.view.frame.size.height;
        videoView.frame.size.width = self.view.frame.size.width;
        videoView.frame.origin = CGPoint(x: 0, y: 0)
        videoView.userInteractionEnabled = false;
        self.view.addSubview(videoView);
        
        
        
        let avAsset =  AVAsset(URL: url);
        let avPlayerItem = AVPlayerItem(asset: avAsset);
        videoPlayer = AVPlayer(playerItem: avPlayerItem);
        let avPlayerLayer = AVPlayerLayer(player: videoPlayer);
        
        let duration: Float = Float(CMTimeGetSeconds((self.videoPlayer.currentItem?.asset.duration)!))
        if(duration < Float(config.media.videoMinLimit)) {
            imageView.image = thumbnail(sourceURL: url);
            self.media = Media.Photo(image: imageView.image!);
            return;
        }
        
        avPlayerLayer.frame = videoView.bounds;
        videoView.layer.addSublayer(avPlayerLayer);
        videoView.layer.zPosition = -1; // to show the icons
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPlayer.seekToTime(kCMTimeZero);
        print("HELLO");
        print(url);
        videoPlayer.play();
        videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: videoPlayer.currentItem, queue: nil)
        { notification in
            
            // hard coded to have proper loop; no aide exists for something like this
            let duration: Float = Float(CMTimeGetSeconds((self.videoPlayer.currentItem?.asset.duration)!))
            let totalTime: Int64 = Int64(duration);
            var startTime = totalTime*5;
            if(duration > 0.7 && duration < 0.9){
                startTime = 25;
            } else if(duration > 0.6 && duration <= 0.7) {
                startTime = 23;
            }
            else if(startTime == 0){
                startTime = 14;
            } // if 1 do something
            else if (totalTime < 3) {
                startTime = 20;
            }
            let t1 = CMTimeMake(startTime, 100);
            self.videoPlayer.seekToTime(t1)
        }
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        switch self.media! {
        case .Photo(let image): self.imageView.image =  fixImageOrientation(image);
        case .Video(let url): self.playVideo(url);
        }
    }
    
    @IBAction func editCaptionAction(sender: UIButton) {
        captionView.hidden = !captionView.hidden;
        captionTextfield.hidden = !captionTextfield.hidden;
        if(!captionTextfield.hidden){
            captionTextfield.becomeFirstResponder();
        } else {
            captionTextfield.resignFirstResponder();
        }
    }
    let notification = CWStatusBarNotification()
    
    func uploadPhotoToAWS(img: UIImage, imageID: String) {
        print("uploadPhotoToAWS()");
        let ext = "png";
        
        // create a local image that we can use to upload to s3
        let path:NSString = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("image.png");
        let imageData:NSData = UIImageJPEGRepresentation(img, 1.0)!
        imageData.writeToFile(path as String, atomically: true);
        // once the image is saved we can use the path to create a local fileurl
        let url:NSURL = NSURL(fileURLWithPath: path as String);
        
        let uploadRequest = AWSS3TransferManagerUploadRequest();
        uploadRequest.body = url;
        uploadRequest.key = "\(config.aws.password)/\(imageID).\(ext)";
        uploadRequest?.ACL = AWSS3ObjectCannedACL.PublicRead;
        
        uploadRequest.bucket = config.aws.bucket;
        uploadRequest.contentType = "image/" + ext;
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager();
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                print("Upload failed  (\(error))");
            }
            if let exception = task.exception {
                print("Upload failed  (\(exception))");
                
            }
            if task.result != nil {
                let s3URL = NSURL(string: "http://s3.amazonaws.com/\(config.aws.bucket)/\(uploadRequest.key!)")!;
                print("Uploaded to:\n\(s3URL)");
                putActivateMedia(imageID, mediaCreatorId: Users.sharedInstance.nodeId!, callback: {()})                
            }
            else {
                print("Unexpected empty result.");
            }
            return nil;
        }
    }
    
    func compressVideo(inputURL: NSURL, outputURL: NSURL, handler:(session: AVAssetExportSession)-> Void) {
        let urlAsset = AVURLAsset(URL: inputURL, options: nil)
        if let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileTypeQuickTimeMovie
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
                handler(session: exportSession)
            }
        }
    }
    
    func uploadVideoToAWS(outputFileURL: NSURL!, videoID: String) {
        let x = NSData(contentsOfURL: outputFileURL)
        print("File size before compression: \(Double(x!.length / 1048576)) mb")
        
        let compressedURL = NSURL.fileURLWithPath(NSTemporaryDirectory() + NSUUID().UUIDString + ".mp4")
        compressVideo(outputFileURL, outputURL: compressedURL) { (session) in
            switch session.status {
            case .Unknown:
                break
            case .Waiting:
                break
            case .Exporting:
                break
            case .Completed:
                let data = NSData(contentsOfURL: compressedURL)
                print("File size after compression: \(Double(data!.length) / 1048576.0) mb")
                self.uploadVideo(compressedURL, videoID: videoID);
            case .Failed:
                break
            case .Cancelled:
                break
            }
        }
        
    }
    
    func uploadVideo(outputFileURL:  NSURL, videoID: String) {
        let ext = "mp4";
        let transferManager:AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        let uploadRequest = AWSS3TransferManagerUploadRequest();
        uploadRequest.bucket = config.aws.bucket;
        uploadRequest.key = "\(config.aws.password)/\(videoID).\(ext)";
        uploadRequest.body = outputFileURL;
        uploadRequest?.ACL = AWSS3ObjectCannedACL.PublicRead;  // AWSS3StorageClass.ReducedRedundancy
        
        // Don't know if I need this block
        uploadRequest.uploadProgress = ({
            (bytesSent: Int64, totalBytesSent: Int64,  totalBytesExpectedToSend: Int64) in
        })
        
        transferManager.upload(uploadRequest).continueWithBlock({ (task: AWSTask) -> AnyObject! in
            if task.error != nil {
                if task.error!.domain == AWSS3TransferManagerErrorDomain {
                    switch task.error!.code {
                    case AWSS3TransferManagerErrorType.Cancelled.rawValue:
                        print("Upload cancelled!");
                    case AWSS3TransferManagerErrorType.Paused.rawValue:
                        print("Upload paused!");
                    default:
                        print("Error: %@", task.error);
                        // TODO: Need to delete media with that id if upload fails
                    }
                } else {
                    print("Unknown error while uploading: %@", task.error);
                    // TODO: error message
                }
            } else {
                print("File %@ uploaded successfully. %@", outputFileURL, task.exception);
                putActivateMedia(videoID, mediaCreatorId: Users.sharedInstance.nodeId!, callback: {()})
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(outputFileURL);
                }
                catch _ {
                    print("Could not delete %@", outputFileURL);
                }
                
                
            }
            
            return nil;
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(captionTextfield.text?.myTrim() == "") {
            hideCaption();
        }
        return true;
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = config.media.captionLimit;
        let currentString: NSString = textField.text!
        let newString: NSString =
            currentString.stringByReplacingCharactersInRange(range, withString: string);
        return newString.length <= maxLength;
    }
    
}
