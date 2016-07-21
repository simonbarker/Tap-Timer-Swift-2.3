//
//  TimerModel.swift
//  Tap Timer
//
//  Created by Simon Barker on 12/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

enum AlertNoise {
    case SchoolBell
    case DogBark
    case BoxingBell
    case Horn
    case Alien
    case Car
}

enum BaseColor {
    case SkyBlue
    case Red
    case Purple
    case Yellow
    case Green
    case Gray
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
    var UUID: String
    var colorScheme: BaseColor
    
    init(withName name: String, duration: Int, UUID: String, color: BaseColor) {
        self.name = name
        self.active = false
        self.paused = false
        self.duration = duration
        self.UUID = UUID
        self.audioAlert = AlertNoise.SchoolBell
        self.colorScheme = color
        super.init()
    }
    
    convenience override init() {
        self.init(withName: "Tap Timer 1", duration: 10, UUID: NSUUID().UUIDString, color: .Red)
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
            return ("Car Horn", "mp3")
        case .BoxingBell:
            return ("School Bell", "mp3")
        case .Horn:
            return ("Car Horn", "mp3")
        case .Alien:
            return ("School Bell", "mp3")
        case .Car:
            return ("Car Horn", "mp3")
        }
    }
    
    func getColorScheme() -> [String : UIColor] {
        switch colorScheme {
        case .SkyBlue:
            return ["lightColor": UIColor.flatSkyBlueColor(), "darkColor": UIColor.flatSkyBlueColorDark()]
        case .Purple:
            return ["lightColor": UIColor.flatPurpleColor(), "darkColor": UIColor.flatPurpleColorDark()]
        case .Red:
            return ["lightColor": UIColor.flatRedColor(), "darkColor": UIColor.flatRedColorDark()]
        case .Yellow:
            return ["lightColor": UIColor.flatYellowColor(), "darkColor": UIColor.flatYellowColorDark()]
        case .Green:
            return ["lightColor": UIColor.flatGreenColor(), "darkColor": UIColor.flatGreenColorDark()]
        case .Gray:
            return ["lightColor": UIColor.flatGrayColor(), "darkColor": UIColor.flatGrayColorDark()]
        }
    }
    
}