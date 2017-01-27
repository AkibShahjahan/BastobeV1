//
//  MediaHelper.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-08-20.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import AVFoundation

func getVideoLoopStartTime(videoPlayer: AVPlayer) -> Int64 {
    let duration: Float = Float(CMTimeGetSeconds((videoPlayer.currentItem?.asset.duration)!))
    let totalTime: Int64 = Int64(duration);
    var startTime = totalTime*7;
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
    return startTime;
}