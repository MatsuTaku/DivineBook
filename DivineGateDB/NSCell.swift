//
//  NSCell.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/14/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData

class NSCell: UITableViewCell {
    
    @IBOutlet weak var engy1: UIImageView!
    @IBOutlet weak var engy2: UIImageView!
    @IBOutlet weak var engy3: UIImageView!
    @IBOutlet weak var engy4: UIImageView!
    @IBOutlet weak var engy5: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var boost: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var critical: UILabel!
    @IBOutlet weak var crt: UILabel!
    
    
    let elementColor: [UIColor?] = [nil,                    // 0
        UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 0.4),   // 1 炎
        UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 0.4),   // 2 水
        UIColor(red: 0.5, green: 1, blue: 0.5, alpha: 0.4),   // 3 風
        UIColor(red: 1, green: 1, blue: 0.5, alpha: 0.4),     // 4 光
        UIColor(red: 0.8, green: 0.4, blue: 1, alpha: 0.4),   // 5 闇
        UIColor(red: 1, green: 1, blue: 1, alpha: 0.4),       // 6 無
        UIColor(red: 1, green: 0.8, blue: 0.8, alpha: 0.4)    // 7 回復
    ]
    
    let iconImage: [UIImage?] = [
        UIImage(named: "panel_source.png"),    // 0
        UIImage(named: "flame.png"),    // 1 炎
        UIImage(named: "aqua.png"),    // 2 水
        UIImage(named: "wind.png"),     // 3 風
        UIImage(named: "light.png"),    // 4 光
        UIImage(named: "dark.png"),     // 5 闇
        UIImage(named: "none.png"),     // 6 無
        UIImage(named: "hart.png"),     // 7 回復
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
        name.preferredMaxLayoutWidth = self.frame.width - 118
        detail.preferredMaxLayoutWidth = self.frame.width - 50
        boost.preferredMaxLayoutWidth = self.frame.width - 50
    }
    
    // MARK: - main setting
    
    func setCell(NS: NSData) {
        self.fixedData(NS)
        switch  NS.target {
        case 0:
            self.healNS(NS)
        case 1, 2:
            self.attackNS(NS)
        default :
            break
        }
        detail.sizeToFit()
        
    }
    
    func setStatisticsCell(NS: NSData) {
        self.fixedData(NS)
        switch  NS.target {
        case 0:
            self.healNS(NS)
        case 1, 2:
            self.statisticsNS(NS)
        default :
            break
        }
        detail.sizeToFit()
    }
    
    func setOneCell(NS: NSData) {
        self.fixedData(NS)
        switch  NS.target {
        case 0:
            self.healNS(NS)
        case 1, 2:
            self.oneAttackNS(NS)
        default :
            break
        }
        detail.sizeToFit()
    }
    
    func setOneStatisticsCell(NS: NSData) {
        self.fixedData(NS)
        switch  NS.target {
        case 0:
            self.healNS(NS)
        case 1, 2:
            self.oneStatisticsNS(NS)
        default :
            break
        }
        detail.sizeToFit()
    }
    
    func setPlusCell(NS: NSData) {
        self.fixedData(NS)
        switch  NS.target {
        case 0:
            self.healNS(NS)
        case 1, 2:
            self.attackPlusNS(NS)
        default :
            break
        }
        detail.sizeToFit()
        
    }
    
    func setStatisticsPlusCell(NS: NSData) {
        self.fixedData(NS)
        switch  NS.target {
        case 0:
            self.healNS(NS)
        case 1, 2:
            self.statisticsPlusNS(NS)
        default :
            break
        }
        detail.sizeToFit()
    }
    
    func setOnePlusCell(NS: NSData) {
        self.fixedData(NS)
        switch  NS.target {
        case 0:
            self.healNS(NS)
        case 1, 2:
            self.oneAttackPlusNS(NS)
        default :
            break
        }
        detail.sizeToFit()
    }
    
    func setOneStatisticsPlusCell(NS: NSData) {
        self.fixedData(NS)
        switch  NS.target {
        case 0:
            self.healNS(NS)
        case 1, 2:
            self.oneStatisticsPlusNS(NS)
        default :
            break
        }
        detail.sizeToFit()
    }
    
    // MARK: function
    
    func fixedData(NS: NSData) {
        name.text = NS.name
        engy1.image = iconImage[Int(NS.panel[0])]
        engy2.image = iconImage[Int(NS.panel[1])]
        engy3.image = iconImage[Int(NS.panel[2])]
        engy4.image = iconImage[Int(NS.panel[3])]
        engy5.image = iconImage[Int(NS.panel[4])]
        if NS.element != 0 {
            value.textColor = elementColor[Int(NS.element)]
            type.textColor = elementColor[Int(NS.element)]
        }
        if NS.boost == "" {
            boost.text = NS.boost
        } else {
            boost.text = NSString(format: "■BOOST:%@", NS.boost)
        }
        let iconName = NSString(format: "%03d-icon.png", NS.unit)
        if let iconImage = UIImage(named: iconName) {
            icon.image = iconImage
        } else {
            icon.image = UIImage(named: "empty-icon.png")
        }
    }
    
    // MARK: healNS
    
    func healNS(NS: NSData) {
        // 回復詳細文生成
        detail.text = detailHealString(NS)
        type.text = "HEAL"
        value.text = NSString(format: "%.0f%%", NS.leverage * 100)
        critical.text = nil
        crt.text = nil
    }
    
    // MARK: attackNS
    
    func attackNS(NS: NSData) {
        self.attackFixed(NS)
    }
    
    func statisticsNS(NS: NSData) {
        self.attackFixed(NS)
        let txt = type.text
        type.text = txt! + "c"
        // ダメージ期待値計算処理
    }
    
    func oneAttackNS(NS: NSData) {
        self.attackFixed(NS)
        let txt = type.text
        type.text = txt! + "/\(NS.panels())"
    }
    
    func oneStatisticsNS(NS: NSData) {
        self.attackFixed(NS)
        let txt = type.text
        type.text = txt! + "c/\(NS.panels())"
    }
    
    func attackPlusNS(NS: NSData) {
        self.attackFixed(NS)
        let txt = type.text
        type.text = txt! + "+"
    }
    
    func statisticsPlusNS(NS: NSData) {
        self.attackFixed(NS)
        let txt = type.text
        type.text = txt! + "+c"
        // ダメージ期待値計算処理
    }
    
    func oneAttackPlusNS(NS: NSData) {
        self.attackFixed(NS)
        let txt = type.text
        type.text = txt! + "+/\(NS.panels())"
    }
    
    func oneStatisticsPlusNS(NS: NSData) {
        self.attackFixed(NS)
        let txt = type.text
        type.text = txt! + "+c/\(NS.panels())"
    }
    
    
    func attackFixed(NS: NSData) {
        // 攻撃力期待値詳細文生成
        detail.text = detailDamageString(NS)
        // ダメージ計算処理
        value.text = NSString(format: "%.0f", NS.value!)
        let tage = ["ATK", "ALL\nATK"]
        type.text = tage[Int(NS.target) - 1]
        critical.text = NSString(format: "%.0f%%", NS.critical() * 100)
        crt.text = "CRT"
    }
    
    // MARK: detail
    
    func detailDamageString(NS: NSData) -> String {
        var string: String?
        if NS.detail == "" {
            let element: [String] = ["?", "炎", "水", "風", "光", "闇", "無"]
            var target = ""
            var leverage = ""
            switch  NS.target {
            case    1:  // 単体
                target = "単"
                switch  NS.leverage {
                case    1:
                    leverage = "小"
                case    1.6:
                    leverage = "中"
                case    2.3:
                    leverage = "大"
                case    3:
                    leverage = "特大"
                case    4.5:
                    leverage = "超特大"
                case    6:
                    leverage = "絶大"
                case    8:
                    leverage = "超絶大"
                default :
                    leverage = "?"
                }
            case    2:  // 全体
                target = "全"
                switch  NS.leverage {
                case    1:
                    leverage = "小"
                case    1.6:
                    leverage = "中"
                case    1.8:
                    leverage = "大"
                case    2.5:
                    leverage = "特大"
                case    2.8:
                    leverage = "超特大"
                case    3:
                    leverage = "絶大"
                case    4:
                    leverage = "超絶大"
                default :
                    leverage = "?"
                }
            default :
                target = "?"
            }
            var critical = ""
            if NS.crt != 0 {
                critical = NSString(format: "(CRT+%.0f%%)", NS.crt * 100)
            }
            string = "敵\(target)体に\(element[Int(NS.element)])属性の\(leverage)ダメージを与える\(critical)"
        } else {
            string = NS.detail
        }
        return  string!
    }
    
    func detailHealString(NS: NSData) -> String {
        var string: String?
        if NS.detail == "" {
            string = NSString(format: "HPを%.0f%%回復する", NS.leverage * 100)
        } else {
            string = NS.detail
        }
        return  string!
    }
    
}
