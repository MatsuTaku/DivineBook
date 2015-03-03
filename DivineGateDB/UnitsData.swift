//
//  UnitsData.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData

class UnitsData: NSManagedObject {
    
    @NSManaged var unit: Int
    @NSManaged var name: String
    @NSManaged var element: Int
    @NSManaged var rare: Int
    @NSManaged var race: [String]
    @NSManaged var cost: Int
    @NSManaged var lv: Int
    @NSManaged var hp: Double
    @NSManaged var atk: Double
    @NSManaged var exp: Double  // ※init修正
    
    func initUnitsData(Unit: Int, Name: String, Element: Int, Rare: Int, Race: [String], Cost: Int, Lv: Int, Hp: Double, Atk: Double) {
        unit = Unit
        name = Name
        element = Element
        rare = Rare
        race = Race
        cost = Cost
        lv = Lv
        hp = Hp
        atk = Atk
    }
    
    func atkPlus() -> Double {
        return atk + 99 * 5
    }
    
    func stusOfPlus() -> Double {
        let stus = hp / 10 + atk / 5
        return stus
    }
   
}
