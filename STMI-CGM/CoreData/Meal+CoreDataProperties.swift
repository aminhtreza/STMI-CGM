//
//  Meal+CoreDataProperties.swift
//  STMI-CGM
//
//  Created by iMac on 9/16/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//
//

import Foundation
import CoreData


extension Meal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meal> {
        return NSFetchRequest<Meal>(entityName: "Meal")
    }

    @NSManaged public var calories: Double
    @NSManaged public var carbs: Double
    @NSManaged public var comments: String?
    @NSManaged public var fat: Double
    @NSManaged public var inputDate: Date?
    @NSManaged public var mealName: String?
    @NSManaged public var protein: Double
    @NSManaged public var picture: Picture?

}

extension Meal : Identifiable {

}
