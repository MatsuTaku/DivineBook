//
//  PSCell.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 2015/08/24.
//  Copyright (c) 2015年 TakumaMatsumoto. All rights reserved.
//

import UIKit

class PSCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var icon: IconImageView!
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    
    let elementColor: [UIColor?] = [nil,                    // 0
        UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 0.4),   // 1 炎
        UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 0.4),   // 2 水
        UIColor(red: 0.5, green: 1, blue: 0.5, alpha: 0.4),   // 3 風
        UIColor(red: 1, green: 1, blue: 0.5, alpha: 0.4),     // 4 光
        UIColor(red: 0.8, green: 0.4, blue: 1, alpha: 0.4),   // 5 闇
        UIColor(red: 1, green: 1, blue: 1, alpha: 0.4),       // 6 無
        UIColor(red: 1, green: 0.8, blue: 0.8, alpha: 0.4)    // 7 回復
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setCell(ps: PS, showIcon: Bool) {
        name.text = ps.name
        detail.text = ps.detail
        if showIcon {
            icon.setIcon(ps.No, touchable: true)
        } else {
            hideIcon()
        }
    }
    
    func setEmptyCell() {
        name.text = "Empty"
        detail.text = nil
        hideIcon()
    }
    
    func hideIcon() {
        icon.hidden = true
        iconWidth.constant = 0
    }
    
}
