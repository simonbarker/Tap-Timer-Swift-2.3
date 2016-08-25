//
//  ViewController.swift
//  Tap Timer
//
//  Created by Simon Barker on 12/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit
import iCarousel

class ViewController: UIViewController, timerProtocol, iCarouselDataSource, iCarouselDelegate, UITextFieldDelegate, proUpgradeDelegate, intervalProtocol {
    
    @IBOutlet var carousel: iCarousel!
    
    @IBOutlet var carouselTopConstraint: NSLayoutConstraint!
    @IBOutlet var carouselBottomConstraint: NSLayoutConstraint!
    @IBOutlet var carouselTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var carouselLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var timerTitleTextField: UITextField!
    @IBOutlet var timerRepeatLabel: UILabel!
    @IBOutlet var alarmRepeatLabel: UILabel!
    
    var timers = [TimerModel]()
    var timerViews = [TimerView]()
    var intervalTimers = [IntervalModel]()
    var intervalViews = [IntervalView]()
    
    var settingsConstraints = [NSLayoutConstraint]()
    var timerConstraints = [NSLayoutConstraint]()

    var displayedTimer: TimerView!
    var displayedInterval: IntervalView!
    
    var timer: TimerModel!
    var intervalTimer: IntervalModel!
    
    var settingsMode: Bool = false
    
    //array to save images to allow button tinting reset
    var soundButtonImages: [UIImage] = []
    
    @IBOutlet var proFeaturesButton: UIButton!
    @IBOutlet var createIntervalButton: UIButton!
    @IBOutlet var intervalIcon: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initial view set up
        Helper.addBackgroundGradient(self.view)
        
        createTimers()
        
        createIntervalTimers()
        
        setupUI()
        
    }
    
    func setupUI() {
        if isPro == true {
            timerTitleTextField.hidden = false
            createIntervalButton.hidden = false
            intervalIcon.hidden = false
            proFeaturesButton.hidden = true
        } else {
            timerTitleTextField.hidden = true
            createIntervalButton.hidden = true
            intervalIcon.hidden = true
            proFeaturesButton.hidden = false
        }
        
        //instantiate first timer
        timer = timers[0]
        timerTitleTextField.text = timer.name
        timerTitleTextField.delegate = self
        alarmRepeatLabel.text = "\(timer.alarmRepetitions)"
        timerRepeatLabel.text = "\(timer.timerRepetitions)"
        
        //grab original images from sound UIButton
        for i in (200...205) {
            let button = self.view.viewWithTag(i) as? UIButton
            soundButtonImages.append((button!.imageView?.image)!)
        }
        
        //highlight correct sound
        highlightCorrectSoundButtonForTimer(timer)
        
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .CoverFlow
        carousel.bounces = false
        carousel.clipsToBounds = true
        
        settingsMode = true
    }
    
    func createTimers() {
        
        let timerColorSchemes = [BaseColor.SkyBlue, BaseColor.Purple, BaseColor.Red, BaseColor.Yellow, BaseColor.Green, BaseColor.Gray]
        
        var totalTimers = 1
        if isPro == true {
            totalTimers = 6
        }
        
        //look for timers in NSUserDefaults
        let savedTimers = TTDefaultsHelper.getSavedTimers()
        
        if savedTimers.count == 0 {
            //if no timers in defaults then create and save them
            for i in 0...(totalTimers - 1) {
                
                let t = TimerModel.init(withName: "Tap Timer \(i)", duration: 10, UUID: NSUUID().UUIDString, color: timerColorSchemes[i], alertNoise: AlertNoise.Car, timerRepetitions: 0, alarmRepetitions: 0)
                t.alarmRepetitions = 1
                t.delegate = self
                timers.append(t)
            }
            
            TTDefaultsHelper.saveTimers(timers)
            
            
        } else {
            //if there are timers in defaults then load them up
            timers = savedTimers
        }
        
        //have timers so just make the views
        let phoneType = Helper.detectPhoneScreenSize()
        
        for t in timers {
            t.delegate = self
            let tView = TimerView.init()
            
            if isPro == true {
                if phoneType == "4" {
                    tView.frame = CGRect(x: 0, y: 0, width: 100, height: 160)
                } else if phoneType == "5" {
                    tView.frame = CGRect(x: 0, y: 0, width: 100, height: 160)
                } else if phoneType == "6" {
                    tView.frame = CGRect(x: 0, y: 0, width: 100, height: 190)
                } else { //6+
                    tView.frame = CGRect(x: 0, y: 0, width: 125, height: 260)
                }
            } else {
                if phoneType == "4" {
                    tView.frame = CGRect(x: 0, y: 0, width: 100, height: 160)
                } else if phoneType == "5" {
                    tView.frame = CGRect(x: 0, y: 0, width: 160, height: 280)
                } else if phoneType == "6" {
                    tView.frame = CGRect(x: 0, y: 0, width: 160, height: 280)
                } else { //6+
                    tView.frame = CGRect(x: 0, y: 0, width: 200, height: 400)
                }
            }
            
            let colors = t.getColorScheme()
            tView.setColorScheme(colorLight: colors["lightColor"]!, colorDark: colors["darkColor"]!)
            tView.setTimeRemainingLabel(t.duration)
            tView.setCountDownBarFromPercentage(1)
            tView.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
            tView.timerLabel.hidden = false
            tView.timerLabel.font = tView.timerLabel.font.fontWithSize(20.0)
            
            
            //set up gesture recognisers for timer
            let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchDetected(_:)))
            
            tView.addGestureRecognizer(pinchGestureRecogniser)
            
            timerViews.append(tView)
        }
        
    }
    
    func createIntervalTimers() {
        
        let savedIntervals = TTDefaultsHelper.getSavedIntervalTimers()
        
        if savedIntervals.count != 0 {
            
            intervalTimers = savedIntervals
            
            for i in savedIntervals {
                
                i.delegate = self
                
                let timer1 = i.timer1
                let timer2 = i.timer2
                
                let tView = TimerView.init()
                
                let phoneType = Helper.detectPhoneScreenSize()
                if phoneType == "4" {
                    tView.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
                } else if phoneType == "5" {
                    tView.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
                } else if phoneType == "6" {
                    tView.frame = CGRect(x: 0, y: 0, width: 100, height: 95)
                } else { //6+
                    tView.frame = CGRect(x: 0, y: 0, width: 125, height: 130)
                }
                
                let colors = timer1.getColorScheme()
                tView.setColorScheme(colorLight: colors["lightColor"]!, colorDark: colors["darkColor"]!)
                tView.setTimeRemainingLabel(timer1.duration)
                tView.setCountDownBarFromPercentage(1)
                tView.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
                tView.timerLabel.hidden = false
                tView.timerLabel.font = tView.timerLabel.font.fontWithSize(20.0)
                
                
                let tView2 = TimerView.init()
                
                if phoneType == "4" {
                    tView2.frame = CGRect(x: 0, y: 80, width: 100, height: 80)
                } else if phoneType == "5" {
                    tView2.frame = CGRect(x: 0, y: 80, width: 100, height: 80)
                } else if phoneType == "6" {
                    tView2.frame = CGRect(x: 0, y: 95, width: 100, height: 95)
                } else { //6+
                    tView2.frame = CGRect(x: 0, y: 130, width: 125, height: 130)
                }
                
                let colors2 = timer2.getColorScheme()
                tView2.setColorScheme(colorLight: colors2["lightColor"]!, colorDark: colors2["darkColor"]!)
                tView2.setTimeRemainingLabel(timer2.duration)
                tView2.setCountDownBarFromPercentage(1)
                tView2.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
                tView2.timerLabel.hidden = false
                tView2.timerLabel.font = tView.timerLabel.font.fontWithSize(20.0)
                
                let intervalView = IntervalView()
                
                if phoneType == "4" {
                    intervalView.frame = CGRect(x: 0, y: 0, width: 100, height: 160)
                } else if phoneType == "5" {
                    intervalView.frame = CGRect(x: 0, y: 0, width: 100, height: 160)
                } else if phoneType == "6" {
                    intervalView.frame = CGRect(x: 0, y: 0, width: 100, height: 190)
                } else { //6+
                    intervalView.frame = CGRect(x: 0, y: 0, width: 125, height: 260)
                }
                intervalView.addSubview(tView)
                intervalView.addSubview(tView2)
                
                //set up gesture recognisers for timer
                let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(self.intervalTimerPinchDetected(_:)))
                
                intervalView.addGestureRecognizer(pinchGestureRecogniser)
                
                intervalViews.append(intervalView)
                
            }
            
        }
        
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
    
    //MARK: - Gesture recognisers
    func singleTapDetected(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended && settingsMode == false {
            if sender.view == displayedTimer {
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
            } else if sender.view == displayedInterval {
                
                print("Start interval")
                intervalTimer.startIntervalTimer()
                
            }
        }
        
    }
    
    func doubleTapDetected(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended && settingsMode == false {
            if sender.view == displayedTimer {
            
                //reset timer
                timer.clearTimer()
                displayedTimer.reset()
                displayedTimer.setTimeRemainingLabel(timer.duration)
                
                //remove notification
                Helper.removeNotificationFromSchedule(timer)
                
            } else if sender.view == displayedInterval {
                
                //reset interval
                
            }
        }
        
    }
    
    func panDetected(sender: UIPanGestureRecognizer) {
        
        if settingsMode == false {
            changeTimerBasedOnDistanceFromBottom(sender)
            //update defaults
            TTDefaultsHelper.saveTimers(timers)
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
    
    func intervalTimerPinchDetected(sender: UIPinchGestureRecognizer) {
        if sender.state == .Began {
            
            if sender.scale < 1 {
                
                changeViewModeTo("intervalSettings")
                
                settingsMode = true
            } else {
                
                changeViewModeTo("intervalTimer")
                
                settingsMode = false
            }
        }
    }
    
    //MARK: - Toggle view mode between settings and timer
    func changeViewModeTo(mode: String){
        
        if mode == "settings" && settingsMode != true {
            addSettingsModeConstraintsToTimerView()
            animatedLayoutIfNeeded(removeView: true, viewToRemove: displayedTimer)
            
            guard let index = timers.indexOf(timer) else {
                print("Index of timer object not found in timers array")
                return
            }
                
            timerViews[index].setCountDownBarFromPercentage(timer.percentageThroughTimer())
        }
        if mode == "timer" && settingsMode != false {
            
            //this is the most upsetting block of code I've ever written - it works but it's ugly
            displayedTimer = TimerView.init()
            self.displayedTimer.translatesAutoresizingMaskIntoConstraints = false
            displayedTimer.frame = CGRect(x: (self.view.bounds.size.width)/2, y: (self.view.bounds.size.height)/2, width: 1, height: 1)
            let colors = timer.getColorScheme()
            displayedTimer.setColorScheme(colorLight: colors["lightColor"]!, colorDark: colors["darkColor"]!)
            
            displayedTimer.setTimeRemainingLabel(timer.timeToDisplay())
            displayedTimer.timerLabel.hidden = false
            
            displayedTimer.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
            
            //set up gesture recognisers for timer
            let singleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.singleTapDetected(_:)))
            singleTapGestureRecogniser.numberOfTapsRequired = 1
            
            let doubleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapDetected(_:)))
            doubleTapGestureRecogniser.numberOfTapsRequired = 2
            singleTapGestureRecogniser.requireGestureRecognizerToFail(doubleTapGestureRecogniser)
            let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(self.panDetected(_:)))
            panGestureRecogniser.minimumNumberOfTouches = 2
            let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchDetected(_:)))
            
            displayedTimer.addGestureRecognizer(singleTapGestureRecogniser)
            displayedTimer.addGestureRecognizer(doubleTapGestureRecogniser)
            displayedTimer.addGestureRecognizer(panGestureRecogniser)
            displayedTimer.addGestureRecognizer(pinchGestureRecogniser)
            
            self.view.addSubview(displayedTimer)
            
            //make the view small before making it full screen so that is grows from the center of the screen
            addSettingsModeConstraintsToTimerView()
            self.view.layoutIfNeeded()
            
            addTimerModeConstraintsToTimerView()
            animatedLayoutIfNeeded(removeView: false)
            
            displayedTimer.setCountDownBarFromPercentage(timer.percentageThroughTimer())
            
        }
        if mode == "intervalSettings" && settingsMode != true {
            
            addSettingsModeConstraintsToIntervalView()
            animatedLayoutIfNeeded(removeView: true, viewToRemove: displayedInterval)
            
            /*guard let index = timers.indexOf(timer) else {
                print("Index of timer object not found in timers array")
                return
            }*/
            
            //timerViews[index].setCountDownBarFromPercentage(timer.percentageThroughTimer())
        }
        if mode == "intervalTimer" && settingsMode != false {
            
            print("In change to interval Timer mode")
            
            displayedInterval = IntervalView.init()
            self.displayedInterval.translatesAutoresizingMaskIntoConstraints = false
            displayedInterval.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
            let colors1 = intervalTimer.timer1.getColorScheme()
            displayedInterval.setColorScheme1(colorLight: colors1["lightColor"]!, colorDark: colors1["darkColor"]!)
            displayedInterval.setTimeRemainingLabel1(intervalTimer.timer1.timeToDisplay())
            displayedInterval.timer1Label.hidden = false
            
            let colors2 = intervalTimer.timer2.getColorScheme()
            displayedInterval.setColorScheme2(colorLight: colors2["lightColor"]!, colorDark: colors2["darkColor"]!)
            displayedInterval.setTimeRemainingLabel2(intervalTimer.timer2.timeToDisplay())
            displayedInterval.timer2Label.hidden = false
            
            displayedInterval.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
            
            //set up gesture recognisers for interval
            let singleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.singleTapDetected(_:)))
            singleTapGestureRecogniser.numberOfTapsRequired = 1
            
            let doubleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapDetected(_:)))
            doubleTapGestureRecogniser.numberOfTapsRequired = 2
            singleTapGestureRecogniser.requireGestureRecognizerToFail(doubleTapGestureRecogniser)
            let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(self.panDetected(_:)))
            panGestureRecogniser.minimumNumberOfTouches = 2
            let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(self.intervalTimerPinchDetected(_:)))
            
            displayedInterval.addGestureRecognizer(singleTapGestureRecogniser)
            displayedInterval.addGestureRecognizer(doubleTapGestureRecogniser)
            displayedInterval.addGestureRecognizer(panGestureRecogniser)
            displayedInterval.addGestureRecognizer(pinchGestureRecogniser)
            
            self.view.addSubview(displayedInterval)
            
            //make the view small before making it full screen so that is grows from the center of the screen
            addSettingsModeConstraintsToIntervalView()
            self.view.layoutIfNeeded()
            
            addTimerModeConstraintsToIntervalView()
            animatedLayoutIfNeeded(removeView: false)
            
            displayedInterval.setCountDownBar1FromPercentage(intervalTimer.timer1.percentageThroughTimer())
            displayedInterval.setCountDownBar2FromPercentage(intervalTimer.timer2.percentageThroughTimer())

        }
        
    }
    
    func animatedLayoutIfNeeded(removeView removeView: Bool, viewToRemove: UIView?=nil){
        UIView.animateWithDuration(0.3, delay: 0, options: [UIViewAnimationOptions.CurveEaseIn] , animations: {
            self.view.layoutIfNeeded()
        }) { (true) in
            if removeView == true {
                if viewToRemove == self.displayedInterval {
                    self.displayedInterval.removeFromSuperview()
                } else {
                    self.displayedTimer.removeFromSuperview()
                }
            }
        }
    }
    
    //MARK: - Set timer methods
    func changeTimerBasedOnDistanceFromBottom(sender: UIPanGestureRecognizer) {
        
        //only let timer time be changed if not active
        if timer.active == false {
            let location = sender.locationInView(displayedTimer)
            //let velocity = sender.velocityInView(timerView)
            let screenHeight = self.view.frame.size.height
            
            if sender.state == UIGestureRecognizerState.Began {
                
            } else {
                
                let duration = Int(1 * exp(((1-(abs(location.y))/screenHeight))*9.5))
                
                timer.duration = duration
                timer.clearTimer()
                displayedTimer.reset()
                displayedTimer.setTimeRemainingLabel(duration)
                
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
            
            let t = carousel.currentItemView as? TimerView
            
            t!.setColorScheme(colorLight: colors["lightColor"]!, colorDark: colors["darkColor"]!)
            
            //change color of the highlighted sound button
            for i in (200...205) {
                let button = self.view.viewWithTag(i) as? UIButton
                if button?.imageView?.image != soundButtonImages[i - 200]{
                    Helper.addButtonTint(button!, timerColorScheme: timer.getColorScheme())
                }
            }
            
            //update defaults
            TTDefaultsHelper.saveTimers(timers)
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
            
            //update defaults
            TTDefaultsHelper.saveTimers(timers)
        }
    }
    
    @IBAction func alarmRepeatMinusTapped(sender: AnyObject) {
        if timer.alarmRepetitions == 1 {
            return
        } else {
            timer.alarmRepetitions -= 1
            alarmRepeatLabel.text = "\(timer.alarmRepetitions)"
            //update defaults
            TTDefaultsHelper.saveTimers(timers)
        }
    }
    
    @IBAction func alarmRepeatPlusTapped(sender: AnyObject) {
        if timer.alarmRepetitions == 10 {
            return
        } else {
            timer.alarmRepetitions += 1
            alarmRepeatLabel.text = "\(timer.alarmRepetitions)"
            //update defaults
            TTDefaultsHelper.saveTimers(timers)
        }
    }
    
    @IBAction func timerRepeatMinusTapped(sender: AnyObject) {
        if timer.timerRepetitions == 0 {
            return
        } else {
            timer.timerRepetitions -= 1
            timerRepeatLabel.text = "\(timer.timerRepetitions)"
            //update defaults
            TTDefaultsHelper.saveTimers(timers)
        }
    }
    
    @IBAction func timerRepeatPlusTapped(sender: AnyObject) {
        if timer.timerRepetitions == 99 {
            return
        } else {
            timer.timerRepetitions += 1
            timerRepeatLabel.text = "\(timer.timerRepetitions)"
            //update defaults
            TTDefaultsHelper.saveTimers(timers)
        }
    }
    
    
    //MARK: - Timer protocol delegate methods
    func timerFired(timer: TimerModel) {
        
        guard let index = timers.indexOf(timer) else {
            print("Index of timer object not found in timers array")
            return
        }

        timerViews[index].setCountDownBarFromPercentage(timer.percentageThroughTimer())
        timerViews[index].setTimeRemainingLabel(timer.timeToDisplay())
        
        //update displayed timer if this timer is the current timer
        if carousel.currentItemIndex == index {
            displayedTimer.setCountDownBarFromPercentage(timer.percentageThroughTimer())
            displayedTimer.setTimeRemainingLabel(timer.timeToDisplay())
        }
        
    }
    
    func timerEnded(timer: TimerModel) {
        
        guard let index = timers.indexOf(timer) else {
            print("Index of timer object not found in timers array")
            return
        }
        
        timerViews[index].setTimeRemainingLabel(timer.duration)
        timerViews[index].reset()
        
        //update displayed timer if this timer is the current timer
        if carousel.currentItemIndex == index {
            displayedTimer.setTimeRemainingLabel(timer.duration)
            displayedTimer.reset()
        }
        
    }
    
    //MARK: - Interval protocol delegate methods
    func intervalTimerFired(interval: IntervalModel, timer: TimerModel) {
        guard let index = intervalTimers.indexOf(interval) else {
            print("Index of interval not found")
            return
        }
        
        print("Index \(index)")
        
        intervalViews[index].setTimeRemainingLabel1(timer.timeToDisplay())
        intervalViews[index].setCountDownBar1FromPercentage(timer.percentageThroughTimer())
        
        //update displayed timer if this timer is the current timer
        if carousel.currentItemIndex == index + timers.count {
            print("index + timers.count \(index + timers.count)")
            displayedInterval.setCountDownBar1FromPercentage(timer.percentageThroughTimer())
            displayedInterval.setTimeRemainingLabel1(timer.timeToDisplay())
        }
        
        
    }
    
    func intervalTimerEnded(interval: IntervalModel, timer: TimerModel) {
        
    }
    
    //MARK: - proUpgradeDelegate methods
    func upgradedToPro(upgradeSucessful: Bool) {
        print("Upgraded to pro delegate method called")
        if upgradeSucessful == true {
            print("Upgrading")
            TTDefaultsHelper.removeAllTimers()
            timers.removeAll()
            timerViews.removeAll()
            
            createTimers()
            setupUI()
            carousel.reloadData()
        }
    }
    
    //MARK: - Layout Constraints
    func addSettingsModeConstraintsToTimerView() {
        
        if timerConstraints.count != 0 {
            NSLayoutConstraint.deactivateConstraints(timerConstraints)
        }
        
        timerConstraints.removeAll()
        settingsConstraints.removeAll()
        
        let views = ["timerView": displayedTimer]
        
        let timerHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-75-[timerView]-75-|",
            options: [],
            metrics: nil,
            views: views)
        for constraint in timerHorizontalConstraints{
            constraint.identifier = "timerHorizontalConstraints.settingsMode"
        }
        settingsConstraints += timerHorizontalConstraints
        
        let timerVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-65-[timerView]-45-|",
            options: [],
            metrics: nil,
            views: views)
        for constraint in timerVerticalConstraints{
            constraint.identifier = "timerVerticalConstraints.settingsMode"
        }
        settingsConstraints += timerVerticalConstraints
        
        NSLayoutConstraint.activateConstraints(settingsConstraints)
    }
    
    func addTimerModeConstraintsToTimerView() {
        
        if settingsConstraints.count != 0 {
            NSLayoutConstraint.deactivateConstraints(settingsConstraints)
        }
        
        timerConstraints.removeAll()
        settingsConstraints.removeAll()
        
        let views = ["timerView": displayedTimer]
        
        let timerHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-0-[timerView]-0-|",
            options: [],
            metrics: nil,
            views: views)
        for constraint in timerHorizontalConstraints{
            constraint.identifier = "timerHorizontalConstraints.timerMode"
        }
        timerConstraints += timerHorizontalConstraints
        
        let timerVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-0-[timerView]-0-|",
            options: [],
            metrics: nil,
            views: views)
        for constraint in timerVerticalConstraints{
            constraint.identifier = "timerVerticalConstraints.timerMode"
        }
        timerConstraints += timerVerticalConstraints
        
        NSLayoutConstraint.activateConstraints(timerConstraints)
    }

    

    
    func addSettingsModeConstraintsToIntervalView() {
        
        if timerConstraints.count != 0 {
            NSLayoutConstraint.deactivateConstraints(timerConstraints)
        }
        
        timerConstraints.removeAll()
        settingsConstraints.removeAll()
        
        let views = ["timerView": displayedInterval]
        
        let timerHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-75-[timerView]-75-|",
            options: [],
            metrics: nil,
            views: views)
        for constraint in timerHorizontalConstraints{
            constraint.identifier = "intervalHorizontalConstraints.settingsMode"
        }
        settingsConstraints += timerHorizontalConstraints
        
        let timerVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-65-[timerView]-45-|",
            options: [],
            metrics: nil,
            views: views)
        for constraint in timerVerticalConstraints{
            constraint.identifier = "intervalVerticalConstraints.settingsMode"
        }
        settingsConstraints += timerVerticalConstraints
        
        NSLayoutConstraint.activateConstraints(settingsConstraints)
    }
    
    func addTimerModeConstraintsToIntervalView() {
        
        if settingsConstraints.count != 0 {
            NSLayoutConstraint.deactivateConstraints(settingsConstraints)
        }
        
        timerConstraints.removeAll()
        settingsConstraints.removeAll()
        
        let views = ["timerView": displayedInterval]
        
        let timerHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-0-[timerView]-0-|",
            options: [],
            metrics: nil,
            views: views)
        for constraint in timerHorizontalConstraints{
            constraint.identifier = "intervalHorizontalConstraints.timerMode"
        }
        timerConstraints += timerHorizontalConstraints
        
        let timerVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-0-[timerView]-0-|",
            options: [],
            metrics: nil,
            views: views)
        for constraint in timerVerticalConstraints{
            constraint.identifier = "intervalVerticalConstraints.timerMode"
        }
        timerConstraints += timerVerticalConstraints
        
        NSLayoutConstraint.activateConstraints(timerConstraints)
    }
    
    
    
    
    
    //MARK: - Carousel Delegate and Datasoure Methods
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        return timers.count + intervalTimers.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        
        if index < timers.count {
            return timerViews[index]
        } else {
            return intervalViews[index - timers.count]
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
        if isPro == true {
            return 100.0
        } else {
            return 190.0
        }
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        
        if carousel.currentItemIndex < timers.count {
            
            timer = timers[carousel.currentItemIndex]
            
            //update sound buttons
            //clear previously highlighted buttons
            for i in (200...205) {
                let button = self.view.viewWithTag(i) as? UIButton
                button?.imageView?.image = soundButtonImages[i-200]
            }
            
            highlightCorrectSoundButtonForTimer(timer)
            
            timerTitleTextField.text = timer.name
            
            alarmRepeatLabel.text = "\(timer.alarmRepetitions)"
            timerRepeatLabel.text = "\(timer.timerRepetitions)"
        } else {
            
            intervalTimer = intervalTimers[carousel.currentItemIndex - timers.count]
            
            timerTitleTextField.text = intervalTimer.name
            
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //MARK: - Keyboard dismissal
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        //update defaults
        TTDefaultsHelper.saveTimers(timers)
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        timer.name = timerTitleTextField.text!
    }
    
    //MARK: - Segue Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowProFeaturesSegue"{
            if let vc = segue.destinationViewController as? UpgradeToProViewController {
                vc.delegate = self
            }
        }
    }
    
}


