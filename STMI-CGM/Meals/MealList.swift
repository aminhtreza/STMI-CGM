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
    @State private var showAlert:Bool=true
    
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
                            let calVal=meal.calories
                            let proVal=meal.protein
                            let carbVal=meal.carbs
                            let fatVal=meal.fat
                            let mealPicAdd=self.mealPictureFileNameGetter(thisMeal:meal)
                            let mealPicUIImage=MealPictureGetter(mealPicAdd:mealPicAdd)
                            let mealPicImage=Image(uiImage: mealPicUIImage)
//                            testSorush(str:mealPicAdd)
                            NavigationLink(meal.mealName!,destination: EditMeal(meal:meal,mealName:meal.mealName!,calories: String(calVal),protein: String(proVal),carbs: String(carbVal),fat: String(fatVal),ingredients:meal.ingredients!,portions:meal.portions!,startTime: meal.startTime,startTimeSelected:true, finishTime: meal.finishTime,finishTimeSelected:true,image: mealPicImage,inputImage: mealPicUIImage,mealPicAdd: mealPicAdd))
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
    func mealPictureFileNameGetter(thisMeal:Meal) -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        var mealPicAdd=String(thisMeal.objectID.debugDescription)
        var index = mealPicAdd.index(mealPicAdd.lastIndex(of: "/")!, offsetBy: 1)
        mealPicAdd=String(mealPicAdd[index...])
        
        index = mealPicAdd.index(mealPicAdd.lastIndex(of: ">")!, offsetBy: 0)
        mealPicAdd=String(mealPicAdd[..<index])
        
        mealPicAdd = documentsDirectory.appendingPathComponent(mealPicAdd+".jpeg").path
        print(mealPicAdd)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: mealPicAdd) {
            mealPicAdd=""
        }
        return mealPicAdd
    }
    func MealPictureGetter(mealPicAdd:String)->UIImage{
        if mealPicAdd==""{
            let mealPicUIImage=UIImage(systemName: "heart.fill")
            return mealPicUIImage!
        }
        let mealPicUIImage=UIImage(named: mealPicAdd)
        return mealPicUIImage!
    }
    func testSorush(str:String){
        print("I am here!!!!!")
        print(str)
        print("I am here!!!!!")
    }
}
