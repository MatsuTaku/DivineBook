//
//  NSData.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/14/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData

class NSData: NSManagedObject {
    
    @NSManaged var unit: Int
    @NSManaged var number: Int
    @NSManaged var unitsName: String
    @NSManaged var name: String
    @NSManaged var detail: String
    @NSManaged var boost: String
    @NSManaged var panel: [Int]
    @NSManaged var target: Int
    @NSManaged var element: Int
    @NSManaged var leverage: Double
    @NSManaged var crt: Double
    @NSManaged var attack: Double
    var value: Double?
    
    func initNSData(Unit: Int, Number: Int, Name: String, Detail: String?, Boost: String?, Panel: [Int], Target: Int, Element: Int, Leverage: Double, Critical: Double?) {
        unit = Unit
        number = Number
        name = Name
        detail = (Detail == nil) ? "" : Detail!
        boost = (Boost == nil) ? "" : Boost!
        var p = Panel
        for _ in Panel.count..<5 {
            p.append(0)
        }
        panel = p
        target = Target
        element = Element
        leverage = Leverage
        if (Critical == nil) {
            crt = 0
        } else {
            crt = Critical!
        }
        setAttack()
    }
    
    func initNSDataFromCSV(data: NSDictionary) {
        /* table.headers
        Unit
        Number
        Type
        Panel
        Target
        Leverage
        Crt
        Boost
        Detail
        */
        unit = data["Unit"] as! Int
        number = data["Number"] as! Int
        if let srcUnitsName = data["Unit'sName"] as? String {
            unitsName = srcUnitsName
        } else if let srcUnitsName = (data["Unit'sName"] as? NSNumber)?.description {
            unitsName = srcUnitsName
        }
        if let nsName = data["Name"] as? String {
            name = nsName
        } else {
            if let nsName = data["Name"] as? NSNumber {
                if nsName != 0 {
                    name = nsName.description
                }
            }
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
        var p = [Int]()
        let srcPanel = data["Panel"] as! [String]
        for nowPanel in srcPanel {
            switch nowPanel {
            case    "炎":
                p.append(1)
            case    "水":
                p.append(2)
            case    "風":
                p.append(3)
            case    "光":
                p.append(4)
            case    "闇":
                p.append(5)
            case    "無":
                p.append(6)
            case    "回":
                p.append(7)
            default :
                break
            }
        }
        let num = p.count
        for _ in num..<5 {
            p.append(0)
        }
        panel = p
        let srcTarget = data["Target"] as! String
        switch srcTarget {
        case    "単体":
            target = 1
        case    "全体":
            target = 2
        case    "回復":
            target = 0
        default :
            break
        }
        let srcType = data["Type"] as! String
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
            break
        }
        let srcLeverage = data["Leverage"] as! String
        if target == 0 {   // 回復NS
            let healStrings = srcLeverage.componentsSeparatedByString("%")
            let healValue: Double = (healStrings[0] as NSString).doubleValue / 100
            leverage = healValue
        } else if target == 1 { // 単体攻撃
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
                break
            }
        } else if target == 2 { // 全体攻撃
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
                break
            }
        }
        if let srcCrt = data["Critical"] as? String {
            let crtStrings = srcCrt.componentsSeparatedByString("%")
            crt = (crtStrings[0] as NSString).doubleValue / 100
        } else {
            crt = 0
        }
        setAttack()
    }
    
    func setAttack() {
        if target != 0 {
            let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = appDel.managedObjectContext!
            var request = NSFetchRequest(entityName: "UnitsData")
            request.predicate = NSPredicate(format: "unit = %d", unit)
            var result = context.executeFetchRequest(request, error: nil) as! [UnitsData]
            
            if result.count > 0 {
                attack = result[0].atk * leverage
            } else {
                println("unit isn't found!")
            }
            value = attack
        } else {
            attack = 1
            value = leverage
        }
    }
    
    
    func attackPlus() -> Double {
        return (attack / leverage + 99 * 5) * leverage
    }
    
    func stat() -> Double {
        return attack * (1 + critical() / 2)
    }
    
    func statPlus() -> Double {
        return attackPlus() * (1 + critical() / 2)
    }
    
    func onePanelAtk() -> Double {
        return attack / Double(panels())
    }
    
    func onePanelAtkPlus() -> Double {
        return attackPlus() / Double(panels())
    }
    
    func onePanelStat() -> Double {
        return stat() / Double(panels())
    }
    
    func onePanelStatPlus() -> Double {
        return statPlus() / Double(panels())
    }
    
    func panels() -> Int {
        for i in 0..<5 {
            if panel[i] == 0 {
                return i
            }
        }
        return 5
    }
    
    func critical() -> Double {
        if target != 0 {
            let list = [0.02, 0.04, 0.07, 0.10, 0.13]
            return list[panels() - 1] + crt
        } else {
            return 0
        }
    }
    
    func condition() -> [Int] {
        var cond = [0, 0, 0, 0, 0, 0, 0, 0] // 8 kind of panels   [0] = enpty ~ [7] = hart
        for p in panel {
            cond[p]++
        }
        return cond
    }
    
}
