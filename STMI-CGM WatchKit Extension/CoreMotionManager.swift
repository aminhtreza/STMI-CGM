
//
//  InterfaceController.swift
//  SensorCollector WatchKit Extension
//
//  Created by Sorush Omidvar on 8/18/21.
//
import Foundation
import CoreLocation
import CoreMotion
import WatchConnectivity

/*
// MARK: - Interface controller
class CoreMotionManager: NSObject, CLLocationManagerDelegate, WCSessionDelegate, ObservableObject {
    
    let motionManager = CMMotionManager()
    var locationManagerBootFlag = true
    var motionManagerBootFlag = true
    var wirelessBootFlag = true
    var firstTime = true
    
    let keepWatchCopy = false
    
    let sensorInterval = 6.0/60.0
    let timerInterval = 3.0/60.0
    let sensorSessionDuration = 60.0
    
    let gravityFlag = false
    let accelFlag = true
    let gyroFlag = true
    let attitudeFlag = true
    var sensorNumber = 0.0
    
    var lastFile=""
    var currentStat=""
    var syncedFiles=0
    var writtenFiles=0
    
    var errorLog=""
    
    var filesToBeSenttoPhone = [String: URL]()
    
    let locationManager = CLLocationManager()
    var sensorData = [Double]()
    var timeOffset = 0.0
    let session = WCSession.default
    
    @Published var accelx = 0.0
    var ref: DatabaseReference! = Database.database().reference()
    
    // does initial configurations
    func loader(){
        //self.activateSession()
        self.motionManagerInitializer()
        self.locationManagerInitializer()
    }
}

// MARK: - Motion
extension CoreMotionManager {
    func motionManagerInitializer(){
        self.motionManager.deviceMotionUpdateInterval=self.sensorInterval
        self.sensorNumber = 1.0
        if self.accelFlag{
            self.sensorNumber += 3
        }
        if self.gyroFlag{
            self.sensorNumber += 3
        }
        if self.gravityFlag{
            self.sensorNumber += 3
        }
        if self.attitudeFlag{
            self.sensorNumber += 3
        }
    }
    
    func motionFetch(){
        if self.motionManager.isDeviceMotionAvailable{
            let handler:CMDeviceMotionHandler = {data,error in
                if let validData = data{
                    if self.motionManagerBootFlag{
                        let jan12001=NSDate(timeIntervalSinceReferenceDate: TimeInterval(1609480800-978328800)) //shifting from 1970 to 1 Jan 2021 to save some extra digits
                        self.timeOffset = NSDate().timeIntervalSince(jan12001 as Date) - validData.timestamp
                        self.motionManagerBootFlag = false
                    }
                    self.sensorData.append(validData.timestamp+self.timeOffset)
                    
                    if self.accelFlag{
                        self.sensorData.append(validData.userAcceleration.x)
                        self.accelx = validData.userAcceleration.x
                        print("came here: \(self.accelx)")
                        self.sensorData.append(validData.userAcceleration.y)
                        self.sensorData.append(validData.userAcceleration.z)
                    }
                    if self.gyroFlag{
                        self.sensorData.append(validData.rotationRate.x)
                        self.sensorData.append(validData.rotationRate.y)
                        self.sensorData.append(validData.rotationRate.z)
                    }
                    if self.gravityFlag{
                        self.sensorData.append(validData.gravity.x)
                        self.sensorData.append(validData.gravity.y)
                        self.sensorData.append(validData.gravity.z)
                    }
                    if self.attitudeFlag{
                        self.sensorData.append(validData.attitude.yaw)
                        self.sensorData.append(validData.attitude.pitch)
                        self.sensorData.append(validData.attitude.roll)
                    }
                    // print(validData.timestamp+self.timeOffset)
                }
                else{
                    print("The core motion data is not available on this watch")
                }
            }
            self.motionManager.startDeviceMotionUpdates(to:OperationQueue.current!,withHandler: handler)
        }
        else{
            print("The core motion data is not available on this watch")
        }
    }
}

// MARK: - Location
extension CoreMotionManager {
    func locationManagerInitializer(){
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates=true
        if self.locationManager.authorizationStatus == .authorizedAlways || self.locationManager.authorizationStatus == .authorizedWhenInUse{
            self.currentStat="Running"
            self.locationManager.startUpdatingLocation()
            self.motionFetch()
        }
        else{
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: CLLocationManagerDelegate functions (automatically ran in background)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.locationManagerBootFlag{
            self.locationManagerBootFlag=false
            Timer.scheduledTimer(withTimeInterval: self.timerInterval, repeats: true){ (t) in
                if self.sensorData.count >= Int(self.sensorNumber / self.motionManager.deviceMotionUpdateInterval * self.sensorSessionDuration){
                    self.stringWritter()
                }
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Authority did change with current",self.locationManager.authorizationStatus.rawValue)
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse{
            self.locationManager.startUpdatingLocation()
            self.motionFetch()
        }
        else{
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("The location is not available and this led to an error")
        /*
        self.currentStat="E4-Loc: \(error)"
        self.statusTB.setText(self.currentStat)
        self.statusTB.setTextColor(.red)
        */
        self.errorLog+="E4 \n \(error) "+"-------------------------"
        self.errorLoger()

    }
}




// MARK: - Watch file and message transfer functions
extension CoreMotionManager {
    // activates watch session
    func activateSession(){
        if self.wirelessBootFlag{
            self.session.delegate=self
            self.session.activate()
            print("the session is activated")
        }
    }

    // determins whether session was successfully activated or not
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WC Session activation failed with error: " + "\(error.localizedDescription)")
            self.currentStat="E1-WC activation error: \(error)"
            self.errorLog+="E1 \n \(error) "+"-------------------------"
            self.errorLoger()
            return
        }
        print("WC Session activated with state: " + "\(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    // is called by locationManager(_didUpdateLocations)
    func stringWritter(){
        let myDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-HH:mm:ss"
        let currentTime = dateFormatter.string(from: myDate)
        let fileName = currentTime + ".cm"
        
        var fileContext=fileName + "\n"
        let toBeWritten=self.sensorData
        self.sensorData.removeAll()
        for element in toBeWritten{
            fileContext+=String(round(element*1000)/1000)+"\n"
        }
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let fileURL = dir.appendingPathComponent(fileName)
                try fileContext.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                print("stringWritter successfully wrote the data at",fileName)
                self.filesToBeSenttoPhone[fileName]=fileURL
                self.writtenFiles+=1
                self.lastFile=fileName
                self.sendMsgToPhone()
                self.statusUpdate()
            }
            catch{
                print("Error in the stringWritter Function")
                self.currentStat="E7-stringWritter"
                self.errorLog+="E7 \n "+"-------------------------"
                self.errorLoger()

            }
        }
    }
    
    // called by stringWriter to send data to iPhone
    func sendMsgToPhone(){
        print("sendMsgToPhone Func")
        if WCSession.isSupported() && WCSession.default.isReachable{
            print("Phone is reachable and supported")
            do{
                for (fileName,fileURL) in self.filesToBeSenttoPhone{
                    let fileDes = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                    let fileSize = fileDes.fileSize!
                    let dataContent = try Data.init(contentsOf: fileURL)
                    WCSession.default.sendMessageData(dataContent, replyHandler: nil, errorHandler: { (error) -> Void in
                        self.currentStat="E2-Send: \(error)"
                        print("sendMsgToPhone error 1",error)
                        self.errorLog+="E2 \n \(error) "+"-------------------------"
                        self.errorLoger()
                        return
                    })
                    print("------------Success----------",fileSize/1000," kb ",fileURL)
                    self.filesToBeSenttoPhone.removeValue(forKey: fileName)
                    if !self.keepWatchCopy{
                        self.dataCleaner(fileURL: fileURL)
                    }
                    self.syncedFiles+=1
                    self.statusUpdate()
                }
            }
            catch{
                print("sendMsgToPhone error 2")
                self.currentStat="E3-Send"
                self.errorLog+="E3 \n"+"-------------------------"
                self.errorLoger()

            }
        }
    }
    
    // removes files after they're sent to iPhone
    func dataCleaner(fileURL:URL){
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            print("Error in deleting")
            self.currentStat="E5-dataCleaner"
            self.errorLog+="E5 \n "+"-------------------------"
            self.errorLoger()
        }
    }
    
    // updates the interface with current status
    func statusUpdate(){
        let fileURLs=self.fileListing()
        if fileURLs.count != 0{
            let localFilesInt = fileURLs.count
        }
        else{
            let localFilesInt = fileURLs.count

        }
    }
    
    // validates the list of file URLS
    func fileListing()->[URL]{
        let myDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-HH:mm:ss"
        let fileName = dateFormatter.string(from: myDate)
        print(fileName)
        var fileURLs: Array<URL> = Array()

        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            fileURLs = try fileURLs.sorted{ $0.path < $1.path }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            self.currentStat="E6-FileListing"
            self.errorLog+="E6 \n "+"-------------------------"
            self.errorLoger()
        }
        return fileURLs
    }
}

// MARK: - Helper functions
extension CoreMotionManager {
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
}
*/
