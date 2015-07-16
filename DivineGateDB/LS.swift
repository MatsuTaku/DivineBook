//
//  LS.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 2015/06/28.
//  Copyright (c) 2015年 TakumaMatsumoto. All rights reserved.
//

import UIKit

class LS: NSObject {
    
    var No: Int
    var unitsName: String
    var name: String
    var detail: String
    var target: [String]
    var leverage: [Double]
    var limit: Bool
    
    init(data: NSDictionary) {
        /*  data.keys
        No
        Unit'sName
        Name
        Target1
        Target2
        Limit
        HP
        ATK
        Detail
        */
        No = data["No"] as! Int
        
        if let srcUnitsName = data["Unit'sName"] as? String {
            unitsName = srcUnitsName
        } else if let srcUnitsName = data["Unit'sName"] as? NSNumber{
            unitsName = srcUnitsName.description
        } else {
            unitsName = ""
        }
        
        if let nsName = data["Name"] as? String {
            name = nsName
        } else if let nsName = data["Name"] as? NSNumber {
            if nsName != 0 {
                name = nsName.description
            } else {
                name = ""
            }
        } else {
            name = ""
        }
        
        if let nsDetail = data["Detail"] as? String {
            detail = nsDetail
        } else {
            detail = ""
        }
        
        var targetArray = [String]()
        for i in 0..<2 {
            if let srcTarget = data["Target\(i + 1)"] as? String {
                targetArray.append(srcTarget)
            } else {
                targetArray.append("")
            }
        }
        target = targetArray
        
        var levelArray = [Double]()
        let levelKey = ["HP", "ATK"]
        for i in 0..<2 {
            if let srcLeverage = data[levelKey[i]] as? String {
                let levelStr = srcLeverage.componentsSeparatedByString("%")
                let levelVolume: Double = (levelStr[0] as NSString).doubleValue / 100
                levelArray.append(levelVolume)
            } else {
                levelArray.append(1.00)
            }
        }
        leverage = levelArray
        
        if let limitCheck = data["Limit"] as? String {
            if limitCheck == "*" {
                limit = true
            } else {
                limit = false
            }
        } else {
            limit = false
        }
    }
    
    func showNo() -> Int {
        return No
    }
    
    func maxLev() -> Double {
        return max(leverage[0], leverage[1])
    }
    
    func minLev() -> Double {
        return min(leverage[0], leverage[1])
    }
   
}
