//
//  AddNewEntry.swift
//  STMI-CGM
//
//  Created by iMac on 5/14/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

struct AddNewEntry: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Meal.entity(), sortDescriptors: []) var meals: FetchedResults<Meal>
    enum ActiveSheet {
       case first, second
    }
    func closeSheet() {
        self.showSheet = false
    }

    @State private var showSheet = false
    @State private var activeSheet: ActiveSheet = .first
    
    var body: some View {
        HStack{
            Button(action: {
                self.showSheet = true
                self.activeSheet = .first
            }) {
                VStack{
                    Image("activity")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140, height: 140, alignment: .center)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("maroon"), lineWidth: 2))
                        .shadow(radius: 10)
                        .padding()
                    Text("Activity")
                        .font(.custom("Teko-Medium", size: 25))
                        .foregroundColor(Color.white)
                        .frame(width: 125, height: 60, alignment: .center)
                        .background(Color.blue)
                        .cornerRadius(40)
                }
            }
            Divider()
            Button(action: {
                self.showSheet = true
                self.activeSheet = .second
            }, label:{
                VStack {
                    Image("meal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140, height: 140, alignment: .center)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("maroon"), lineWidth: 2))
                        .shadow(radius: 10)
                        .padding()
                    Text("Meal")
                        .font(.custom("Teko-Medium", size: 25))
                        .foregroundColor(Color.white)
                        .frame(width: 125, height: 60, alignment: .center)
                        .background(Color.blue)
                        .cornerRadius(40)

                }
            })
        }
        .sheet(isPresented: $showSheet, onDismiss: closeSheet) {
            if self.activeSheet == .first {
                ActivityMainIFC().navigationBarTitle("STMI", displayMode: .inline)
                .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            } else {
                MealList().navigationBarTitle("STMI", displayMode: .inline)
                .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            }
            
        }
    }
}

struct AddNewEntry_Previews: PreviewProvider {
    static var previews: some View {
        AddNewEntry()
    }
}
