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
    
    func setAttack() {
        if target != 0 {
            let appDel = UIApplication.sharedApplication().delegate as AppDelegate
            let context = appDel.managedObjectContext!
            var request = NSFetchRequest(entityName: "UnitsData")
            request.predicate = NSPredicate(format: "unit = %d", unit)
            var result = context.executeFetchRequest(request, error: nil) as [UnitsData]
            
            if result.count > 0 {
                attack = result[0].atk * leverage
                println(attack)
            } else {
                println("unit isn't found!")
            }
            value = attack
        } else {
            attack = 0
            value = 0
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
        let list = [0.02, 0.04, 0.07, 0.10, 0.13]
        return list[panels() - 1] + crt
    }
    
    func condition() -> [Int] {
        var cond = [0, 0, 0, 0, 0, 0, 0, 0] // 8 kind of panels   [0] = enpty ~ [7] = hart
        for p in panel {
            cond[p]++
        }
        return cond
    }
    
}
