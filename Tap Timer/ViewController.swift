//
//  ViewController.swift
//  Tap Timer
//
//  Created by Simon Barker on 12/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit
import iCarousel

class ViewController: UIViewController, timerProtocol {
    
    var timers = [Int]()

    @IBOutlet var timerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var timerTrailingContraint: NSLayoutConstraint!
    @IBOutlet var timerTopContraint: NSLayoutConstraint!
    @IBOutlet var timerBottomContraint: NSLayoutConstraint!
    
    @IBOutlet var timerView: TimerView!
    
    //timer model
    var timer: TimerModel!
    
    //var to tell if we are in settings or timer mode - important for gestures
    var settingsMode: Bool = false
    
    var newStartTimeMilliSeconds: Int = 0
    
    var soundButtonImages: [UIImage] = []
    
    @IBOutlet var alarmRepetitionsSlider: UISlider!
    @IBOutlet var alarmRepetitionsSliderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initial view set up
        setupSettingsView()
        changeViewModeTo("timer")
        
        //create the timer
        timer = TimerModel.init(withName: "Tap Timer 1", duration: 10, UUID: NSUUID().UUIDString, color: .SkyBlue)
        timer.alarmRepetitions = 1
        timer.delegate = self
        
        //set up timer view
        let colors = timer.getColorScheme()
        timerView.setColorScheme(colorLight: colors["lightColor"]!, colorDark: colors["darkColor"]!)
        timerView.setTimeRemainingLabel(timer.duration)
        timerView.setCountDownBarFromPercentage(1.0)
        timerView.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
        
        //set up gesture recognisers for timer
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
        
        //grab original images from sound UIButton
        for i in (200...205) {
            let button = self.view.viewWithTag(i) as? UIButton
            soundButtonImages.append((button!.imageView?.image)!)
        }
        
        //highlight correct sound
        highlightCorrectSoundButtonForTimer(timer)
        
        //for developemnt purposes
        changeViewModeTo("settings")
        
    }
    
    func highlightCorrectSoundButtonForTimer(timer: TimerModel) {
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
        Helper.addButtonTint(button!, timerColorScheme: timer.getColorScheme())
    }
    
    func setupSettingsView() {
        Helper.addBackgroundGradient(self.view)
    }
    
    //MARK: - Gesture recognisers
    func singleTapDetected(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended && settingsMode == false {
            if timer.audioPlaying == true {
                timer.player.stop()
                timer.audioPlaying = false
            } else {
                
                if timer.active == false && timer.paused == false {
                    
                    //start timer
                    timer.start()
                    
                    Helper.registerTimerNotification(timer)
                    
                    
                } else if timer.active == false && timer.paused == true {
                    
                    //start timer
                    timer.restart()
                    
                    Helper.registerTimerNotification(timer)
                    
                    
                } else {
                    
                    //pause timer
                    timer.pause()
                    
                    //remove notification
                    Helper.removeNotificationFromSchedule(timer)
                    
                }
            }
        }
        
    }
    
    func doubleTapDetected(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended && settingsMode == false {
            //reset timer
            timer.reset()
            timerView.reset()
            timerView.setTimeRemainingLabel(timer.duration)
            
            //remove notification
            Helper.removeNotificationFromSchedule(timer)
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
                timer.reset()
                timerView.reset()
                timerView.setTimeRemainingLabel(duration)
                
            }
        }
    }

    //MARK: - IBActions
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
                    Helper.addButtonTint(button!, timerColorScheme: timer.getColorScheme())
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
            Helper.addButtonTint(sender, timerColorScheme: timer.getColorScheme())
            
            timer.loadAudio()
            timer.playAudio(0)//play audio once to indicate that it has been changed
        }
    }
    
    @IBAction func sliderMoved(sender: UISlider) {
        timer.alarmRepetitions = Int(sender.value)
        alarmRepetitionsSliderLabel.text = "\(Int(sender.value))"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    //Timer protocol delegate methods
    func timerFired(timer: TimerModel) {
        timerView.setCountDownBarFromPercentage(timer.percentageThroughTimer())
        timerView.setTimeRemainingLabel(timer.timeFromEndTime())
    }
    func timerEnded(timer: TimerModel) {
        timerView.setTimeRemainingLabel(timer.duration)
        timerView.reset()
    }
}


