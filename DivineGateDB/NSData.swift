//
//  NSData.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/14/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit

class NSData: NSObject {
    
    var name: String
    var panel: [Int]
    var leverage: Double
    var unit: Int
    var type: Int
    var detail: String
    var target: Int
    
    init(name: String, detail: String, panel: [Int], target: Int, leverage: Double, unit: Int, type: Int) {
        self.name = name
        self.panel = panel
        self.leverage = leverage
        self.unit = unit
        self.type = type
        self.detail = detail
        self.target = target
    }
   
}
