//
//  PhonetoWatch.swift
//  continousHeartRateMonitor
//
//  Created by iMac on 3/9/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import Foundation
import WatchConnectivity
import SwiftUI
var session: WCSession!

var HRArray: [Double] = []
var latArray: [Double] = []
var longArray: [Double] = []
var altArray: [Double] = []
var rollArray: [Double] = []
var pitchArray: [Double] = []
var yawArray: [Double] = []
var dateArray: [Double] = []

class PhonetoWatch: NSObject, WCSessionDelegate, ObservableObject {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Sensors.entity(), sortDescriptors: []) var sensors: FetchedResults<Sensors>
    
    @Published var watchLatitude: Double = 0.0
    @Published var watchLongitude: Double = 0.0
    @Published var watchAltitude: Double = 0.0
    @Published var HeartRate: Double = 0.0
    @Published var watchRoll: Double = 0.0
    @Published var watchPitch: Double = 0.0
    @Published var watchYaw: Double = 0.0
    
    // Assign to local variable (can't update published variables with a delegate)
    var wLatitude: Double = 0.0
    var wLongitude: Double = 0.0
    var wAltitude: Double = 0.0
    var wRoll: Double = 0.0
    var wPitch: Double = 0.0
    var wYaw: Double = 0.0
    var wHR: Double = 0.0
    var wDate: Double = 0.0
    
    internal func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        self.wLatitude = message["latitude"]! as! Double
        self.wLongitude = message["longitude"]! as! Double
        self.wAltitude = message["altitude"]! as! Double
        self.wRoll = message["roll"]! as! Double
        self.wPitch = message["pitch"]! as! Double
        self.wYaw = message["yaw"]! as! Double
        self.wHR = message["HR"]! as! Double
        self.wDate = message["date"]! as! Double
        print("Message received: HR:\(wHR), Lat:\(wLatitude), Roll:\(wRoll)")
        //print(TimeInterval(wDate))
        //print(Date(timeIntervalSince1970: wDate))
        
        self.appendArrays()
    }
    
    func appendArrays() {
        HRArray.append(wHR)
        latArray.append(wLatitude)
        altArray.append(wAltitude)
        longArray.append(wLongitude)
        rollArray.append(wRoll)
        pitchArray.append(wPitch)
        yawArray.append(wYaw)
        dateArray.append(wDate) //Date(timeIntervalSince1970: TimeInterval(wDate)!)
        print(HRArray.count)
    }
    
    /*
    internal func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        self.wLatitude = userInfo["latitude"]! as! Double
        self.wLongitude = userInfo["longitude"]! as! Double
        self.wAltitude = userInfo["altitude"]! as! Double
        self.wRoll = userInfo["roll"]! as! Double
        self.wPitch = userInfo["pitch"]! as! Double
        self.wYaw = userInfo["yaw"]! as! Double
        self.wHR = userInfo["HR"]! as! Double
        self.wDate = userInfo["date"]! as! Double
        print("UserInfo received: HR:\(wHR), Lat:\(wLatitude), Roll:\(wRoll)")
        print(TimeInterval(wDate))
        print(Date(timeIntervalSince1970: wDate))
        
        self.HRArray.append(wHR)
        self.latArray.append(wLatitude)
        self.altArray.append(wAltitude)
        self.longArray.append(wLongitude)
        self.rollArray.append(wRoll)
        self.pitchArray.append(wPitch)
        self.yawArray.append(wYaw)
        self.dateArray.append(wDate) //Date(timeIntervalSince1970: TimeInterval(wDate)!)
        print(HRArray.count)
    }
    */
    
    func saveToMoc() {
        
    }
    
    func clearArrays() {
        HRArray = []
        latArray = []
        longArray = []
        altArray = []
        rollArray = []
        pitchArray = []
        yawArray = []
        dateArray = []
    }
    
    func updateUI() {
        self.watchLatitude = wLatitude //Double(wLatitude)!.roundTo(places: 1)
        self.watchLongitude = wLongitude
        self.watchAltitude = wAltitude
        self.watchYaw = wYaw
        self.watchRoll = wRoll
        self.watchPitch = wPitch
        self.HeartRate = wHR
    }
    
    func background() -> Bool {
        let state = UIApplication.shared.applicationState
        if state == .background || state == .inactive {
            return true
        } else {
            return false
        }
    }

    func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        } else {
            print("WC session not supported)")
        }
    }
    
    func appInstalled() -> Bool {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            if session.isWatchAppInstalled {
                return true
            } else {
                return false
            }
        } else {
            print("WC session not supported)")
            return false
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
    
    func watchPaired() -> Bool {
        if WCSession.isSupported() {
            let session = WCSession.default
            if session.isPaired {
                return true
            } else {
                return false
            }
            
        } else {
            return false
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    func sessionDidDeactivate(_ session: WCSession) {
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
}

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
