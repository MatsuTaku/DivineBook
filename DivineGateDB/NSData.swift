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
    @NSManaged var panel: [Int]
    @NSManaged var target: Int
    @NSManaged var element: Int
    @NSManaged var leverage: Double
    @NSManaged var type: String
    @NSManaged var critical: Double
    @NSManaged var attack: Double
    
    func initNSData(Unit: Int, Number: Int, Name: String, Detail: String?, Panel: [Int], Target: Int, Element: Int, Leverage: Double, Type: String, Critical: Double?) {
        unit = Unit
        number = Number
        name = Name
        detail = (Detail != nil) ? Detail! : ""
        var p = Panel
        for _ in Panel.count..<5 {
            p.append(0)
        }
        panel = p
        target = Target
        element = Element
        leverage = Leverage
        type = Type
        if Critical != nil {
            critical = Critical!
        }
        setAttack()
    }
    
    func setAttack() {
        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDel.managedObjectContext!
        var request = NSFetchRequest(entityName: "UnitsData")
        request.predicate = NSPredicate(format: "unit = %d", unit)
        var result = context.executeFetchRequest(request, error: nil) as [UnitsData]
        
        if result.count > 0 {
            attack = result[0].atk * leverage
        }
    }
    
}
