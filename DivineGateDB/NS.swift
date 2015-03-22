//
//  NS.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 3/12/15.
//  Copyright (c) 2015 TakumaMatsumoto. All rights reserved.
//

import UIKit

class NS: NSObject {
    
    var No: Int
    var number: Int
    var unitsName: String
    var name: String
    var detail: String
    var boost: String
    var panel: [Int]
    var target: Int
    var element: Int
    var leverage: Double
    var crt: Double
    var attack: Double
    var panels: Int
    
    var critical: Double
    var value: Double?
    
    init(data: NSDictionary, atk: Double) {
        /* table.headers
        No
        Number
        Unit'sName
        Type
        Panel
        Target
        Leverage
        Crt
        Boost
        Detail
        */
        No = data["No"] as Int
        number = data["Number"] as Int
        
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
            name = nsName.description
        } else {
            name = ""
        }
        
        if let nsDetail = data["Detail"] as? String {
            detail = nsDetail
        } else {
            detail = ""
        }
        
        if let nsBoost = data["Boost"] as? String {
            boost = nsBoost
        } else {
            boost = ""
        }
        
        let srcPanel = data["Panel"] as [String]
        var panelNo = [Int]()
        for nowPanel in srcPanel {
            switch nowPanel {
            case    "炎":
                panelNo.append(1)
            case    "水":
                panelNo.append(2)
            case    "風":
                panelNo.append(3)
            case    "光":
                panelNo.append(4)
            case    "闇":
                panelNo.append(5)
            case    "無":
                panelNo.append(6)
            case    "回":
                panelNo.append(7)
            default :
                break
            }
        }
        for _ in panelNo.count..<5 {
            panelNo.append(0)
        }
        panel = panelNo
        
        let srcTarget = data["Target"] as String
        switch srcTarget {
        case    "単体":
            target = 1
        case    "全体":
            target = 2
        case    "回復":
            target = 0
        default :
            target = -1
        }
        
        let srcType = data["Type"] as String
        switch srcType {
        case    "炎":
            element = 1
        case    "水":
            element = 2
        case    "風":
            element = 3
        case    "光":
            element = 4
        case    "闇":
            element = 5
        case    "無":
            element = 6
        default :
            element = 0
        }
        
        let srcLeverage = data["Leverage"] as String
        if target == 0 {
            // 回復NS
            let healStrings = srcLeverage.componentsSeparatedByString("%")
            let healVolume: Double = (healStrings[0] as NSString).doubleValue / 100
            leverage = healVolume
        } else if target == 1 {
            // 単体攻撃
            switch srcLeverage {
            case    "小":
                leverage = 1
            case    "中":
                leverage = 1.6
            case    "大":
                leverage = 2.3
            case    "特大":
                leverage = 3.0
            case    "超特大":
                leverage = 4.5
            case    "絶大":
                leverage = 6.0
            case    "超絶大":
                leverage = 8.0
            default :
                leverage = 0
            }
        } else if target == 2 {
            // 全体攻撃
            switch srcLeverage {
            case    "小":
                leverage = 1
            case    "中":
                leverage = 1.6
            case    "大":
                leverage = 1.8
            case    "特大":
                leverage = 2.5
            case    "超特大":
                leverage = 2.8
            case    "絶大":
                leverage = 3.0
            case    "超絶大":
                leverage = 4.0
            default :
                leverage = 0
            }
        } else {
            leverage = 0
        }
        
        if let srcCrt = data["Critical"] as? String {
            let crtStrings = srcCrt.componentsSeparatedByString("%")
            crt = (crtStrings[0] as NSString).doubleValue / 100
        } else {
            crt = 0
        }
        
        var count = 0
        for p in panel {
            if p == 0 {
                break
            }
            count++
        }
        panels = count
        
        if target != 0 {
            // 攻撃NS
            attack = atk * leverage
            let list = [0.02, 0.04, 0.07, 0.10, 0.13]
            critical = list[panels - 1] + crt
        } else {
            // 回復NS
            attack = 1
            critical = 0
        }
        
        println("Did set \(No):\(name)")
    }
    
    func condition() -> [Int] {
        var cond = [0, 0, 0, 0, 0, 0, 0, 0] // 8 kind of panels   [0] = enpty ~ [7] = hart
        for p in panel {
            cond[p]++
        }
        return cond
    }
    
    func changeValue(#plusIs: Bool, crtIs: Bool, averageIs: Bool) {
        if target != 0 {
        value = Double(plusIs ? attack+99*5*leverage : attack) * Double(crtIs ? 1+critical/2 : 1) / Double(averageIs ? panels : 1)
        } else {
            let healVolume = [0.15, 0.30, 0.60, 1.00]
            let healCount = condition()[7]
//            value = Double((leverage + (healCount >= 2 ? healVolume[healCount - 2] : 0)) / (averageIs ? Double(panels) : 1))
            value = Double(leverage / (averageIs ? Double(panels) : 1))
        }
    }
    
    func showNo() -> Int {
        return No
    }
   
}
