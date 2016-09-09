//
//  ViewController.swift
//  Tap Timer
//
//  Created by Simon Barker on 12/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit
import iCarousel
import AVFoundation

class ViewController: UIViewController, timerProtocol, proUpgradeDelegate, intervalProtocol, intervalTimerCreationDelegate {
    
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
    var addViews = [UIView]()
    
    var keyboardManager: KeyboardManager!
    var carouselDelegate: CarouselDelegate!
    
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
    
    var timerSetTimer = NSTimer()
    var timerBeingSet = false
    var dot = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initial view set up
        Helper.addBackgroundGradient(self.view)
        
        createTimers()
        
        createIntervalTimers()
        
        if isPro == true {
            createAddTimerPanel()
        }
        
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
        
        keyboardManager = KeyboardManager(withViewController: self)
        
        //instantiate first timer
        timer = timers[0]
        timerTitleTextField.text = timer.name
        timerTitleTextField.delegate = keyboardManager
        alarmRepeatLabel.text = "\(timer.alarmRepetitions)"
        timerRepeatLabel.text = "\(timer.timerRepetitions)"
        
        //grab original images from sound UIButton
        for i in (200...205) {
            let button = self.view.viewWithTag(i) as? UIButton
            soundButtonImages.append((button!.imageView?.image)!)
        }
        
        //highlight correct sound
        highlightCorrectSoundButtonForTimer(timer)
        
        carouselDelegate = CarouselDelegate.init(withViewController: self)
        carousel.delegate = carouselDelegate
        carousel.dataSource = carouselDelegate
        carousel.type = .CoverFlow
        carousel.bounces = false
        carousel.clipsToBounds = true
        
        settingsMode = true
    }
    
    func createTimers() {
        
        //look for timers in NSUserDefaults
        let savedTimers = TTDefaultsHelper.getSavedTimers()
        
        if savedTimers.count == 0 {
            //if no timers in defaults then create and save them
                
            let t = TimerModel.init(withName: "Tap Timer", duration: 10, UUID: NSUUID().UUIDString, color: BaseColor.SkyBlue, alertNoise: AlertNoise.ChurchBell, timerRepetitions: 1, alarmRepetitions: 1)
            t.delegate = self
            timers.append(t)
            
            TTDefaultsHelper.saveTimers(timers)
            
        } else {
            //if there are timers in defaults then load them up
            timers = savedTimers
        }
        
        //have timers so just make the views
        for t in timers {
            
            t.delegate = self
            let tView = TimerView.init()
            
            tView.frame = Helper.frameSizeFor(isPro, singleOrDoubleCarousel: "single")
            
            let colors = t.getColorScheme()
            tView.setColorScheme(colorLight: colors["lightColor"]!, colorDark: colors["darkColor"]!)
            tView.setTimeRemainingLabel(t.duration)
            tView.setCountDownBarFromPercentage(1)
            tView.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
            tView.timerLabel.hidden = false
            tView.timerLabel.font = tView.timerLabel.font.fontWithSize(20.0)
            tView.timerRepetitionLabel.text = "0 / \(t.timerRepetitions)"
            tView.timerRepetitionLabel.font = tView.timerRepetitionLabel.font.fontWithSize(10.0)
            
            //set up gesture recognisers for timer
            let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchDetected(_:)))
            let swipeGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(self.deleteTimer(_:)))
            swipeGestureRecogniser.direction = .Up
            
            tView.addGestureRecognizer(pinchGestureRecogniser)
            tView.addGestureRecognizer(swipeGestureRecogniser)
            
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
                
                let iView = IntervalView.init()
                
                iView.frame = Helper.frameSizeFor(true, singleOrDoubleCarousel: "single")
            
                
                let colors1 = timer1.getColorScheme()
                iView.timer1View.setColorScheme(colorLight: colors1["lightColor"]!, colorDark: colors1["darkColor"]!)
                iView.timer1View.setTimeRemainingLabel(timer1.duration)
                iView.timer1View.setCountDownBarFromPercentage(1)
                iView.timer1View.timerLabel.hidden = false
                iView.timer1View.timerLabel.font = iView.timer1View.timerLabel.font.fontWithSize(20.0)
                iView.timer1View.dropshadow(false)
                iView.timer1View.timerRepetitionLabel.hidden = true
                
                let colors2 = timer2.getColorScheme()
                iView.timer2View.setColorScheme(colorLight: colors2["lightColor"]!, colorDark: colors2["darkColor"]!)
                iView.timer2View.setTimeRemainingLabel(timer2.duration)
                iView.timer2View.setCountDownBarFromPercentage(1)
                iView.timer2View.timerLabel.hidden = false
                iView.timer2View.timerLabel.font = iView.timer2View.timerLabel.font.fontWithSize(20.0)
                iView.timer2View.dropshadow(false)
                iView.timer2View.timerRepetitionLabel.hidden = true
                
                iView.intervalCounterLabel.text = "\(i.currentIntervalRepetition) / \(i.intervalRepetitions)"
                iView.intervalCounterLabel.font = iView.intervalCounterLabel.font.fontWithSize(10.0)
                iView.layer.zPosition = 100 //make sure the interval timer view sits on top of the settings panel
                
                //set up gesture recognisers for timer
                let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(self.intervalTimerPinchDetected(_:)))
                let swipeGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(self.deleteTimer(_:)))
                swipeGestureRecogniser.direction = .Up
                
                iView.addGestureRecognizer(pinchGestureRecogniser)
                iView.addGestureRecognizer(swipeGestureRecogniser)
                
                iView.timer1View.translatesAutoresizingMaskIntoConstraints = false
                iView.timer2View.translatesAutoresizingMaskIntoConstraints = false
                
                intervalViews.append(iView)
                
                
            }
            
        }
        
    }
    
    func createAddTimerPanel() {
        
        let addView = UIView()
        
        addView.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "addTimerButton")
        let imageView = UIImageView(image: image)
        
        addView.frame = Helper.frameSizeFor(true, singleOrDoubleCarousel: "single")
        
        imageView.frame = CGRect(x: (addView.frame.width/2)-25, y: (addView.frame.height/2)-25, width: 50, height: 50)
        addView.addSubview(imageView)
        
        let tapGestureRecogniser = UITapGestureRecognizer.init(target: self, action: #selector(self.addNewTimer(_:)))
        addView.addGestureRecognizer(tapGestureRecogniser)
        
        addViews.append(addView)
        
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
                        displayedTimer.timerRepetitionLabel.text = "\(timer.currentTimerRepetition) / \(timer.timerRepetitions)"
                        
                    } else if timer.active == false && timer.paused == true {
                        
                        //start timer
                        timer.restart()

                    } else {
                        
                        //pause timer
                        timer.pause()
                        
                    }
                }
            } else if sender.view == displayedInterval {
                
                if intervalTimer.audioPlaying() == true {
                    intervalTimer.stopAudio()
                } else {
                    
                    if intervalTimer.active == false && intervalTimer.paused == false {
                        
                        //start timer
                        intervalTimer.start()
                        displayedInterval.intervalCounterLabel.text = "\(intervalTimer.currentIntervalRepetition) / \(intervalTimer.intervalRepetitions)"
                        
                        //Helper.registerTimerNotification(intervalTimer.currentActiveTimer)
                        
                    } else if intervalTimer.active == false && intervalTimer.paused == true {
                        
                        //start timer
                        intervalTimer.restart()
                        
                        //Helper.registerTimerNotification(intervalTimer.currentActiveTimer)
                        
                        
                    } else {
                        
                        //pause timer
                        intervalTimer.pause()
                        
                        //remove notification
                        //Helper.removeNotificationFromSchedule(intervalTimer.currentActiveTimer)
                        
                    }
                }
                
                
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
                
                guard let index = timers.indexOf(timer) else {
                    print("Index of timer not found")
                    return
                }
                timerViews[index].reset()
                timerViews[index].setTimeRemainingLabel(timer.duration)
                timerViews[index].timerRepetitionLabel.text = "0 / \(timer.timerRepetitions)"
                displayedTimer.timerRepetitionLabel.text = timerViews[index].timerRepetitionLabel.text
                
                
            } else if sender.view == displayedInterval {
                
                //reset interval
                intervalTimer.clearInterval()
                displayedInterval.timer1View.setTimeRemainingLabel(intervalTimer.timer1.duration)
                displayedInterval.timer1View.reset()
                displayedInterval.timer2View.setTimeRemainingLabel(intervalTimer.timer2.duration)
                displayedInterval.timer2View.reset()
                displayedInterval.intervalCounterLabel.text = "\(intervalTimer.currentIntervalRepetition) / \(intervalTimer.intervalRepetitions)"
                
                //remove notification
                //Helper.removeNotificationFromSchedule(timer)
                
                guard let index = intervalTimers.indexOf(intervalTimer) else {
                    print("Index of timer not found")
                    return
                }
                
                intervalViews[index].timer1View.setTimeRemainingLabel(intervalTimer.timer1.duration)
                intervalViews[index].timer1View.reset()
                intervalViews[index].timer2View.setTimeRemainingLabel(intervalTimer.timer2.duration)
                intervalViews[index].timer2View.reset()
                intervalViews[index].intervalCounterLabel.text = "\(intervalTimer.currentIntervalRepetition) / \(intervalTimer.intervalRepetitions)"
                
            }
        }
        
    }
    
    func panDetected(pan: UIPanGestureRecognizer) {
        
        if settingsMode == false {
            
            let pt = pan.translationInView(self.view)
            
            switch (pan.state) {
            case .Began:
                self.draggingStart()
                break
            case .Changed:
                dot.center = CGPointMake(self.view.frame.width - dot.frame.width/2, self.view.center.y + pt.y)
                break
            case .Ended:
                self.draggingEnded()
                break
            default:
                break
            }
        }
        
    }
    
    func draggingStart() {
        self.timerBeingSet = true
    }
    
    func draggingEnded() {
        self.timerBeingSet = false
        UIView.animateWithDuration(0.2) {
            self.dot.center = CGPointMake(self.view.frame.width - self.dot.frame.width/2, self.view.center.y)
        }
    }
    
    func timerSetTimerFired() {
        if (self.timerBeingSet) {

            let distance = self.dot.center.y - self.view.center.y
            
            if distance < 50 && distance > -50 {
                
                timerSetTimer.invalidate()
                timerSetTimer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(self.timerSetTimerFired), userInfo: nil, repeats: true)
                
            } else {
                
                timerSetTimer.invalidate()
                timerSetTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(self.timerSetTimerFired), userInfo: nil, repeats: true)

            }
            
            var distance2 = distance * distance
            
            if distance < 0 {
                distance2 *= -1
            }
            
            let deltaD = Int(round(0.0025 * (distance2)))
            
            timer.duration -= deltaD
            
            if timer.duration < 0 {
                timer.duration = 0
            }
            timer.clearTimer()
            displayedTimer.reset()
            displayedTimer.setTimeRemainingLabel(timer.duration)
            
            TTDefaultsHelper.saveTimers(timers)
            
            guard let index = timers.indexOf(timer) else {
                print("Index of timer not found")
                return
            }
            
            timerViews[index].setTimeRemainingLabel(timer.duration)

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
    
    func deleteTimer(sender: UISwipeGestureRecognizer) {
        if sender.state == .Ended {
            
            if self.timers.count > 1 {
                let deleteTimerConfirmation = UIAlertController(title: "Delete Timer", message: "Are you sure you want to delete this timer?", preferredStyle: UIAlertControllerStyle.Alert)
                
                deleteTimerConfirmation.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                   
                    var index = self.carousel.currentItemIndex
                    
                    //workout if we are swiping a timer or interval
                    if self.carousel.currentItemIndex < self.timers.count {
                        if self.timers.count > 1 {
                            self.timers.removeAtIndex(index)
                            self.timerViews.removeAtIndex(index)
                        }
                    } else {
                        self.intervalTimers.removeAtIndex(index - self.timers.count)
                        self.intervalViews.removeAtIndex(index - self.timers.count)
                    }
                    
                    TTDefaultsHelper.saveTimers(self.timers)
                    TTDefaultsHelper.saveIntervalTimers(self.intervalTimers)
                    
                    self.carousel.reloadData()
                    
                    if index == 0 {
                        index = 1
                    }
                    
                    self.carousel.scrollToItemAtIndex(index-1, animated: true)
                    
                    //clear previously highlighted buttons
                    for i in (200...205) {
                        let button = self.view.viewWithTag(i) as? UIButton
                        button?.imageView?.image = self.soundButtonImages[i-200]
                    }
                    
                    self.highlightCorrectSoundButtonForTimer(self.timer)
                    
                }))
                
                deleteTimerConfirmation.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                    
                }))
                presentViewController(deleteTimerConfirmation, animated: true, completion: nil)

            } else {
                if isPro {
                    Helper.displayAlert("Can't Delete Timer", message: "You can't delete the only timer left", viewController: self)
                }
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
    
    func addNewTimer(sender: UITapGestureRecognizer) {
        
        let newTimer = TimerModel.init(withName: "New Tap Timer", duration: 10, UUID: NSUUID().UUIDString, color: BaseColor.SkyBlue, alertNoise: AlertNoise.ChurchBell, timerRepetitions: 1, alarmRepetitions: 1)
        newTimer.delegate = self
        timers.append(newTimer)
        
        
        let tView = TimerView.init()
        
        tView.frame = Helper.frameSizeFor(true, singleOrDoubleCarousel: "single")
        
        let colors = newTimer.getColorScheme()
        tView.setColorScheme(colorLight: colors["lightColor"]!, colorDark: colors["darkColor"]!)
        tView.setTimeRemainingLabel(newTimer.duration)
        tView.setCountDownBarFromPercentage(1)
        tView.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
        tView.timerLabel.hidden = false
        tView.timerLabel.font = tView.timerLabel.font.fontWithSize(20.0)
        tView.timerRepetitionLabel.text = "0 / \(newTimer.timerRepetitions)"
        tView.timerRepetitionLabel.font = tView.timerRepetitionLabel.font.fontWithSize(10.0)
        
        //set up gesture recognisers for timer
        let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchDetected(_:)))
        let swipeGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(self.deleteTimer(_:)))
        swipeGestureRecogniser.direction = .Up
        
        tView.addGestureRecognizer(pinchGestureRecogniser)
        tView.addGestureRecognizer(swipeGestureRecogniser)
        
        timerViews.append(tView)
        
        timer = newTimer
        
        TTDefaultsHelper.saveTimers(timers)
        
        carousel.reloadData()
        
        self.carousel.scrollToItemAtIndex(carousel.numberOfItems-1, animated: false)
        
        self.carousel.scrollToItemAtIndex(carousel.numberOfItems-2, animated: true)
        
        //setUIforTimerSettings()
        
    }
    
    //MARK: - Toggle view mode between settings and timer
    func changeViewModeTo(mode: String){
        
        if mode == "settings" && settingsMode != true {
            addSettingsModeConstraintsToTimerView()
            timerSetTimer.invalidate()
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
            displayedTimer.timerRepetitionLabel.text = "0 / \(timer.timerRepetitions)"
            displayedTimer.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
            
            let triangleBase: CGFloat = 25
            let triangleHeight: CGFloat = 45
            
            dot = TriangleView(frame: CGRectMake(self.view.frame.width - triangleHeight, self.view.frame.height/2 - triangleBase/2, triangleHeight, triangleBase))
            dot.layer.zPosition = 102
            dot.alpha = 0.3
            displayedTimer.addSubview(dot)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panDetected(_:)))
            
            dot.addGestureRecognizer(pan)
            
            timerSetTimer = NSTimer.scheduledTimerWithTimeInterval(0.20, target: self, selector: #selector(self.timerSetTimerFired), userInfo: nil, repeats: true)
            
            //set up gesture recognisers for timer
            let singleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.singleTapDetected(_:)))
            singleTapGestureRecogniser.numberOfTapsRequired = 1
            
            let doubleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapDetected(_:)))
            doubleTapGestureRecogniser.numberOfTapsRequired = 2
            singleTapGestureRecogniser.requireGestureRecognizerToFail(doubleTapGestureRecogniser)
            //let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(self.panDetected(_:)))
            //panGestureRecogniser.minimumNumberOfTouches = 2
            let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchDetected(_:)))
            
            displayedTimer.addGestureRecognizer(singleTapGestureRecogniser)
            displayedTimer.addGestureRecognizer(doubleTapGestureRecogniser)
            //displayedTimer.addGestureRecognizer(panGestureRecogniser)
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
            
            guard let index = timers.indexOf(timer) else {
                print("Index of timer object not found in timers array")
                return
            }
            
            timerViews[index].setCountDownBarFromPercentage(timer.percentageThroughTimer())
        }
        if mode == "intervalTimer" && settingsMode != false {
            
            print("In change to interval Timer mode")
            
            displayedInterval = IntervalView.init()
            self.displayedInterval.translatesAutoresizingMaskIntoConstraints = false
            displayedInterval.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
            let colors1 = intervalTimer.timer1.getColorScheme()
            displayedInterval.timer1View.setColorScheme(colorLight: colors1["lightColor"]!, colorDark: colors1["darkColor"]!)
            displayedInterval.timer1View.setTimeRemainingLabel(intervalTimer.timer1.timeToDisplay())
            displayedInterval.timer1View.timerLabel.hidden = false
            displayedInterval.timer1View.dropshadow(false)
            displayedInterval.timer1View.timerRepetitionLabel.hidden = true
            
            let colors2 = intervalTimer.timer2.getColorScheme()
            displayedInterval.timer2View.setColorScheme(colorLight: colors2["lightColor"]!, colorDark: colors2["darkColor"]!)
            displayedInterval.timer2View.setTimeRemainingLabel(intervalTimer.timer2.timeToDisplay())
            displayedInterval.timer2View.timerLabel.hidden = false
            displayedInterval.timer2View.dropshadow(false)
            displayedInterval.timer2View.timerRepetitionLabel.hidden = true
            
            displayedInterval.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
            displayedInterval.intervalCounterLabel.text = "\(intervalTimer.currentIntervalRepetition) / \(intervalTimer.intervalRepetitions)"
            
            //set up gesture recognisers for interval
            let singleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.singleTapDetected(_:)))
            singleTapGestureRecogniser.numberOfTapsRequired = 1
            
            let doubleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapDetected(_:)))
            doubleTapGestureRecogniser.numberOfTapsRequired = 2
            singleTapGestureRecogniser.requireGestureRecognizerToFail(doubleTapGestureRecogniser)
            let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(self.intervalTimerPinchDetected(_:)))
            
            displayedInterval.addGestureRecognizer(singleTapGestureRecogniser)
            displayedInterval.addGestureRecognizer(doubleTapGestureRecogniser)
            displayedInterval.addGestureRecognizer(pinchGestureRecogniser)
            
            self.view.addSubview(displayedInterval)
            
            //make the view small before making it full screen so that is grows from the center of the screen
            addSettingsModeConstraintsToIntervalView()
            self.view.layoutIfNeeded()
            
            addTimerModeConstraintsToIntervalView()
            animatedLayoutIfNeeded(removeView: false)
            
            displayedInterval.timer1View.setCountDownBarFromPercentage(intervalTimer.timer1.percentageThroughTimer())
            displayedInterval.timer2View.setCountDownBarFromPercentage(intervalTimer.timer2.percentageThroughTimer())

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
        //make sure this only works for timers
        if settingsMode == true && carousel.currentItemIndex < (timers.count) {
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
            
            Helper.activateAudioSessionInMainThread()
            timer.loadAudio()
            timer.playAudio(0)//play audio once to indicate that it has been changed
            
            //update defaults
            TTDefaultsHelper.saveTimers(timers)
        }
    }
    
    @IBAction func alarmRepeatMinusTapped(sender: AnyObject) {
        //check if looking at interval or timer
        if carousel.currentItemIndex < timers.count {
            if timer.alarmRepetitions == 1 {
                return
            } else {
                timer.alarmRepetitions -= 1
                alarmRepeatLabel.text = "\(timer.alarmRepetitions)"
                //update defaults
                TTDefaultsHelper.saveTimers(timers)
            }
        } else {
            if intervalTimer.timer1.alarmRepetitions == 1 {
                return
            } else {
                intervalTimer.decreaseAlarmRepetitions()
                alarmRepeatLabel.text = "\(intervalTimer.timer1.alarmRepetitions)"
                TTDefaultsHelper.saveIntervalTimers(intervalTimers)
            }
        }
    }
    
    @IBAction func alarmRepeatPlusTapped(sender: AnyObject) {
        //check if looking at interval or timer
        if carousel.currentItemIndex < timers.count {
            if timer.alarmRepetitions == 10 {
                return
            } else {
                timer.alarmRepetitions += 1
                alarmRepeatLabel.text = "\(timer.alarmRepetitions)"
                //update defaults
                TTDefaultsHelper.saveTimers(timers)
            }
        } else {
            if intervalTimer.timer1.alarmRepetitions == 10 {
                return
            } else {
                intervalTimer.increaseAlarmRepetitions()
                alarmRepeatLabel.text = "\(intervalTimer.timer1.alarmRepetitions)"
                TTDefaultsHelper.saveIntervalTimers(intervalTimers)
            }
        }
    }
    
    @IBAction func timerRepeatMinusTapped(sender: AnyObject) {
        //check if looking at interval or timer
        if isPro {
            if carousel.currentItemIndex < timers.count {
                if timer.timerRepetitions == 1 {
                    return
                } else {
                    timer.timerRepetitions -= 1
                    updateLabelsForTimerRepetitions()
                }
            } else {
                if intervalTimer.intervalRepetitions == 1 {
                    return
                } else {
                    intervalTimer.intervalRepetitions -= 1
                    updateLabelsForIntervalRepetitions()
                }
            }
        } else {
            Helper.displayAlert("Pro Feature", message: "Timer repeat is one of our many pro feaatures", viewController: self)
        }
    }
    
    @IBAction func timerRepeatPlusTapped(sender: AnyObject) {
        if isPro {
            //check if looking at interval or timer
            if carousel.currentItemIndex < timers.count {
                if timer.timerRepetitions == 99 {
                    return
                } else {
                    timer.timerRepetitions += 1
                    updateLabelsForTimerRepetitions()
                }
            } else {
                if intervalTimer.intervalRepetitions == 99 {
                    return
                } else {
                    intervalTimer.intervalRepetitions += 1
                    updateLabelsForIntervalRepetitions()
                }
            }
        } else {
            Helper.displayAlert("Pro Feature", message: "Timer repeat is one of our many pro feaatures", viewController: self)
        }
    }
    
    func updateLabelsForTimerRepetitions() {
        timerRepeatLabel.text = "\(timer.timerRepetitions)"
        //update defaults
        TTDefaultsHelper.saveTimers(timers)
        
        guard let index = timers.indexOf(timer) else {
            print("Index of timer not found in timers")
            return
        }
        
        timerViews[index].timerRepetitionLabel.text = "\(timer.currentTimerRepetition) / \(timer.timerRepetitions)"
        
    }
    
    func updateLabelsForIntervalRepetitions() {
        timerRepeatLabel.text = "\(intervalTimer.intervalRepetitions)"
        //update defaults
        TTDefaultsHelper.saveIntervalTimers(intervalTimers)
        
        guard let index = intervalTimers.indexOf(intervalTimer) else {
            print("Index of interval not foud in timers")
            return
        }
        
        intervalViews[index].intervalCounterLabel.text = "\(intervalTimer.currentIntervalRepetition) / \(intervalTimer.intervalRepetitions)"
    }
    
    //MARK: - Timer protocol delegate methods
    func timerFired(timer: TimerModel) {
        
        guard let index = timers.indexOf(timer) else {
            print("Index of timer object not found in timers array")
            return
        }

        timerViews[index].setCountDownBarFromPercentage(timer.percentageThroughTimer())
        timerViews[index].setTimeRemainingLabel(timer.timeToDisplay())
        timerViews[index].timerRepetitionLabel.text = "\(timer.currentTimerRepetition) / \(timer.timerRepetitions)"
        
        //update displayed timer if this timer is the current timer
        if carousel.currentItemIndex == index {
            displayedTimer.setCountDownBarFromPercentage(timer.percentageThroughTimer())
            displayedTimer.setTimeRemainingLabel(timer.timeToDisplay())
            displayedTimer.timerRepetitionLabel.text = "\(timer.currentTimerRepetition) / \(timer.timerRepetitions)"
        }
        
    }
    
    func timerEnded(timer: TimerModel) {
        
        guard let index = timers.indexOf(timer) else {
            print("Index of timer object not found in timers array")
            return
        }
        
        timerViews[index].setTimeRemainingLabel(timer.duration)
        timerViews[index].reset()
        timerViews[index].timerRepetitionLabel.text = "\(timer.currentTimerRepetition) / \(timer.timerRepetitions)"
        
        //update displayed timer if this timer is the current timer
        if carousel.currentItemIndex == index {
            displayedTimer.setTimeRemainingLabel(timer.duration)
            displayedTimer.reset()
            displayedTimer.timerRepetitionLabel.text = "\(timer.currentTimerRepetition) / \(timer.timerRepetitions)"
        }
        
    }
    
    //MARK: - Interval protocol delegate methods
    func intervalTimerFired(interval: IntervalModel, timer: TimerModel) {
        guard let index = intervalTimers.indexOf(interval) else {
            print("Index of interval not found")
            return
        }
        
        intervalViews[index].intervalCounterLabel.text = "\(interval.currentIntervalRepetition) / \(interval.intervalRepetitions)"
        
        if timer == interval.timer1 {
            intervalViews[index].timer1View.setTimeRemainingLabel(timer.timeToDisplay())
            intervalViews[index].timer1View.setCountDownBarFromPercentage(timer.percentageThroughTimer())
            
            //update displayed timer if this timer is the current timer
            if carousel.currentItemIndex == index + timers.count {
                displayedInterval.timer1View.setCountDownBarFromPercentage(timer.percentageThroughTimer())
                displayedInterval.timer1View.setTimeRemainingLabel(timer.timeToDisplay())
            }
        } else {
            intervalViews[index].timer2View.setTimeRemainingLabel(timer.timeToDisplay())
            intervalViews[index].timer2View.setCountDownBarFromPercentage(timer.percentageThroughTimer())
            
            //update displayed timer if this timer is the current timer
            if carousel.currentItemIndex == index + timers.count {
                displayedInterval.timer2View.setCountDownBarFromPercentage(timer.percentageThroughTimer())
                displayedInterval.timer2View.setTimeRemainingLabel(timer.timeToDisplay())
            }
        }
        
    }
    
    func intervalTimerEnded(interval: IntervalModel, timer: TimerModel) {
        guard let index = intervalTimers.indexOf(interval) else {
            print("Index of interval not found")
            return
        }
        
        //only want to reset the view when timer 2 completes
        if timer == interval.timer2 {
            intervalViews[index].timer1View.setTimeRemainingLabel(interval.timer1.duration)
            intervalViews[index].timer1View.reset()
            intervalViews[index].timer2View.setTimeRemainingLabel(interval.timer2.duration)
            intervalViews[index].timer2View.reset()
            intervalViews[index].intervalCounterLabel.text = "\(interval.currentIntervalRepetition) / \(interval.intervalRepetitions)"
            
            //update displayed timer if this timer is the current timer
            if carousel.currentItemIndex == index + timers.count {
                displayedInterval.timer1View.setTimeRemainingLabel(interval.timer1.duration)
                displayedInterval.timer1View.reset()
                displayedInterval.timer2View.setTimeRemainingLabel(interval.timer2.duration)
                displayedInterval.timer2View.reset()
                displayedInterval.intervalCounterLabel.text = "\(interval.currentIntervalRepetition) / \(interval.intervalRepetitions)"
            }
        }
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
            createAddTimerPanel()
            carousel.reloadData()
        }
    }
    
    //MARK: - Created interval delegate methods
    func createdIntervalTimer(newIntervalTimer: IntervalModel) {
        
        intervalTimers.append(newIntervalTimer)
        
        newIntervalTimer.delegate = self
        
        let iView = IntervalView.init()
        
        iView.frame = Helper.frameSizeFor(isPro, singleOrDoubleCarousel: "single")
        
        let colors1 = newIntervalTimer.timer1.getColorScheme()
        iView.timer1View.setColorScheme(colorLight: colors1["lightColor"]!, colorDark: colors1["darkColor"]!)
        iView.timer1View.setTimeRemainingLabel(newIntervalTimer.timer1.duration)
        iView.timer1View.setCountDownBarFromPercentage(1)
        iView.timer1View.timerLabel.hidden = false
        iView.timer1View.timerLabel.font = iView.timer1View.timerLabel.font.fontWithSize(20.0)
        iView.timer1View.dropshadow(false)
        iView.timer1View.timerRepetitionLabel.hidden = true
        
        let colors2 = newIntervalTimer.timer2.getColorScheme()
        iView.timer2View.setColorScheme(colorLight: colors2["lightColor"]!, colorDark: colors2["darkColor"]!)
        iView.timer2View.setTimeRemainingLabel(newIntervalTimer.timer2.duration)
        iView.timer2View.setCountDownBarFromPercentage(1)
        iView.timer2View.timerLabel.hidden = false
        iView.timer2View.timerLabel.font = iView.timer2View.timerLabel.font.fontWithSize(20.0)
        iView.timer2View.dropshadow(false)
        iView.timer2View.timerRepetitionLabel.hidden = true
        
        iView.intervalCounterLabel.text = "\(newIntervalTimer.currentIntervalRepetition) / \(newIntervalTimer.intervalRepetitions)"
        iView.intervalCounterLabel.font = iView.intervalCounterLabel.font.fontWithSize(10.0)
        iView.layer.zPosition = 100 //make sure the interval timer view sits on top of the settings panel
        
        //set up gesture recognisers for timer
        let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(self.intervalTimerPinchDetected(_:)))
        let swipeGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(self.deleteTimer(_:)))
        swipeGestureRecogniser.direction = .Up
        
        iView.addGestureRecognizer(pinchGestureRecogniser)
        iView.addGestureRecognizer(swipeGestureRecogniser)
        
        iView.timer1View.translatesAutoresizingMaskIntoConstraints = false
        iView.timer2View.translatesAutoresizingMaskIntoConstraints = false
        
        intervalViews.append(iView)
        
        TTDefaultsHelper.saveIntervalTimers(intervalTimers)
        
        carousel.reloadData()
        
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
    
    //MARK: ui methods
    func setUIforTimerSettings() {
        timer = timers[carousel.currentItemIndex]
        
        //update sound buttons
        //clear previously highlighted buttons
        for i in (200...205) {
            let button = self.view.viewWithTag(i) as? UIButton
            button?.imageView?.image = soundButtonImages[i-200]
            button?.setImage(soundButtonImages[i-200], forState: .Normal)
            button?.setImage(soundButtonImages[i-200], forState: .Disabled)
            button?.enabled = true
        }
        //enable colour buttons
        for i in (100...105) {
            let button = self.view.viewWithTag(i) as? UIButton
            button?.enabled = true
        }
        
        highlightCorrectSoundButtonForTimer(timer)
        
        timerTitleTextField.text = timer.name
        
        alarmRepeatLabel.text = "\(timer.alarmRepetitions)"
        timerRepeatLabel.text = "\(timer.timerRepetitions)"
    }
    
    func disableAllSoundAndColourButtons() {
        //sound
        for i in (200...205) {
            let button = self.view.viewWithTag(i) as? UIButton
            button?.imageView?.image = soundButtonImages[i-200]
            button?.setImage(soundButtonImages[i-200], forState: .Normal)
            
            let origImage = button?.imageView?.image
            let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            button?.setImage(tintedImage, forState: .Disabled)
            
            button?.tintColor = UIColor.flatWhiteColorDark()
            
            button?.enabled = false
        }
        
        //colour
        for i in (100...105) {
            let button = self.view.viewWithTag(i) as? UIButton
            button?.enabled = false
        }
    }
    
    func enableRepetitionButtons() {
        for i in (300...303) {
            let button = self.view.viewWithTag(i) as? UIButton
            button?.enabled = true
        }
    }
    
    func disableRepetitionButtons() {
        for i in (300...303) {
            let button = self.view.viewWithTag(i) as? UIButton
            button?.enabled = false
        }
    }
    
    //MARK: - Segue Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowProFeaturesSegue"{
            if let vc = segue.destinationViewController as? UpgradeToProViewController {
                vc.delegate = self
            }
        }
        if segue.identifier == "showCreateIntervalSegue"{
            if let vc = segue.destinationViewController as? CreateIntervalTimerViewController {
                vc.delegate = self
            }
        }
    }
    
    //MARK: - Misc vc methods
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}


