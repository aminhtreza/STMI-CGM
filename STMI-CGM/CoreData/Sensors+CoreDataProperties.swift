//
//  Sensors+CoreDataProperties.swift
//  STMI-CGM
//
//  Created by iMac on 9/16/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//
//

import Foundation
import CoreData


extension Sensors {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sensors> {
        return NSFetchRequest<Sensors>(entityName: "Sensors")
    }

    @NSManaged public var altitude: String?
    @NSManaged public var date: Date
    @NSManaged public var heartRate: Int16
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var pitch: String?
    @NSManaged public var roll: String?
    @NSManaged public var yaw: String?

}

extension Sensors : Identifiable {

}
