//
//  TimerView.swift
//  Tap Timer
//
//  Created by Simon Barker on 12/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit

class TimerView: UIView {

    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var countDownBar: UIView!
    @IBOutlet var countDownBarTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet var timerRepetitionLabel: UILabel!
    
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
        contentView.layer.zPosition = 2
        countDownBar.layer.zPosition = 3
        timerLabel.layer.zPosition = 4
        
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
        let nib = UINib(nibName: "TimerView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    func setTimeRemainingLabel(seconds: Int) {
        
        let hours: Int = seconds / 3600
        let minutes: Int = (seconds - (hours * 3600)) / 60
        let remainderSeconds: Int = seconds - (60 * minutes) - (hours * 3600)
        
        //let remainderMilliSeconds: Int = milliSeconds - (60000 * minutes) - (remainderSeconds * 1000)
        
        if seconds < 3600 { //1 hour
            timerLabel.text = String(format: "%0.2d:%.2d", minutes, remainderSeconds)
        } else {
            timerLabel.text = String(format: "%0.2d:%0.2d:%.2d", hours, minutes, remainderSeconds)
        }
        
    }
    
    func setCountDownBarFromPercentage(percentage: Double){
        //get screen height
        let screenHeight = self.frame.size.height
        
        //calculate percentage through timer
        var percentageDone = 1 - percentage
        
        //stop the contraint trying to go negative
        if percentageDone > 1 {
            percentageDone = 1.0
        }
        
        //set constraint to that percentage of the screen height
        countDownBarTopSpaceConstraint.constant = screenHeight * CGFloat(percentageDone)
        
        UIView.animateWithDuration(0.01, delay: 0, options: [UIViewAnimationOptions.CurveLinear, UIViewAnimationOptions.AllowUserInteraction] , animations: {
            self.contentView.layoutIfNeeded()
        }) { (true) in
            
        }
    }
    
    func reset(){
        self.setCountDownBarFromPercentage(1.0)
    }
    
    func setColorScheme(colorLight colorLight: UIColor, colorDark: UIColor) {
        contentView.backgroundColor = colorLight
        countDownBar.backgroundColor = colorDark
    }
    

}

