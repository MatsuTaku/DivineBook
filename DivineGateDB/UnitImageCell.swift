//
//  UnitImageCell.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 2016/01/16.
//  Copyright © 2016年 TakumaMatsumoto. All rights reserved.
//

import UIKit

class UnitImageCell: UITableViewCell {
    
    @IBOutlet weak var unitImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(unitNo: Int) {
        let imageName = NSString(format: "%03d", unitNo) as String
        if let unitImage = UIImage(named: imageName) {
            unitImageView.image = unitImage
        } else {
            unitImageView.image = nil
        }
    }
    
}
