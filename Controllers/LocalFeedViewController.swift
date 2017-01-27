//
//  LocalFeedViewController.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-05-24.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit
import CoreLocation
import AWSS3
import MediaPlayer
import AVFoundation



class LocalFeedViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {
    
    @IBOutlet weak var photoView: UIImageView!;
    @IBOutlet weak var closeButton: UIButton!;
    @IBOutlet weak var likeButton: UIButton!;
    @IBOutlet weak var spreadButton: UIButton!;
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentPostButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var captionView: UIView!
    @IBOutlet weak var captionLabel: UILabel!;
    @IBOutlet weak var gestureView: UIView!;
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var spreadCountLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var feedType: String = String();
    
    var locationManager: CLLocationManager = CLLocationManager();
    var latitude: Double = Double();
    var longitude: Double = Double();
    
    var index: Int = 0;
    var mediaFeed: [Medias] = [Medias]();
    var currentLiked: Bool = false;
    var initialLiked: Bool = false;
    var spreaded: Bool = false;
    var infoOpen: Bool = true;
    var currentMedia:Medias = Medias();
    
    var nextMediaStorage: Any = false;
    var currentMediaStorage: Any = false;
    var previousMediaStorage: Any = false;
    var forward: Bool = true;
    
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0
    var keyboardHeight = CGFloat();

    var initialPlayer = AVPlayer();
    var initialPlayerLayer = AVPlayerLayer();
    
    var activityIndicatorView: NVActivityIndicatorView!
    var activityIndicating: Bool = false;
    
    var commentList = [Comments]()
    
    var videoView = UIView();

    override func viewDidLoad() {
        super.viewDidLoad();
        
        // This will come into play later on in development
        commentsView.hidden = true;
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        let latitude: Double = getLatitude(locationManager);
//        let longitude: Double = getLongitude(locationManager);
        commentTextField.delegate = self;
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocalFeedViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocalFeedViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(LocalFeedViewController.nextMedia));
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left;
        gestureView.addGestureRecognizer(swipeLeft);
        
        let touch = UITapGestureRecognizer(target: self, action: #selector(LocalFeedViewController.nextMedia));
        touch.numberOfTapsRequired = 1;
        gestureView.addGestureRecognizer(touch);
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(LocalFeedViewController.previousMedia));
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right;
        gestureView.addGestureRecognizer(swipeRight);
        
        let tableTapped = UITapGestureRecognizer(target: self, action: #selector(LocalFeedViewController.commentsTableTap));
        commentsTableView.addGestureRecognizer(tableTapped)
        
        hideTopIcons();
       // startActivityAnimating();
        design();
        initializeFeed(latitude, long: longitude);
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
    
    func commentsTableTap() {
        commentTextField.resignFirstResponder();
    }

    func design() {
        photoView.backgroundColor = designs.colors.theme;
        
        closeButton.layer.shadowRadius = designs.button.shadowRadius;
        closeButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        closeButton.layer.shadowOffset = CGSizeZero;
        closeButton.layer.masksToBounds = false;
        
        infoButton.layer.shadowRadius = designs.button.shadowRadius;
        infoButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        infoButton.layer.shadowOffset = CGSizeZero;
        infoButton.layer.masksToBounds = false;
        
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
        
        timeAgoLabel.layer.shadowRadius = designs.label.shadowRadius;
        timeAgoLabel.layer.shadowOpacity = designs.label.shadowOpactiyLabels;
        
        commentPostButton.layer.cornerRadius = 5;
       // commentsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        commentsTableView.tableFooterView = UIView()
        
        commentsView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        captionView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6);
        
        infoView.hidden = infoOpen;
        infoView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        infoView.layer.shadowRadius = 4.0;
        infoView.layer.shadowOpacity = 0.9;
        infoView.layer.shadowOffset = CGSizeZero;
        infoView.layer.masksToBounds = false;
        
        videoView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        videoView.backgroundColor = designs.colors.theme;
        //videoView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
        videoView.frame.size.height = self.view.frame.size.height;
        videoView.frame.size.width = self.view.frame.size.width;
        videoView.frame.origin = CGPoint(x: 0, y: 0)
        videoView.userInteractionEnabled = false;
        
        //closeButton.hidden = false;
    }
    
    func initializeFeed(lat: Double, long: Double) {
        startActivityIndicator();
        
        captionView.hidden = true;
        captionLabel.hidden = true;

        index = 0;
        if(feedType == "Local Feed") {
            getLocalStream(lat, yCord: long, callback: {(mediaList: [Medias]) -> Void in
                self.mediaFeed = mediaList;
                self.checkFeed();
            })
        } else if(feedType == "Local Rank") {
            getLocalRank(lat, yCord: long, callback: {(mediaList: [Medias]) -> Void in
                self.mediaFeed = mediaList;
                self.checkFeed();
            })
        } else if(feedType == "Global Feed") {
            getGlobalStream({(mediaList: [Medias]) -> Void in
                self.mediaFeed = mediaList;
                self.checkFeed();
            })
        } else if(feedType == "Global Rank") {
            getGlobalRank({(mediaList: [Medias]) -> Void in
                self.mediaFeed = mediaList;
                self.checkFeed();
            })
        } else if(feedType == "Comment Stream") {
            getUserComments({(mediaList: [Medias]) -> Void in
                self.mediaFeed = mediaList;
                self.checkFeed();
            })
        } else if(feedType == "Spread Stream") {
            getUserSpreads({(mediaList: [Medias]) -> Void in
                self.mediaFeed = mediaList;
                self.checkFeed();
            })
        } else if(feedType == "Like Stream") {
            getUserLikes({(mediaList: [Medias]) -> Void in
                self.mediaFeed = mediaList;
                self.checkFeed();
            })
        }
        else {
            stopActivityIndicator();
            closeAction(closeButton);
        }
    }
    
    func checkFeed() {
        if(self.mediaFeed.count == 0) {
            statusNotification(strings.status.noMedia, duration: 2.0, type: "negative");
            performClosureAfterDelay(2.5, closure: {
                self.stopActivityAnimating();
                self.closeAction(self.closeButton);
            });
        } else {
            self.initializeMedias();
        }
    }
    
    func initializeMedias() {
        if(mediaFeed.count != 0) {
            setupMedia();
            
            let mediaId = currentMedia.id;
            let mediaType = currentMedia.type;
            deleteButton.hidden = !(currentMedia.creatorId == USER_NODE_ID)
            if(mediaType == "Video") {
                playVideo(mediaId);
            } else { // "Photo"
                downloadAndShowImage(mediaId)
            }
            if(mediaFeed.count == 1) { return; }
            
            storeMedia(mediaFeed[index + 1].id, mediaType: mediaFeed[index + 1].type,  next: true);
        } else {
            noMoreMedias();
        }
    }
    
    func setupMedia() {
        currentMedia = mediaFeed[self.index];
        mediaViewSetup(currentMedia);
        mediaLikeSetup(currentMedia);
        mediaSpreadSetup(currentMedia);
        infoSetup(currentMedia);
        let mediaId = currentMedia.id;
        commentsSetup(mediaId);
        dateAndLocationSetup(currentMedia.time, lat: currentMedia.coordinate.x, long: currentMedia.coordinate.y);
    }
    
    func storeMedia(mediaId: String, mediaType: String, next: Bool) {
        if(next) {
            self.nextMediaStorage = false;
        } else {
            self.previousMediaStorage = false;
        }
        
        if(mediaType == "Photo") {
            let ext = "png";
            //        let urlPath: String = config.aws.url + "/" + config.aws.bucket + "/" + config.aws.password + "/" + photoID + "." + ext;
            let urlPath: String = "\(config.aws.cloudfrontURL)/"+mediaId+"."+ext;
            let url: NSURL = NSURL(string: urlPath)!;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                if let data = NSData(contentsOfURL: url) {
                    dispatch_async(dispatch_get_main_queue(), {
                        let downloadedImage = UIImage(data: data);
                        if(next) {
                            self.nextMediaStorage = fixImageOrientation(downloadedImage!);
                        } else {
                            self.previousMediaStorage = fixImageOrientation(downloadedImage!);
                        }
                    });
                } else {
                    // TODO: Show error message
                }
            }
        } else {
            let ext = "mp4";
            let urlPath: String = "\(config.aws.cloudfrontURL)/"+mediaId+"."+ext;
            let url: NSURL = NSURL(string: urlPath)!;

            let avAsset =  AVAsset(URL: url);
            let videoPlayerItem = AVPlayerItem(asset: avAsset);
            var videoPlayer = AVPlayer(playerItem: videoPlayerItem);
            var playerLayer =   AVPlayerLayer(player: videoPlayer);
            videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None;
            playerLayer.frame = videoView.bounds;
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            print(urlPath);
            if(next) {
                self.nextMediaStorage = playerLayer;
            } else {
                self.previousMediaStorage = playerLayer;
            }
        }
    }
    
    func cleanUpMedia() {
        if currentMediaStorage is AVPlayerLayer {
            (currentMediaStorage as! AVPlayerLayer).player?.pause();
//            (currentMediaStorage as! AVPlayerLayer).player?.replaceCurrentItemWithPlayerItem(nil);
        }
        
    }
    
    func loadMedia() {
        if(index < self.mediaFeed.count) {
            
            setupMedia();
           // let mediaId = currentMedia.id;
            let mediaType = currentMedia.type;
            let mediaCaption = currentMedia.caption;
            deleteButton.hidden = !(currentMedia.creatorId == USER_NODE_ID)
            captionMechanism(mediaCaption);
            var storeIndex: Int = Int();
            if(mediaType == "Photo") {
                if(forward) {
                    if(previousMediaStorage is AVPlayerLayer) {
                        (previousMediaStorage as! AVPlayerLayer).player?.pause();
                        (previousMediaStorage as! AVPlayerLayer).player = nil;
                        (previousMediaStorage as! AVPlayerLayer).removeFromSuperlayer()
                    }
                    previousMediaStorage = currentMediaStorage;
                    currentMediaStorage = nextMediaStorage;
                    self.photoView.image = currentMediaStorage as? UIImage
                    storeIndex = index + 1;
                } else if(!forward) {
                    if(nextMediaStorage is AVPlayerLayer) {
                        (nextMediaStorage as! AVPlayerLayer).player?.pause()
                        (nextMediaStorage as! AVPlayerLayer).player = nil;
                        (nextMediaStorage as! AVPlayerLayer).removeFromSuperlayer()
                    }
                    nextMediaStorage = currentMediaStorage
                    currentMediaStorage = previousMediaStorage;
                    self.photoView.image = currentMediaStorage as? UIImage
                    storeIndex = index - 1;
                }
                self.photoView.layer.zPosition = 0;
                if(storeIndex < mediaFeed.count && storeIndex >= 0){
                    storeMedia(mediaFeed[storeIndex].id, mediaType: mediaFeed[storeIndex].type, next: forward);
                }


            } else if(mediaType == "Video") {
              //  self.showIcons();
                self.videoView.layer.zPosition = -1; // to show the icons
                self.photoView.layer.zPosition = -2;
                self.view.addSubview(self.videoView);

                if(forward) {
                    if(previousMediaStorage is AVPlayerLayer) {
                        (previousMediaStorage as! AVPlayerLayer).player?.pause()
                        (previousMediaStorage as! AVPlayerLayer).player = nil;
                        (previousMediaStorage as! AVPlayerLayer).removeFromSuperlayer()
                    }
                    previousMediaStorage = currentMediaStorage;
                    currentMediaStorage = nextMediaStorage;
                    (currentMediaStorage as! AVPlayerLayer).player?.seekToTime(kCMTimeZero)
                    (currentMediaStorage as! AVPlayerLayer).player?.play()
                    self.videoView.layer.addSublayer(currentMediaStorage as! AVPlayerLayer);
                    storeIndex = index + 1;
                } else if(!forward) {
                    if(nextMediaStorage is AVPlayerLayer) {
                        (nextMediaStorage as! AVPlayerLayer).player?.pause()
                        (nextMediaStorage as! AVPlayerLayer).player = nil;
                        (nextMediaStorage as! AVPlayerLayer).removeFromSuperlayer()
                    }
                    nextMediaStorage = currentMediaStorage;

                    currentMediaStorage = previousMediaStorage;
                    (currentMediaStorage as! AVPlayerLayer).player?.seekToTime(kCMTimeZero)
                    (currentMediaStorage as! AVPlayerLayer).player?.play()
                    self.videoView.layer.addSublayer(currentMediaStorage as! AVPlayerLayer);
                    storeIndex = index - 1;
                }
                if(storeIndex < mediaFeed.count && storeIndex >= 0){
                    storeMedia(mediaFeed[storeIndex].id, mediaType: mediaFeed[storeIndex].type, next: forward);
                }
                NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: (currentMediaStorage as! AVPlayerLayer).player?.currentItem, queue: nil)
                { notification in
                    (self.currentMediaStorage as! AVPlayerLayer).player!
                        .seekToTime(CMTimeMake(getVideoLoopStartTime((self.currentMediaStorage as! AVPlayerLayer).player!)*2, 100))
                    self.showIcons();
                }
            }
        } else {
            noMoreMedias();
        }
    }


    func nextMedia() {
        if(index+1 >= self.mediaFeed.count) {
            noMoreMedias();
            return;
        }
        if(USER_POINTS <= 0) {
            noPointsStatus();
            closeAction(closeButton);
        }
        if nextMediaStorage is Bool || (nextMediaStorage is AVPlayerLayer && !(nextMediaStorage as! AVPlayerLayer).readyForDisplay){
            return;
        }
        forward = true;
        if(checkInternet()) {
            cleanUpMedia();
            // TODO: call a function here that will disable everything... nah
            applyLikeChange();
            index += 1;
            loadMedia();
        }
        
        
    }
    
    func previousMedia() {
        if (index <= 0) {
            noMoreMedias();
            return;
        }
        if previousMediaStorage is Bool || (previousMediaStorage is AVPlayerLayer && !(previousMediaStorage as! AVPlayerLayer).readyForDisplay){
            return;
        }
        forward = false;
        if(checkInternet()) {
            index -= 1;
            cleanUpMedia();
            applyLikeChange();
            loadMedia();
        }
    }
    
    func applyLikeChange() {
        let mediaId: String = currentMedia.id;
        let mediaCreatorId: String = currentMedia.creatorId;
        
        if(initialLiked != currentLiked) {
            if(currentLiked) {
                currentMedia.incrementLikes();
                putLikeMedia(mediaId, mediaCreatorId: mediaCreatorId, callback: {() -> Void in});
            } else {
                currentMedia.decrementLikes();
                putUnlikeMedia(mediaId, mediaCreatorId: mediaCreatorId, callback: {() -> Void in});
            }
        }
    }
    
    @IBAction func closeAction(sender: UIButton) {
        cleanUpMedia();
        if(self.mediaFeed.count != 0) {applyLikeChange()};
        sender.enabled = false;
        
        let controller: ScrollMainViewController = storyboard!.instantiateViewControllerWithIdentifier("ScrollMainView") as! ScrollMainViewController
        if(feedType == "Comment Stream" || feedType == "Spread Stream" || feedType == "Like Stream") {
            controller.startPage = "PERSONAL";

        } else {
            controller.startPage = "MAIN";
        }
        self.presentViewController(controller, animated: false, completion: nil);
    }
    
    @IBAction func infoAction(sender: UIButton) {
        infoOpen = !infoOpen;
        infoView.hidden = infoOpen;
    }
    
    
    @IBAction func commentPostAction(sender: UIButton) {
        if(!checkInternet()) { return; }
        
        if(commentTextField.text?.myTrim() != "") {
            let mediaId: String = currentMedia.id
//            postComment(mediaId, commentContent: commentTextField.text!.myTrim()) { (commentList) in
//                self.commentsSetup(mediaId);
//            }
            commentTextField.text = "";
            commentTextField.resignFirstResponder();
        }
        
    }
    
    @IBAction func likeAction(sender: UIButton) {
        if(!checkInternet()) { return; }

        currentLiked = !currentLiked;
        likeCountUpdate()
        likeButtonMechanism();
    }
    
    func likeCountUpdate() {
        let currentCount: Int = Int(likeCountLabel.text!)!
        if(currentLiked) {
            likeCountLabel.text = "\(currentCount+1)"
        } else {
            likeCountLabel.text = "\(currentCount-1)"
        }
    }
    
    @IBAction func commentAction(sender: UIButton) {
        if(!checkInternet()) { return; }

        commentsView.hidden = false;
        closeButton.hidden = true;
        infoButton.hidden = true;
        commentButton.hidden = true;
        likeButton.hidden = true;
        spreadButton.hidden = true;

    }
    
    @IBAction func flagAction(sender: UIButton) {
        if(self.currentMedia.creatorId != USER_NODE_ID) {
            confirmationAlert(self, title: strings.prompt.flagTitle, message: strings.prompt.flagMessage, yes: {
                    putFlagMedia(self.currentMedia.id, mediaCreatorId: self.currentMedia.creatorId, callback: {
                        messageAlert(self, title: strings.prompt.flaggedTitle, message: strings.prompt.flaggedMessage);
                    })
                }) {
                    // Not flagging
            }
        }
    }
    
    @IBAction func blockAction(sender: UIButton) {
        blockFunctionality(currentMedia.creatorName, blockId: currentMedia.creatorId)
    }
    
    @IBAction func deleteAction(sender: UIButton) {
        if(self.currentMedia.creatorId == USER_NODE_ID) {
            confirmationAlert(self, title: strings.prompt.deleteMediaTitle, message: strings.prompt.deleteMediaMessage, yes: {
                deleteMedia(self.currentMedia.id) {
                    messageAlert(self, title: strings.prompt.deletedMediaTitle, message: strings.prompt.deletedMediaMessage)
                }
            }) {
                // NO
            }
        }
    }
    @IBAction func closeCommentsAction(sender: UIButton) {
        self.view.endEditing(true)
      //  commentsView.hidden = true;
        commentsView.hidden = true;
        closeButton.hidden = false;
        infoButton.hidden = false;
        commentButton.hidden = false;
        likeButton.hidden = false;
        spreadButton.hidden = false;
    }
    
    func blockFunctionality(blockName: String, blockId: String) {
        if(blockId != USER_NODE_ID) {
            confirmationAlert(self, title: strings.prompt.blockTitle, message: strings.prompt.blockMessage(currentMedia.creatorName), yes: {
                putBlockUser(self.currentMedia.creatorId, callback: {
                    messageAlert(self, title: strings.prompt.blockedTitle, message: strings.prompt.blockedMessage);
                })
            }) {
                // NO
            }
        }
    }

    func commentsTableGoToBottom() {
        if(commentList.count == 0) {return};
        let indexPath = NSIndexPath(forRow: commentList.count-1, inSection: 0)
        commentsTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        commentsTableGoToBottom();
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        commentPostAction(commentPostButton)
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
    
    @IBAction func spreadAction(sender: AnyObject) {
        if(!checkInternet()) { return; }
        if(!spreaded) {
            currentMedia.incrementSpreads();
            spreadCountLabel.text = "\(currentMedia.info.spreads)";
            let mediaId: String = currentMedia.id;
            let mediaCreatorId: String = currentMedia.creatorId;
            putSpreadMedia(mediaId, mediaCreatorId: mediaCreatorId, callback: {() -> Void in});
            spreaded = true;
            spreadButtonMechanism();
        }
    }
    
    func captionMechanism(caption: String) {
        if(caption == "CAPTION" || caption == "") {
            captionView.hidden = true;
            captionLabel.hidden = true;
        } else {
            captionView.hidden = false;
            captionLabel.hidden = false;
            captionLabel.text = caption;
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
                        self.timeAgoLabel.text = "\(time.timeAgoSinceNow())\n\(city), \(country)"
                    }
                }
            }
        }

    }
    
    func startActivityIndicator() {
        activityIndicatorView = makeActivityIndicator(self);
        activityIndicatorView.startAnimation();
        activityIndicating = true;
    }
    func stopActivityIndicator() {
        activityIndicatorView.stopAnimation();
        activityIndicating = false;
    }
    
    func commentsSetup(mediaId: String) {
        getCommentsByMediaId(mediaId) { (commentList) in
            self.commentList = commentList;
            self.commentsTableView.reloadData();
            self.commentsTableGoToBottom();
        }
    }
    
    func mediaViewSetup(media: Medias) {
        let mediaId = media.id;
        isMediaViewed(mediaId, callback: {(response: Bool) -> Void in
            if(!response) {
                self.currentMedia.incrementViews();
                USER_POINTS -= 1;
                self.viewCountLabel.text = "\(Int(self.viewCountLabel.text!)!+1)"
                putViewMedia(mediaId, callback:{() -> Void in});
            }
        })
        
        //putViewMedia(mediaId, callback:{() -> Void in});
    }
    
    func mediaLikeSetup(media: Medias) {
        let mediaId = media.id;
        isMediaLiked(mediaId, callback: {(response: Bool) -> Void in
            self.initialLiked = response;
            self.currentLiked = response;
            self.likeButtonMechanism();
        });
    }
    
    func mediaSpreadSetup(media: Medias) {
        let mediaId = media.id;
        isMediaSpreaded(mediaId, callback: {(response: Bool) -> Void in
            self.spreaded = response;
            self.spreadButtonMechanism();
        })
    }
    
    func infoSetup(media: Medias) {
        infoOpen = true;
        infoView.hidden = infoOpen;
        
        authorLabel.text = "by " + media.creatorName;
        viewCountLabel.text = "\(media.info.views)"
        likeCountLabel.text = "\(media.info.likes)"
        spreadCountLabel.text = "\(media.info.spreads)"
        
    }
    
    func noMoreMedias() {
        statusNotification(strings.status.noMoreMedia, duration: 2.0, type: "neutral");
    }

    func downloadAndShowImage(photoID: String) {
        let ext = "png";
//        let urlPath: String = config.aws.url + "/" + config.aws.bucket + "/" + config.aws.password + "/" + photoID + "." + ext;
        let urlPath: String = "\(config.aws.cloudfrontURL)/"+photoID+"."+ext;
        let url: NSURL = NSURL(string: urlPath)!;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let data = NSData(contentsOfURL: url) {

                dispatch_async(dispatch_get_main_queue(), {
                    let downloadedImage = UIImage(data: data);
                    self.photoView.layer.zPosition = 0;
                    self.currentMediaStorage = fixImageOrientation(downloadedImage!);
                    self.photoView.image = (self.currentMediaStorage as! UIImage);
                    self.stopActivityIndicator();
                    self.showIcons();
                    let mediaCaption = self.currentMedia.caption;
                    self.captionMechanism(mediaCaption);
                });
            } else {
                // TODO: Show error message
            }
        }
        
    }
    
    private func playVideo(videoID: String) {
        let ext = "mp4"
        let urlPath: String = "\(config.aws.cloudfrontURL)/"+videoID+"."+ext;
        print(urlPath);
        let url: NSURL = NSURL(string: urlPath)!;
        
        let avAsset =  AVAsset(URL: url);
        let videoPlayerItem = AVPlayerItem(asset: avAsset);
        initialPlayer = AVPlayer(playerItem: videoPlayerItem);
        initialPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None

        initialPlayerLayer = AVPlayerLayer(player: initialPlayer);
        initialPlayerLayer.frame = videoView.bounds;
        initialPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        initialPlayerLayer.addObserver(self, forKeyPath: "readyForDisplay", options: NSKeyValueObservingOptions(), context: nil)
        
        self.initialPlayer.play();
        self.videoView.layer.zPosition = -1; // to show the icons
        self.photoView.layer.zPosition = -2;
        self.videoView.layer.addSublayer(self.initialPlayerLayer);
        self.currentMediaStorage = self.initialPlayerLayer;
        self.view.addSubview(self.videoView);

        

        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: initialPlayer.currentItem, queue: nil)
        { notification in
            self.initialPlayerLayer.player!.seekToTime(CMTimeMake(getVideoLoopStartTime(self.initialPlayer), 100))
            self.showIcons();
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?,
                                         ofObject object: AnyObject?, change: [String : AnyObject]?,
                                                  context: UnsafeMutablePointer<Void>) {
        if keyPath == "readyForDisplay"{
            
            dispatch_async(dispatch_get_main_queue(), {
                self.stopActivityIndicator();
                self.showIcons();
                let mediaCaption = self.currentMedia.caption;
                self.captionMechanism(mediaCaption);

                //sleep(2);
                
//                self.initialPlayerLayer.player!.play();
//                self.videoView.layer.zPosition = -1; // to show the icons
//                self.photoView.layer.zPosition = -2;
//                
                self.initialPlayerLayer.removeObserver(self, forKeyPath:"readyForDisplay")
//
//
//                self.videoView.layer.addSublayer(self.initialPlayerLayer);
//                self.currentMediaStorage = self.initialPlayerLayer;
//                self.view.addSubview(self.videoView);

            })
        }

    }
    
    func hideTopIcons() {
        closeButton.hidden = true;
        timeAgoLabel.hidden = true;
        infoButton.hidden = true;
        spreadButton.hidden = true;
        likeButton.hidden = true;
        commentButton.hidden = true;
        
        captionView.hidden = true;
        captionLabel.hidden = true;
    }
    func showIcons() {
        closeButton.hidden = false;
        timeAgoLabel.hidden = false;
        infoButton.hidden = false;
        spreadButton.hidden = false;
        likeButton.hidden = false;
        commentButton.hidden = false;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentTableViewCell;
        
        cell.commentText.text = commentList[indexPath.row].commentContent;
        
        // Design
        cell.backgroundColor = UIColor.clearColor()
        cell.preservesSuperviewLayoutMargins = false;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
//        cell.profilePic.layer.borderWidth = 1;
//        cell.profilePic.layer.borderColor = UIColor(red:0.90, green:0.12, blue:0.24, alpha:1.0).CGColor;

      //  cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5);
        
        
        cell.textLabel?.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5);

        
        let urlPath: String = "https://graph.facebook.com/\(commentList[indexPath.row].creatorFbId! as String)/picture?type=normal"
        let profilePicUrl: NSURL = NSURL(string: urlPath)!;

        let task: NSURLSessionTask = NSURLSession.sharedSession().dataTaskWithURL(profilePicUrl) { (data, response, error) in
            if((data) != nil) {
                let image = UIImage(data: data!)
                if((image) != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.profilePicButton.setBackgroundImage(image, forState: .Normal)
                    })
                }
            }
        }
        task.resume()
        
        cell.profilePicButton.tag = indexPath.row;
        cell.profilePicButton.addTarget(self, action: #selector(LocalFeedViewController.commentBlock(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // for divider
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        if(indexPath.row == commentList.count - 1) {
//            commentsTableView.reloadData();
        }
        
        return cell;
    }
    
    func commentBlock(sender:UIButton!) {
        let commenterName: String = commentList[sender.tag].creatorName as String!
        let commenterId: String = commentList[sender.tag].creatorId as String!
        blockFunctionality(commenterName, blockId: commenterId);
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.PortraitUpsideDown];
        return orientation;
    }
    
}
