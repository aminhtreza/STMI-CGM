//
//  ContentView.swift
//  continousHeartRateMonitor WatchKit Extension
//
//  Created by iMac on 2/18/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

let AuthorizationManager = authorizationManager()

struct ContentView: View {
    @State var authorized = false
    @State var showAlert = false
    
    var body: some View {
        VStack {
            if authorized {
                mainWatchIFC()
            } else {
                Text("Need access to HealthKit")
                Button("Authorize HealthKit") {
                    AuthorizationManager.AuthorizeHK()
                    withAnimation {
                        if AuthorizationManager.authorized {
                            self.authorized = true
                        } else {
                            self.showAlert = true
                        }
                    }
                }
            }
        }
        .onAppear {
            if AuthorizationManager.authorized {
                self.authorized = true
            } else {
                AuthorizationManager.AuthorizeHK()
            }
        }
        .onAppear(perform: AuthorizationManager.AuthorizeHK)
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
