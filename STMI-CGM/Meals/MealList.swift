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
    @FetchRequest(entity: Meal.entity(), sortDescriptors: []) var meals: FetchedResults<Meal>
    @State private var showSheet = false
    @State private var activeSheet: ActiveSheet = .first
    
    @State var image: Image?
    @State var mealName = ""
    @State var startTime = Date()
    @State var finishTime = Date()
    @State var calories = 0.0
    @State var protein = 0.0
    @State var carbs = 0.0
    @State var fat = 0.0
    @State var ingredients = ""
    @State var portions = ""
    
    let dateFormatter = DateFormatter()
    
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
                                    Text("\(meal.mealName!)")
                                        .font(.headline)
                                    Text(meal.startTime, style: .date)
                                    HStack {
                                        Text(meal.startTime, style: .time)
                                        Text("-")
                                        Text(meal.finishTime, style: .time)
                                    }
                                    
                                }                                
                           }.onTapGesture {
                                self.image = Image(uiImage: UIImage(data: Data((meal.picture!)))!)
                                self.startTime = meal.startTime
                                self.finishTime = meal.finishTime
                                self.mealName = meal.mealName ?? "Missing meal name"
                                self.calories = meal.calories
                                self.carbs = meal.carbs
                                self.fat = meal.fat
                                self.protein = meal.protein
                                self.ingredients = meal.ingredients ?? "Missing ingredients"
                                self.portions = meal.portions ?? "Missing portios"
                                self.activeSheet = .second
                                self.showSheet = true
                           }
                        }.onDelete(perform: deleteMeal)
                    }
                }.navigationBarTitle(Text("My meals"),displayMode: .inline)
            }//.onAppear(perform: dateformatter)
            .sheet(isPresented: $showSheet, onDismiss: closeSheet) {
                if self.activeSheet == .first {
                    AddNewMeal().navigationBarTitle("STMI", displayMode: .inline)
                        .environment(\.managedObjectContext, self.moc)
                } else if self.activeSheet == .second {
                    DisplayMeal(mealName: self.mealName, image: self.image, startTime: self.startTime, finishTime: self.finishTime, calories: self.calories, protein: self.protein, carbs: self.carbs, fat: self.fat, ingredients: self.ingredients, portions: self.portions)
                }
            }
        }
    }
}

extension MealList {
    func deleteMeal(at offsets: IndexSet) {
        for i in offsets {
            let meal = meals.reversed()[i]
            moc.delete(meal)
        }
        try! self.moc.save()
         
    }
    
    func closeSheet() {
        self.showSheet = false
    }
    
    enum ActiveSheet {
       case first, second
    }
    
    func dateformatter() {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        MealList()
    }
}
