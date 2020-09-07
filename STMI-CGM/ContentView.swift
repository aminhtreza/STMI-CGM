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
            MainUI()
                .tabItem {
                    Text("Entries")
                    Image(systemName: "book.fill")
                    
            }
            WatchConnectivityPreview()
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
