//
//  ContentView.swift
//  continousHeartRateMonitor WatchKit Extension
//
//  Created by iMac on 2/18/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State var authorized = false
    @State var showAlert = false
    @State var hr = 0.0
    var ref: DatabaseReference! = Database.database().reference()
    
    @ObservedObject var coreMotionManager = CoreMotionManager()
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var HeartRateManager = heartRateManager()
    var body: some View {
        VStack{
            HStack{
                Text("❤️").font(.system(size: 50))
                Spacer()
            }
            HStack{
                Text("\(coreMotionManager.accelx)")
                    .fontWeight(.regular)
                    .font(.system(size: 70))
                Text("BPM")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.red)
                    .padding(.bottom, 28.0)
                Spacer()
            }
        }
        .padding()
        .onAppear {
            coreMotionManager.loader()
            print("loader ran")
            if HeartRateManager.authorized {
                self.authorized = true
            } else {
                HeartRateManager.AuthorizeHK()
            }
            
            
        }
        .onAppear(perform: HeartRateManager.AuthorizeHK)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Authorization Failed"), message: Text("Try restarting or reinstalling the app"), dismissButton: .default(Text("Dismiss")))
        }
        .onReceive(timer) { _ in
            coreMotionManager.storeMotionData()
            //self.ref.child("motion").child("roll").setValue(["username": "username"])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
