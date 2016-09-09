//
//  carouselDelegate.swift
//  Tap Timer
//
//  Created by Simon Barker on 09/09/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit
import iCarousel

class CarouselDelegate: NSObject, iCarouselDataSource, iCarouselDelegate {
    
    var vc: ViewController!
    
    init(withViewController viewController: ViewController) {
        vc = viewController
        
        super.init()
    }
    
    //MARK: - Carousel Delegate and Datasoure Methods
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        return vc.timers.count + vc.intervalTimers.count + vc.addViews.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        
        if index < vc.timers.count {
            return vc.timerViews[index]
        } else if index < vc.timers.count + vc.intervalTimers.count {
            return vc.intervalViews[index - vc.timers.count]
        } else {
            return vc.addViews[0]
        }
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            return value * 0.7
        }
        return value
    }
    
    func carouselItemWidth(carousel: iCarousel) -> CGFloat {
        return Helper.frameSizeFor(isPro, singleOrDoubleCarousel: "single").width
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        
        vc.timerTitleTextField.enabled = true
        vc.enableRepetitionButtons()
        
        //workout if we changed to a timer or interval
        if carousel.currentItemIndex < vc.timers.count {
            
            vc.setUIforTimerSettings()
            
        } else if carousel.currentItemIndex < (vc.timers.count + vc.intervalTimers.count) {
            
            vc.intervalTimer = vc.intervalTimers[carousel.currentItemIndex - vc.timers.count]
            
            //update sound buttons
            //clear previously highlighted buttons
            vc.disableAllSoundAndColourButtons()
            
            vc.highlightCorrectSoundButtonForTimer(vc.intervalTimer.timer1)
            vc.highlightCorrectSoundButtonForTimer(vc.intervalTimer.timer2)
            
            vc.timerTitleTextField.text = vc.intervalTimer.name
            vc.timerTitleTextField.enabled = true
            vc.timerRepeatLabel.text = "\(vc.intervalTimer.intervalRepetitions)"
            vc.alarmRepeatLabel.text = "\(vc.intervalTimer.timer1.alarmRepetitions)"
            
        } else {
            //clear previously highlighted buttons
            vc.disableAllSoundAndColourButtons()
            vc.disableRepetitionButtons()
            
            vc.timerTitleTextField.text = ""
            vc.alarmRepeatLabel.text = "1"
            vc.timerRepeatLabel.text = "1"
            
        }
    }
    
}
