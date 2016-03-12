//
//  PSTable.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 2015/08/24.
//  Copyright (c) 2015年 TakumaMatsumoto. All rights reserved.
//

import UIKit
import NTYCSVTable

class PSTable: NSObject {
    
    var rows: [PS]
    
    init(units: [Int]?) {
        if let path = NSBundle.mainBundle().pathForResource("ps", ofType: "csv") {
            let url = NSURL.fileURLWithPath(path)
            let table = NTYCSVTable(contentsOfURL: url)
            
            var psArray = [PS]()
            for psData in table.rows {
                if let unitNo = units {
                    var cont = true
                    let dataNo = psData["No"] as? Int
                    for no in unitNo {
                        if dataNo == no {
                            cont = false
                            break
                        }
                    }
                    if cont {
                        continue
                    }
                }
                if psData["Name"] is String {
                    let ps = PS(data: psData as! NSDictionary)
                    psArray.append(ps)
                }
            }
            rows = psArray
        } else {
            rows = []
        }
    }
    
    convenience override init() {
        self.init(units: nil)
    }
   
}
