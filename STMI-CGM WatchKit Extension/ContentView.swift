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
    
    var body: some View {
        VStack{
            Button("Good morning") {
                self.ref.child("MorningEntry").child("\(coreMotionManager.getDate())").setValue(["Good morning": "participant"])
            }
        }
        .padding()
        
        .onAppear {
            coreMotionManager.loader()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Authorization Failed"), message: Text("Try restarting or reinstalling the app"), dismissButton: .default(Text("Dismiss")))
        }
         
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
