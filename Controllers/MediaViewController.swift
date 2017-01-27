//
//  MediaViewController.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-10-23.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class MediaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var spreadButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var pinButton: UIButton!
    
    @IBOutlet var commentsView: UIView!
    @IBOutlet var commentsTableView: UITableView!
    var commentsBlurView: UIView = UIView();
    
    @IBOutlet var commentTextField: UITextField!
    
    @IBOutlet var infoView: UIView!
    @IBOutlet var creatorNameLabel: UILabel!
    @IBOutlet var creatorProfileImage: UIImageView!
    @IBOutlet var viewCountLabel: UILabel!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var spreadCountLabel: UILabel!
    @IBOutlet var flagButton: UIButton!
    @IBOutlet var blockButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var timeAgoLabel: UILabel!
    
    @IBOutlet var captionView: UIView!
    @IBOutlet var captionTextfield: UITextField!
    
    
    var theMedia: Medias = Medias();
    var directionForward: Bool = Bool();
    var currentIndex: Int = Int();
    
    var activityIndicatorView: NVActivityIndicatorView!
    
    var commentsList = [Comments]()
    
    var currentLiked: Bool = false;
    var initialLiked: Bool = false;
    var spreaded: Bool = false;
    
    var userLatitude: Double = Double();
    var userLongitude: Double = Double();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        design();
        
        startActivityIndicator();
        if(theMedia.type == "Photo") {
            setUpImage(theMedia.id);
        } else {
            playVideo(theMedia.id);
        }
        
        configureMedia();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MediaViewController.appWillGoToBackground), name: UIApplicationWillResignActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MediaViewController.appWillComeToForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MediaViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MediaViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        let tableTapped = UITapGestureRecognizer(target: self, action: #selector(MediaViewController.commentsTableTap));
        commentsTableView.addGestureRecognizer(tableTapped)
        
        commentsTableView.delegate = self;
        commentsTableView.dataSource = self;
        
        commentTextField.delegate = self;
        
    }
    
    // App Focus
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true);
        videoPlayer.play();
        
        // VERY VERY IMPORTANT
        FeedViewController.mainIndex = currentIndex;
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true);
        videoPlayer.pause();
        videoPlayer.seekToTime(kCMTimeZero);
        
        theMedia.applyLikeChange(initialLiked, final: currentLiked);
    }
    
    func appWillGoToBackground() {
        videoPlayer.pause();
        videoPlayer.seekToTime(kCMTimeZero);
    }
    
    func appWillComeToForeground() {
        videoPlayer.play();
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Design
    func design() {
        self.view.backgroundColor = UIColor.blackColor();
        
        likeButton.layer.shadowRadius = designs.button.shadowRadius;
        likeButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        likeButton.layer.shadowOffset = CGSizeZero;
        likeButton.layer.masksToBounds = false;
        
        spreadButton.layer.shadowRadius = designs.button.shadowRadius;
        spreadButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        spreadButton.layer.shadowOffset = CGSizeZero;
        spreadButton.layer.masksToBounds = false;
        
        commentButton.layer.shadowRadius = designs.button.shadowRadius;
        commentButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        commentButton.layer.shadowOffset = CGSizeZero;
        commentButton.layer.masksToBounds = false;
        
        infoButton.layer.shadowRadius = designs.button.shadowRadius;
        infoButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        infoButton.layer.shadowOffset = CGSizeZero;
        infoButton.layer.masksToBounds = false;
        
        locationLabel.layer.shadowRadius = designs.button.shadowRadius;
        locationLabel.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        locationLabel.layer.shadowOffset = CGSizeZero;
        locationLabel.layer.masksToBounds = false;
        
        timeAgoLabel.layer.shadowRadius = designs.button.shadowRadius;
        timeAgoLabel.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        timeAgoLabel.layer.shadowOffset = CGSizeZero;
        timeAgoLabel.layer.masksToBounds = false;
        
        commentsBlurView.hidden = true;
        commentsView.hidden = true;
        commentsTableView.tableFooterView = UIView()
        
        infoView.hidden = true;
        infoView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.65);
        infoView.layer.borderColor = UIColor.whiteColor().CGColor;
        infoView.layer.borderWidth = 2.0;
        
        creatorProfileImage.layer.cornerRadius = creatorProfileImage.frame.size.width / 2;
        creatorProfileImage.clipsToBounds = true;
        
        if(theMedia.pinned) {
            pinButton.hidden = false;
        } else {
            pinButton.hidden = true;
        }
        pinButton.layer.shadowRadius = designs.button.shadowRadius;
        pinButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        pinButton.layer.shadowOffset = CGSizeZero;
        pinButton.layer.masksToBounds = false;
        
        captionView.hidden = true;
        captionView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6);
        captionTextfield.hidden = true;
        captionTextfield.userInteractionEnabled = false;
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(MediaViewController.closeAction));
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down;
        self.view.addGestureRecognizer(swipeDown);
    }
    
    func commentsDesign() {
        commentsTableView.backgroundColor = UIColor.clearColor();
        
        commentsBlurView.frame = self.view.bounds;
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            blurEffectView.frame = commentsBlurView.bounds;
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            commentsBlurView.addSubview(blurEffectView);
            
            self.view.addSubview(commentsBlurView);
            self.view.addSubview(commentsView);
            
        } else {
            self.view.backgroundColor = UIColor.blackColor();
        }
    }
    
    // Initializations
    func configureMedia() {
        mediaLikeSetup();
        mediaSpreadSetup();
        commentsSetup();
        theMedia.mediaViewSetup(({
            // this has to be here so that view is gotten first
            self.infoSetup();
        }));
        dateAndLocationSetup(theMedia.time, lat: theMedia.coordinate.x, long: theMedia.coordinate.y);
    }
    
    func mediaLikeSetup() {
        isMediaLiked(theMedia.id, callback: {(response: Bool) -> Void in
            self.initialLiked = response;
            self.currentLiked = response;
            self.likeButtonMechanism();
        });
    }
    
    func mediaSpreadSetup() {
        isMediaSpreaded(theMedia.id, callback: {(response: Bool) -> Void in
            self.spreaded = response;
            self.spreadButtonMechanism();
        })
    }
    
    func mediaCaptionSetup() {
        if(theMedia.caption != "") {
            captionView.hidden = false;
            captionTextfield.text = theMedia.caption;
            captionTextfield.hidden = false;
        }
    }
    
    func commentsSetup() {
        getCommentsByMediaId(theMedia.id) { (commentsList) in
            self.commentsList = commentsList;
            self.commentsTableView.reloadData();
            self.commentsTableGoToBottom();
        }
        if(!isWithinAccessRadius(theMedia.coordinate.x, mediaLong: theMedia.coordinate.y, userLat: userLatitude, userLong: userLongitude)) {
            commentTextField.hidden = true;
        }
    }
    
    func infoSetup() {
        theMedia.getCreatorPic { (image) in
            self.creatorProfileImage.image = image;
        }
        viewCountLabel.text = String(theMedia.info.views);
        likeCountLabel.text = String(theMedia.info.likes);
        spreadCountLabel.text = String(theMedia.info.spreads);
        
        if(theMedia.creatorId == Users.sharedInstance.nodeId) {
            flagButton.hidden = true;
            blockButton.hidden = true;
        } else {
            deleteButton.hidden = true;
        }
        
    }
    
    func dateAndLocationSetup(time: NSDate, lat: Double, long: Double) {
        let geoCoder = CLGeocoder();
        let location = CLLocation(latitude: lat, longitude: long)
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if(error != nil) {
                //                statusNotification(strings.error.noLocation, duration: 2.0, type: "negative");
                //                self.closeAction(self.closeButton);
            } else {
                let placeArray = placemarks as [CLPlacemark]!
                let placeMark: CLPlacemark = (placeArray?[0])!
                
                if let city = placeMark.addressDictionary!["City"] as? String {
                    if let country = placeMark.addressDictionary!["Country"] as? String{
                        self.locationLabel.text = "\(city), \(country)";
                        self.timeAgoLabel.text = time.shortTimeAgoSinceNow();
                    }
                }
            }
        }
        
    }
    
    // UI Mechanisms
    
    func likeButtonMechanism() {
        if(currentLiked) {
            likeButton.setImage(UIImage(named: "likeIcon.png"), forState: UIControlState.Normal);
        } else {
            likeButton.setImage(UIImage(named: "unlikeIcon.png"), forState: UIControlState.Normal);
        }
    }
    
    func spreadButtonMechanism() {
        if(spreaded) {
            spreadButton.setImage(UIImage(named: "spreadedIcon.png"), forState: UIControlState.Normal);
        } else {
            spreadButton.setImage(UIImage(named: "unspreadedIcon.png"), forState: UIControlState.Normal);
        }
    }
    
    
    // Actions
    func closeAction() {
        self.dismissViewControllerAnimated(false, completion: nil);
    }
    
    @IBAction func commentsCloseAction(sender: UIButton) {
        commentsBlurView.hidden = true;
        commentsView.hidden = true;
    }
    
    @IBAction func commentAction(sender: UIButton) {
        commentsTableView.reloadData();
        commentsDesign();
        commentsBlurView.hidden = false;
        commentsView.hidden = false;
    }
    
    @IBAction func spreadAction(sender: UIButton) {
        if(!checkInternet()) { return; }
        if(!spreaded) {
            theMedia.incrementSpreads();
            //spreadCountLabel.text = "\(currentMedia.info.spreads)";
            let mediaId: String = theMedia.id;
            let mediaCreatorId: String = theMedia.creatorId;
            putSpreadMedia(mediaId, mediaCreatorId: mediaCreatorId, callback: {() -> Void in});
            spreaded = true;
            spreadButtonMechanism();
        }
    }
    
    @IBAction func likeAction(sender: UIButton) {
        if(!checkInternet()) { return; }
        
        currentLiked = !currentLiked;
        let currentCount: Int = Int(likeCountLabel.text!)!
        if(currentLiked) {
            likeCountLabel.text = "\(currentCount+1)"
            
        } else {
            likeCountLabel.text = "\(currentCount-1)"
            
        }
        likeButtonMechanism();
    }
    
    @IBAction func infoAction(sender: UIButton) {
        infoView.hidden = !infoView.hidden;
    }
    
    @IBAction func flagAction(sender: UIButton) {
        confirmationAlert(self, title: strings.prompt.flagTitle, message: strings.prompt.flagMessage, yes: {
            putFlagMedia(self.theMedia.id, mediaCreatorId: self.theMedia.creatorId, callback: {
                messageAlert(self, title: strings.prompt.flaggedTitle, message: strings.prompt.flaggedMessage);
            })
        }) {
            // Not flagging
        }
    }
    
    @IBAction func blockAction(sender: UIButton) {
        confirmationAlert(self, title: strings.prompt.blockTitle, message: strings.prompt.blockMessage(theMedia.creatorName), yes: {
            putBlockUser(self.theMedia.creatorId, callback: {
                messageAlert(self, title: strings.prompt.blockedTitle, message: strings.prompt.blockedMessage);
            })
        }) {
            // NO
        }
    }
    
    @IBAction func deleteAction(sender: UIButton) {
        confirmationAlert(self, title: strings.prompt.deleteMediaTitle, message: strings.prompt.deleteMediaMessage, yes: {
            deleteMedia(self.theMedia.id) {
                messageAlert(self, title: strings.prompt.deletedMediaTitle, message: strings.prompt.deletedMediaMessage)
            }
        }) {
            // NO
        }
        
    }
    
    @IBAction func pinAction(sender: UIButton) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnePinView") as! OnePinMapViewController;
        controller.latitude = theMedia.coordinate.x;
        controller.longitude = theMedia.coordinate.y;
        
        self.presentViewController(controller, animated: false, completion: nil);
    }
    
    @IBOutlet var imageView: UIImageView!
    func setUpImage(photoId: String) {
        downloadAndDisplayImage(photoId);
    }
    
    func downloadAndDisplayImage(photoId: String) {
        let ext = "png";
        //        let urlPath: String = config.aws.url + "/" + config.aws.bucket + "/" + config.aws.password + "/" + photoID + "." + ext;
        let urlPath: String = "\(config.aws.cloudfrontURL)/"+photoId+"."+ext;
        let url: NSURL = NSURL(string: urlPath)!;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let data = NSData(contentsOfURL: url) {
                
                dispatch_async(dispatch_get_main_queue(), {
                    let downloadedImage = UIImage(data: data);
                    self.imageView.image = downloadedImage;
                    self.stopActivityIndicator();
                    // self.imageView.layer.zPosition = 10;
                });
            } else {
                // TODO: Show error message
            }
        }
        
    }
    
    var videoPlayer = AVPlayer();
    var avPlayerLayer = AVPlayerLayer();
    func playVideo(videoId: String) {
        let ext = "mp4";
        let urlPath: String = "\(config.aws.cloudfrontURL)/"+videoId+"."+ext;
        let url: NSURL = NSURL(string: urlPath)!;
        
        let avAsset =  AVAsset(URL: url);
        let avPlayerItem = AVPlayerItem(asset: avAsset);
        
        videoPlayer = AVPlayer(playerItem: avPlayerItem);
        
        avPlayerLayer = AVPlayerLayer(player: videoPlayer);
        
        
        let videoView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        videoView.frame.size.height = self.view.frame.size.height;
        videoView.frame.size.width = self.view.frame.size.width;
        videoView.frame.origin = CGPoint(x: 0, y: 0)
        videoView.userInteractionEnabled = false;
        self.view.addSubview(videoView);
        avPlayerLayer.frame = videoView.bounds;
        avPlayerLayer.addObserver(self, forKeyPath: "readyForDisplay", options: NSKeyValueObservingOptions(), context: nil)
        videoView.layer.addSublayer(avPlayerLayer);
        
        avPlayerLayer.frame = videoView.bounds;
        videoView.layer.addSublayer(avPlayerLayer);
        videoView.layer.zPosition = -1; // to show the icons
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPlayer.seekToTime(kCMTimeZero);
        videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: videoPlayer.currentItem, queue: nil)
        { notification in
            self.videoPlayer.seekToTime(kCMTimeZero)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?,
                                         ofObject object: AnyObject?, change: [String : AnyObject]?,
                                                  context: UnsafeMutablePointer<Void>) {
        if keyPath == "readyForDisplay"{
            dispatch_async(dispatch_get_main_queue(), {
                self.stopActivityIndicator();
                self.avPlayerLayer.removeObserver(self, forKeyPath:"readyForDisplay")
                
            })
        }
        
    }
    
    func startActivityIndicator() {
        hideIcons();
        activityIndicatorView = makeActivityIndicator(self);
        activityIndicatorView.startAnimation();
    }
    
    func stopActivityIndicator() {
        activityIndicatorView.stopAnimation();
        showIcons();
    }
    
    func hideIcons() {
        spreadButton.hidden = true;
        likeButton.hidden = true;
        commentButton.hidden = true;
        infoButton.hidden = true;
        locationLabel.hidden = true;
        timeAgoLabel.hidden = true;
        pinButton.hidden = true;
    }
    
    func showIcons() {
        mediaCaptionSetup();
        spreadButton.hidden = false;
        likeButton.hidden = false;
        commentButton.hidden = false;
        infoButton.hidden = false;
        locationLabel.hidden = false;
        timeAgoLabel.hidden = false;
        if(theMedia.pinned) {
            pinButton.hidden = false;
        }
    }
    
    // Comments Helper
    func commentPostAction() {
        confirmationAlert(self, title: strings.prompt.postCommentTitle, message: strings.prompt.confirmation, yes: {
            if(!checkInternet()) { return; }
            
            if(self.commentTextField.text?.myTrim() != "") {
                let mediaId: String = self.theMedia.id
                postComment(mediaId, userLat: self.userLatitude, userLong: self.userLongitude, mediaLat: self.theMedia.coordinate.x, mediaLong: self.theMedia.coordinate.y, commentContent: self.commentTextField.text!.myTrim()) { (commentList) in
                    self.commentsSetup();
                }
                self.commentTextField.text = "";
            }
        }) {
            // do nothing
        }
    }
    
    // TableView Stuff
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nib = UINib(nibName: "CommentsTableViewCell", bundle: nil);
        commentsTableView.registerNib(nib, forCellReuseIdentifier: "CommentsCell");
        let cell = commentsTableView.dequeueReusableCellWithIdentifier("CommentsCell", forIndexPath: indexPath) as! CommentsTableViewCell;
        
        let theComment:Comments = commentsList[indexPath.row];
        
        // Cell Design
        cell.backgroundColor = UIColor.clearColor()
        cell.preservesSuperviewLayoutMargins = false;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
        
        // Cell Setup
        theComment.getProfilePic { (image) in
            cell.profilePicImage.image = image;
            cell.profilePicImage.layer.cornerRadius = cell.profilePicImage.frame.size.width / 2;
            cell.profilePicImage.clipsToBounds = true;
        }
        cell.nameLabel.text = theComment.creatorName;
        
        cell.commentLabel.text = theComment.commentContent;
        cell.timeLabel.text = theComment.time.shortTimeAgoSinceNow();
        
        return cell;
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80;
    }
    
    func commentsTableGoToBottom() {
        if(commentsList.count == 0) {return};
        let indexPath = NSIndexPath(forRow: commentsList.count-1, inSection: 0)
        commentsTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
    
    // TextField Stuff
    func textFieldDidBeginEditing(textField: UITextField) {
        commentsTableGoToBottom();
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        commentPostAction();
        return true;
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = config.comment.commentLimit;
        let currentString: NSString = textField.text!
        let newString: NSString =
            currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }
    
    
    // Keyboard Stuff
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0
    var keyboardHeight = CGFloat();
    
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
    
    func commentsTableTap() {
        commentTextField.resignFirstResponder();
    }
}

