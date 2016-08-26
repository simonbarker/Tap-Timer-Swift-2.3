//
//  TimerView.swift
//  Tap Timer
//
//  Created by Simon Barker on 12/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit

class IntervalView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var timer1View: TimerView!
    @IBOutlet var timer2View: TimerView!
    
    @IBOutlet var intervalCounterLabel: UILabel!
    
    @IBOutlet var timerBoxEqualHeights: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    
    /*override func awakeFromNib() {
        
    }*/
    
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView.frame = bounds
        
        // contentView the view stretch with containing view
        contentView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView)
        
        //set z indexes
        contentView.layer.zPosition = 1
        
        dropshadow(true)
    }
    
    func dropshadow(state: Bool) {
        if state == true {
            self.layer.shadowColor = UIColor.blackColor().CGColor
            self.layer.shadowOpacity = 0.25
            self.layer.shadowOffset = CGSizeMake(2, 3)
            self.layer.shadowRadius = 4
        } else {
            self.layer.shadowColor = UIColor.blackColor().CGColor
            self.layer.shadowOpacity = 0.0
            self.layer.shadowOffset = CGSizeMake(2, 3)
            self.layer.shadowRadius = 4
        }
        
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "IntervalView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    

}

