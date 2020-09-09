//
//  ContentView.swift
//  STMI-CGM
//
//  Created by iMac on 5/7/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            MainUI() // Navigates to meals and activities
                .tabItem {
                    Text("Entries")
                    Image(systemName: "book.fill")
                    
            }
            WatchConnectivityPreview() // displayes motion sensor data
                .tabItem {
                    Text("Sensors")
                    Image(systemName: "rays")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
