//
//  Buttons.swift
//  STMI-CGM
//
//  Created by iMac on 12/16/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

struct NotSelectedButtonStyle: ButtonStyle {
    var selected: Bool = false
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white).opacity(1)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(self.selected ? Color.red : Color.black).opacity(0.5)
            .cornerRadius(15.0)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
