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
    
    @IBOutlet var timer1Box: UIView!
    @IBOutlet var timer1Label: UILabel!
    @IBOutlet var countDownBar1: UIView!
    @IBOutlet var countDownBar1TopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet var timer2Box: UIView!
    @IBOutlet var timer2Label: UILabel!
    @IBOutlet var countDownBar2: UIView!
    @IBOutlet var countDownBar2TopSpaceConstraint: NSLayoutConstraint!
    
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
        timer1Box.layer.zPosition = 2
        timer2Box.layer.zPosition = 2
        countDownBar1.layer.zPosition = 3
        countDownBar2.layer.zPosition = 3
        timer1Label.layer.zPosition = 4
        timer2Label.layer.zPosition = 4
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSizeMake(2, 3)
        self.layer.shadowRadius = 4
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "IntervalView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    func setTimeRemainingLabel1(seconds: Int) {
        
        let hours: Int = seconds / 3600
        let minutes: Int = (seconds - (hours * 3600)) / 60
        let remainderSeconds: Int = seconds - (60 * minutes) - (hours * 3600)
        
        //let remainderMilliSeconds: Int = milliSeconds - (60000 * minutes) - (remainderSeconds * 1000)
        
        if seconds < 3600 { //1 hour
            timer1Label.text = String(format: "%0.2d:%.2d", minutes, remainderSeconds)
        } else {
            timer1Label.text = String(format: "%0.2d:%0.2d:%.2d", hours, minutes, remainderSeconds)
        }
        
    }
    
    func setTimeRemainingLabel2(seconds: Int) {
        
        let hours: Int = seconds / 3600
        let minutes: Int = (seconds - (hours * 3600)) / 60
        let remainderSeconds: Int = seconds - (60 * minutes) - (hours * 3600)
        
        //let remainderMilliSeconds: Int = milliSeconds - (60000 * minutes) - (remainderSeconds * 1000)
        
        if seconds < 3600 { //1 hour
            timer2Label.text = String(format: "%0.2d:%.2d", minutes, remainderSeconds)
        } else {
            timer2Label.text = String(format: "%0.2d:%0.2d:%.2d", hours, minutes, remainderSeconds)
        }
        
    }
    
    func setCountDownBar1FromPercentage(percentage: Double){
        //get timer box height
        let timer1BoxHeight = timer1Box.frame.size.height

        //calculate percentage through timer
        var percentageDone = 1 - percentage
        
        //stop the contraint trying to go negative
        if percentageDone > 1 {
            percentageDone = 1.0
        }
        
        //set constraint to that percentage of the screen height
        countDownBar1TopSpaceConstraint.constant = timer1BoxHeight * CGFloat(percentageDone)
        
        UIView.animateWithDuration(0.01, delay: 0, options: [UIViewAnimationOptions.CurveLinear, UIViewAnimationOptions.AllowUserInteraction] , animations: {
            self.contentView.layoutIfNeeded()
        }) { (true) in
            
        }
    }
    
    func setCountDownBar2FromPercentage(percentage: Double){
        //get timer box height
        let timer2BoxHeight = timer2Box.frame.size.height
        
        //calculate percentage through timer
        var percentageDone = 1 - percentage
        
        //stop the contraint trying to go negative
        if percentageDone > 1 {
            percentageDone = 1.0
        }
        
        //set constraint to that percentage of the screen height
        countDownBar2TopSpaceConstraint.constant = timer2BoxHeight * CGFloat(percentageDone)
        
        UIView.animateWithDuration(0.01, delay: 0, options: [UIViewAnimationOptions.CurveLinear, UIViewAnimationOptions.AllowUserInteraction] , animations: {
            self.contentView.layoutIfNeeded()
        }) { (true) in
            
        }
    }
    
    
    
    func reset(){
        self.setCountDownBar1FromPercentage(1.0)
    }
    
    func setColorScheme1(colorLight colorLight: UIColor, colorDark: UIColor) {
        timer1Box.backgroundColor = colorLight
        countDownBar1.backgroundColor = colorDark
    }
    
    func setColorScheme2(colorLight colorLight: UIColor, colorDark: UIColor) {
        timer2Box.backgroundColor = colorLight
        countDownBar2.backgroundColor = colorDark
    }
    

}

