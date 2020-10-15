//
//  WatchToPhone.swift
//  continousHeartRateMonitor WatchKit Extension
//
//  Created by iMac on 3/9/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import Foundation
import WatchConnectivity
import SwiftUI

var watchToPhone = WatchtoPhone()

var sensorData: [String:Any] = [:]

class WatchtoPhone: NSObject, WCSessionDelegate {
    
    func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("Watch session activated \(session.activationState)")
        } else {
            print("WC session not supported)")
        }
    }
    
    func watchReachable() -> Bool {
        if WCSession.isSupported() {
            let session = WCSession.default
            if session.isReachable {
                return true
            } else {
                return false
            }
            
        } else {
            return false
        }
    }
    
    var lastMessage: CFAbsoluteTime = 0
    func sendPhoneMessage(message: Dictionary<String, Any>) {
        let currentTime = CFAbsoluteTimeGetCurrent()
            if lastMessage + 0.2 > currentTime {
                return
            }
        print("sendPhoneMessage")
        if (WCSession.default.isReachable) {
            WCSession.default.sendMessage(message as [String : Any], replyHandler: nil)
        }
        lastMessage = CFAbsoluteTimeGetCurrent()
    }
    
    // can run in background
    var lastUserInfo: CFAbsoluteTime = 0
    func sendUserInfo(userInfo: Dictionary<String, Any>) {
        let currentTime = CFAbsoluteTimeGetCurrent()
        if lastUserInfo + 0.2 > currentTime {
            return
        }
        print("sendUserInfo")
        WCSession.default.transferUserInfo(userInfo)
        lastUserInfo = CFAbsoluteTimeGetCurrent()
    }
    
    // function will be called using a timer to send at a reoccuring interval
    func sendSensorDataToPhone() {
        sensorData["date"] = Double(Date().timeIntervalSince1970)
        print("\(Date(timeIntervalSince1970: Double(Date().timeIntervalSince1970)))")
        //self.sendUserInfo(userInfo: sensorData)
        self.sendPhoneMessage(message: sensorData)
        //WCSession.default.sendMessage(sensorData as [String : Any], replyHandler: nil)
        print("Sending Sensor data to phone")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    }
}

//Dictionary to send everything to iPhone
//var sensorData = ["HR":String, "roll":"--", "pitch":"--", "yaw":"--", "latitude":"--", "longitude":"--", "altitude":"--"]
