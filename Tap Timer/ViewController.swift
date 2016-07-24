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
    
    var timers = [TimerModel]()
    var timerViews = [TimerView]()
    
    var settingsConstraints = [NSLayoutConstraint]()
    var timerConstraints = [NSLayoutConstraint]()

    /*@IBOutlet var timerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var timerTrailingContraint: NSLayoutConstraint!
    @IBOutlet var timerTopContraint: NSLayoutConstraint!
    @IBOutlet var timerBottomContraint: NSLayoutConstraint!
 
    @IBOutlet var timerView: TimerView!*/
    var timerView: TimerView!
    
    @IBOutlet var alarmRepetitionsSlider: UISlider!
    @IBOutlet var alarmRepetitionsSliderLabel: UILabel!
    
    //timer model
    var timer: TimerModel!
    
    //var to tell if we are in settings or timer mode - important for gestures
    var settingsMode: Bool = false
    
    //array to save images to allow tinting
    var soundButtonImages: [UIImage] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initial view set up
        setupSettingsView()
        
        //create the timers
        let timerColorSchemes = [BaseColor.SkyBlue, BaseColor.Purple, BaseColor.Red, BaseColor.Yellow, BaseColor.Green, BaseColor.Gray]
        for i in 0...5 {
            timer = TimerModel.init(withName: "Tap Timer \(i)", duration: 10, UUID: NSUUID().UUIDString, color: timerColorSchemes[i])
            timer.alarmRepetitions = 1
            timer.delegate = self
            timers.append(timer)
        }
        
        //set up timer view
        timerView = TimerView.init()
        
        timerView.frame = self.view.bounds
        
        let colors = timer.getColorScheme()
        timerView.setColorScheme(colorLight: colors["lightColor"]!, colorDark: colors["darkColor"]!)
        timerView.setTimeRemainingLabel(timer.duration)
        timerView.setCountDownBarFromPercentage(1.0)
        timerView.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
        timerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(timerView)
        
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
        timerView.addGestureRecognizer(pinchGestureRecogniser)
        
        //grab original images from sound UIButton
        for i in (200...205) {
            let button = self.view.viewWithTag(i) as? UIButton
            soundButtonImages.append((button!.imageView?.image)!)
        }
        
        //highlight correct sound
        highlightCorrectSoundButtonForTimer(timer)
        
        //for developemnt purposes
        addTimerModeConstraints()
        
        
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
        
        if mode == "settings" {
            addSettingsModeConstraints()
            self.timerView.timerLabel.hidden = true
        }
        if mode == "timer" {
            addTimerModeConstraints()
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
    
    //MARK: - Layout Constraints
    func addTimerModeConstraints() {

        let views = ["timerView": timerView]
        
        let timerHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-0-[timerView]-0-|",
            options: [],
            metrics: nil,
            views: views)
        settingsConstraints += timerHorizontalConstraints
    
        let timerVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-0-[timerView]-0-|",
            options: [],
            metrics: nil,
            views: views)
        settingsConstraints += timerVerticalConstraints

        NSLayoutConstraint.deactivateConstraints(timerConstraints)
        NSLayoutConstraint.activateConstraints(settingsConstraints)
    }
    
    func addSettingsModeConstraints() {
        
        let views = ["timerView": timerView]
        
        let timerHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-75-[timerView]-75-|",
            options: [],
            metrics: nil,
            views: views)
        timerConstraints += timerHorizontalConstraints
        
        let timerVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-105-[timerView]-85-|",
            options: [],
            metrics: nil,
            views: views)
        timerConstraints += timerVerticalConstraints
        
        NSLayoutConstraint.deactivateConstraints(settingsConstraints)
        NSLayoutConstraint.activateConstraints(timerConstraints)
    }
    
}


