//
//  InterfaceController.swift
//  continousHeartRateMonitor WatchKit Extension
//
//  Created by iMac on 2/18/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import Foundation
import HealthKit
import WatchKit
import WatchConnectivity

class HealthkitManager: ObservableObject {
    private var healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    let energyUnit = HKUnit.kilocalorie()
    let stepUnit = HKUnit.count()
    let measuringVariables: [HKQuantityTypeIdentifier] = [.heartRate, .activeEnergyBurned, .stepCount]
    
    var query: HKStatisticsCollectionQuery?
    
    var healthKitData: [Double] = []
    
    // file stuff
    var filesToBeSenttoPhone = [String: URL]()
    var errorLog=""
    var timeOffset = 0.0
    
    func start() {
        autorizeHealthKit()
        for variable in measuringVariables {
            startQuery(quantityTypeIdentifier: variable)
        }
        let timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            self.stringWritter()
        }
    }
    
    func autorizeHealthKit() {
        let healthKitTypes: Set = [
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
        ]
        
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in
        }
        print("HK Authorized")
    }
    
    private func startQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            self.process(samples, type: quantityTypeIdentifier)
        }
        
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)

        query.updateHandler = updateHandler
        healthStore.execute(query)
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var heartRate = 0.0
        var energyBurned = 0.0
        var stepCount = 0.0
        
        for sample in samples {
            if type == .heartRate {
                heartRate = sample.quantity.doubleValue(for: heartRateQuantity)
                print("HR: \(heartRate) at \(Date())")
            } else if type == .activeEnergyBurned {
                energyBurned = sample.quantity.doubleValue(for: energyUnit)
                print("Active Energy: \(energyBurned) at \(Date())")
            } else if type == .stepCount {
                stepCount = sample.quantity.doubleValue(for: stepUnit)
                print("Step count: \(stepCount) at \(Date())")
            }
        }
        
        self.healthKitData.append(Date().timeIntervalSince1970)
        self.healthKitData.append(heartRate)
        self.healthKitData.append(energyBurned)
        self.healthKitData.append(stepCount)
        
    }
    
    // MARK: - Send data to phone
    
    func stringWritter(){
        let myDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-HH:mm:ss"
        let currentTime = dateFormatter.string(from: myDate)
        let fileName = currentTime + ".hk"
        
        var fileContext=fileName + "\n"
        let toBeWritten=self.healthKitData
        self.healthKitData.removeAll()
        for element in toBeWritten{
            fileContext+=String(round(element*1000)/1000)+"\n"
        }
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let fileURL = dir.appendingPathComponent(fileName)
                try fileContext.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                print("stringWritter successfully wrote the data at",fileName)
                self.filesToBeSenttoPhone[fileName]=fileURL
                self.sendMsgToPhone()
            }
            catch{
                print("Error in the stringWritter Function")
                
                self.errorLog+="E7 \n "+"-------------------------"
                self.errorLoger()

            }
        }
    }
    
    // called by stringWriter to send data to iPhone
    func sendMsgToPhone(){
        print("sendMsgToPhone Func HK")
        if WCSession.isSupported() && WCSession.default.isReachable{
            print("Phone is reachable and supported")
            do{
                for (fileName,fileURL) in self.filesToBeSenttoPhone{
                    let fileDes = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                    let fileSize = fileDes.fileSize!
                    let dataContent = try Data.init(contentsOf: fileURL)
                    WCSession.default.sendMessageData(dataContent, replyHandler: nil, errorHandler: { (error) -> Void in
                        print("sendMsgToPhone error 1",error)
                        self.errorLog+="E2 \n \(error) "+"-------------------------"
                        self.errorLoger()
                        return
                    })
                    print("------------Success----------",fileSize/1000," kb ",fileURL)
                    self.filesToBeSenttoPhone.removeValue(forKey: fileName)
                    self.dataCleaner(fileURL: fileURL)
                }
            }
            catch{
                print("sendMsgToPhone error 2")
                self.errorLog+="E3 \n"+"-------------------------"
                self.errorLoger()
            }
        }
    }
    
    enum STMIError: Error {
        case IOError
        case sortingError
    }
    
    // called by many functions. Logs whatever the current error is
    func errorLoger(){
        print("errorLoger", self.errorLog)
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let fileURL = dir.appendingPathComponent("errorLog")
                try errorLog.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                WCSession.default.transferFile(fileURL, metadata: nil)
            }
            catch{
                print("Error in logging error")
            }
        }
    }
    
    func dataCleaner(fileURL:URL){
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            print("Error in deleting")
            self.errorLog+="E5 \n "+"-------------------------"
            self.errorLoger()
        }
    }
   
}


