//
//  LSCell.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 2015/06/28.
//  Copyright (c) 2015年 TakumaMatsumoto. All rights reserved.
//

import UIKit

class LSCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var icon: IconImageView!
    @IBOutlet weak var iconWidth: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(ls: LS, showIcon: Bool) {
        name.text = nameString(ls)
        detail.text = detailString(ls)
        if showIcon {
            icon.setIcon(ls.No, touchable: true)
        } else {
            hideIcon()
        }
    }
    
    //  MARK: detail
    
    func nameString(ls: LS) -> String {
        var string: String?
        if ls.name == "" {
            /*
            let element: [String] = ["?", "炎", "水", "風", "光", "闇", "無"]
            let races: [String] = ["全員", "人間", "竜", "神", "魔物", "妖精", "獣", "機械", "強化合成用"]
            */
            var targetStr = ""
            for target in ls.target {
                switch target {
                case "":
                    targetStr += ""
                case "炎":    // 炎
                    targetStr += "フィア"
                case "水":    // 水
                    targetStr += "アクア"
                case "風":    // 風
                    targetStr += "ウィンダ"
                case "光":    // 光
                    targetStr += "ライト"
                case "闇":    // 闇
                    targetStr += "ダクタ"
                case "無":    // 無
                    targetStr += "ノン"
                case "人間":    // 人間
                    targetStr += "ヒューマ"
                case "竜":    // 竜
                    targetStr += "ドラゴ"
                case "神":    // 神
                    targetStr += "ゴッド"
                case "魔物":    // 魔物
                    targetStr += "デモ"
                case "妖精":    // 妖精
                    targetStr += "スピリ"
                case "獣":    // 獣
                    targetStr += "ビースト"
                case "機械":    // 機械
                    targetStr += "マシナ"
                case "強化合成用":    // 強化合成用
                    targetStr += "強化"
                case "全員":  // 全員
                    targetStr += "オール"
                default :
                    targetStr += "?"
                }
            }
            
            var rize = ""
            if ls.limit {
                rize = "リミット"
            } else {
                rize = "ライズ"
            }
            
            var shift = ""
            let HP = ls.leverage[0]
            let ATK = ls.leverage[1]
            let Life: Bool = HP > ATK
            let Assault: Bool = HP < ATK
            let Shift = ls.minLev() > 1.0
            if Life {
                shift += "ライフ"
            }
            if Assault {
                shift += "アサルト"
            }
            if Shift {
                shift += "シフト"
            }
            let shiftType = Shift ? min(HP, ATK) : max(HP, ATK)
            
            var value = ""
            let greeceNum = ["", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ", "Ⅷ", "Ⅸ", "Ⅹ"]
            value = greeceNum[Int((shiftType - 1) * 2) - 1]
            
            var plus = ""
            if Shift && abs(HP - ATK) >= 1.0 {
                plus = "+"
            }
            
            string = "\(targetStr)\(rize):\(shift)\(value)\(plus)"
        } else {
            string = ls.name
        }
        return string!
    }
    
    func detailString(ls: LS) -> String {
        var string: String?
        if ls.detail.isEmpty {
            var target = ""
            if ls.target[0] != "全員" {
                var targetStr = [String]()
                let elements: [String] = ["?", "炎", "水", "風", "光", "闇", "無"]
                let races: [String] = ["人間", "竜", "神", "魔物", "妖精", "獣", "機械", "強化合成用"]
                let targets = elements + races
                targetnumber: for nowTarget in ls.target {
                    if !nowTarget.isEmpty {
                        for i in 0..<targets.count {
                            if nowTarget == targets[i] {
                                var kind = ""
                                if i > 0 && i <= 6 {
                                    kind = "属性"
                                } else if i > 6 && i < 15 {
                                    kind = "族"
                                }
                                targetStr.append(nowTarget + kind)
                                continue targetnumber
                            }
                        }
                        targetStr.append("?")
                    } else {
                        targetStr.append("")
                    }
                }
                
                var limit = ""
                if !ls.limit && !ls.target[1].isEmpty {
                    limit += "ユニットまたは"
                }
                
                target = "の\(targetStr[0])\(limit)\(targetStr[1])ユニット"
            } else {
                target = "全員"
            }
            
            var rize = ""
            let HP = ls.leverage[0]
            let ATK = ls.leverage[1]
            let Life = HP > ATK
            let Assault = HP < ATK
            let Shift = ls.minLev() > 1.0
            if Shift {
                if HP == ATK {
                    rize = NSString(format: "HPと攻撃力が%.1f倍", ls.leverage[0]) as String
                } else {
                    rize = NSString(format: "HPが%.1f倍、攻撃力が%.1f倍",  ls.leverage[0], ls.leverage[1]) as String
                }
            } else if Life {
                rize = NSString(format: "HPが%.1f倍", ls.leverage[0]) as String
            } else if Assault {
                rize = NSString(format: "攻撃力が%.1f倍", ls.leverage[1]) as String
            }
            
            string = "味方\(target)の\(rize)になる"
        } else {
            string  = ls.detail
        }
        return string!
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
