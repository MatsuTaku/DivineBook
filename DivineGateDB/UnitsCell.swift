//
//  UnitsCell.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData

class UnitsCell: UITableViewCell {
    
    @IBOutlet weak var icon: IconImageView!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rare: UILabel!
    @IBOutlet weak var race: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var hp: UILabel!
    @IBOutlet weak var atk: UILabel!
    @IBOutlet weak var plus: UILabel!
    
    let elementColor: [UIColor?] = [nil,                    // 0
        UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 0.2), // 1 炎
        UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 0.2), // 2 水
        UIColor(red: 0.5, green: 1, blue: 0.5, alpha: 0.2), // 3 風
        UIColor(red: 1, green: 1, blue: 0.5, alpha: 0.2),   // 4 光
        UIColor(red: 0.8, green: 0.4, blue: 1, alpha: 0.2), // 5 闇
        UIColor(red: 1, green: 1, blue: 1, alpha: 0.2),     // 6 無
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func setCell(unit: Unit) {
        icon.setIcon(unit.No, touchable: false)
        number.text = NSString(format: "No. %d", unit.No) as String
        name.text = unit.name
        //        race.text = unit.race.count == 1 ? unit.race[0] : unit.race[0] + "/" + unit.race[1]
        let raceText = (unit.race as NSArray).componentsJoinedByString("/")
        race.text = raceText
        var string = ""
        let star = "★"
        for _ in 0..<Int(unit.rare) {
            string += star
        }
        rare.text = string
        rare.textColor = elementColor[Int(unit.element)]
        level.text = NSString(format: "Lv. %d", unit.lv) as String
        hp.text = NSString(format: "HP %.0f", unit.hp) as String
        atk.text = NSString(format: "ATK %.0f", unit.atk) as String
        plus.text = NSString(format: "+換算 %.1f", unit.status()) as String
    }
    
    func setEmptyCell() {
        icon.image = UIImage(named: "empty-icon.png")
        number.text = nil
        name.text = "Empty"
        race.text = nil
        rare.text = nil
        level.text = nil
        hp.text = nil
        atk.text = nil
        plus.text = nil
    }

    
}
