//
//  UnitsData.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit

class UnitsData: NSObject {
    
    var num: Int
    var name: String
    var type: Int
    var rare: Int
    var race: String
    var cost: Int
    
    init(num: Int, name: String, type: Int, rare: Int, race: String, cost: Int) {
        self.num = num
        self.name = name
        self.type = type
        self.rare = rare
        self.race = race
        self.cost = cost
    }
   
}
