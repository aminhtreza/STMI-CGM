//
//  MainUI.swift
//  STMI-CGM
//
//  Created by iMac on 5/7/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

struct MainUI: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Activity.entity(), sortDescriptors: []) var activities: FetchedResults<Activity>
    @FetchRequest(entity: Meal.entity(), sortDescriptors: []) var meals: FetchedResults<Meal>
    @FetchRequest(entity: Sensors.entity(), sortDescriptors: []) var sensors: FetchedResults<Sensors>
    
    @ObservedObject var phonetoWatch = PhonetoWatch()

    @State var username = "Amin"
    @State var dayNum = 420
    @State var addNewEntry = false

    func calcTotEntries(count: inout Int) {
        count = meals.count + activities.count
    }
    var body: some View {
        VStack{
            VStack{
                Text("Systems and Technology for Medicine and IoT lab")
                    .multilineTextAlignment(.center)
                    .frame(width: 300, height: 150, alignment: .center)
                    .font(.custom("Anton-Regular", size: 30))
                
                Text(phonetoWatch.watchReachable() ? "Connected to watch": phonetoWatch.appInstalled() ? "Please open the app on your watch": "Please install the watch app")
                Text("\(sensors.count)")
                Button("Clear data") {
                    self.clearSensors()
                }
            }
            AddNewEntry()
        }
        .onAppear {
            self.phonetoWatch.activateSession()
            self.updateUI()
            //self.saveToMoc()
        }
    }
}

extension MainUI {
    
    func updateUI() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            self.phonetoWatch.updateUI()
            print(self.phonetoWatch.background() ? "Background":"Foreground")
            for i in 0..<phonetoWatch.HRArray.count {
                let sensors = Sensors(context: self.moc)
                sensors.heartRate = Int16(phonetoWatch.HRArray[i]) ?? -99
                sensors.roll = phonetoWatch.rollArray[i]
                sensors.pitch = phonetoWatch.pitchArray[i]
                sensors.yaw = phonetoWatch.yawArray[i]
                sensors.latitude = phonetoWatch.latArray[i]
                sensors.altitude = phonetoWatch.altArray[i]
                sensors.longitude = phonetoWatch.longArray[i]
                sensors.date = phonetoWatch.dateArray[i]
                do {try self.moc.save()}
                catch {print(error)}
            }
            print(phonetoWatch.HRArray.count)
            phonetoWatch.clearArrays()
            
            /*
            if !self.phonetoWatch.background() {
                print(phonetoWatch.HRArray.count)
            }
            */
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
            if self.phonetoWatch.HeartRate == 0 || self.phonetoWatch.watchRoll == "" {
                
            } else {
                let sensors = Sensors(context: self.moc)
                sensors.heartRate = Int16(self.phonetoWatch.HeartRate)
                sensors.roll = self.phonetoWatch.watchRoll
                sensors.pitch = self.phonetoWatch.watchPitch
                sensors.yaw = self.phonetoWatch.watchYaw
                sensors.latitude = self.phonetoWatch.watchLatitude
                sensors.altitude = self.phonetoWatch.watchLongitude
                sensors.longitude = self.phonetoWatch.watchAltitude
                sensors.date = Date()
                do {try self.moc.save()}
                catch {print(error)}
            }
        }
    }
    
    func clearSensors() {
        for sensor in sensors {
            moc.delete(sensor)
        }
        try! self.moc.save()
    }
}

struct MainUI_Previews: PreviewProvider {
    static var previews: some View {
        MainUI()
    }
}


