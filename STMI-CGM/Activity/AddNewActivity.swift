//
//  practiceAddActivity.swift
//  STMI
//
//  Created by iMac on 3/26/20.
//  Copyright © 2020 Ryan Ramirez. All rights reserved.
//

import SwiftUI

struct AddNewActivity: View {
    //Creates a context for our managed object. Basically creating an instance of our core data
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentation
    
    @State private var activityType = ["Exercise", "Travel", "Sleep", "Work", "Other"]
    @State private var exercisingType = ["Running", "Weightlifting", "Biking", "Walking", "Yoga", "Other"]
    @State private var travelingType = ["Walking", "Driving" ,"Ubering", "Biking", "Taking the bus", "Flying"]
    @State private var travelingLocation = ["Home", "Work", "School", "Grocery store", "Gym", "Friends house", "Restaurant", "Bar", "Out of town"]
    @State private var sleepType = ["Night sleep", "Nap"]
    @State private var workingType = ["Actively walking", "Mostly standing", "Some walking some standing", "Sedentary", "Mostly sedentary"]

    @State private var typeSelection = 0
    @State private var detailSelection = 0
    @State private var fromSelection = 0
    @State private var toSelection = 0
    
    @State var otherActivity = ""
    @State var otherExercise = ""
    @State var otherDetail = ""
    @State var startTime = Date()
    @State var finishTime = Date()
    
    var body: some View {
        VStack {
            NavigationView {
                VStack{
                    Section {
                        Form {
                            Picker(selection: $typeSelection, label: Text("Activity type")) {
                                ForEach(0..<activityType.count) {
                                    Text(self.activityType[$0]).foregroundColor(.blue)
                                }
                            }.pickerStyle(SegmentedPickerStyle())

                            if self.typeSelection == 1 {
                                Picker(selection: $fromSelection, label: Text("From")) {
                                    ForEach(0..<travelingLocation.count) {
                                        Text(self.travelingLocation[$0]).foregroundColor(.blue)
                                    }
                                }
                                Picker(selection: $toSelection, label: Text("To")) {
                                    ForEach(0..<travelingLocation.count) {
                                        Text(self.travelingLocation[$0]).foregroundColor(.blue)
                                    }
                                }
                            }
                            
                            if self.typeSelection == 4 {
                                TextField("Description:", text: $otherActivity)
                            } else {
                                Picker(selection: $detailSelection, label: Text("Activity detail")) {
                                    if self.typeSelection == 0 { // Exercising
                                        ForEach(0..<exercisingType.count) {
                                            Text(self.exercisingType[$0]).foregroundColor(.blue)
                                        }
                                    } else if self.typeSelection == 1 { // Traveling
                                        ForEach(0..<travelingType.count) {
                                            Text(self.travelingType[$0]).foregroundColor(.blue)
                                        }
                                    } else if self.typeSelection == 2 { // sleep
                                        ForEach(0..<sleepType.count) {
                                            Text(self.sleepType[$0]).foregroundColor(.blue)
                                        }
                                    } else if self.typeSelection == 3 { // Working
                                        ForEach(0..<workingType.count) {
                                            Text(self.workingType[$0]).foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                            
                            if self.typeSelection == 0 && self.detailSelection == 5 {
                                TextField("Description:", text: $otherExercise)
                            }
                            
                            // End Activity detail
                            DatePicker(selection: $startTime) {
                                Text("Start")
                            }
                            DatePicker(selection: $finishTime) {
                                Text("Finish")
                            }
                        }
                    } .navigationBarTitle("Choose activity")
                    Button(action: {
                        self.saveToMoc()
                    }) {
                        Text("Save activity")
                        .font(.custom("Teko-Medium", size: 25))
                        .foregroundColor(Color.white)
                        .frame(width: 220, height: 60, alignment: .center)
                        .background(Color.blue)
                        .cornerRadius(40)
                    }.padding()
                }
            }
        }
    }
    
    
    func saveToMoc() {
        let activity = Activities(context: self.moc)
        activity.activityType = self.activityType[typeSelection]
        switch self.typeSelection {
        case 0:
            if self.detailSelection == 5 {
                activity.activityDetail = self.otherExercise
            } else {
                activity.activityDetail = self.exercisingType[self.detailSelection]
            }
        case 1:
            activity.activityDetail = self.travelingType[self.detailSelection]
            activity.travelFrom = self.travelingLocation[self.fromSelection]
            activity.travelTo = self.travelingLocation[self.toSelection]
        case 2:
            activity.activityDetail = self.sleepType[self.detailSelection]
        case 3:
            activity.activityDetail = self.workingType[self.detailSelection]
        case 4:
            activity.activityDetail = self.otherActivity
        default:
            activity.activityDetail = "no activity"
        }
        activity.startTime = self.startTime
        activity.finishTime = self.finishTime
        
        do {try self.moc.save()}
        catch {print(error)}
    
        self.presentation.wrappedValue.dismiss()
    }
}

struct AddNewActivity_Previews: PreviewProvider {
    static var previews: some View {
        AddNewActivity()
    }
}
