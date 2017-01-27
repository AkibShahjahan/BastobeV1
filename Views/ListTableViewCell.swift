//
//  ListTableViewCell.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-08-11.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet var sideImage: UIImageView!
    @IBOutlet var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
