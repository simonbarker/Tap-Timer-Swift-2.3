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
    
}

