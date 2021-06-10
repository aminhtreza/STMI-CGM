//
//  ContentView.swift
//  STMI-CGM
//
//  Created by iMac on 5/7/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI
var phoneToWatch = PhonetoWatch()
import UserNotifications


struct ContentView: View {
    @FetchRequest(entity: Credentials.entity(), sortDescriptors: []) var credentials: FetchedResults<Credentials>
    
    var body: some View {
        MainUI()
            .onAppear {
                requestAuthorization()
                
            }
        //AuthorizePage()
        /*
        if credentials.count == 0 {
            AuthorizePage()
        } else {
            MainUI()
        }
        */
        
    }
}

// Notifications
extension ContentView {
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        scheduleNotification()
    }
    
    // hackingwithswift.com
    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        
        // breakfast notification
        let breakfast = UNMutableNotificationContent()
            breakfast.title = "WhatU8"
            breakfast.subtitle = "Breakfast"
            breakfast.body = "Kindly log what you had for breakfast in the app."
            breakfast.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "breakfast_.mp3"))
        
        var breakfastComponents = DateComponents()
            //breakfastComponents.hour = 9
            //breakfastComponents.minute = 0
            breakfastComponents.hour = 8
            breakfastComponents.minute = 32
            breakfastComponents.second = 0
        let breakfastTrigger = UNCalendarNotificationTrigger(dateMatching: breakfastComponents, repeats: true)
        let breakfastRequest = UNNotificationRequest(identifier: UUID().uuidString, content: breakfast, trigger: breakfastTrigger)
        center.add(breakfastRequest, withCompletionHandler: nil)
        
        // lunch notification
        let lunch = UNMutableNotificationContent()
            lunch.title = "WhatU8"
            lunch.subtitle = "Lunch"
            lunch.body = "Kindly log what you had for lunch in the app."
            lunch.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "lunch_.mp3"))
        var lunchComponents = DateComponents()
            //lunchComponents.hour = 14
            //lunchComponents.minute = 0
            lunchComponents.hour = 8
            lunchComponents.minute = 32
            lunchComponents.second = 20
            
        
        let lunchTrigger = UNCalendarNotificationTrigger(dateMatching: lunchComponents, repeats: true)
        let lunchRequest = UNNotificationRequest(identifier: UUID().uuidString, content: lunch, trigger: lunchTrigger)
        center.add(lunchRequest, withCompletionHandler: nil)
        
        // dinner notification
        let dinner = UNMutableNotificationContent()
            dinner.title = "WhatU8"
            dinner.subtitle = "Dinner"
            dinner.body = "Kindly log what you had for dinner in the app."
            dinner.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "dinner_.mp3"))
        var dinnerComponents = DateComponents()
        //dinnerComponents.hour = 19
        //dinnerComponents.minute = 0
        dinnerComponents.hour = 8
        dinnerComponents.minute = 32
        dinnerComponents.second = 40
        let dinnerTrigger = UNCalendarNotificationTrigger(dateMatching: dinnerComponents, repeats: true)
        let dinnerRequest = UNNotificationRequest(identifier: UUID().uuidString, content: dinner, trigger: dinnerTrigger)
        center.add(dinnerRequest, withCompletionHandler: nil)
        
        print("requests added")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
