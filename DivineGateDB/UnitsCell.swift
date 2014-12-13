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
    @IBOutlet weak var cost: UILabel!
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
        number?.text = String(unit.num)
        name?.text = unit.name
        race?.text = unit.race
        cost?.text = NSString(format: "COST %d", unit.cost)
        var Rare = "★"
        let star = "★"
        for _ in 1..<unit.rare {
            Rare += star
        }
        rare?.text = Rare
        
        if number?.text != nil {
            println("No.\(unit.num) rare:\(Rare)   race:\(unit.race)   cost:\(unit.cost)  [\(unit.name)]")
        } else {
            println("didn't inclused \(indexPath.row)")
        }
    }
    
}
