//
//  PS.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 2015/07/25.
//  Copyright (c) 2015年 TakumaMatsumoto. All rights reserved.
//

import UIKit

class PS: NSObject {
    
    var No: Int
    var number: Int
    var unitsName: String
    var name: String
    var detail: String
    
    init(data: NSDictionary) {
        No = data["No"] as! Int
        number = data["number"] as! Int
        
        if let srcUnitsName = data["Unit'sName"] as? String {
            unitsName = srcUnitsName
        } else if let srcUnitsName = data["Unit'sName"] as? NSNumber {
            unitsName = srcUnitsName.description
        } else {
            unitsName = ""
        }
        
        if let psName = data["Name"] as? String {
            name = psName
        } else if let psName = data["Name"] as? NSNumber {
            name = psName.description
        } else {
            name = ""
        }
        
        if let psDetail = data["Detail"] as? String {
            detail = psDetail
        } else {
            detail = ""
        }
    }
    
   
}
