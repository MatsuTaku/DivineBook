//
//  NSCell.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/14/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit

class NSCell: UITableViewCell {
    
    @IBOutlet weak var engy1: UIImageView!
    @IBOutlet weak var engy2: UIImageView!
    @IBOutlet weak var engy3: UIImageView!
    @IBOutlet weak var engy4: UIImageView!
    @IBOutlet weak var engy5: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var damage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(NS: NSData, atIndexPath indexPath: NSIndexPath) {
        
    }
    
}
