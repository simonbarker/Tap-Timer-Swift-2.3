//
//  TTDefaultsHelper.swift
//  Tap Timer
//
//  Created by Simon Barker on 05/08/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import Foundation

class TTDefaultsHelper: NSObject {
    
    static func checkIfPro() -> Bool {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let isPro = defaults.objectForKey("isPro") as? Bool {
            print("isPro = \(isPro)")
            return isPro
        }
        
        return false
        
    }
    
    static func upgradeToPro() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(true, forKey: "isPro")
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
    
}

