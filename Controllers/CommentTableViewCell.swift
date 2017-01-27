//
//  CommentTableViewCell.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-07-16.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
        
    @IBOutlet var profilePicButton: UIButton!
    @IBOutlet var commentText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
