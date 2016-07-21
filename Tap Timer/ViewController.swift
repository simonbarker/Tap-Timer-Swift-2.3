//
//  ViewController.swift
//  Tap Timer
//
//  Created by Simon Barker on 12/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet var timerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var timerTrailingContraint: NSLayoutConstraint!
    @IBOutlet var timerTopContraint: NSLayoutConstraint!
    @IBOutlet var timerBottomContraint: NSLayoutConstraint!
    
    @IBOutlet var timerView: TimerView!
    
    var audioPlayer: AVAudioPlayer?
    
    //audio playng flag
    var audioPlaying = false
    
    //timer model
    var timer: TimerModel!
    
    //var to tell if we are in settings or timer mode - important for gestures
    var settingsMode: Bool = false
    
    var countDownTimer: NSTimer = NSTimer()
    var endAudioTimer: NSTimer = NSTimer()
    
    var newStartTimeMilliSeconds: Int = 0
    
    var player: AVAudioPlayer = AVAudioPlayer()
    
    var soundButtonImages: [UIImage] = []
    
    @IBOutlet var alarmRepetitionsSlider: UISlider!
    @IBOutlet var alarmRepetitionsSliderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSettingsView()
        
        changeViewModeTo("timer")
        
        timer = TimerModel.init(withName: "Tap Timer 1", duration: 10, UUID: NSUUID().UUIDString, color: .SkyBlue)
        timer.alarmRepetitions = 1
        
        //set up timer view
        let colors = timer.getColorScheme()
        timerView.setColorScheme(colorLight: colors["lightColor"]!, colorDark: colors["darkColor"]!)
        timerView.setTimeRemainingLabel(timer.duration)
        timerView.setCountDownBarFromPercentage(1.0)
        timerView.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
        
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
        
        //grab oringal images from sound UIButton
        for i in (200...205) {
            let button = self.view.viewWithTag(i) as? UIButton
            soundButtonImages.append((button!.imageView?.image)!)
        }
        
        //highlight correct sound
        highlightCorrectSoundButtonForTimer()
        
    }
    
    func highlightCorrectSoundButtonForTimer() {
        var tag = 200
        switch timer.audioAlert {
        case .ChurchBell:
            tag = 200
        case .DogBark:
            tag = 201
        case .BoxingBell:
            tag = 202
        case .Horn:
            tag = 203
        case .Alien:
            tag = 204
        case .Car:
            tag = 205
        }
        
        let button = self.view.viewWithTag(tag) as? UIButton
        addButtonTint(button!)
    }
    
    func setupSettingsView() {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.whiteColor().CGColor, UIColor.blackColor().CGColor]
        gradient.opacity = 0.15
        self.view.layer.insertSublayer(gradient, atIndex: 0)
    
    }
    
    func timerFired() {
        //update timer
        
        guard let timerEndTime = timer.timerEndTime else {
            print("No timer end time available")
            return
        }
        
        //count down timer ended
        if NSDate().compare(timerEndTime) == NSComparisonResult.OrderedDescending {
            
            if !didNotificationFire(timer) {
                loadAudio()
                playAudio(timer.alarmRepetitions - 1)
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
        print("loading audio")
        let audioFile = timer.alertAudio()
        
        let audioPath = NSBundle.mainBundle().pathForResource(audioFile.0, ofType: audioFile.1)!
        
        do {
            try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath))
            player.delegate = self
            audioPlayer = player
        } catch {
            print("Error: \(error) in loadind audio file")
        }
        
    }
    
    func playAudio(loops: Int) {
        
        print("playing audio")
        
        player.numberOfLoops = loops
        player.currentTime = 0.0
        player.play()
        
        audioPlaying = true
    }
    
    //MARK: - Gesture recognisers
    func singleTapDetected(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended && settingsMode == false {
            if audioPlaying == true {
                audioPlayer!.stop()
                audioPlayer = nil
                audioPlaying = false
            } else {
                
                if timer.active == false && timer.paused == false {
                    
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
            
            if sender.scale < 1 {
                
                changeViewModeTo("settings")
                
                settingsMode = true
            } else {
                
                changeViewModeTo("timer")
                
                settingsMode = false
            }
        }
    }
    
    //MARK: - Toggle view mode between settings and timer
    func changeViewModeTo(mode: String){
        
        let constraints = [timerLeadingConstraint, timerTrailingContraint, timerTopContraint, timerBottomContraint]
        
        if mode == "settings" {
            constraints[0].constant = 55
            constraints[1].constant = 55
            constraints[2].constant = 105
            constraints[3].constant = 85
            self.timerView.timerLabel.hidden = true
        }
        if mode == "timer" {
            constraints[0].constant = -20
            constraints[1].constant = -20
            constraints[2].constant = 0
            constraints[3].constant = 0
            self.timerView.timerLabel.hidden = false
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: [UIViewAnimationOptions.CurveEaseIn] , animations: {
            self.view.layoutIfNeeded()
        }) { (true) in
            
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

    //MARK: - Color tapped
    @IBAction func colorTapped(sender: UIButton) {
        if settingsMode {
            switch sender.tag {
            case 100:
                timer.colorScheme = .SkyBlue
            case 101:
                timer.colorScheme = .Purple
            case 102:
                timer.colorScheme = .Red
            case 103:
                timer.colorScheme = .Yellow
            case 104:
                timer.colorScheme = .Green
            case 105:
                timer.colorScheme = .Gray
            default:
                print("No color")
            }
            
            let colors = timer.getColorScheme()
            
            timerView.setColorScheme(colorLight: colors["lightColor"]!, colorDark: colors["darkColor"]!)
            
            //change color of the highlighted sound button
            for i in (200...205) {
                let button = self.view.viewWithTag(i) as? UIButton
                if button?.imageView?.image != soundButtonImages[i - 200]{
                    addButtonTint(button!)
                }
            }
        }
    }
    
    @IBAction func soundTapped(sender: UIButton) {
        if settingsMode {
            switch sender.tag {
            case 200:
                timer.audioAlert = .ChurchBell
            case 201:
                timer.audioAlert = .DogBark
            case 202:
                timer.audioAlert = .BoxingBell
            case 203:
                timer.audioAlert = .Horn
            case 204:
                timer.audioAlert = .Alien
            case 205:
                timer.audioAlert = .Car
            default:
                print("no sound")
            }
            
            //clear previously highlighted buttons
            for i in (200...205) {
                let button = self.view.viewWithTag(i) as? UIButton
                button?.imageView?.image = soundButtonImages[i-200]
            }
            
            //change color of tapped button
            addButtonTint(sender)
            
            loadAudio()
            playAudio(0)
        }
    }
    
    func addButtonTint(button: UIButton) {
        let origImage = button.imageView?.image
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        button.setImage(tintedImage, forState: .Normal)
        
        let colors = timer.getColorScheme()
        button.tintColor = colors["lightColor"]!
    }
    
    @IBAction func sliderMoved(sender: UISlider) {
        timer.alarmRepetitions = Int(sender.value)
        alarmRepetitionsSliderLabel.text = "\(Int(sender.value))"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - AVPlayer Delegate
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        audioPlaying = false
    }
    
}

