//
//  Category.swift
//  Todo-Realm
//
//  Created by Yilmaz Edis on 8.12.2021.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
}
