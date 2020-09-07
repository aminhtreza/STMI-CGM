//
//  ActivityMainIFC.swift
//  STMI
//
//  Created by iMac on 3/25/20.
//  Copyright © 2020 Ryan Ramirez. All rights reserved.
//

import SwiftUI

struct ActivityMainIFC: View {
    // have to redefine the MOC so it can be used by the code
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Activity.entity(), sortDescriptors: []) var activities: FetchedResults<Activity>
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
                    Button(action: {
                        self.showSheet = true
                        self.activeSheet = .first
                        print(self.activities.count)
                    }) {
                        Section {
                            HStack{
                                Text("Add new activity")
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                            }
                        }
                    }.padding()
                    Section(header: Text("History")) {
                        ForEach(activities, id: \.self) {activity in
                           VStack {
                                HStack{
                                    Text("\(activity.activityType!)")
                                    .font(.title)
                                        .frame(width: 117, height: 60, alignment: .center)
                                    Divider()
                                    VStack {
                                        Text("\(activity.activityDetail!.detail!)")
                                        Text("Start: \(self.dateFormatter.string(from: activity.startTime!))")
                                        Text("Finish: \(self.dateFormatter.string(from: activity.endTime!)) ")
                                        HStack{
                                            Text("\(activity.activityDetail!.from ?? "")")
                                            Text("\(activity.activityDetail!.to ?? "")")
                                        }
                                    }
                                    .multilineTextAlignment(.leading)
                                }
                                //Text("\(self.dateFormatter.string(from: activity.inputDate!))")
                            }
                        }.onDelete(perform: deleteMeal)
                    }
                }.navigationBarTitle(Text("My activities"),displayMode: .inline)
            }.onAppear(perform: dateformatter)
            .sheet(isPresented: $showSheet, onDismiss: closeSheet) {
                if self.activeSheet == .first {
                    AddNewActivity().navigationBarTitle("STMI", displayMode: .inline)
                    .environment(\.managedObjectContext, self.moc)
                } else {
                    AddStoredActivity().navigationBarTitle("STMI", displayMode: .inline)
                    .environment(\.managedObjectContext, self.moc)
                }
            }
        }
    }
    func deleteMeal(at offsets: IndexSet) {
        for i in offsets {
            let activity = activities[i]
            moc.delete(activity)
        }
        try! self.moc.save()
    }
    func closeSheet() {
        self.showSheet = false
    }
    enum ActiveSheet {
       case first, second
    }
    
}

struct ActivityMainIFC_Previews: PreviewProvider {
    static var previews: some View {
        MealList()
    }
}

/*
import SwiftUI

struct ActivityMainIFC: View {
    
    //Creates a context for our managed object. Basically creating an instance of our core data
    @Environment(\.managedObjectContext) var managedObjectContext
    // Fetch our data from CoreData from the managed object Activity
    @FetchRequest(entity: Activity.entity(), sortDescriptors: [])
    
    var activities: FetchedResults<Activity>
    @State var displayActivities = false
    @State var addActivity = false
    @State var btnText = "Show activities"
    @State var btn2Text = "Add activity"
    
    // function to delete unwanted data
    func deleteActivity(at offsets: IndexSet) {
        for i in offsets {
            let activity = activities[i]
            managedObjectContext.delete(activity)
        }
    }
    
    var body: some View {
        NavigationView {
            List{
                NavigationLink(destination: AddNewActivity()) {
                    Section {
                        HStack{
                            Text("Add new activity")
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.large)
                        }
                    }
                }.padding()
                NavigationLink(destination: AddNewActivity()) {
                    Section {
                        HStack{
                            Text("Add stored activity")
                            Spacer()
                            Image(systemName: "doc.fill")
                            .foregroundColor(.green)
                            .imageScale(.large)
                        }
                    }
                }.padding()
            }
            .navigationBarTitle(Text("My activities"),displayMode: .inline)
        }
    } // end body
}

struct ActivityMainIFC_Previews: PreviewProvider {
    static var previews: some View {
        ActivityMainIFC()
    }
}
*/
