//
//  LSTable.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 2015/06/28.
//  Copyright (c) 2015年 TakumaMatsumoto. All rights reserved.
//

import UIKit
import NTYCSVTable

class LSTable: NSObject {
    
    var rows: [LS]
    
    init(units: [Int]?) {
        if let path = NSBundle.mainBundle().pathForResource("ls", ofType: "csv") {
            let url = NSURL.fileURLWithPath(path)
            let table = NTYCSVTable(contentsOfURL: url)
            
            var lsArray = [LS]()
            for lsData in table.rows {
                if let unitNo = units {
                    var cont = true
                    let dataNo = lsData["No"] as? Int
                    for no in unitNo {
                        if dataNo == no {
                            cont = false
                        }
                    }
                    if cont {
                        continue
                    }
                }
                if lsData["Name"] is String || lsData["Target1"] is String {
                    let ls = LS(data: lsData as! NSDictionary)
                    lsArray.append(ls)
                }
            }
            rows = lsArray
        } else {
            rows = []
        }
    }
    
    convenience override init() {
        self.init(units: nil)
    }
   
}
