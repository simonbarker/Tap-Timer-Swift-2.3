//
//  ViewController.swift
//  Tap Timer
//
//  Created by Simon Barker on 12/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var timerView: TimerView!
    
    //timer model
    var timer: TimerModel!
    
    //var to tell if we are in settings or timer mode - important for gestures
    var settingsMode: Bool = false
    
    var countDownTimer: NSTimer = NSTimer()
    
    var newStartTimeMilliSeconds: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = TimerModel.init(withName: "Stretch Timer", startTimeMilliSeconds: 10000)
        
        timerView.setTimerLabelFromMilliSeconds(timer.startTimeMilliSeconds)
        timerView.setCurrentCountDownConstraint(timer.currentTimeMilliSeconds, ofStartTime: timer.startTimeMilliSeconds)
        
        let singleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.singleTapDetected(_:)))
        singleTapGestureRecogniser.numberOfTapsRequired = 1
        
        
        let doubleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapDetected(_:)))
        doubleTapGestureRecogniser.numberOfTapsRequired = 2
        
        singleTapGestureRecogniser.requireGestureRecognizerToFail(doubleTapGestureRecogniser)
        
        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(self.panDetected(_:)))
        
        timerView.addGestureRecognizer(singleTapGestureRecogniser)
        timerView.addGestureRecognizer(doubleTapGestureRecogniser)
        timerView.addGestureRecognizer(panGestureRecogniser)
        
    }
    
    func timerFired() {
        //update timer
        if timer.currentTimeMilliSeconds > 10 {
            timer.currentTimeMilliSeconds -= 10
        } else {
            countDownTimer.invalidate()
            timer.resetTimer()
        }
        
        //update UI
        timerView.setTimerLabelFromMilliSeconds(timer.currentTimeMilliSeconds)
        timerView.setCurrentCountDownConstraint(timer.currentTimeMilliSeconds, ofStartTime: timer.startTimeMilliSeconds)
    }
    
    
    //MARK: - Gesture recognisers
    func singleTapDetected(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended {
            if timer.startTimeMilliSeconds != 0 && timer.currentTimeMilliSeconds != 0 {
                if !timer.active {
                    //start timer
                    timer.active = true
                    countDownTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
                } else {
                    //pause timer
                    timer.active = false
                    countDownTimer.invalidate()
                }
            }
            
        }
        
    }
    
    func doubleTapDetected(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended {
            //reset timer
            countDownTimer.invalidate()
            timer.resetTimer()
            timerView.setTimerLabelFromMilliSeconds(timer.currentTimeMilliSeconds)
            timerView.setCurrentCountDownConstraint(timer.currentTimeMilliSeconds, ofStartTime: timer.startTimeMilliSeconds)
        }
        
    }
    
    func panDetected(sender: UIPanGestureRecognizer) {
        
        changeTimerBasedOnTranslation(sender)
        
        
    }
    
    var peakTranslationUp = CGPoint(x: 0, y: 0)
    var peakTranslationDown = CGPoint(x: 0, y: 0)
    
    //MARK: - Set timer methods
    func changeTimerBasedOnTranslation(sender: UIPanGestureRecognizer) {
        
        //only let timer time be changed if not active
        if timer.active == false {
            let translation = sender.translationInView(timerView)
            let velocity = sender.velocityInView(timerView)
            let screenHeight = self.view.frame.size.height
            
            if sender.state == UIGestureRecognizerState.Began {
                peakTranslationUp.y = 0
                peakTranslationDown.y = 0
            } else {
                
                if velocity.y < 0 {
                    
                    print("Increase time")
                    
                    if translation.y < peakTranslationUp.y {
                        peakTranslationUp.y = translation.y
                    }
                    
                    let testTime = Int(1000 * exp(((abs(peakTranslationDown.y - translation.y))/screenHeight)*10.8383))
                    
                    newStartTimeMilliSeconds += testTime
                    if newStartTimeMilliSeconds > 86400000 {
                        newStartTimeMilliSeconds = 86400000
                    }
                } else {
                    
                    print("Decrease time")
                    
                    if translation.y > peakTranslationDown.y {
                        peakTranslationDown.y = translation.y
                    }
                    
                    let testTime = Int(1000 * exp(((abs(peakTranslationUp.y - translation.y))/screenHeight)*10.8383))
                    
                    newStartTimeMilliSeconds -= testTime
                    if newStartTimeMilliSeconds < 0 {
                        newStartTimeMilliSeconds = 0
                    }
                }
                
            }
            
            timer.startTimeMilliSeconds = newStartTimeMilliSeconds
            timer.resetTimer()
            timerView.reset()
            timerView.setTimerLabelFromMilliSeconds(timer.startTimeMilliSeconds)
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

