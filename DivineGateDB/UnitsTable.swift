//
//  UnitsTable.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 3/12/15.
//  Copyright (c) 2015 TakumaMatsumoto. All rights reserved.
//

import UIKit
import NTYCSVTable

class UnitsTable: NSObject {
    
    var rows: [Unit]
    
    override init() {
        if let path = NSBundle.mainBundle().pathForResource("units", ofType: "csv") {
            let url = NSURL.fileURLWithPath(path)
            let table = NTYCSVTable(contentsOfURL: url)
            
            var unitsArray = [Unit]()
            for unitData in table.rows {
                if let race = unitData["Type"] as? String {
                    let unit = Unit(data: unitData as NSDictionary)
                    unitsArray.append(unit)
                }
            }
            rows = unitsArray
        } else {
            rows = []
        }
    }
    
}
