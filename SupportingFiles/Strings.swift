//
//  Strings.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-07-28.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import Foundation

class Strings {
    struct statusStrings {
        let earnCredit: String = "Earn credits by posting amazing stobes";
        let enableLocation: String = "Please enable location in Settings"
        let uploading: String = "Uploading..."
        let noMoreMedia: String = "No more stobes"
        let noMedia: String = "No stobes available"
    }
    struct errorStrings {
        let noInternet: String = "No internet connection";
        let noCredit: String = "You are out of credit";
        let noLocation: String = "Failed to access location"

    }
    struct rulebookStrings {
        let pointRules: [String] = [
            "Earn credits for each Favorite received",
            "Earn credits for each Spread received",
            "Spend 1 credit for each unique stobe viewed",
            "View any received stobes credit-free",
        ];
    }
    struct promptStrings {
        let flagTitle: String = "Flag Stobe";
        let flagMessage: String = "Are you sure you want to flag this stobe?";
        let flaggedTitle: String = "Flagged!";
        let flaggedMessage: String = "The stobe has been successfully flagged.";
        let blockTitle: String = "Block User";
        let blockedTitle: String = "Blocked!";
        let blockedMessage: String = "User has been permanently blocked.";
        func blockMessage(name: String) -> String {
            return "Are you sure you want to block \(name)?";
        }
        let deleteMediaTitle: String = "Delete Stobe";
        let deleteMediaMessage: String = "Are you sure you want to delete this stobe?";
        let deletedMediaTitle: String = "Deleted!";
        let deletedMediaMessage: String = "The stobe will be gone from your feed shortly.";
        let postCommentTitle: String = "Post Comment";
        let confirmation: String = "Are you sure?";
    }
    struct fileNames {
        struct previewNames {
            let localStream = "localStreamPreview";
            let localRank = "localRankPreview";
            let globalStream = "globalStreamPreview";
            let globalRank = "globalRankPreview";
            let like = "likePreview";
            let spread = "spreadPreview";
            let comment = "commentPreview";
            let profile = "profilePreview";
        }
        let preview = previewNames();
    }
    
    struct feedStrings {
        let localStream = "Local Stream";
        let localRank = "Local Rank";
        let globalRank = "Global Rank";
        let commentStream = "Comment Stream";
        let likeStream = "Like Stream";
        let spreadStream = "Spread Stream";
    }
    
    struct listTypeStrings {
        let friends = "Friends";
    }
    
    struct pagesString {
        let main = "MAIN";
        let personal = "PERSONAL";
        let camera = "CAMERA";
    }
    
    let status = statusStrings();
    let error = errorStrings();
    let rulebook = rulebookStrings();
    let prompt = promptStrings();
    let file = fileNames();
    let feed = feedStrings();
    let listType = listTypeStrings();
    let pages = pagesString();
}