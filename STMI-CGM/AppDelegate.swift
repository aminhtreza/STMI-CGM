//
//  AppDelegate.swift
//  STMI
//
//  Created by Ryan Ramirez on 3/22/20.
//  Copyright © 2020 Ryan Ramirez. All rights reserved.
//

// !!!!!!!!!!!!!!!!!!!!!!! ATTENTION READ BELOW !!!!!!!!!!!!!!!!!!!!!
// The loader function below needs to be modified the first time you install the app. We need to gather the participant id prior to storing data. Therefore, the portion that calls the participant id needs to be blocked off and then uncommented and redeplyed after the first run

import UIKit
import CoreData
import Foundation
import WatchConnectivity
import Network
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    let session = WCSession.default
    var fileNumber=0
    var uID = ""
    let keepPhoneCopy = false
    var internetConnectivity=false
    let monitor = NWPathMonitor()
    var filesToBeSent = [String: URL]()
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.loader()
        return true
    }
    
    func loader(){
        var cred: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Credentials")
        do {
            cred = try self.persistentContainer.viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // comment this part when deploying the code for the first time
        ///*
        ///
        if cred.isEmpty {
            self.uID = "99 didn't work"
        } else {
            let participantIds = cred[0].committedValues(forKeys: ["participantId"])
            let id = participantIds["participantId"]
            self.uID = id as! String // UID of the iPhone for documentation
        }
        
        //*/
        
        self.setupWatchConnectivity() // Establishes connection with the apple watch
        self.internetStat() // Determins whether device is connected to the internet
        FirebaseApp.configure() // Establishes connection with Firebase
    }
    
    // Establish connection with apple watch
    func setupWatchConnectivity() {
        print("setupWatchConnectivity func")
        if WCSession.isSupported() {
            self.session.delegate = self
            if self.session.activationState == .activated {
                print("the session is already activated")
                return
            }
            self.session.activate()
            print("the session is activated")
        }
    }
    
    // Determins whether device is connected to the internet
    func internetStat(){
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.internetConnectivity=true
            } else {
                self.internetConnectivity=false
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        
        
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Watch Session delegate functions
    // Background functions that are automatically run
    
    // Defines actions for whenever iphone receives a message from the watch
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("successfully recieved a msg",messageData.count)
        self.msgSaver(messageData: messageData) // saves the incoming message data
    }
    
    // Defines actions for whenever iphone receives a file from the watch
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("file has been recieved")
        self.errorSender(fileURL: file.fileURL) // stores files to firebase
    }
   
    // Defines actions for whenever watch session is deactivated
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // MARK: - WatchSession: didReceiveMessageData
    func msgSaver(messageData:Data){
        print("msgSaver called ")
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let fileURL = dir.appendingPathComponent("TempFile.stmi")
                try messageData.write(to: fileURL)
                let fileContext=self.stringReader(fileURL: fileURL) // calls stringReader function
                self.stringWriter(fileContext: fileContext) // calls stringWriter function
            }
            catch{
                print("msgSaver error")
            }
        }
    }
    
    // reads msg recieved from watch as a string
    func stringReader(fileURL:URL)->String{
        do {
            let fileContext = try String(contentsOf: fileURL, encoding: .utf8)
            return fileContext
        }
        catch {
            print("stringReader error")
        }
        return String("")
    }
    
    // writes string received from watch to firebase
    func stringWriter(fileContext:String){
        var index = fileContext.index(fileContext.firstIndex(of: "\n")!,offsetBy: 1)
        let actualContextTemp = fileContext[index...]
        let actualContext = String(actualContextTemp)
        
        index = fileContext.index(fileContext.firstIndex(of: "\n")!,offsetBy: -1)
        let fileNameTemp = fileContext[...index]
        let fileName = String(fileNameTemp)
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let fileURL = dir.appendingPathComponent(fileName)
                try actualContext.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                print("stringWritter successfully wrote the data at",fileName)
                self.filesToBeSent[fileName] = fileURL
                self.fireBaseUploader()
            }
            catch{
                print("stringWritter error")
            }
        }
    }
    
    // uploads string received from watch to firebase
    func fireBaseUploader(){
        print("fireBaseUploader")
        if self.internetConnectivity{
            let storage=Storage.storage()
            let storageRef = storage.reference()
            for (fileName, fileURL) in self.filesToBeSent {
                let fileRef = storageRef.child(self.uID+"/"+fileName)
                let uploadTask = fileRef.putFile(from: fileURL, metadata: nil) { metadata, error in
                    guard let metadata = metadata else {
                        print("firBaseUploader error:",error)
                        return
                    }
                    let size = metadata.size
                    print("File is uploaded successfully:",fileName,size)
                    self.filesToBeSent.removeValue(forKey: fileName)
                    if !self.keepPhoneCopy{
                        self.dataCleaner(fileURL: fileURL) // cleans the fileURL for future readings
                    }
                }
            }
        }
    }
    
    // MARK: - WatchSession: didReceive file
    func errorSender(fileURL:URL){
        let fileURL=self.errorFileCopier(fileURL: fileURL)
        if self.internetConnectivity{
            let storage=Storage.storage()
            let storageRef = storage.reference()
            let fileRef = storageRef.child(self.uID+"/"+"errorLog")
            fileRef.putFile(from: fileURL, metadata: nil)
        }
    }
    
    func errorFileCopier(fileURL:URL)->URL{
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURLCopy = dir!.appendingPathComponent("errorLog")
        var fileContext=""
        do {
            fileContext = try String(contentsOf: fileURL, encoding: .utf8)
            try fileContext.write(to: fileURLCopy, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            print("stringReader error")
            return fileURLCopy
        }
        return fileURLCopy
    }

    
    // MARK: Helper functions
    func fileListing()->[URL]{
        var fileURLs: Array<URL> = Array()
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            fileURLs = try fileURLs.sorted{ $0.path < $1.path }
        } catch {
            print("fileListing error: \(error.localizedDescription)")
        }
        return fileURLs
    }

    func dataCleaner(fileURL:URL){
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            print("dataCleaner error")
        }
    }
    
    enum STMIError: Error {
        case IOError
        case sortingError
        case fireBaseError
    }


    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "STMI-CGMcoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

