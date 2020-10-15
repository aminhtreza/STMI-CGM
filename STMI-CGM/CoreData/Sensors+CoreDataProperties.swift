//
//  Sensors+CoreDataProperties.swift
//  STMI-CGM
//
//  Created by iMac on 10/15/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//
//

import Foundation
import CoreData


extension Sensors {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sensors> {
        return NSFetchRequest<Sensors>(entityName: "Sensors")
    }

    @NSManaged public var roll: Double
    @NSManaged public var pitch: Double
    @NSManaged public var yaw: Double
    @NSManaged public var altitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var heartRate: Double
    @NSManaged public var date: Double

}

extension Sensors : Identifiable {

}
