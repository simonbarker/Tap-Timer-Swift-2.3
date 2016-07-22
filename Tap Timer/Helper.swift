//
//  Helper.swift
//  Tap Timer
//
//  Created by Simon Barker on 22/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import Foundation
import UIKit

class Helper: NSObject {
    
    static func addBackgroundGradient(view: UIView) {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.whiteColor().CGColor, UIColor.blackColor().CGColor]
        gradient.opacity = 0.15
        view.layer.insertSublayer(gradient, atIndex: 0)
    
    }
}