//
//  TimerModel.swift
//  Tap Timer
//
//  Created by Simon Barker on 12/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import Foundation

class TimerModel: NSObject {
    
    var name: String
    var active: Bool
    var startTimeMilliSeconds: Int
    var currentTimeMilliSeconds: Int
    
    init(withName name: String, startTimeMilliSeconds: Int) {
        self.name = name
        self.active = false
        self.startTimeMilliSeconds = startTimeMilliSeconds
        self.currentTimeMilliSeconds = startTimeMilliSeconds
        super.init()
    }
    
    convenience override init() {
        self.init(withName: "Timer", startTimeMilliSeconds: 150000)
    }
    
    func resetTimer() {
        active = false
        currentTimeMilliSeconds = startTimeMilliSeconds
    }
    
    
    
}