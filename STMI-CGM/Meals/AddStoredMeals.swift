//
//  StoredMeals.swift
//  CGM-Meals
//
//  Created by iMac on 4/6/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

struct AddStoredMeals: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Meal.entity(), sortDescriptors: []) var meals: FetchedResults<Meal>
    
    @State var addingMeal = false
    
    @State var calories: Double = 0
    @State var carbs: Double = 0
    @State var protein: Double = 0
    @State var fat: Double = 0
    @State var mealName: String? = ""

    let dateFormatter = DateFormatter()
    
    var body: some View {
        VStack {
            NavigationView {
                List{
                    ForEach(meals, id: \.self) {meal in
                        HStack {
                            Image(uiImage: UIImage(data: Data((meal.picture?.imageData)!))!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80, alignment: .center)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                .shadow(radius: 10)
                                .padding()
                            Button(action: {
                                self.addingMeal = true
                                self.mealName = meal.mealName
                                self.carbs = meal.carbs
                                self.protein = meal.protein
                                self.fat = meal.fat
                                self.calories = meal.calories
                            }) {
                                VStack {
                                    Text("\(meal.mealName!)")
                                        .font(.title)
                                    Divider()
                                    Text("Calories: \(Int(meal.calories))")
                                        .multilineTextAlignment(.leading)
                                    Text("\(self.dateFormatter.string(from: meal.inputDate!))")
                                }
                            }
                        }
                    }
                }.navigationBarTitle(Text("Existing meals"),displayMode: .inline)
            }
        }.onAppear(perform: dateformatter)
            .sheet(isPresented: $addingMeal) {
                AddStoredMeal(calories: self.calories, carbs: self.carbs, protein: self.protein, fat: self.fat, mealName: self.mealName)
                .environment(\.managedObjectContext, self.moc)
        }
    }
    func dateformatter() {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
    }
    func deleteMeal(at offsets: IndexSet) {
        for i in offsets {
            let meal = meals[i]
            moc.delete(meal)
        }
        try! self.moc.save()
    }
}


// MARK: - View that adds the meal
struct AddStoredMeal: View {
    @State var calories: Double
    @State var carbs: Double
    @State var protein: Double
    @State var fat: Double
    @State var mealName: String?
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Meal.entity(), sortDescriptors: []) var meals: FetchedResults<Meal>
    
    @Environment(\.presentationMode) var presentation // to make this view dismiss itself
    
    @State var showActionSheet = false
    @State var showImagePicker = false
    @State var showAlert = false
    @State var sourceType: UIImagePickerController.SourceType = .camera
    @State var image: Image?
    @State var inputImage: UIImage?

    var body: some View {
        VStack {
            VStack{
                if image != nil {
                    GeometryReader {geo in
                        self.image?
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                            .border(Color.white,width: 1)
                            .cornerRadius(20)
                            .shadow(radius: 2)
                            .clipped()
                    }
                } else {
                        CameraButton(showActionSheet: $showActionSheet)
                            .frame(width: 100, height: 100, alignment: .center
                    )
                }
            }
            .onTapGesture {
                self.showActionSheet = true
            }
            .frame(width: 250, height: 250, alignment: .center)

            
            Section{
                List {
                    Text("Name: \(self.mealName!)")
                    Text("Calories: \(Int(calories))")
                    Text("Carbs: \(Int(carbs))")
                    Text("Protein: \(Int(protein))")
                    Text("Fat: \(Int(fat))")
                }
                .frame(height: 210)
                .padding()
            }
            Button(action: {
                if self.image != nil {
                    self.saveToMoc()
                } else {
                    self.showAlert.toggle()
                }
            }){
                Text("Add meal")
            }

                // Whenever you click on the camera this will open
            .actionSheet(isPresented: $showActionSheet, content: { () -> ActionSheet in
                ActionSheet(title: Text("Select Image"), buttons: [
                    ActionSheet.Button.default(Text("Camera"), action: {
                        self.showImagePicker.toggle()
                        self.sourceType = .camera
                    }),
                    ActionSheet.Button.default(Text("Photo Gallery"), action: {
                        self.showImagePicker.toggle()
                        self.sourceType = .photoLibrary
                    })
                ])
            })
                // After choosing from camera or gallery this will open
            .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage, sourceType: self.sourceType)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Please upload image"), message: Text("We need an image to store this meal. If you don't have an image please find one on Google that best represents what you ate."), dismissButton: .default(Text("Got it!")))
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else {return}
        image = Image(uiImage: inputImage)
    }
    
    func saveToMoc() {
        let meal = Meal(context: self.moc)
        meal.mealName = self.mealName
        meal.calories = Double(self.calories)
        meal.carbs = Double(self.carbs)
        meal.protein = Double(self.protein)
        meal.fat = Double(self.fat)
        meal.inputDate = Date()
        
        meal.picture = Picture(context: self.moc)
        meal.picture?.imageData = self.inputImage?.jpegData(compressionQuality: 100)
        
        do {try self.moc.save()}
        catch {print(error)}
    
        self.presentation.wrappedValue.dismiss()
    }
}


// MARK: - Preview
struct StoredMeals_Previews: PreviewProvider {
    static var previews: some View {
        AddStoredMeals()
    }
}


