//
//  NSTable.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 3/12/15.
//  Copyright (c) 2015 TakumaMatsumoto. All rights reserved.
//

import UIKit
import NTYCSVTable

class NSTable: NSObject {
    
    var rows: [NS]
    var emptyCount = 0
    
    override init() {
        if let path = NSBundle.mainBundle().pathForResource("ns", ofType: "csv") {
            let url = NSURL.fileURLWithPath(path)
            let table = NTYCSVTable(contentsOfURL: url)
            
            let units = UnitsTable()
            
            var nsArray = [NS]()
            var index = -1
            for nsData in table.rows {
                var exist = false
                for number in 1...2 {
                    if let isExist = nsData["Type\(number)"] as? String {
                        if !exist {
                            exist = true
                            index++
                        }
                        var nsDict = [String: AnyObject]()
                        nsDict["No"] = nsData["No"]
                        nsDict["Unit'sName"] = nsData["Unit'sName"]
                        nsDict["Number"] = number
                        nsDict["Name"] = nsData["Name\(number)"]
                        nsDict["Type"] = nsData["Type\(number)"]
                        var panels = [String]()
                        for i in 1...5 {
                            if let nowPanel = nsData["P\(i)\(number)"] as? String {
                                panels.append(nowPanel)
                            }
                        }
                        nsDict["Panel"] = panels
                        nsDict["Target"] = nsData["Tage\(number)"]
                        nsDict["Leverage"] = nsData["Lev\(number)"]
                        nsDict["Critical"] = nsData["Crt\(number)"]
                        nsDict["Boost"] = nsData["Boost\(number)"]
                        nsDict["Detail"] = nsData["Detail\(number)"]
                        
                        let no = nsDict["No"] as Int
                        var atk: Double = 0
                        if units.rows[index].No == no {
                            atk = units.rows[index].atk
                        } else {
                            let predicate = NSPredicate(format: "showNo == %d", no)
                            if let master = ((units.rows as NSArray).filteredArrayUsingPredicate(predicate!) as [Unit]).first {
                                atk = master.atk
                            }
                        }
                        let ns = NS(data: nsDict, atk: atk)
                        nsArray.append(ns)
                    }
                }
            }
            
            rows = nsArray
        } else {
            rows = []
        }
    }
   
}
