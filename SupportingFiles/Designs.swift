//
//  Designs.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-07-28.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import Foundation

class Designs {
    struct labelConfig {
        let shadowRadius: CGFloat = 8.0;
        let shadowOpactiyLabels: Float = 1.0;
    }
    struct buttonConfig {
        let shadowRadius: CGFloat = 10.0;
        let shadowOpactiyLabels: Float = 1;
        // Note: can't make the alpha's 0 when touch up cuz otherwise it can never be selected again;
        let shadeAlpha: CGFloat = 0.1;
        let shadeTouchDownAlpha: CGFloat = 0.5;
    }
    struct imageConfig {
        let shadowRadius: CGFloat = 4.0;
        let shadowOpactiyLabels: Float = 0.9;
    }
    struct colorsConfig {
        let theme: UIColor = UIColor(red:0.90, green:0.12, blue:0.24, alpha:1.0);
    }
    let label = labelConfig();
    let button = buttonConfig();
    let image = imageConfig();
    let colors = colorsConfig()
}