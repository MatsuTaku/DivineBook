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
    
    func initUnitsDataFromCSV(data: NSDictionary) {
        /*  table.headers
        No
        Name
        Type
        Race1
        Race2
        COST
        Rare
        MaxLv
        HP
        ATK
        */
        unit = (data["No"] as! Int)
        if let unitName = data["Name"] as? String {
            name = unitName
        } else if let unitName = (data["Name"] as? Int)?.description {
            name = unitName
        }
        let stype = data["Type"] as! String
        switch stype {
        case    "炎":
            element = 1
        case    "水":
            element = 2
        case    "風":
            element = 3
        case    "光":
            element = 4
        case    "闇":
            element = 5
        case    "無":
            element = 6
        default :
            element = 0
        }
        var races = [String]()
        if let race1 = data["Race1"] as? String {
            races.append(race1)
        }
        if let race2 = data["Race2"] as? String {
            races.append(race2)
        }
        race = races
        if let iCost = data["COST"] as? Int {
            cost = iCost
        }
        if let iRare = data["Rare"] as? Int {
            rare = iRare
        }
        if let iLv = data["MaxLv"] as? Int {
            lv = iLv
        }
        if let iHp = data["HP"] as? Double {
            hp = iHp
        }
        if let iAtk = data["ATK"] as? Double {
            atk = iAtk
        }
    }
    
    func atkPlus() -> Double {
        return atk + 99 * 5
    }
    
    func stusOfPlus() -> Double {
        let stus = hp / 10 + atk / 5
        return stus
    }
   
}
