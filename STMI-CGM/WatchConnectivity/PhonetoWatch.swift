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
// ryan is here again

var session: WCSession!

class PhonetoWatch: NSObject, WCSessionDelegate, ObservableObject {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Sensors.entity(), sortDescriptors: []) var sensors: FetchedResults<Sensors>
    
    @Published var watchLatitude = ""
    @Published var watchLongitude = ""
    @Published var watchAltitude = ""
    @Published var HeartRate = -99
    @Published var watchRoll = ""
    @Published var watchPitch = ""
    @Published var watchYaw = ""
    
    var HRArray: [String] = []
    var latArray: [String] = []
    var longArray: [String] = []
    var altArray: [String] = []
    var rollArray: [String] = []
    var pitchArray: [String] = []
    var yawArray: [String] = []
    var dateArray: [Date] = []
    
    // Assign to local variable (can't update published variables with a delegate
    var wLatitude = ""
    var wLongitude = ""
    var wAltitude = ""
    var wRoll = ""
    var wPitch = ""
    var wYaw = ""
    var wHR = ""
    var wDate = ""
    
    internal func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        wLatitude = message["latitude"]! as? String ?? "--"
        wLongitude = message["longitude"]! as? String ?? "--"
        wAltitude = message["altitude"]! as? String ?? "--"
        wRoll = message["roll"]! as! String
        wPitch = message["pitch"]! as! String
        wYaw = message["yaw"]! as! String
        wHR = message["HR"]! as! String
        wDate = message["date"]! as! String
        print("Message received: HR:\(wHR), Lat:\(wLatitude), Roll:\(wRoll)")
        print(wDate)
        
        HRArray.append(wHR)
        latArray.append(wLatitude)
        altArray.append(wAltitude)
        longArray.append(wLongitude)
        rollArray.append(wRoll)
        pitchArray.append(wPitch)
        yawArray.append(wYaw)
        dateArray.append(Date(timeIntervalSince1970: TimeInterval(wDate)!))
        //dateArray.append(wDate)
    }
    
    
    internal func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        wLatitude = userInfo["latitude"]! as? String ?? "--"
        wLongitude = userInfo["longitude"]! as? String ?? "--"
        wAltitude = userInfo["altitude"]! as? String ?? "--"
        wRoll = userInfo["roll"]! as! String
        wPitch = userInfo["pitch"]! as! String
        wYaw = userInfo["yaw"]! as! String
        wHR = userInfo["HR"]! as! String
        wDate = userInfo["date"] as! String
        print("UserInfo received: HR:\(wHR), Lat:\(wLatitude), Roll:\(wRoll)")
        print(wDate)
        //print("\(Date(timeIntervalSince1970: TimeInterval(wDate)!))")
        //saveToMoc()
        
        HRArray.append(wHR)
        latArray.append(wLatitude)
        altArray.append(wAltitude)
        longArray.append(wLongitude)
        rollArray.append(wRoll)
        pitchArray.append(wPitch)
        yawArray.append(wYaw)
        dateArray.append(Date(timeIntervalSince1970: TimeInterval(wDate)!))
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
        watchLatitude = wLatitude //Double(wLatitude)!.roundTo(places: 1)
        watchLongitude = wLongitude
        watchAltitude = wAltitude
        watchYaw = wYaw
        watchRoll = wRoll
        watchPitch = wPitch
        HeartRate = Int(wHR) ?? 0
    }

    /*
    func saveToMoc() {
        let sensors = Sensors(context: self.moc)
        sensors.heartRate = Int16(wHR)!
        sensors.roll = wRoll
        sensors.pitch = wPitch
        sensors.yaw = wYaw
        sensors.latitude = wLatitude
        sensors.altitude = wAltitude
        sensors.longitude = wLongitude
        sensors.date = wDate
        do {try self.moc.save()}
        catch {print(error)}
    }
    */
    
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
