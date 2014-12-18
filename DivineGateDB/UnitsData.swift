//
//  UnitsData.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit

class UnitsData: NSObject, NSCoding {
    
    var num: Int = 0
    var name: String = "????"
    var type: Int = -1
    var rare: Int = 0
    var race: String = "???"
    var cost: Int = 0
    var lv: Int = 0
    var hp: Int = 0
    var atk: Int = 0
    
    init(num: Int, name: String, type: Int, rare: Int, race: String, cost: Int, lv: Int, hp: Int, atk: Int) {
        self.num = num
        self.name = name
        self.type = type
        self.rare = rare
        self.race = race
        self.cost = cost
        self.lv = lv
        self.hp = hp
        self.atk = atk
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(num, forKey: "num")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(type, forKey: "type")
        aCoder.encodeObject(rare, forKey: "rare")
        aCoder.encodeObject(race, forKey: "race")
        aCoder.encodeObject(cost, forKey: "cost")
        aCoder.encodeObject(lv, forKey: "lv")
        aCoder.encodeObject(hp, forKey: "hp")
        aCoder.encodeObject(atk, forKey: "atk")
    }
    
    required init(coder aDecoder: NSCoder) {
        num = aDecoder.decodeObjectForKey("num") as Int
        name = aDecoder.decodeObjectForKey("name") as String
        type = aDecoder.decodeObjectForKey("type") as Int
        rare = aDecoder.decodeObjectForKey("rare") as Int
        race = aDecoder.decodeObjectForKey("race") as String
        cost = aDecoder.decodeObjectForKey("cost") as Int
        lv = aDecoder.decodeObjectForKey("lv") as Int
        hp = aDecoder.decodeObjectForKey("hp") as Int
        atk = aDecoder.decodeObjectForKey("atk") as Int
    }
   
}
