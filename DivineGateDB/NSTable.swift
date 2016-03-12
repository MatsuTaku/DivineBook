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
    
    init(units: [Int]?) {
        if let path = NSBundle.mainBundle().pathForResource("ns", ofType: "csv") {
            let url = NSURL.fileURLWithPath(path)
            let table = NTYCSVTable(contentsOfURL: url)
        
            let unitTable = UnitsTable(units: units)
            
            var nsArray = [NS]()
            var index = 0
            for nsData in table.rows {
                if let units = units {
                    let dataNo = nsData["No"] as? Int
                    var cont = true
                    for no in units {
                        if dataNo == no {
                            cont = false
                        }
                    }
                    if cont {
                        continue
                    }
                }
                var exist = true
                for number in 1...2 {
                    if nsData["Type\(number)"] is String {
                        if exist {
                            exist = false
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
                        
                        let no = nsDict["No"] as! Int
                        var atk: Double = 0
                        if unitTable.rows[index - 1].No == no {
                            atk = unitTable.rows[index - 1].atk
                        } else {
                            let predicate = NSPredicate(format: "showNo == %d", no)
                            if let master = ((unitTable.rows as NSArray).filteredArrayUsingPredicate(predicate) as! [Unit]).first {
                                atk = master.atk
                            }
                        }
                        let ns = NS(data: nsDict, atk: atk)
                        nsArray.append(ns)
                    }
                }
            }
            rows = nsArray
            
            if units == nil {
                // 標準回復NS追加
                var healNSArray = [NS]()
                let healValues: [String] = ["15%", "30%", "60%", "100%"]
                let healStrings: [String] = ["ヒール：スモール", "ヒール：ミドル", "ヒール：ラージ", "ヒール：フル"]
                for i in 0..<4 {
                    var nsDict = [String: AnyObject]()
                    nsDict["No"] = 0
                    nsDict["Unit'sName"] = ""
                    nsDict["Number"] = i + 1
                    nsDict["Name"] = healStrings[i]
                    nsDict["Type"] = "回"
                    var panels = [String]()
                    for _ in 0...i+1 {
                        panels.append("回")
                    }
                    nsDict["Panel"] = panels
                    nsDict["Target"] = "回復"
                    nsDict["Leverage"] = healValues[i]
                    nsDict["Critical"] = 0
                    nsDict["Boost"] = ""
                    nsDict["Detail"] = "標準回復NS（\(healValues[i])回復）"
                    let ns = NS(data: nsDict, atk: 0)
                    healNSArray.append(ns)
                }
                rows += healNSArray
            }
            
        } else {
            rows = []
        }
    }
    
    convenience override init() {
        self.init(units: nil)
    }
   
}
