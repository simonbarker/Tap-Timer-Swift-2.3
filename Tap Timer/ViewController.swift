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
        
        timer = TimerModel.init(withName: "Stretch Timer", startTimeMilliSeconds: 10000)
        
        timerView.setTimerLabelFromMilliSeconds(timer.startTimeMilliSeconds)
        timerView.setCurrentCountDownConstraint(timer.currentTimeMilliSeconds, ofStartTime: timer.startTimeMilliSeconds)
        
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
        if timer.currentTimeMilliSeconds > 10 {
            timer.currentTimeMilliSeconds -= 10
        } else {
            //timer finished
            print("timer finished")
            
            player.currentTime = 0.0
            player.play()
            endAudioTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.endAlertSound), userInfo: nil, repeats: false)
            
            countDownTimer.invalidate()
            timer.resetTimer()
        }
        
        //update UI
        timerView.setTimerLabelFromMilliSeconds(timer.currentTimeMilliSeconds)
        timerView.setCurrentCountDownConstraint(timer.currentTimeMilliSeconds, ofStartTime: timer.startTimeMilliSeconds)
    }
    
    func loadAudio(){
        
        let audioPath = NSBundle.mainBundle().pathForResource("School Bell", ofType: "mp3")!
        
        do {
            
            try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath))
            
        } catch {
            print("Error: \(error) in loadind audio file")
        }
        
    }
    
    func endAlertSound() {
        player.stop()
        endAudioTimer.invalidate()
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
                
                newStartTimeMilliSeconds = Int(1000 * exp(((1-(abs(location.y))/screenHeight))*9.5))
                
            }
            
            timer.startTimeMilliSeconds = newStartTimeMilliSeconds
            timer.resetTimer()
            timerView.reset()
            timerView.setTimerLabelFromMilliSeconds(timer.startTimeMilliSeconds)
        }
        
    }
    
    var peakTranslationUp = CGPoint(x: 0, y: 0)
    var peakTranslationDown = CGPoint(x: 0, y: 0)
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
                    
                    let testTime = Int(1000 * exp(((abs(peakTranslationDown.y - translation.y))/screenHeight)*7.8383))
                    
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

