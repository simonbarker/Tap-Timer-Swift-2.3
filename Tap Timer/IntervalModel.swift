//
//  IntervalModel.swift
//  Tap Timer
//
//  Created by Simon Barker on 25/08/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit

protocol intervalProtocol {
    func intervalTimerFired(interval: IntervalModel, timer: TimerModel)
    func intervalTimerEnded(interval: IntervalModel, timer: TimerModel)
}

class IntervalModel: NSObject, timerProtocol {
    
    var name: String
    var timer1: TimerModel
    var timer2: TimerModel
    var currentActiveTimer: TimerModel
    var active: Bool
    var paused: Bool
    var intervalRepetitions: Int
    var currentIntervalRepetition: Int
    var delegate: intervalProtocol? = nil
    
    init(withName name: String, timer1: TimerModel, timer2: TimerModel, intervalRepetitions: Int) {
        self.name = name
        self.timer1 = timer1
        self.timer2 = timer2
        self.intervalRepetitions = intervalRepetitions
        self.currentIntervalRepetition = 0
        self.currentActiveTimer = self.timer1
        self.active = false
        self.paused = false
        
        super.init()
        
        timer1.delegate = self
        timer2.delegate = self
        
    }
    
    // MARK: NSCoding
    required convenience init? (coder decoder: NSCoder) {
        print("in interval init coder")
        guard let name = decoder.decodeObjectForKey("name") as? String
            else {
                print("init coder name guard failed")
                return nil
        }
        guard let timer1 = decoder.decodeObjectForKey("timer1") as? TimerModel
            else {
                print("init coder timer1 guard failed")
                return nil
        }
        guard let timer2 = decoder.decodeObjectForKey("timer2") as? TimerModel
            else {
                print("init coder timer2 guard failed")
                return nil
        }
        guard let intervalRepetitions = decoder.decodeObjectForKey("intervalRepetitions") as? Int
            else {
                print("init coder intervalRepetitions guard failed")
                return nil
        }
        
        print("initCoder Interval guards passed, initing timer")
        
        self.init(withName: name, timer1: timer1, timer2: timer2, intervalRepetitions: intervalRepetitions)
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.timer1, forKey: "timer1")
        coder.encodeObject(self.timer2, forKey: "timer2")
        coder.encodeObject(self.intervalRepetitions, forKey: "intervalRepetitions")
    }
    
    func startIntervalTimer() {
        print("Starting timer1")
        currentActiveTimer.start()
    }
    
    
    //MARK: - Timer protocol delegate methods
    func timerFired(timer: TimerModel) {
        
        self.delegate?.intervalTimerFired(self, timer: timer)
        
    }
    
    func timerEnded(timer: TimerModel) {
        
        print("timer ended")
        currentActiveTimer.reset()
        if currentActiveTimer == timer1 {
            //need to run timer2
            currentActiveTimer = timer2
            currentActiveTimer.start()
        } else if currentActiveTimer == timer2 {
            //need to check if this is the final one
            if currentIntervalRepetition != intervalRepetitions {
                currentActiveTimer = timer1
                currentActiveTimer.start()
            } else {
                currentIntervalRepetition = 0
            }
        }
        
    }
    
    
    
}
