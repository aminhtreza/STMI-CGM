//
//  E4Main.swift
//  STMI-CGM
//
//  Created by iMac on 5/10/21.
//  Copyright © 2021 Amin Hamiditabar. All rights reserved.
//

import SwiftUI


struct E4Main: View {
    @ObservedObject var empatica = Empatica()
    @State var showSheet = false
    var body: some View {
        NavigationView {
            VStack {
                ForEach(self.empatica.devices, id: \.self) { device in
                    Text(device.serialNumber)
                }
                Text("GSR length: \(self.empatica.pE4GSR.count)")
                Text("Temp length: \(self.empatica.pE4Temp.count)")
                Text("x length: \(self.empatica.pE4x.count)")
                Text("y length: \(self.empatica.pE4y.count)")
                Text("z length: \(self.empatica.pE4z.count)")
                Button("Update values") {
                    self.empatica.updateValues()
                }
                Button("Discover new devices") {
                    self.showSheet = true
                }
            }
        }.sheet(isPresented: $showSheet, onDismiss: closeSheet) {
            E4(empatica: empatica)
        }
    }
}

extension E4Main {
    func closeSheet() {
        self.showSheet = false
    }
}

struct E4Main_Previews: PreviewProvider {
    static var previews: some View {
        E4Main()
    }
}
