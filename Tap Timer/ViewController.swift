//
//  ViewController.swift
//  Tap Timer
//
//  Created by Simon Barker on 12/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit
import iCarousel

class ViewController: UIViewController, timerProtocol, iCarouselDataSource, iCarouselDelegate, UITextFieldDelegate {
    
    @IBOutlet var carousel: iCarousel!
    
    @IBOutlet var carouselTopConstraint: NSLayoutConstraint!
    @IBOutlet var carouselBottomConstraint: NSLayoutConstraint!
    @IBOutlet var carouselTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var carouselLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var timerTitleTextField: UITextField!
    @IBOutlet var timerRepeatLabel: UILabel!
    
    var timers = [TimerModel]()
    var timerViews = [TimerView]()
    
    var settingsConstraints = [NSLayoutConstraint]()
    var timerConstraints = [NSLayoutConstraint]()

    var displayedTimer: TimerView!
    
    @IBOutlet var alarmRepeatLabel: UILabel!
    
    var timer: TimerModel!
    
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
        
        //grab original images from sound UIButton
        for i in (200...205) {
            let button = self.view.viewWithTag(i) as? UIButton
            soundButtonImages.append((button!.imageView?.image)!)
        }
        
        //highlight correct sound
        highlightCorrectSoundButtonForTimer(timer)
        
        //setup carousel
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
        
        for i in 0...(totalTimers - 1) {
            let t = TimerModel.init(withName: "Tap Timer \(i)", duration: 10, UUID: NSUUID().UUIDString, color: timerColorSchemes[i])
            t.alarmRepetitions = 1
            t.delegate = self
            timers.append(t)
            
            let tView = TimerView.init()
            if isPro == true {
                tView.frame = CGRect(x: 0, y: 0, width: 100, height: 190)
            } else {
                tView.frame = CGRect(x: 0, y: 0, width: 180, height: 342)
            }
            
            let colors = t.getColorScheme()
            tView.setColorScheme(colorLight: colors["lightColor"]!, colorDark: colors["darkColor"]!)
            tView.setTimeRemainingLabel(t.duration)
            tView.setCountDownBarFromPercentage(1)
            tView.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
            tView.timerLabel.hidden = true
            
            //set up gesture recognisers for timer
            let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchDetected(_:)))
            
            tView.addGestureRecognizer(pinchGestureRecogniser)
            
            timerViews.append(tView)
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
            timer.clearTimer()
            displayedTimer.reset()
            displayedTimer.setTimeRemainingLabel(timer.duration)
            
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
        
        if mode == "settings" && settingsMode != true {
            addSettingsModeConstraints()
            animatedLayoutIfNeeded(removeView: true)
            
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
            addSettingsModeConstraints()
            self.view.layoutIfNeeded()
            
            addTimerModeConstraints()
            animatedLayoutIfNeeded(removeView: false)
            
            displayedTimer.setCountDownBarFromPercentage(timer.percentageThroughTimer())
            
        }
        
    }
    
    func animatedLayoutIfNeeded(removeView removeView: Bool){
        UIView.animateWithDuration(0.3, delay: 0, options: [UIViewAnimationOptions.CurveEaseIn] , animations: {
            self.view.layoutIfNeeded()
        }) { (true) in
            if removeView == true {
                self.displayedTimer.removeFromSuperview()
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
    
    @IBAction func alarmRepeatMinusTapped(sender: AnyObject) {
        if timer.alarmRepetitions == 1 {
            return
        } else {
            timer.alarmRepetitions -= 1
            alarmRepeatLabel.text = "\(timer.alarmRepetitions)"
        }
    }
    
    @IBAction func alarmRepeatPlusTapped(sender: AnyObject) {
        if timer.alarmRepetitions == 10 {
            return
        } else {
            timer.alarmRepetitions += 1
            alarmRepeatLabel.text = "\(timer.alarmRepetitions)"
        }
    }
    
    @IBAction func timerRepeatMinusTapped(sender: AnyObject) {
        if timer.timerRepetitions == 0 {
            return
        } else {
            timer.timerRepetitions -= 1
            timerRepeatLabel.text = "\(timer.timerRepetitions)"
        }
    }
    
    @IBAction func timerRepeatPlusTapped(sender: AnyObject) {
        if timer.timerRepetitions == 99 {
            return
        } else {
            timer.timerRepetitions += 1
            timerRepeatLabel.text = "\(timer.timerRepetitions)"
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
    
    //MARK: - Layout Constraints
    func addSettingsModeConstraints() {
        
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
        settingsConstraints += timerHorizontalConstraints
        
        let timerVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-105-[timerView]-85-|",
            options: [],
            metrics: nil,
            views: views)
        settingsConstraints += timerVerticalConstraints
            
        NSLayoutConstraint.activateConstraints(settingsConstraints)
    }
    
    func addTimerModeConstraints() {
        
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
        timerConstraints += timerHorizontalConstraints
        
        let timerVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-0-[timerView]-0-|",
            options: [],
            metrics: nil,
            views: views)
        timerConstraints += timerVerticalConstraints
        
        NSLayoutConstraint.activateConstraints(timerConstraints)
    }

    //MARK: - Carousel Delegate and Datasoure Methods
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        return timers.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        return timerViews[index]
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            return value * 0.7
        }
        return value
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
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
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        timer.name = timerTitleTextField.text!
    }
    
    
}


