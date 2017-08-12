//
//  ServerValue.swift
//  AvantariApp
//
//  Created by Swathy Sudarsanan on 10/08/17.
//  Copyright © 2017 BladeSilver. All rights reserved.
//

import UIKit
import RealmSwift

class ServerValue: Object {

    dynamic var value: Int = Int()
    dynamic var id: String = String()
    
    func save() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
}
