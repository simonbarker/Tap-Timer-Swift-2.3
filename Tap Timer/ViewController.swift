//
//  ViewController.swift
//  Tap Timer
//
//  Created by Simon Barker on 12/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet var timerView: TimerView!
    
    //timer model
    var timer: TimerModel!
    
    //var to tell if we are in settings or timer mode - important for gestures
    var settingsMode: Bool = false
    
    var countDownTimer: NSTimer = NSTimer()
    var endAudioTimer: NSTimer = NSTimer()
    
    var newStartTimeMilliSeconds: Int = 0
    
    var player: AVAudioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = TimerModel.init(withName: "Stretch Timer", duration: 10)
        
        timerView.setTimeRemainingLabel(timer.duration)
        timerView.setCountDownBarFromPercentage(1.0)
        
        //set up gesture recognisers
        let singleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.singleTapDetected(_:)))
        singleTapGestureRecogniser.numberOfTapsRequired = 1
        
        
        let doubleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapDetected(_:)))
        doubleTapGestureRecogniser.numberOfTapsRequired = 2
        
        singleTapGestureRecogniser.requireGestureRecognizerToFail(doubleTapGestureRecogniser)
        
        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(self.panDetected(_:)))
        
        timerView.addGestureRecognizer(singleTapGestureRecogniser)
        timerView.addGestureRecognizer(doubleTapGestureRecogniser)
        timerView.addGestureRecognizer(panGestureRecogniser)
        
        loadAudio()
        
    }
    
    func timerFired() {
        //update timer
        
        guard let timerEndTime = timer.timerEndTime else {
            print("No timer end time available")
            return
        }
        
        if NSDate().compare(timerEndTime) == NSComparisonResult.OrderedDescending {
            
            playAudioFor(2)
            
            countDownTimer.invalidate()
            timer.resetTimer()
            timerView.setTimeRemainingLabel(timer.duration)
            timerView.reset()
            
        } else {
            
            timerView.setCountDownBarFromPercentage(timer.percentageThroughTimer())
            timerView.setTimeRemainingLabel(timer.timeFromEndTime())
            
        }
    }
    
    func loadAudio(){
        
        let audioPath = NSBundle.mainBundle().pathForResource("School Bell", ofType: "mp3")!
        
        do {
            try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath))
        } catch {
            print("Error: \(error) in loadind audio file")
        }
        
    }
    
    func playAudioFor(seconds: Int) {
        //play audio for 2 seconds
        player.currentTime = 0.0
        player.play()
        endAudioTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(seconds), target: self, selector: #selector(self.endAlertSound), userInfo: nil, repeats: false)
    }
    
    func endAlertSound() {
        player.stop()
        endAudioTimer.invalidate()
    }
    
    //MARK: - Gesture recognisers
    func singleTapDetected(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended {
            if timer.active == false && timer.paused == false{
                
                //start timer
                timer.active = true
                countDownTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
                timer.timerStartTime = NSDate()
                timer.timerEndTime = NSDate().dateByAddingTimeInterval(NSTimeInterval((timer.duration)))
                
            } else if timer.active == false && timer.paused == true {
                
                //start timer
                timer.active = true
                timer.paused = false
                countDownTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
                
                //reset end time
                timer.timerStartTime = NSDate()
                
                guard let remaining = timer.remainingWhenPaused else {
                    print("No paused remaining time")
                    return
                }
                
                timer.timerEndTime = NSDate().dateByAddingTimeInterval(NSTimeInterval((remaining)))
                
            } else {
                
                //pause timer
                timer.active = false
                timer.paused = true
                timer.setPausedRemaining()
                countDownTimer.invalidate()
                
            }
        }
        
    }
    
    func doubleTapDetected(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended {
            //reset timer
            countDownTimer.invalidate()
            timer.resetTimer()
            timerView.reset()
            timerView.setTimeRemainingLabel(timer.duration)
            timer.timerStartTime = nil
            timer.timerEndTime = nil
        }
        
    }
    
    func panDetected(sender: UIPanGestureRecognizer) {
        
        changeTimerBasedOnDistanceFromBottom(sender)
        
    }
    
    //MARK: - Set timer methods
    func changeTimerBasedOnDistanceFromBottom(sender: UIPanGestureRecognizer) {
        
        //only let timer time be changed if not active
        if timer.active == false {
            let location = sender.locationInView(timerView)
            //let velocity = sender.velocityInView(timerView)
            let screenHeight = self.view.frame.size.height
            
            if sender.state == UIGestureRecognizerState.Began {
                
            } else {
                
                let duration = Int(1 * exp(((1-(abs(location.y))/screenHeight))*9.5))
                
                timer.duration = duration
                timer.resetTimer()
                timerView.reset()
                timerView.setTimeRemainingLabel(duration)
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

