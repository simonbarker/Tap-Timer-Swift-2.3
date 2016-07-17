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

    @IBOutlet var timerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var timerTrailingContraint: NSLayoutConstraint!
    @IBOutlet var timerTopContraint: NSLayoutConstraint!
    @IBOutlet var timerBottomContraint: NSLayoutConstraint!
    
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
        
        timer = TimerModel.init(withName: "Tap Timer 1", duration: 10, UUID: NSUUID().UUIDString)
        
        timerView.setTimeRemainingLabel(timer.duration)
        timerView.setCountDownBarFromPercentage(1.0)
        
        //set up gesture recognisers
        let singleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.singleTapDetected(_:)))
        singleTapGestureRecogniser.numberOfTapsRequired = 1
        
        
        let doubleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapDetected(_:)))
        doubleTapGestureRecogniser.numberOfTapsRequired = 2
        
        singleTapGestureRecogniser.requireGestureRecognizerToFail(doubleTapGestureRecogniser)
        
        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(self.panDetected(_:)))
        
        let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchDetected(_:)))
        
        timerView.addGestureRecognizer(singleTapGestureRecogniser)
        timerView.addGestureRecognizer(doubleTapGestureRecogniser)
        timerView.addGestureRecognizer(panGestureRecogniser)
        
        self.view.addGestureRecognizer(pinchGestureRecogniser)
        
        loadAudio()
        
    }
    
    func timerFired() {
        //update timer
        
        guard let timerEndTime = timer.timerEndTime else {
            print("No timer end time available")
            return
        }
        
        if NSDate().compare(timerEndTime) == NSComparisonResult.OrderedDescending {
            
            if !didNotificationFire(timer) {
                playAudioFor(2)
            }
            
            countDownTimer.invalidate()
            timer.resetTimer()
            timerView.setTimeRemainingLabel(timer.duration)
            timerView.reset()
            removeNotificationFromSchedule(timer)
            
        } else {
            
            timerView.setCountDownBarFromPercentage(timer.percentageThroughTimer())
            timerView.setTimeRemainingLabel(timer.timeFromEndTime())
            
        }
    }
    
    //Mark: - Audio methods
    func loadAudio(){
        
        let audioFile = timer.alertAudio()
        
        let audioPath = NSBundle.mainBundle().pathForResource(audioFile.0, ofType: audioFile.1)!
        
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
        endAudioTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(seconds), target: self, selector: #selector(self.endAAudio), userInfo: nil, repeats: false)
    }
    
    func endAAudio() {
        player.stop()
        endAudioTimer.invalidate()
    }
    
    //MARK: - Gesture recognisers
    func singleTapDetected(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended && settingsMode == false {
            if timer.active == false && timer.paused == false{
                
                //start timer
                timer.active = true
                countDownTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
                timer.timerStartTime = NSDate()
                timer.timerEndTime = NSDate().dateByAddingTimeInterval(NSTimeInterval((timer.duration)))
                
                registerTimerNotification(timer)
                
                
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
                
                registerTimerNotification(timer)
                
                
            } else {
                
                //pause timer
                timer.active = false
                timer.paused = true
                timer.setPausedRemaining()
                countDownTimer.invalidate()
                
                //remove notification
                removeNotificationFromSchedule(timer)
                
            }
        }
        
    }
    
    func doubleTapDetected(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended && settingsMode == false {
            //reset timer
            countDownTimer.invalidate()
            timer.resetTimer()
            timerView.reset()
            timerView.setTimeRemainingLabel(timer.duration)
            timer.timerStartTime = nil
            timer.timerEndTime = nil
            
            //remove notification
            removeNotificationFromSchedule(timer)
        }
        
    }
    
    func panDetected(sender: UIPanGestureRecognizer) {
        
        if settingsMode == false {
            changeTimerBasedOnDistanceFromBottom(sender)
        }
        
    }
    
    func pinchDetected(sender: UIPinchGestureRecognizer) {
        if sender.state == .Began {
            
            let constraints = [timerLeadingConstraint, timerTrailingContraint, timerTopContraint, timerBottomContraint]
            
            if sender.scale < 1 {
                
                constraints[0].constant = 75
                constraints[1].constant = 75
                constraints[2].constant = 95
                constraints[3].constant = 95
                
                settingsMode = true
            } else {
                
                constraints[0].constant = -20
                constraints[1].constant = -20
                constraints[2].constant = 0
                constraints[3].constant = 0
                
                settingsMode = false
            }
        }
    }
    
    //MARK: - Notification methods
    func registerTimerNotification(timer: TimerModel){
        //register local notificaton
        let notification = UILocalNotification()
        notification.alertBody = "\(timer.name) done!"
        notification.alertAction = "open"
        notification.fireDate = timer.timerEndTime
        notification.soundName = "\(timer.alertAudio().0).\(timer.alertAudio().1)"
        notification.userInfo = ["title": timer.name, "UUID": timer.UUID]
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func removeNotificationFromSchedule(timer: TimerModel){
        let scheduledNotifications: [UILocalNotification]? = UIApplication.sharedApplication().scheduledLocalNotifications
        guard scheduledNotifications != nil else {return} // Nothing to remove, so return
        
        for notification in scheduledNotifications! { // loop through notifications...
            if (notification.userInfo!["UUID"] as! String == timer.UUID) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                break
            }
        }
    }
    
    func didNotificationFire(timer: TimerModel) -> Bool {
        let scheduledNotifications: [UILocalNotification]? = UIApplication.sharedApplication().scheduledLocalNotifications
        guard scheduledNotifications != nil else {return false} // Nothing to remove, so return
        
        for notification in scheduledNotifications! { // loop through notifications...
            if (notification.userInfo!["UUID"] as! String == timer.UUID) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                //found a notification so timer didn't end in background
                return false
            }
        }
        //didn't find notificaiton so must have fired already
        return true
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

