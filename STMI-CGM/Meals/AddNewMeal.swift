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
    
    @State var startTime: Date = Date()
    @State var startTimeSelected = false
    @State var finishTime: Date = Date()
    @State var finishTimeSelected = false
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Meal.entity(), sortDescriptors: []) var meals: FetchedResults<Meal>
    @Environment(\.presentationMode) var presentation // to make this view dismiss itself
    
    @State var showActionSheet = false
    @State var showImagePicker = false
    @State var showAlert = false
    @State var sourceType: UIImagePickerController.SourceType = .camera
    @State var image: Image?
    @State var inputImage: UIImage?
    @State var cameraPic = false
    
    @State var eatingNow = false
    @State var oldMeal = false
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    Section{
                        List {
                            TextField("Name" ,text:  self.$mealName)
                            TextField("Calories", text: self.$calories)
                            TextField("Protein", text: self.$protein)
                            TextField("Carbs", text: self.$carbs)
                            TextField("Fat", text: self.$fat)
                        }
                        .padding()
                    }
                    VStack{
                        if self.image != nil {
                             self.image?
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150, alignment: .center)
                                .clipShape(Rectangle())
                                .cornerRadius(20)
                                .shadow(radius: 10)
                                .onTapGesture {self.showActionSheet = true}
                                .padding()
                        } else {
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .foregroundColor(.blue)
                                .imageScale(.large)
                                .frame(width: 130, height: 130, alignment: .center)
                                .onTapGesture {self.showActionSheet = true}
                                .padding()
                        }
                    }.onTapGesture {self.showActionSheet = true}
                }.frame(width: geo.size.width, height: geo.size.height/2, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                HStack {
                    Button("Start eating") {
                        withAnimation{self.eatingNow.toggle()}
                    }.buttonStyle(NotSelectedButtonStyle(selected: self.eatingNow)).padding()
                    Button("Input old meal") {
                        withAnimation{self.oldMeal.toggle()}
                    }.buttonStyle(NotSelectedButtonStyle(selected: self.oldMeal)).padding()
                }.padding()
                
                if eatingNow {
                    VStack {
                        if !startTimeSelected {
                            Button("Start") {
                                self.startTime = Date()
                                withAnimation{self.startTimeSelected = true}
                            }.buttonStyle(NotSelectedButtonStyle())
                        } else {
                            Text(startTime, style: .time).padding(.horizontal)
                        }
                        
                        if !finishTimeSelected {
                            Button("Finish") {
                                self.finishTime = Date()
                                withAnimation{self.finishTimeSelected = true}
                            }.buttonStyle(NotSelectedButtonStyle())
                        } else {
                            Text(finishTime, style: .time).padding(.horizontal)
                        }
                    }
                }
                
                if oldMeal {
                    VStack {
                        DatePicker("Start time", selection: self.$startTime)
                        DatePicker("Finish time", selection: self.$finishTime)
                    }.padding()
                }
                
                Spacer()
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
                }.padding()

                // Whenever you click on the camera this will open
                .actionSheet(isPresented: self.$showActionSheet, content: { () -> ActionSheet in
                    ActionSheet(title: Text("Select Image"), buttons: [
                        ActionSheet.Button.default(Text("Camera"), action: {
                            self.showImagePicker.toggle()
                            self.sourceType = .camera
                            self.cameraPic = true
                        }),
                        ActionSheet.Button.default(Text("Photo Gallery"), action: {
                            self.showImagePicker.toggle()
                            self.sourceType = .photoLibrary
                            self.cameraPic = false
                        }),
                        ActionSheet.Button.cancel()
                    ])
                })
                    // After choosing from camera or gallery this will open
                
                    .sheet(isPresented: self.$showImagePicker, onDismiss: self.loadImage) {
                    ImagePicker(image: self.$inputImage, camera: self.$cameraPic)
                }
                .alert(isPresented: self.$showAlert) {
                    Alert(title: Text("Please upload image"), message: Text("We need an image to store this meal. If you don't have an image please find one on Google that best represents what you ate."), dismissButton: .default(Text("Got it!")))
                }
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
        meal.startTime = startTime
        meal.finishTime = finishTime
        meal.picture = self.inputImage?.jpegData(compressionQuality: 100)
        
        do {try self.moc.save()}
        catch {print(error)}
    
        self.presentation.wrappedValue.dismiss()
        
    }
}


/*
struct AddMeal_Previews: PreviewProvider {
    static var previews: some View {
        AddNewMeal(mealName: "", calories: "", protein: "", carbs: "", fat: "")
    }
}
*/
