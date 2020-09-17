//
//  Activity+CoreDataProperties.swift
//  STMI-CGM
//
//  Created by iMac on 9/16/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//
//

import Foundation
import CoreData


extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity")
    }

    @NSManaged public var activityType: String?
    @NSManaged public var endTime: Date?
    @NSManaged public var startTime: Date?
    @NSManaged public var activityDetail: ActivityDetail?

}

extension Activity : Identifiable {

}
