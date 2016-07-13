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
        
        timerView.addGestureRecognizer(singleTapGestureRecogniser)
        timerView.addGestureRecognizer(doubleTapGestureRecogniser)
        
    }
    
    func timerFired() {
        //update timer
        if timer.currentTimeMilliSeconds > 0 {
            timer.currentTimeMilliSeconds -= 10
        } else {
            //this should never happen but it's a double catch to make sure we stop the timer
            countDownTimer.invalidate()
            timer.resetTimer()
        }
        
        //update UI
        timerView.setTimerLabelFromMilliSeconds(timer.currentTimeMilliSeconds)
        timerView.setCurrentCountDownConstraint(timer.currentTimeMilliSeconds, ofStartTime: timer.startTimeMilliSeconds)
    }
    
    
    func singleTapDetected(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended {

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
    
    func doubleTapDetected(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended {
            //reset timer
            countDownTimer.invalidate()
            timer.resetTimer()
            timerView.setTimerLabelFromMilliSeconds(timer.currentTimeMilliSeconds)
            timerView.setCurrentCountDownConstraint(timer.currentTimeMilliSeconds, ofStartTime: timer.startTimeMilliSeconds)
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

