//
//  CommentsTableViewCell.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-11-13.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var profilePicImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
