//
//  Helper.swift
//  Tap Timer
//
//  Created by Simon Barker on 22/07/2016.
//  Copyright © 2016 sbarker. All rights reserved.
//

import Foundation
import UIKit

class Helper: NSObject {
    
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
        
        print("registered Notification")
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    static func removeNotificationFromSchedule(timer: TimerModel){
        let scheduledNotifications: [UILocalNotification]? = UIApplication.sharedApplication().scheduledLocalNotifications
        guard scheduledNotifications != nil else {return} // Nothing to remove, so return
        
        for notification in scheduledNotifications! { // loop through notifications...
            if (notification.userInfo!["UUID"] as! String == timer.UUID) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                print("removed Notification")
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
}