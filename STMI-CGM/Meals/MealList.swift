//
//  MealList.swift
//  CGM-Meals
//
//  Created by iMac on 4/6/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

struct MealList: View {
    @Environment(\.managedObjectContext) var moc
    //@FetchRequest(entity: Meal.entity(), sortDescriptors: []) var meals: FetchedResults<Meal>
    @State private var showSheet = false
    @State private var activeSheet: ActiveSheet = .first
    
    let dateFormatter = DateFormatter()
    func dateformatter() {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
    }
    
    var body: some View {
        VStack {
            NavigationView {
                List{
                    /*
                    Button(action: {
                        self.showSheet = true
                        self.activeSheet = .first
                        print(self.meals.count)
                    }) {
                        Section {
                            HStack{
                                Text("Add new meal")
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                            }
                        }
                    }.padding()
                    Button(action: {
                        self.showSheet = true
                        self.activeSheet = .second
                        print(self.meals.count)
                    }) {
                        Section {
                            HStack{
                                Text("Add existing meal")
                                Spacer()
                                Image(systemName: "doc.fill")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                            }
                        }
                    }.padding()
                    */
                    Section(header: Text("History")) {
                        /*
                        ForEach(meals, id: \.self) {meal in
                           HStack {
                                Text("\(meal.mealName!)")
                                .font(.title)
                                .frame(width: 117, height: 60, alignment: .center)
                                Divider()
                                VStack {
                                    Text("Calories: \(Int(meal.calories))")
                                    .multilineTextAlignment(.leading)
                                    Text("Date: \(self.dateFormatter.string(from: meal.inputDate!))")
                                }                                
                            }
                        }.onDelete(perform: deleteMeal)
                        */
                    }
                }
                .navigationBarTitle(Text("My meals"),displayMode: .inline)
            }.onAppear(perform: dateformatter)
            .sheet(isPresented: $showSheet, onDismiss: closeSheet) {
                if self.activeSheet == .first {
                    AddNewMeal().navigationBarTitle("STMI", displayMode: .inline)
                    .environment(\.managedObjectContext, self.moc)
                } else {
                    AddStoredMeals().navigationBarTitle("STMI", displayMode: .inline)
                    .environment(\.managedObjectContext, self.moc)
                }
            }
        }
    }
    
    func deleteMeal(at offsets: IndexSet) {
        /*
        for i in offsets {
            let meal = meals[i]
            moc.delete(meal)
        }
        try! self.moc.save()
         */
    }
    
    func closeSheet() {
        self.showSheet = false
    }
    enum ActiveSheet {
       case first, second
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        MealList()
    }
}
