//
//  Meal+CoreDataProperties.swift
//  STMI-CGM
//
//  Created by iMac on 12/15/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//
//

import Foundation
import CoreData


extension Meal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meal> {
        return NSFetchRequest<Meal>(entityName: "Meal")
    }

    @NSManaged public var mealName: String?
    @NSManaged public var calories: Double
    @NSManaged public var carbs: Double
    @NSManaged public var protein: Double
    @NSManaged public var fat: Double
    @NSManaged public var startTime: Date
    @NSManaged public var finishTime: Date
    @NSManaged public var picture: Data?

}

extension Meal : Identifiable {

}
