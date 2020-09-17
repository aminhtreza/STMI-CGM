//
//  Picture+CoreDataProperties.swift
//  STMI-CGM
//
//  Created by iMac on 9/16/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//
//

import Foundation
import CoreData


extension Picture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Picture> {
        return NSFetchRequest<Picture>(entityName: "Picture")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var meal: Meal?

}

extension Picture : Identifiable {

}
