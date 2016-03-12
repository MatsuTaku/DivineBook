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
    
    init(units: [Int]?) {
        if let path = NSBundle.mainBundle().pathForResource("units", ofType: "csv") {
            let url = NSURL.fileURLWithPath(path)
            let table = NTYCSVTable(contentsOfURL: url)
            
            var unitsArray = [Unit]()
            for unitData in table.rows {
                if let units = units {
                    var cont = true
                    for no in units {
                        let dataNo = unitData["No"] as? Int
                        if dataNo == no {
                            cont = false
                        }
                    }
                    if cont {
                        continue
                    }
                }
                if unitData["Type"] is String {
                    let unit = Unit(data: unitData as! NSDictionary)
                    unitsArray.append(unit)
                }
            }
            rows = unitsArray
        } else {
            rows = []
        }
    }
    
    convenience override init() {
        self.init(units: nil)
    }
    
}
