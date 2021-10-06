//
//  Credentials+CoreDataProperties.swift
//  STMI-CGM
//
//  Created by iMac on 11/11/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//
//

import Foundation
import CoreData

extension Credentials {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Credentials> {
        return NSFetchRequest<Credentials>(entityName: "Credentials")
    }

    @NSManaged public var participantId: String?

}

extension Credentials : Identifiable {

}
