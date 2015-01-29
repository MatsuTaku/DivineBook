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
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var critical: UILabel!
    @IBOutlet weak var crt: UILabel!
    
    
    let elementColor: [UIColor?] = [nil,                    // 0
        UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 1),   // 1 炎
        UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1),   // 2 水
        UIColor(red: 0.5, green: 1, blue: 0.5, alpha: 1),   // 3 風
        UIColor(red: 1, green: 1, blue: 0.5, alpha: 1),     // 4 光
        UIColor(red: 0.8, green: 0.4, blue: 1, alpha: 1),   // 5 闇
        UIColor(red: 1, green: 1, blue: 1, alpha: 1),       // 6 無
        UIColor(red: 1, green: 0.8, blue: 0.8, alpha: 1)    // 7 回復
    ]
    
    let iconImage: [UIImage?] = [
        UIImage(named: "empty.png"),    // 0
        UIImage(named: "flame.png"),    // 1 炎
        UIImage(named: "water.png"),    // 2 水
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
    
    func setCell(NS: NSData) {
        name.text = NS.name
        engy1.image = iconImage[NS.panel[0]]
        engy2.image = iconImage[NS.panel[1]]
        engy3.image = iconImage[NS.panel[2]]
        engy4.image = iconImage[NS.panel[3]]
        engy5.image = iconImage[NS.panel[4]]
        switch  NS.target {
        case 0:
            // 回復詳細文生成
            detail.text = detailHealString(NS)
            type.text = "HEAL"
            value.text = NSString(format: "%.0f%%", NS.leverage * 100)
            critical.text = nil
            crt.text = nil
        case 1, 2:
            // 攻撃詳細文生成
            detail.text = detailDamageString(NS)
            let tage = ["ATK", "ALL\nATK"]
            type.text = tage[NS.target - 1]
            // ダメージ計算処理
            value.text = setAttack(NS)
            critical.text = NSString(format: "%.0f%%", (setCritical(array: NS.panel, critical: NS.critical) * 100))
            crt.text = "CRT"
        default :
            break
        }
        if NS.element != 0 {
            value.textColor = elementColor[NS.element]
            type.textColor = elementColor[NS.element]
        }
        detail.sizeToFit()
    }
    
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
            if NS.critical != 0 {
                critical = NSString(format: "(CRT+%.0f%%)", NS.critical * 100)
            }
            string = "敵\(target)体に\(element[NS.element])属性の\(leverage)ダメージを与える\(critical)"
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
    
    func setAttack(NS: NSData) -> String {
        var string: String?
        if  NS.attack != 0 {
        string = NSString(format: "%.0f", NS.attack)
        } else {
            string = "?????"
        }
        return  string!
    }
    
    func setCritical(#array: [Int], critical plus: Double) -> Double {
        var num: Int = 0
        var critical: Double?
        for i in 0..<array.count {
            if array[i] != 0 {
                num++
            }
        }
        let crt = [0.00, 0.02, 0.04, 0.07, 0.10, 0.14]
        critical = crt[num]
        if  plus != 0 {
            critical! += plus
        }
        return  critical!
    }
    
}
