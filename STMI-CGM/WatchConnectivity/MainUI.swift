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
    //@FetchRequest(entity: Activity.entity(), sortDescriptors: []) var activities: FetchedResults<Activity>
    //@FetchRequest(entity: Meal.entity(), sortDescriptors: []) var meals: FetchedResults<Meal>
    @FetchRequest(entity: Sensors.entity(), sortDescriptors: []) var sensors: FetchedResults<Sensors>
    
    @ObservedObject var phonetoWatch = PhonetoWatch()

    @State var username = "Amin"
    @State var dayNum = 1
    @State var addNewEntry = false
    
    @State var showSheet = false

    func calcTotEntries(count: inout Int) {
        //count = meals.count + activities.count
    }
    var body: some View {
        VStack{
            VStack{
                Text("Systems and Technology for Medicine and IoT lab")
                    .multilineTextAlignment(.center)
                    .frame(width: 300, height: 150, alignment: .center)
                    .font(.custom("Anton-Regular", size: 30))
                
                Text(phonetoWatch.watchReachable() ? "Connected to watch": phonetoWatch.appInstalled() ? "Please open the app on your watch": "Please install the watch app").font(.custom("", size: 15))
                Text("Number of events stored: \(sensors.count)").font(.custom("", size: 12))
                Button("Clear data") {
                    self.clearSensors()
                }
                //Button("Authorization Page") {self.showSheet = true}
                
            }
            AddNewEntry()
        }
        .onAppear {
            self.phonetoWatch.activateSession()
            self.updateUI()
            self.saveToMoc()
        }
    }
}

extension MainUI {
    
    func updateUI() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            self.phonetoWatch.updateUI()
            //print(self.phonetoWatch.background() ? "Backgrounds":"Foregrounds")
            self.saveToMoc()
        }
    }
    
    func deleteSensorData(at offsets: IndexSet) {
        for i in offsets {
            let sensor = sensors[i]
            moc.delete(sensor)
        }
    }
    
    func saveToMoc() {
        //print("Saving \(dateArray.count)")
        for i in 0..<dateArray.count {
            print("saving?")
            let sensors = Sensors(context: self.moc)
            sensors.heartRate = HRArray[i]
            sensors.roll = rollArray[i]
            sensors.pitch = pitchArray[i]
            sensors.yaw = yawArray[i]
            sensors.latitude = latArray[i]
            sensors.altitude = altArray[i]
            sensors.longitude = longArray[i]
            sensors.date = dateArray[i]
            do {try self.moc.save()}
            catch {print(error)}
        }
        HRArray = []
        latArray = []
        longArray = []
        altArray = []
        rollArray = []
        pitchArray = []
        yawArray = []
        dateArray = []
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
