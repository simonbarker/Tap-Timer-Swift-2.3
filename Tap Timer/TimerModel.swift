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
import AVFoundation

//protocol provides a way for the timer to tell the view controller that has fired, this allows the viewcontroller to update the UI correctly
protocol timerProtocol {
    func timerFired(timer: TimerModel)
    func timerEnded(timer: TimerModel)
}

enum AlertNoise: String {
    case ChurchBell = "ChurchBell"
    case DogBark = "DogBark"
    case BoxingBell = "BoxingBell"
    case Horn = "Horn"
    case Alien = "Alien"
    case Car = "Car"
}

enum BaseColor: String {
    case SkyBlue = "SkyBlue"
    case Red = "Red"
    case Purple = "Purple"
    case Yellow = "Yellow"
    case Green = "Green"
    case Gray = "Gray"
}

class TimerModel: NSObject, NSCoding, AVAudioPlayerDelegate {
    
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
    var alarmRepetitions: Int
    var timerRepetitions: Int
    var currentTimerRepetition: Int
    var audioPlaying: Bool
    var player: AVAudioPlayer = AVAudioPlayer()
    var countDownTimer: NSTimer = NSTimer()
    var delegate: timerProtocol? = nil
    
    init(withName name: String, duration: Int, UUID: String, color: BaseColor, alertNoise: AlertNoise, timerRepetitions: Int, alarmRepetitions: Int) {
        self.name = name
        self.active = false
        self.paused = false
        self.duration = duration
        self.UUID = UUID
        self.audioAlert = alertNoise
        self.colorScheme = color
        self.alarmRepetitions = alarmRepetitions
        self.audioPlaying = false
        self.timerRepetitions = timerRepetitions
        self.currentTimerRepetition = 0
        
        let sess = AVAudioSession.sharedInstance()
        if sess.otherAudioPlaying {
            _ = try? sess.setCategory(AVAudioSessionCategoryAmbient, withOptions: [.MixWithOthers])
            _ = try? sess.setActive(true, withOptions: [])
        }
        
        super.init()
    }
    
    convenience override init() {
        self.init(withName: "Tap Timer 1", duration: 10, UUID: NSUUID().UUIDString, color: .Red, alertNoise: .ChurchBell, timerRepetitions: 1, alarmRepetitions: 0)
    }
    
    // MARK: NSCoding
    
    required convenience init? (coder decoder: NSCoder) {
        print("in init coder")
        guard let name = decoder.decodeObjectForKey("name") as? String
        else {
            print("init coder name guard failed")
            return nil
        }
        guard let duration = decoder.decodeObjectForKey("duration") as? Int
        else {
            print("init coder duration guard failed")
            return nil
        }
        guard let audioAlertRawValue = decoder.decodeObjectForKey("audioAlert") as? String
        else {
            print("init coder audioAlert guard failed")
            return nil
        }
        guard let UUID = decoder.decodeObjectForKey("UUID") as? String
        else {
            print("init coder UUID guard failed")
            return nil
        }
        guard let colorSchemeRawValue = decoder.decodeObjectForKey("colorScheme") as? String
        else {
            print("init coder colorScheme guard failed")
            return nil
        }
        guard let alarmRepetitions = decoder.decodeObjectForKey("alarmRepetitions") as? Int
        else {
            print("init coder alarmRepetitions guard failed")
            return nil
        }
        guard let timerRepetitions = decoder.decodeObjectForKey("timerRepetitions") as? Int
        else {
            print("init coder timerRepetitions guard failed")
            return nil
        }
        
        guard let audioAlert = AlertNoise(rawValue: audioAlertRawValue)
            else{
                print("No AlertNoise rawValue case found")
                return nil
        }
        guard let colorScheme = BaseColor(rawValue: colorSchemeRawValue)
            else{
                print("No BaseColor rawValue case found")
                return nil
        }
        
        print("initCoder guards passed, initing timer")
        print("\(name), \(duration), \(UUID), \(colorScheme), \(audioAlert), \(timerRepetitions), \(alarmRepetitions)")
        
        self.init(withName: name, duration: duration, UUID: UUID, color: colorScheme, alertNoise: audioAlert, timerRepetitions: timerRepetitions, alarmRepetitions: alarmRepetitions)
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.duration, forKey: "duration")
        coder.encodeObject(self.audioAlert.rawValue, forKey: "audioAlert")
        coder.encodeObject(self.UUID, forKey: "UUID")
        coder.encodeObject(self.colorScheme.rawValue, forKey: "colorScheme")
        coder.encodeObject(self.alarmRepetitions, forKey: "alarmRepetitions")
        coder.encodeObject(self.timerRepetitions, forKey: "timerRepetitions")
    }
    
    func percentageThroughTimer() -> Double {
        
        if active == false && paused == false {
            return 1.0
        } else if active == false && paused == true {
            return Double(Double(remainingWhenPaused!)/Double(duration))
        } else if active == true && paused == false {
            guard let timerEnd = timerEndTime as NSDate! else {
                print("No timerEndTime set 1")
                return 0.0
            }
            
            let timeRemaing = timerEnd.timeIntervalSinceNow
            
            return timeRemaing/Double(duration)
        } else {
            return Double(remainingWhenPaused!/duration)
        }
        
    }
    
    func timeFromEndTime() -> Int {
        
        guard let timerEnd = timerEndTime as NSDate! else {
            print("No timerEndTime set 2")
            return 0
        }
        
        let timeRemaing = timerEnd.timeIntervalSinceNow
        
        return Int(timeRemaing)
    }
    
    func setPausedRemaining() {
        
        guard let timerEnd = timerEndTime as NSDate! else {
            print("No timerEndTime set 3")
            return
        }
        
        remainingWhenPaused = Int(timerEnd.timeIntervalSinceNow)
    }
    
    func alertAudio() -> (String, String){
        switch audioAlert {
        case .ChurchBell:
            return ("Church Bell", "mp3")
        case .DogBark:
            return ("Car Horn", "mp3")
        case .BoxingBell:
            return ("Church Bell", "mp3")
        case .Horn:
            return ("Car Horn", "mp3")
        case .Alien:
            return ("Church Bell", "mp3")
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
    
    //Mark: - Audio methods
    func loadAudio(){
        
        let audioFile = self.alertAudio()
        
        let audioPath = NSBundle.mainBundle().pathForResource(audioFile.0, ofType: audioFile.1)!
        
        do {
            try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath))
            player.delegate = self
        } catch {
            print("Error: \(error) in loadind audio file")
        }
        
    }
    
    func playAudio(loops: Int) {

        player.numberOfLoops = loops
        player.currentTime = 0.0
        player.play()
        
        audioPlaying = true
    }
    
    //MARK: - AVPlayer Delegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        audioPlaying = false
    }
    
    //MARK: - Timer control methods
    func start() {
        active = true
        paused = false
        currentTimerRepetition += 1
        countDownTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
        timerStartTime = NSDate()
        timerEndTime = NSDate().dateByAddingTimeInterval(NSTimeInterval(duration))
    }
    
    func pause() {
        active = false
        paused = true
        setPausedRemaining()
        countDownTimer.invalidate()
    }
    
    func restart() {
        active = true
        paused = false
        countDownTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
        timerStartTime = NSDate()
        timerEndTime = NSDate().dateByAddingTimeInterval(NSTimeInterval(duration))
        
        guard let remaining = remainingWhenPaused else {
            print("No paused remaining time")
            return
        }
        
        timerEndTime = NSDate().dateByAddingTimeInterval(NSTimeInterval(remaining))
    }
    
    func reset() {
        active = false
        paused = false
        countDownTimer.invalidate()
        timerStartTime = nil
        timerEndTime = nil
    }
    
    func clearTimer() {
        active = false
        paused = false
        countDownTimer.invalidate()
        timerStartTime = nil
        timerEndTime = nil
        currentTimerRepetition = 0
    }
    
    
    func timerFired() {
        //update timer
        guard let timerEndTime = timerEndTime else {
            print("No timer end time available")
            return
        }
        
        //count down timer ended
        if NSDate().compare(timerEndTime) == NSComparisonResult.OrderedDescending {
            
            if Helper.appInForeground() == true {
                loadAudio()
                playAudio(alarmRepetitions - 1)
            }
            
            self.reset()
            
            //check repetition count
            if currentTimerRepetition < timerRepetitions {
                self.start()
            } else {
                currentTimerRepetition = 0
            }
            
            self.delegate?.timerEnded(self)
            Helper.removeNotificationFromSchedule(self)
            
        } else {
            
            self.delegate?.timerFired(self)
            
        }
    }
    
    func timeToDisplay() -> Int {
        /*states
        active      paused      time to display
        false       false       duration
        false       true        time remaining when paused
        true        false       time to end
        true        true        time remaining when paused
        */
        if active == false && paused == false {
            return duration
        } else if active == false && paused == true {
            return remainingWhenPaused!
        } else if active == true && paused == false {
            return self.timeFromEndTime()
        } else {
            return remainingWhenPaused!
        }
    }
    
}