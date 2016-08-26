//
//  CreateIntervalTimerViewController.swift
//  Tap Timer
//
//  Created by Simon Barker on 18/08/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit
import iCarousel

class CreateIntervalTimerViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {

    @IBOutlet var carousel1: iCarousel!
    @IBOutlet var carousel2: iCarousel!
    @IBOutlet var timer1Sound: UIImageView!
    @IBOutlet var timer2Sound: UIImageView!
    
    var timers = [TimerModel]()
    var timerViews = [TimerView]()
    
    var timers2 = [TimerModel]()
    var timerViews2 = [TimerView]()
    
    var timer1 = TimerModel()
    var timer2 = TimerModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Helper.addBackgroundGradient(self.view)
        
        timers = TTDefaultsHelper.getSavedTimers()
        timers2 = TTDefaultsHelper.getSavedTimers()
        timer1 = timers[0]
        timer2 = timers2[0]
        
        timerViews = createTimerViewsForTimers(timers)
        timerViews2 = createTimerViewsForTimers(timers2)
        
        setSoundIconForTimer(timer1, image: timer1Sound)
        setSoundIconForTimer(timer2, image: timer2Sound)
        
        setupCarousel(carousel1)
        setupCarousel(carousel2)
        
    }

    func setupCarousel(carousel: iCarousel) {
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .CoverFlow
        carousel.bounces = false
        carousel.clipsToBounds = true
    }
    
    func createTimerViewsForTimers(timers: [TimerModel]) -> [TimerView] {
        
        var tempTimerViews = [TimerView]()
        
        let phoneType = Helper.detectPhoneScreenSize()
        
        for t in timers {
            let tView = TimerView.init()
            
            if phoneType == "4" {
                tView.frame = CGRect(x: 0, y: 0, width: 100, height: 160)
            } else if phoneType == "5" {
                tView.frame = CGRect(x: 0, y: 0, width: 100, height: 160)
            } else if phoneType == "6" {
                tView.frame = CGRect(x: 0, y: 0, width: 100, height: 190)
            } else { //6+
                tView.frame = CGRect(x: 0, y: 0, width: 125, height: 260)
            }
            
            let colors = t.getColorScheme()
            tView.setColorScheme(colorLight: colors["lightColor"]!, colorDark: colors["darkColor"]!)
            tView.setTimeRemainingLabel(t.duration)
            tView.setCountDownBarFromPercentage(1)
            tView.layer.zPosition = 100 //make sure the timer view sits on top of the settings panel
            tView.timerLabel.hidden = false
            tView.timerLabel.font = tView.timerLabel.font.fontWithSize(20.0)
            tView.timerRepetitionLabel.hidden = true
            
            tempTimerViews.append(tView)
        }
        
        return tempTimerViews
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
    
    @IBAction func saveTapped(sender: AnyObject) {
        
        //make sure timers are set as vanilla single run timers
        timer1.alarmRepetitions = 0
        timer1.timerRepetitions = 1
        timer2.alarmRepetitions = 0
        timer2.timerRepetitions = 1
        
        TTDefaultsHelper.createIntervalWithTimers(timer1, timer2: timer2)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    //MARK: - Carousel Delegate and Datasoure Methods
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        return timers.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        if carousel == carousel1{
            return timerViews[index]
        } else {
            return timerViews2[index]
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
        return 100.0
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        if carousel == carousel1 {
        
            timer1 = timers[carousel.currentItemIndex]
            setSoundIconForTimer(timer1, image: timer1Sound)
        
        } else {
            
            timer2 = timers[carousel.currentItemIndex]
            setSoundIconForTimer(timer2, image: timer2Sound)
            
        }
    }
    
    func setSoundIconForTimer(timer: TimerModel, image: UIImageView) {
        switch timer.audioAlert {
        case .Alien:
            image.image = UIImage(named: "Alien")
        case .BoxingBell:
            image.image = UIImage(named: "Boxing bell")
        case .Car:
            image.image = UIImage(named: "Car")
        case .ChurchBell:
            image.image = UIImage(named: "Bell")
        case .DogBark:
            image.image = UIImage(named: "Dog")
        case .Horn:
            image.image = UIImage(named: "Horn")
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }


}
