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
    @IBOutlet weak var icon: IconImageView!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var critical: UILabel!
    @IBOutlet weak var crtLabel: UILabel!
    
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    var defaultIconWidth: CGFloat!
    
    let elementColor: [UIColor?] = [nil,                    // 0
        UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 0.4),   // 1 炎
        UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 0.4),   // 2 水
        UIColor(red: 0.5, green: 1, blue: 0.5, alpha: 0.4),   // 3 風
        UIColor(red: 1, green: 1, blue: 0.5, alpha: 0.4),     // 4 光
        UIColor(red: 0.8, green: 0.4, blue: 1, alpha: 0.4),   // 5 闇
        UIColor(red: 1, green: 1, blue: 1, alpha: 0.4),       // 6 無
        UIColor(red: 1, green: 0.8, blue: 0.8, alpha: 0.4)    // 7 回復
    ]
    
    let panelImage: [UIImage?] = [
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
        defaultIconWidth = iconWidth.constant
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /*
        name.preferredMaxLayoutWidth = self.frame.width - 118
        detail.preferredMaxLayoutWidth = self.frame.width - 50
        boost.preferredMaxLayoutWidth = self.frame.width - 50
        */
    }
    
    // MARK: - main setting
    
    func setCell(ns: NS, showIcon: Bool, plusIs: Bool, crtIs: Bool, averageIs: Bool) {
        name.text = ns.name
        engy1.image = panelImage[Int(ns.panel[0])]
        engy2.image = panelImage[Int(ns.panel[1])]
        engy3.image = panelImage[Int(ns.panel[2])]
        engy4.image = panelImage[Int(ns.panel[3])]
        engy5.image = panelImage[Int(ns.panel[4])]
        if ns.element != 0 {
            value.textColor = elementColor[Int(ns.element)]
            type.textColor = elementColor[Int(ns.element)]
        }
        if ns.boost == "" {
            boost.text = ns.boost
        } else {
            boost.text = NSString(format: "■BOOST:%@", ns.boost) as String
        }
        if showIcon && ns.No >= 1 {
            icon.hidden = false
            iconWidth.constant = defaultIconWidth
            icon.setIcon(ns.No, touchable: true)
        } else {
            hideIcon()
        }
        switch ns.target {
        case    1, 2:   // 攻撃NS
            // 攻撃力期待値詳細文生成
            detail.text = detailDamageString(ns)
            // ダメージ計算処理
            value.text = NSString(format: "%.0f", ns.value!) as String
            let tage = ["ATK", "ALL\nATK"]
            let typeText = NSString(format: "%@%@",
                tage[ns.target-1],
                (averageIs ? "/\(ns.panels.description)" : "") ) as String
            type.text = typeText
            critical.text = NSString(format: "%.0f%%", ns.critical * 100) as String
            crtLabel.text = "CRT"
        case    0:  // 回復NS
            // 回復詳細文生成
            detail.text = detailHealString(ns)
            type.text = NSString(format: "HEAL%@", averageIs ? "/\(ns.panels.description)" : "") as String
            value.text = NSString(format: "%.0f%%", ns.value! * 100) as String
            critical.text = nil
            crtLabel.text = nil
        default :
            break
        }
    }
    
    // MARK: detail
    
    func detailDamageString(ns: NS) -> String {
        var string: String?
        if ns.detail == "" {
            let element: [String] = ["?", "炎", "水", "風", "光", "闇", "無"]
            var target = ""
            var leverage = ""
            switch  ns.target {
            case    1:  // 単体
                target = "単"
                switch  ns.leverage {
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
                case    10:
                    leverage = "極大"
                default :
                    leverage = "?"
                }
            case    2:  // 全体
                target = "全"
                switch  ns.leverage {
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
                case    5:
                    leverage = "極大"
                default :
                    leverage = "?"
                }
            default :
                target = "?"
            }
            var critical = ""
            if ns.crt != 0 {
                critical = NSString(format: "(CRT%@%.0f%%)", ns.crt > 0 ? "+" : "", ns.crt * 100) as String
            }
            string = "敵\(target)体に\(element[Int(ns.element)])属性の\(leverage)ダメージを与える\(critical)"
        } else {
            string = ns.detail
        }
        return  string!
    }
    
    func detailHealString(ns: NS) -> String {
        var string: String?
        if ns.detail == "" {
            string = NSString(format: "HPを%.0f%%回復する", ns.leverage * 100) as String
        } else {
            string = ns.detail
        }
        return  string!
    }
    
    func setEmptyCell() {
        name.text = "Empty"
        engy1.image = panelImage[0]
        engy2.image = panelImage[0]
        engy3.image = panelImage[0]
        engy4.image = panelImage[0]
        engy5.image = panelImage[0]
        detail.text = nil
        boost.text = nil
        hideIcon()
        type.text = nil
        value.text = nil
        critical.text = nil
        crtLabel.text = nil
    }
    
    func hideIcon() {
        icon.hidden = true
        iconWidth.constant = 0
    }
    
}
