//
//  Helper.swift
//  Tap Timer
//
//  Created by Simon Barker on 22/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class Helper: NSObject {
    
    static func displayAlert(title: String, message: String, viewController: UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
        }))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    static func addBackgroundGradient(view: UIView) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.whiteColor().CGColor, UIColor.blackColor().CGColor]
        gradient.opacity = 0.15
        view.layer.insertSublayer(gradient, atIndex: 0)
    
    }
    
    static func addButtonTint(button: UIButton, timerColorScheme: [String : UIColor]) {
        let origImage = button.imageView?.image
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        button.setImage(tintedImage, forState: .Normal)
        
        button.tintColor = timerColorScheme["lightColor"]!
    }
    
    //MARK: - Notification methods
    static func registerTimerNotification(timer: TimerModel){
        //register local notificaton
        let notification = UILocalNotification()
        notification.alertBody = "\(timer.name) done!"
        notification.alertAction = "open"
        notification.fireDate = timer.timerEndTime
        notification.soundName = "\(timer.alertAudio().0).\(timer.alertAudio().1)"
        notification.userInfo = ["title": timer.name, "UUID": timer.UUID]
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    static func removeNotificationFromSchedule(timer: TimerModel){
        let scheduledNotifications: [UILocalNotification]? = UIApplication.sharedApplication().scheduledLocalNotifications
        guard scheduledNotifications != nil else {return} // Nothing to remove, so return
        
        for notification in scheduledNotifications! { // loop through notifications...
            if (notification.userInfo!["UUID"] as! String == timer.UUID) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                break
            }
        }
    }
    
    static func didNotificationFire(timer: TimerModel) -> Bool {
        
        let scheduledNotifications: [UILocalNotification]? = UIApplication.sharedApplication().scheduledLocalNotifications
        guard scheduledNotifications != nil else {return false} // Nothing to remove, so return
        
        for notification in scheduledNotifications! { // loop through notifications...
            if (notification.userInfo!["UUID"] as! String == timer.UUID) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                //found a notification so timer didn't end in background
                return false
            }
        }
        //didn't find notificaiton so must have fired already
        return true
    }
    
    static func appInForeground() -> Bool {
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
            return true
        } else {
            return false
        }
    }
    
    //MARK - Audio Session methods
    
    static func activateAudioSession() {
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
        
            let session = AVAudioSession.sharedInstance();
            do {
                try session.setCategory(AVAudioSessionCategoryPlayback, withOptions: [.DuckOthers])
            } catch {
                print("could not avsession category")
            }
            
            do {
                try session.setActive(true);
            } catch {
                print("could not activate avsession")
            }
        }
    }
    
    static func activateAudioSessionInMainThread() {
            
        let session = AVAudioSession.sharedInstance();
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback, withOptions: [.DuckOthers])
        } catch {
            print("could not avsession category")
        }
        
        do {
            try session.setActive(true);
        } catch {
            print("could not activate avsession")
        }
        
    }
    
    static func dectivateAudioSession() {
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            let session = AVAudioSession.sharedInstance();
            
            do {
                try session.setActive(false);
            } catch {
                print("could not deactivate avsession")
            }
            
        }
        
        
    }
    
    static func cycleAudioSesion() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            let session = AVAudioSession.sharedInstance();
            do {
                try session.setCategory(AVAudioSessionCategoryPlayback, withOptions: [.DuckOthers])
            } catch {
                print("could not avsession category")
            }
            
            do {
                try session.setActive(true);
            } catch {
                print("could not activate avsession")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                dectivateAudioSession()
            }
            
        }
    }
    
    //MARK: - Screen size helpers
    
    static func detectPhoneScreenSize() -> String {
        let screenBounds = UIScreen.mainScreen().bounds
        
        if screenBounds.width == 320 && screenBounds.height == 480 {
            return "4"
        } else if screenBounds.width == 320 && screenBounds.height == 568 {
            return "5"
        } else if screenBounds.width == 375 && screenBounds.height == 667 {
            return "6"
        } else { //6+ so 414 x 736
            return "6+"
        }
    }
    
    static func frameSizeFor(pro: Bool, singleOrDoubleCarousel: String) -> CGRect {
            
        let screenWidth = UIScreen.mainScreen().bounds.width
        
        var timerWidthDivisor: CGFloat = 1.0
        var timerHeightMultiplier: CGFloat = 1.0
        
        if pro == true {
            if singleOrDoubleCarousel == "single" {
            
                timerWidthDivisor = 3
                timerHeightMultiplier = 1.82
                
            } else {
                
                timerWidthDivisor = 3.75
                timerHeightMultiplier = 1.82
                
            }
        } else {
            
            timerWidthDivisor = 2
            timerHeightMultiplier = 1.77
            
        }
        
        let timerWidth = screenWidth / timerWidthDivisor
        let timerHeight = timerWidth * timerHeightMultiplier
        return CGRect(x: 0, y: 0, width: timerWidth, height: timerHeight)
        
    }
    
}
















