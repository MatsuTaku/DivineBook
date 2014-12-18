//
//  UnitsCell.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit

class UnitsCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rare: UILabel!
    @IBOutlet weak var race: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var hp: UILabel!
    @IBOutlet weak var atk: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(unit: UnitsData, atIndexPath indexPath: NSIndexPath)
    {
        if unit.num != 0 {
            number?.text = NSString(format: "No. %d", unit.num)
        } else {
            number?.text = "????"
        }
        name?.text = unit.name
        race?.text = unit.race
        var Rare = "★"
        let star = "★"
        if unit.rare != 0 {
            for _ in 1..<unit.rare {
                Rare += star
            }
            rare?.text = Rare
        } else {
            rare?.text = "???"
        }
        if unit.lv != 0 {
            level?.text = NSString(format: "Lv. %d", unit.lv)
        } else {
            level?.text = "Lv. ??"
        }
        if unit.hp != 0 {
            hp?.text = NSString(format: "HP %d", unit.hp)
        } else {
            hp?.text = "HP ??"
        }
        if unit.atk != 0 {
            atk?.text = NSString(format: "ATK %d", unit.atk)
        } else {
            atk?.text = "ATK ??"
        }
    }
    
}
