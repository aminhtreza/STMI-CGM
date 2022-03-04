//
//  MealList.swift
//  CGM-Meals
//
//  Created by iMac on 4/6/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

struct DetailView:View{
    var mymsg:Meal
    var body: some View{
        Text(mymsg.mealName!)
    }
}

struct MealList: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Meal.entity(), sortDescriptors: []) var meals: FetchedResults<Meal>
    @State private var showSheet = false
    @State private var activeSheet: ActiveSheet = .first
    
    let dateFormatter = DateFormatter()
    let localizedString = NSLocalizedString("LOCALIZED-STRING-KEY", comment: "Describe what is being localized here")
    
    var body: some View {
        VStack {
            NavigationView { // My meals
                List{
                    
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
                    Section(header: Text("History")) {
                        ForEach(meals.reversed(), id: \.self) {meal in
                            NavigationLink(meal.mealName!, destination: DisplayMeal(mealName: meal.mealName!, image: Image(uiImage: UIImage(data: Data((meal.picture!)))!), startTime: meal.startTime, finishTime: meal.finishTime, calories: meal.calories, protein: meal.protein, carbs: meal.carbs, fat: meal.fat, ingredients: meal.ingredients!, portions: meal.portions!))
                            HStack {
                                Image(uiImage: UIImage(data: Data((meal.picture!)))!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100, alignment: .center)
                                    .clipShape(Circle())
                                    .cornerRadius(20)
                                    .shadow(radius: 10)
                                    .padding()
                                VStack {
                                    Text(meal.startTime, style: .date)
                                    HStack {
                                        Text(meal.startTime, style: .time)
                                        Text("-")
                                        Text(meal.finishTime, style: .time)
                                    }

                                }
                            }
                        }.onDelete(perform: deleteMeal)
                    }
                }.navigationBarTitle(Text("My meals"),displayMode: .inline)
            }.sheet(isPresented: $showSheet) {
                if self.activeSheet == .first {
                    AddNewMeal().navigationBarTitle("STMI", displayMode: .inline)
                        .environment(\.managedObjectContext, self.moc)
                }
            }
        }
    }
    func deleteMeal(at offsets: IndexSet) {
        for i in offsets {
            let meal = meals.reversed()[i]
            moc.delete(meal)
        }
        try! self.moc.save()
    }
}
