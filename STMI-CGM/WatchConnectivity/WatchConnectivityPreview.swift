//
//  WatchConnectivityPreview.swift
//  continousHeartRateMonitor
//
//  Created by iMac on 3/9/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.

import SwiftUI
struct WatchConnectivityPreview: View {
    @ObservedObject var phonetoWatch = PhonetoWatch()
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Sensors.entity(), sortDescriptors: []) var sensors: FetchedResults<Sensors>
    
    var body: some View {
        VStack{
            Image("STMITamu")
            .resizable()
            .frame(width: 375, height: 50, alignment: .center)
            .scaledToFill()
            Spacer()
            
            VStack {
                Text("Heart rate: \(phonetoWatch.HeartRate)")
                Text("Latitude: \(phonetoWatch.watchLatitude)")
                Text("Longitude: \(phonetoWatch.watchLongitude)")
                Text("Altitude: \(phonetoWatch.watchAltitude)")
                Text("Roll: \(phonetoWatch.watchRoll)")
                Text("Pitch: \(phonetoWatch.watchPitch)")
                Text("Yaw: \(phonetoWatch.watchYaw)")
                Text("Data count: \(sensors.count)")
                Button("Clear data") {
                    clearSensors()
                }
            }.padding()
            
            
            List {
                Section(header: Text("Stored data")) {
                    ForEach(sensors, id: \.self) {sensor in
                        HStack{
                            VStack {
                                Text("HR: \(sensor.heartRate)")
                                
                                /*
                                if #available(iOS 14.0, *) {
                                    Text(sensor.date, style: .time)
                                } else {
                                    Text("\(sensor.date)")
                                }
                                */
                            }
                            VStack {
                                Text("Roll: \(sensor.roll!)")
                                Text("Pitch: \(sensor.pitch!)")
                                Text("Yaw: \(sensor.yaw!)")
                            }
                            VStack {
                                Text("Lat: \(sensor.latitude!)")
                                Text("Alt: \(sensor.altitude!)")
                                Text("Long: \(sensor.longitude!)")
                            }
                            
                        }
                    }.onDelete(perform: deleteSensorData)
                }
            }
        }
        .onAppear(perform: phonetoWatch.activateSession)
        .onAppear(perform: updateUI)
        .onAppear(perform: saveToMoc)
    }
    func updateUI() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            self.phonetoWatch.updateUI()
        }
    }
    func deleteSensorData(at offsets: IndexSet) {
        for i in offsets {
            let sensor = sensors[i]
            moc.delete(sensor)
        }
        
    }
    func saveToMoc() {
         Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            let sensors = Sensors(context: self.moc)
            if self.phonetoWatch.HeartRate == 0 ||
                self.phonetoWatch.watchRoll == "" ||
                self.phonetoWatch.watchPitch == "" ||
                self.phonetoWatch.watchYaw == "" ||
                self.phonetoWatch.watchLatitude == "" ||
                self.phonetoWatch.watchLongitude == "" ||
                self.phonetoWatch.watchAltitude == "" {
                return
            } else {
                sensors.heartRate = Int16(self.phonetoWatch.HeartRate)
                sensors.roll = self.phonetoWatch.watchRoll
                sensors.pitch = self.phonetoWatch.watchPitch
                sensors.yaw = self.phonetoWatch.watchYaw
                sensors.latitude = self.phonetoWatch.watchLatitude
                sensors.altitude = self.phonetoWatch.watchLongitude
                sensors.longitude = self.phonetoWatch.watchAltitude
                sensors.date = Date()
            }
            do {try self.moc.save()}
            catch {print(error)}
        }
    }
    
    func clearSensors() {
        for sensor in sensors {
            moc.delete(sensor)
        }
        try! self.moc.save()
    }
}

struct WatchConnectivityPreview_Previews: PreviewProvider {
    static var previews: some View {
        WatchConnectivityPreview()
    }
}
