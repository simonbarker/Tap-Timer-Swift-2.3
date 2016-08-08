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
    static let isPro = DefaultsKey<Bool>("isPro")
}

class TTDefaultsHelper: NSObject {
    
    static func checkIfPro() -> Bool {
        
        return false
        
    }

}