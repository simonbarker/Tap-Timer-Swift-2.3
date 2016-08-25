//
//  TTDefaultsHelper.swift
//  Tap Timer
//
//  Created by Simon Barker on 05/08/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let launchCount = DefaultsKey<Int>("launchCount")
    static let isPro = DefaultsKey<Bool?>("isPro")
}

class TTDefaultsHelper: NSObject {
    
    static func checkIfPro() -> Bool {
        
        let pro = Defaults[.isPro]
        
        if pro == nil {
            print("TTDefaultsHelper isPro key doesn't exist")
            Defaults[.isPro] = false
            return false
        }
        
        //Defaults.remove(.isPro)
        return pro!
        
    }
    
    static func upgradeToPro() {
        Defaults[.isPro] = true
    }
    
    //MARK: - Timer Methods
    
    static func saveTimers(timers: [TimerModel]) {
        print("TTDefaultsHelper Saving timers")
        let savedData = NSKeyedArchiver.archivedDataWithRootObject(timers)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(savedData, forKey: "timers")
        
    }
    
    static func getSavedTimers() -> [TimerModel] {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let savedTimers = defaults.objectForKey("timers") as? NSData {
            print("TTDefaultsHelper found timers, returning timers")
            let timers = NSKeyedUnarchiver.unarchiveObjectWithData(savedTimers) as! [TimerModel]
            return timers
        }
        
        print("TTDefaultsHelper no timers found, returning empty timers")
        
        return [TimerModel]()
    }

    static func removeAllTimers() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.remove("timers")
    }
    
    //MARK: - Interval Timer Methods
    
    static func saveIntervalTimers(intervalTimers: [IntervalModel]) {
        print("TTDefaultsHelper Saving intervals")
        let savedData = NSKeyedArchiver.archivedDataWithRootObject(intervalTimers)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(savedData, forKey: "intervals")
    }
    
    static func getSavedIntervalTimers() -> [IntervalModel] {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let savedIntervalTimers = defaults.objectForKey("intervals") as? NSData {
            print("TTDefaultsHelper found interval timers, returning interval timers")
            let intervalTimers = NSKeyedUnarchiver.unarchiveObjectWithData(savedIntervalTimers) as! [IntervalModel]
            return intervalTimers
        }
        print("TTDefaultsHelper found no interval timers, returning empty timers")
        
        return [IntervalModel]()
    }
    
    static func createIntervalWithTimers(timer1: TimerModel, timer2: TimerModel) {
        var intervalTimers = getSavedIntervalTimers()
        
        let newIntervalTimer = IntervalModel(withName: "Interval Timer", timer1: timer1, timer2: timer2, intervalRepetitions: 1)
        
        intervalTimers.append(newIntervalTimer)
        
        saveIntervalTimers(intervalTimers)
        
    }
    
}

