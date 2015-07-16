//
//  Unit.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 3/12/15.
//  Copyright (c) 2015 TakumaMatsumoto. All rights reserved.
//

import UIKit

class Unit: NSObject {
    
    var No: Int
    var name: String
    var element: Int
    var rare: Int
    var race: [String]
    var cost: Int
    var lv: Int
    var hp: Double
    var atk: Double
//    var exp: Double   // ※
//    var group: String // ※
    
    init(data: NSDictionary) {
        /*  data.keys
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
        No = (data["No"] as! Int)
        if let unitName = data["Name"] as? String {
            name = unitName
        } else if let unitName = (data["Name"] as? Int)?.description {
            name = unitName
        } else {
            name = ""
        }
        let typeStr = data["Type"] as! String
        switch typeStr {
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
        cost = data["COST"] as! Int
        rare = data["Rare"] as! Int
        lv = data["MaxLv"] as! Int
        hp = data["HP"] as! Double
        atk = data["ATK"] as! Double
        
        println("Did set \(No):\(name)")
    }
    
    func status() -> Double {
        let stus = hp / 10 + atk / 5
        return stus
    }
    
    func sum() -> Double {
        let sum = hp + atk
        return sum
    }
    
    func showNo() -> Int {
        return No
    }
    
    func race1() -> String {
        return race[0]
    }
    
    func race2() -> String {
        if race.count >= 2 {
            return race[1]
        } else {
            return ""
        }
    }
   
}
