//
//  TriangleView.swift
//  Tap Timer
//
//  Created by Simon Barker on 07/09/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit

class TriangleView: UIView {
    
    override func drawRect(rect: CGRect) {
        
        // Get Height and Width
        let layerHeight = self.layer.frame.height
        let layerWidth = self.layer.frame.width
        
        // Create Path
        let bezierPath = UIBezierPath()
        
        // Draw Points
        bezierPath.moveToPoint(CGPointMake(0, layerHeight/2))
        bezierPath.addLineToPoint(CGPointMake(layerWidth, layerHeight))//bottom right
        bezierPath.addLineToPoint(CGPointMake(layerWidth, 0))//top left
        bezierPath.addLineToPoint(CGPointMake(0, layerHeight/2))
        bezierPath.closePath()
        
        // Apply Color
        UIColor.whiteColor().setFill()
        bezierPath.fill()
        
        // Mask to Path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.CGPath
        self.layer.mask = shapeLayer
        
    }
    
}