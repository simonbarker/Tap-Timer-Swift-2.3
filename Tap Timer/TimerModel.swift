//
//  TimerModel.swift
//  Tap Timer
//
//  Created by Simon Barker on 12/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import Foundation

enum AlertNoise {
    case SchoolBell
    case DogBark
}

class TimerModel: NSObject {
    
    var name: String
    var active: Bool
    var paused: Bool
    var duration: Int
    var remainingWhenPaused: Int?
    var timerEndTime: NSDate?
    var timerStartTime: NSDate?
    var audioAlert: AlertNoise
    
    init(withName name: String, duration: Int) {
        self.name = name
        self.active = false
        self.paused = false
        self.duration = duration
        self.audioAlert = AlertNoise.SchoolBell
        super.init()
    }
    
    convenience override init() {
        self.init(withName: "Timer", duration: 10)
    }
    
    func resetTimer() {
        active = false
        paused = false
    }
    
    func percentageThroughTimer() -> Double {
        
        guard let timerEnd = timerEndTime as NSDate! else {
            print("No timerEndTimer set")
            return 0.0
        }
        
        let timeRemaing = timerEnd.timeIntervalSinceNow
        
        return timeRemaing/Double(duration)
    }
    
    func timeFromEndTime() -> Int {
        
        guard let timerEnd = timerEndTime as NSDate! else {
            print("No timerEndTimer set")
            return 0
        }
        
        let timeRemaing = timerEnd.timeIntervalSinceNow
        
        return Int(timeRemaing)
    }
    
    func setPausedRemaining() {
        
        guard let timerEnd = timerEndTime as NSDate! else {
            print("No timerEndTimer set")
            return
        }
        
        remainingWhenPaused = Int(timerEnd.timeIntervalSinceNow)
    }
    
    func alertAudio() -> (String, String){
        switch audioAlert {
        case .SchoolBell:
            return ("School Bell", "mp3")
        case .DogBark:
            return ("Dog Bark", "mp3")
        }
    }
    
}