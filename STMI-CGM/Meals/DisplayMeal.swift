//
//  DisplayMeal.swift
//  STMI-CGM
//
//  Created by iMac on 12/17/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

struct DisplayMeal: View {
    @State var mealName: String = "Unknown"
    @State var image: Image?
    @State var startTime: Date
    @State var finishTime: Date
    @State var calories: Double
    @State var protein: Double
    @State var carbs: Double
    @State var fat: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    self.image!
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height - 80, alignment: .center)
                    .clipShape(Rectangle())
                    .mask(LinearGradient(gradient: fade, startPoint: .bottom, endPoint: .top))
                    Spacer()
                }
                VStack {
                    Text("\(self.mealName)").font(.custom("Teko-Medium", size: 70))
                    Text(self.startTime, style: .date)
                    HStack {
                        Text(self.startTime, style: .time).font(.headline)
                        Text("-")
                        Text(self.finishTime, style: .time).font(.headline)
                    }
                    if self.calories != 0.0 {Text("Calories: \(Int(self.calories.rounded(toPlaces: 2)))")}
                    if self.protein != 0.0 {Text("Protein: \(Int(self.protein.rounded(toPlaces: 2)))")}
                    if self.carbs != 0.0 {Text("Carbohydrates: \(Int(self.carbs.rounded(toPlaces: 2)))")}
                    if self.fat != 0.0 {Text("Fat: \(Int(self.fat.rounded(toPlaces: 2)))")}
                }
            }
        }
    }
}

