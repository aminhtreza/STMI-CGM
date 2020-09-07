//
//  MainUI.swift
//  STMI-CGM
//
//  Created by iMac on 5/7/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

struct MainUI: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Activity.entity(), sortDescriptors: []) var activities: FetchedResults<Activity>
    @FetchRequest(entity: Meal.entity(), sortDescriptors: []) var meals: FetchedResults<Meal>

    @State var username = "Amin"
    @State var dayNum = 420
    @State var addNewEntry = false
    
    func calcTotEntries(count: inout Int) {
        count = meals.count + activities.count
    }
    var body: some View {
        VStack{
            VStack{
                Image("STMITamu")
                    .resizable()
                    .frame(width: 375, height: 50, alignment: .center)
                    .scaledToFill()
                Text("Systems and Technology for Medicine and IoT lab")
                .multilineTextAlignment(.center)
                .frame(width: 300, height: 150, alignment: .center)
                .font(.custom("Anton-Regular", size: 30))
            }//.onAppear(perform: calcTotEntries(count: &dayNum))
            AddNewEntry()
            /*
            HStack{
                Text("Hey \(username)")
                .font(.custom("BalooDa2-Medium", size: 24))
                .frame(width: 180, height: 60, alignment: .center)
                .multilineTextAlignment(.leading)

                VStack{
                    Text("Day \(dayNum)/14")
                    .font(.custom("Teko-Medium", size: 20))
                    .multilineTextAlignment(.leading)
                    Text("Total entries: \(dayNum)")
                    .font(.custom("Teko-Medium", size: 20))
                    .multilineTextAlignment(.leading)
                }.padding()
            }*/
        }
    }
}

struct MainUI_Previews: PreviewProvider {
    static var previews: some View {
        MainUI()
    }
}


