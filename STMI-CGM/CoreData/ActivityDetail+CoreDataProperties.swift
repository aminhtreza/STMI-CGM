//
//  ActivityDetail+CoreDataProperties.swift
//  STMI-CGM
//
//  Created by iMac on 9/16/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//
//

import Foundation
import CoreData


extension ActivityDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivityDetail> {
        return NSFetchRequest<ActivityDetail>(entityName: "ActivityDetail")
    }

    @NSManaged public var detail: String?
    @NSManaged public var from: String?
    @NSManaged public var to: String?
    @NSManaged public var activity: Activity?

}

extension ActivityDetail : Identifiable {

}
