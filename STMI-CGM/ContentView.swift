//
//  ContentView.swift
//  STMI-CGM
//
//  Created by iMac on 5/7/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI
var phoneToWatch = PhonetoWatch()
struct ContentView: View {
    @FetchRequest(entity: Credentials.entity(), sortDescriptors: []) var credentials: FetchedResults<Credentials>
    
    var body: some View {
        MainUI()
        //AuthorizePage()
        /*
        if credentials.count == 0 {
            AuthorizePage()
        } else {
            MainUI()
        }
        */
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
