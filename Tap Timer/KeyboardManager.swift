//
//  KeyboardDelegate.swift
//  Tap Timer
//
//  Created by Simon Barker on 09/09/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import UIKit

class KeyboardManager: NSObject, UITextFieldDelegate {
    
    var viewController: ViewController!
    
    init(withViewController vc: ViewController) {
        self.viewController = vc
        
        super.init()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        //update defaults
        TTDefaultsHelper.saveTimers(viewController.timers)
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //workout if we changed to a timer or interval
        if viewController.carousel.currentItemIndex < viewController.timers.count {
            viewController.timer.name = viewController.timerTitleTextField.text!
        } else {
            viewController.intervalTimer.name = viewController.timerTitleTextField.text!
        }
    }
    
}
