//
//  MotionManager.swift
//  continousHeartRateMonitor WatchKit Extension
//
//  Created by iMac on 3/9/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion
import WatchConnectivity

class MotionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var motionManager = CMMotionManager()
    var locationManager = CLLocationManager()
    let date = NSTimeIntervalSince1970
        
    @Published var Roll: Double = 0.0
    @Published var Yaw: Double = 0.0
    @Published var Pitch: Double = 0.0
    
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var altitude: Double = 0.0
    
    func setupLocation() {
        print("setupLocation()")
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 1
    }
    
    func startQueuedMotionUpdates() {
       if motionManager.isDeviceMotionAvailable {
        self.motionManager.deviceMotionUpdateInterval = 1.0 
        self.motionManager.showsDeviceMovementDisplay = true
        // if watch 5 or later: (using: .xMagneticNorthZVertical, ...
        self.motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: OperationQueue.current!, withHandler: { (data, error) in
             if let validData = data {
                // Get the attitude relative to the magnetic north reference frame.
                let roll = validData.attitude.roll
                let pitch = validData.attitude.pitch
                let yaw = validData.attitude.yaw
                
                self.Roll = Double(roll).rounded(toPlaces: 2)
                self.Pitch = Double(pitch).rounded(toPlaces: 2)
                self.Yaw = Double(yaw).rounded(toPlaces: 2)
                print(self.Roll)
                
                sensorData["roll"] = self.Roll
                sensorData["yaw"] = self.Yaw
                sensorData["pitch"] = self.Pitch
             }
          })
       }
       else {
        fatalError("App doesn't have device motion available")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // makes sure nothing went wrong and we have location data
        // locations are put into an array, so we grab the first piece of data
        // let lastLocation = locations.last!
        if let location = locations.last {
            // retrieve location data
            self.latitude = Double(round(location.coordinate.latitude * 1000) / 1000).rounded(toPlaces: 3)
            self.longitude = Double(round(location.coordinate.longitude * 1000) / 1000).rounded(toPlaces: 3)
            self.altitude = Double(round(location.altitude * 1000) / 1000).rounded(toPlaces: 3)
            print(self.altitude) // accurate to 111 m
            // store in sensorDate to send to phone
            sensorData["altitude"] = self.altitude
            sensorData["longitude"] = self.longitude
            sensorData["latitude"] = self.latitude
        }
    }
}

extension Double {
    // rounds doubles to a decimal
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


