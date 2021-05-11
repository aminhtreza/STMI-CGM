//
//  E4.swift
//  STMI-CGM
//
//  Created by iMac on 5/10/21.
//  Copyright © 2021 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

struct E4: View {
    @ObservedObject var empatica: Empatica = Empatica()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.presentationMode) var presentation // to make this view dismiss itself
    var body: some View {
        VStack {
            Section {
                Button("Discover") {
                    self.empatica.discover()
                }
                Text(self.empatica.deviceStatus)
                Text("z count: \(self.empatica.pE4z.count)")
                ForEach(self.empatica.devices, id: \.self) {device in
                    List {
                        Button {
                            self.empatica.connect(device: device)
                        } label: {
                            Text("E4 \(device.serialNumber)")
                            
                        }.onReceive(timer) { time in
                            self.empatica.deviceStatusDisplay(status: device.deviceStatus)
                        }
                    }
                }
            }
            .onAppear {
                self.empatica.authenticate()
            }
            .onReceive(timer) { time in
                //self.empatica.updateValues()
            }
        }.navigationBarTitle(Text("Devices"),displayMode: .inline)
    }
}


class Empatica: UIResponder, ObservableObject {
    @Published var devices: [EmpaticaDeviceManager] = []
    @Published var deviceStatus = "Not connected"
    
    @Published var pE4x: [Int] = []
    @Published var pE4y: [Int] = []
    @Published var pE4z: [Int] = []
    @Published var pE4GSR: [Double] = []
    @Published var pE4Temp: [Double] = []
    
    var E4x: [Int] = []
    var E4y: [Int] = []
    var E4z: [Int] = []
    var E4GSR: [Double] = []
    var E4Temp: [Double] = []
    
    func updateValues() {
        self.pE4x = self.E4x
        self.pE4y = self.E4y
        self.pE4z = self.E4z
        self.pE4Temp = self.E4Temp
        self.pE4GSR = self.E4GSR
    }
    
    static let EMPATICA_API_KEY = "e1570faea3b245ccafd361fa5af4f60a"
    private var allDisconnected : Bool {
        return self.devices.reduce(true) { (value, device) -> Bool in
            value && device.deviceStatus == kDeviceStatusDisconnected
        }
    }
    
    func authenticate() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
          EmpaticaAPI.authenticate(withAPIKey: "e1570faea3b245ccafd361fa5af4f60a") { (status, message) in
              if status {
                  // "Authenticated" here you can start discovering devices
                print("Authenticated")
                self.discover()
              }
          }
        }
    }
    
    func discover() {
        EmpaticaAPI.discoverDevices(with: self)
    }
    
    func disconnect(device: EmpaticaDeviceManager) {
        if device.deviceStatus == kDeviceStatusConnected {
            device.disconnect()
        }
        else if device.deviceStatus == kDeviceStatusConnecting {
            device.cancelConnection()
        }
    }
    
    func connect(device: EmpaticaDeviceManager) {
        device.connect(with: self)
    }
    
    func deviceStatusDisplay(status : DeviceStatus) {
        switch status {
        case kDeviceStatusDisconnected:
            self.deviceStatus = "Disconnected"
        case kDeviceStatusConnecting:
            self.deviceStatus = "Connecting..."
        case kDeviceStatusConnected:
            self.deviceStatus = "Connected"
        case kDeviceStatusFailedToConnect:
            self.deviceStatus = "Failed to connect"
        case kDeviceStatusDisconnecting:
            self.deviceStatus = "Disconnecting..."
        default:
            self.deviceStatus = "Unknown"
        }
    }
    
    private func restartDiscovery() {
        print("restartDiscovery")
        guard EmpaticaAPI.status() == kBLEStatusReady else { return }
        if self.allDisconnected {
            print("restartDiscovery • allDisconnected")
            self.discover()
        }
    }
}
 
extension Empatica: EmpaticaDelegate {
    func didDiscoverDevices(_ devices: [Any]!) {
        print("didDiscoverDevices")
        self.devices.removeAll()
        self.devices.append(contentsOf: devices as! [EmpaticaDeviceManager])
        DispatchQueue.main.async {
            //self.tableView.reloadData()
        }
    }
    
    func didUpdate(_ status: BLEStatus) {
        switch status {
        case kBLEStatusReady:
            print("[didUpdate] status \(status.rawValue) • kBLEStatusReady")
            break
        case kBLEStatusScanning:
            print("[didUpdate] status \(status.rawValue) • kBLEStatusScanning")
            break
        case kBLEStatusNotAvailable:
            print("[didUpdate] status \(status.rawValue) • kBLEStatusNotAvailable")
            break
        default:
            print("[didUpdate] status \(status.rawValue)")
        }
    }
    
}

extension Empatica: EmpaticaDeviceDelegate {
    
    func didReceiveTemperature(_ temp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        print("\(device.serialNumber!) TEMP { \(temp) }")
        //self.E4Temp.append(Double(temp))
    }
    
    func didReceiveAccelerationX(_ x: Int8, y: Int8, z: Int8, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        print("\(device.serialNumber!) ACC > {x: \(x), y: \(y), z: \(z)}")
        /*
        self.E4x.append(Int(x))
        self.E4y.append(Int(y))
        self.E4z.append(Int(z))
        */
    }
    
    func didReceiveTag(atTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        print("\(device.serialNumber!) TAG received { \(timestamp) }")
        
    }
    
    func didReceiveGSR(_ gsr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        print("\(device.serialNumber!) GSR { \(abs(gsr)) }")
        //self.E4GSR.append(Double(gsr))
        //self.updateValue(device: device, string: "\(String(format: "%.2f", abs(gsr))) µS")
    }
    
    func didUpdate( _ status: DeviceStatus, forDevice device: EmpaticaDeviceManager!) {
        //self.updateValue(device: device)
        switch status {
        case kDeviceStatusDisconnected:
            print("[didUpdate] Disconnected \(device.serialNumber!).")
            self.restartDiscovery()
            break
        case kDeviceStatusConnecting:
            print("[didUpdate] Connecting \(device.serialNumber!).")
            break
        case kDeviceStatusConnected:
            print("[didUpdate] Connected \(device.serialNumber!).")
            break
        case kDeviceStatusFailedToConnect:
            print("[didUpdate] Failed to connect \(device.serialNumber!).")
            self.restartDiscovery()
            break
        case kDeviceStatusDisconnecting:
            print("[didUpdate] Disconnecting \(device.serialNumber!).")
            break
        default:
            break
        }
    }
}

