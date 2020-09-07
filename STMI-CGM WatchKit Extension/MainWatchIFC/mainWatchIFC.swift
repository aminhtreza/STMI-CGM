//
//  mainWatchIFC.swift
//  continousHeartRateMonitor WatchKit Extension
//
//  Created by iMac on 3/9/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

struct mainWatchIFC: View {
    @ObservedObject var HeartRateManager = heartRateManager() // ObservedObjects are used to let Swift know that this variable will be changing in another class and has SwiftUI update your View simultanously
    @ObservedObject var motionManager = MotionManager()
    
    @State var timer: Timer? = nil
    
    var body: some View {
        GeometryReader { geo in
            VStack{
                Text("HeartRate: \(HeartRateManager.updatedHRValue)bpm").frame(width: geo.size.width, alignment: .leading)
                Text("Roll: \(motionManager.Roll)").frame(width: geo.size.width, alignment: .leading)
                Text("Yaw: \(motionManager.Yaw)").frame(width: geo.size.width, alignment: .leading)
                Text("Pitch: \(motionManager.Pitch)").frame(width: geo.size.width, alignment: .leading)
                Text("Latitude: \(motionManager.latitude)").frame(width: geo.size.width, alignment: .leading)
                Text("Longitude: \(motionManager.longitude)").frame(width: geo.size.width, alignment: .leading)
                Text("Altitude: \(motionManager.altitude)").frame(width: geo.size.width, alignment: .leading)
            }
            .onAppear {
                AuthorizationManager.AuthorizeHK()
                watchToPhone.activateSession()
                motionManager.startQueuedMotionUpdates()
                motionManager.setupLocation()
                HeartRateManager.startWorkout()
                sendPhoneUpdates()
            }
        }
    }
    func sendPhoneUpdates() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
            watchToPhone.sendSensorDataToPhone()
        })
    }
}



struct mainWatchIFC_Previews: PreviewProvider {
    static var previews: some View {
        mainWatchIFC()
    }
}

