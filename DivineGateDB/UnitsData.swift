//
//  UnitsData.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit

class UnitsData: NSObject {
    
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
   
}
