//
//  AddMeal.swift
//  CGM-Meals
//
//  Created by iMac on 4/6/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI

struct AddNewMeal: View {
    @State var mealName:String = ""
    @State var calories: String = ""
    @State var protein: String = ""
    @State var carbs: String = ""
    @State var fat: String = ""
    
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
                    TextField("Name" ,text:  $mealName)
                    TextField("Calories", text: $calories)
                    TextField("Protein", text: $protein)
                    TextField("Carbs", text: $carbs)
                    TextField("Fat", text: $fat)
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
                .font(.custom("Teko-Medium", size: 25))
                .foregroundColor(Color.white)
                .frame(width: 220, height: 60, alignment: .center)
                .background(Color.blue)
                .cornerRadius(40)
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
        meal.calories = Double(self.calories) ?? 0
        meal.carbs = Double(self.carbs) ?? 0
        meal.protein = Double(self.protein) ?? 0
        meal.fat = Double(self.fat) ?? 0
        meal.inputDate = Date()
        
        meal.picture = Picture(context: self.moc)
        meal.picture?.imageData = self.inputImage?.jpegData(compressionQuality: 100)
        
        do {try self.moc.save()}
        catch {print(error)}
    
        self.presentation.wrappedValue.dismiss()
    }
}

struct CameraButton: View{
    @Binding var showActionSheet: Bool //binding variables come from other places and are shared within the structs
    
    var body: some View {
        Button(action: {
            self.showActionSheet.toggle()
        }){
            Image(systemName: "camera.circle.fill")
            .resizable()
            .imageScale(.large)
            
        }
    }
}

struct AddMeal_Previews: PreviewProvider {
    static var previews: some View {
        AddNewMeal(mealName: "", calories: "", protein: "", carbs: "", fat: "")
    }
}
