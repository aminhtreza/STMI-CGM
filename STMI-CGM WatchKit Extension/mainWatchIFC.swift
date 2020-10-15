//
//  mainWatchIFC.swift
//  continousHeartRateMonitor WatchKit Extension
//
//  Created by iMac on 3/9/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI


struct mainWatchIFC: View {
    // ObservedObjects are used to let Swift know that this variable will be changing in another class and has SwiftUI update your View simultanously
    @ObservedObject var HeartRateManager = heartRateManager()
    @ObservedObject var motionManager = MotionManager()
    
    @State var timer: Timer? = nil
    
    var body: some View {
        GeometryReader { geo in
            VStack{
                HStack {
                    Text(watchToPhone.watchReachable() ? "Connected":"Not connected")
                }
                Text("HeartRate: \(self.HeartRateManager.updatedHRValue)bpm").frame(width: geo.size.width, alignment: .leading)
                Text("Roll: \(self.motionManager.Roll.rounded(toPlaces: 2))").frame(width: geo.size.width, alignment: .leading)
                Text("Yaw: \(self.motionManager.Yaw)").frame(width: geo.size.width, alignment: .leading)
                Text("Pitch: \(self.motionManager.Pitch)").frame(width: geo.size.width, alignment: .leading)
                Text("Latitude: \(self.motionManager.latitude)").frame(width: geo.size.width, alignment: .leading)
                Text("Longitude: \(self.motionManager.longitude)").frame(width: geo.size.width, alignment: .leading)
                Text("Altitude: \(self.motionManager.altitude)").frame(width: geo.size.width, alignment: .leading)
            }
            .onAppear {
                //AuthorizationManager.AuthorizeHK() // Ask for Healthkit permission
                watchToPhone.activateSession() // Activate WCSession from our global variable
                self.motionManager.startQueuedMotionUpdates()
                self.motionManager.setupLocation()
                self.HeartRateManager.startWorkout()
                //self.sendPhoneUpdates()
            }
        }
    }
}

extension mainWatchIFC {
    func sendPhoneUpdates() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (Timer) in
            watchToPhone.sendSensorDataToPhone()
        })
    }
}


struct mainWatchIFC_Previews: PreviewProvider {
    static var previews: some View {
        mainWatchIFC()
    }
}

