//
//  NSConditionMenu.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 2/15/15.
//  Copyright (c) 2015 TakumaMatsumoto. All rights reserved.
//

import UIKit

protocol NSConditionMenuDelegate {
    func condMenuWillClose()
    func listConditioning(condIndex condIndex: [Bool], countIndex: [Bool], panelSearchIndex: Int, panelIndex: [Int], typeIndex: Int)
}

class NSConditionMenu: NSObject {
    
    var menuHeight: CGFloat = 330
    let navConHeight: CGFloat = 64  // If you use NavigationController
    let toolBarHeight: CGFloat = 44 // If you use toolBar
    let sourceView: UIView!
    var delegate: NSConditionMenuDelegate?
    var condMenuContainerView = UIView()
    let outsideView = UIView()
    var isMenuOpen: Bool = false
    var animator: UIDynamicAnimator!
    
    var valueChanged: Bool = false

    var condIndex: [Bool] = [false, false, false, false, false, false]
    var countIndex: [Bool] = [false, false, false, false, false]
    var panelIndex: [Int] = [0, 0, 0, 0, 0]   // 8進数で選択中のパネル条件を格納(5桁)
    var panelSearchIndex: Int = 0
    var typeIndex: Int = 0
    
    @IBOutlet weak var flame: UIButton!
    @IBOutlet weak var aqua: UIButton!
    @IBOutlet weak var wind: UIButton!
    @IBOutlet weak var light: UIButton!
    @IBOutlet weak var dark: UIButton!
    @IBOutlet weak var none: UIButton!
    @IBOutlet weak var count1: UIButton!
    @IBOutlet weak var count2: UIButton!
    @IBOutlet weak var count3: UIButton!
    @IBOutlet weak var count4: UIButton!
    @IBOutlet weak var count5: UIButton!
    @IBOutlet weak var segConPanel: UISegmentedControl!
    @IBOutlet weak var panel1: UIButton!
    @IBOutlet weak var panel2: UIButton!
    @IBOutlet weak var panel3: UIButton!
    @IBOutlet weak var panel4: UIButton!
    @IBOutlet weak var panel5: UIButton!
    @IBOutlet weak var segConType: UISegmentedControl!
    /*
    var flame: UIButton?
    var aqua: UIButton?
    var wind: UIButton?
    var light: UIButton?
    var dark: UIButton?
    var none: UIButton?
    var count1: UIButton?
    var count2: UIButton?
    var count3: UIButton?
    var count4: UIButton?
    var count5: UIButton?
    var segConPanel: UISegmentedControl?
    var panel1: UIButton?
    var panel2: UIButton?
    var panel3: UIButton?
    var panel4: UIButton?
    var panel5: UIButton?
    var segConType: UISegmentedControl?
    */
    
    let panelImage = [
        UIImage(named: "empty.png"), // 0 空
        UIImage(named: "flame.png"), // 1 炎
        UIImage(named: "aqua.png"),  // 2 水
        UIImage(named: "wind.png"),  // 3 風
        UIImage(named: "light.png"), // 4 光
        UIImage(named: "dark.png"),  // 5 闇
        UIImage(named: "none.png"),  // 6 無
        UIImage(named: "hart.png")  // 7 回復
    ]
    let panelDisImage = [
        nil, // 0 空
        UIImage(named: "flame_dis.png"), // 1 炎
        UIImage(named: "aqua_dis.png"),  // 2 水
        UIImage(named: "wind_dis.png"),  // 3 風
        UIImage(named: "light_dis.png"), // 4 光
        UIImage(named: "dark_dis.png"),  // 5 闇
        UIImage(named: "none_dis.png"),  // 6 無
        UIImage(named: "hart_dis.png")  // 7 回復
    ]
    let countOnImage = [
        nil, // 0
        UIImage(named: "panel_on_one.png"), // 1
        UIImage(named: "panel_on_two.png"),  // 2
        UIImage(named: "panel_on_three.png"),  // 3
        UIImage(named: "panel_on_four.png"), // 4
        UIImage(named: "panel_on_five.png")  // 5
    ]
    let countOffImage = [
        nil, // 0
        UIImage(named: "panel_off_one.png"), // 1
        UIImage(named: "panel_off_two.png"),  // 2
        UIImage(named: "panel_off_three.png"),  // 3
        UIImage(named: "panel_off_four.png"), // 4
        UIImage(named: "panel_off_five.png")  // 5
    ]
    
    init(sourceView: UIView) {
        self.sourceView = sourceView
        super.init()
        
        self.setUpMenuView()
        
        animator = UIDynamicAnimator(referenceView: sourceView)
        
        // Add hide gesture recognizer
        let hideGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        condMenuContainerView.addGestureRecognizer(hideGestureRecognizer)
        
        let tapOutsideGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapOutsideGesture:")
        outsideView.addGestureRecognizer(tapOutsideGestureRecognizer)
    }
    
    func setUpMenuView() {
        // tapOutsideGestureRecognizer
        outsideView.frame = CGRectZero
        sourceView.addSubview(outsideView)
        
        // Configure condtion menu container
        if let view = UINib(nibName: "NSConditionMenu", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            condMenuContainerView = view
            condMenuContainerView.frame = CGRectMake(0, sourceView.frame.origin.y - menuHeight, sourceView.bounds.width, menuHeight)
            sourceView.addSubview(condMenuContainerView)
        }
        /*
        condMenuContainerView.frame = CGRectMake(0, sourceView.frame.origin.y - menuHeight, sourceView.frame.width, menuHeight)
        condMenuContainerView.backgroundColor = UIColor.clearColor()
        
        sourceView.addSubview(condMenuContainerView)
        */
        /*
        // Add blur View
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        visualEffectView.frame = condMenuContainerView.bounds
        condMenuContainerView.addSubview(visualEffectView)
        
        
        // Configure condition buttons
        // 属性条件
        let elementImageWidth: CGFloat = 40
        let elementImagePadding: CGFloat = (sourceView.frame.width - elementImageWidth * 6) / 7
        let labelFrame = CGRectMake(10, 8, sourceView.frame.width - 20, 14)
        let labelCond: UILabel = UILabel(frame: labelFrame)
        labelCond.text = "属性"
        labelCond.font = UIFont.systemFontOfSize(14)
        labelCond.textColor = UIColor.whiteColor()
        labelCond.textAlignment = NSTextAlignment.Center
        condMenuContainerView.addSubview(labelCond)
        
        flame = UIButton(frame: CGRectMake(elementImagePadding, labelFrame.origin.y + labelFrame.height + 6, elementImageWidth, elementImageWidth))
        flame!.setImage(panelImage[1], forState: .Selected)
        flame!.setImage(panelDisImage[1], forState: .Normal)
        flame!.addTarget(self, action: "flameSelected:", forControlEvents: .TouchUpInside)
        
        aqua = UIButton(frame: CGRectMake(elementImagePadding * 2 + elementImageWidth, labelFrame.origin.y + labelFrame.height + 6, elementImageWidth, elementImageWidth))
        aqua!.setImage(panelImage[2], forState: .Selected)
        aqua!.setImage(panelDisImage[2], forState: .Normal)
        aqua!.addTarget(self, action: "aquaSelected:", forControlEvents: .TouchUpInside)
        
        wind = UIButton(frame: CGRectMake(elementImagePadding * 3 + elementImageWidth * 2, labelFrame.origin.y + labelFrame.height + 6, elementImageWidth, elementImageWidth))
        wind!.setImage(panelImage[3], forState: .Selected)
        wind!.setImage(panelDisImage[3], forState: .Normal)
        wind!.addTarget(self, action: "windSelected:", forControlEvents: .TouchUpInside)
        
        light = UIButton(frame: CGRectMake(elementImagePadding * 4 + elementImageWidth * 3, labelFrame.origin.y + labelFrame.height + 6, elementImageWidth, elementImageWidth))
        light!.setImage(panelImage[4], forState: .Selected)
        light!.setImage(panelDisImage[4], forState: .Normal)
        light!.addTarget(self, action: "lightSelected:", forControlEvents: .TouchUpInside)
        
        dark = UIButton(frame: CGRectMake(elementImagePadding * 5 + elementImageWidth * 4, labelFrame.origin.y + labelFrame.height + 6, elementImageWidth, elementImageWidth))
        dark!.setImage(panelImage[5], forState: .Selected)
        dark!.setImage(panelDisImage[5], forState: .Normal)
        dark!.addTarget(self, action: "darkSelected:", forControlEvents: .TouchUpInside)
        
        none = UIButton(frame: CGRectMake(elementImagePadding * 6 + elementImageWidth * 5, labelFrame.origin.y + labelFrame.height + 6, elementImageWidth, elementImageWidth))
        none!.setImage(panelImage[6], forState: .Selected)
        none!.setImage(panelDisImage[6], forState: .Normal)
        none!.addTarget(self, action: "noneSelected:", forControlEvents: .TouchUpInside)
        
        condMenuContainerView.addSubview(flame!)
        condMenuContainerView.addSubview(aqua!)
        condMenuContainerView.addSubview(wind!)
        condMenuContainerView.addSubview(light!)
        condMenuContainerView.addSubview(dark!)
        condMenuContainerView.addSubview(none!)
        
        // パネル数
        let panelCountWidth: CGFloat = 45
        let panelCountPadding: CGFloat = 10
        let panelCountMargin: CGFloat = (sourceView.frame.width - panelCountWidth * 5 - panelCountPadding * 4)/2
        let labelCount = UILabel(frame: CGRectMake(10, flame!.frame.origin.y + flame!.frame.height + 8, sourceView.frame.width - 20, 14))
        labelCount.text = "パネル数"
        labelCount.font = UIFont.systemFontOfSize(14)
        labelCount.textColor = UIColor.whiteColor()
        labelCount.textAlignment = NSTextAlignment.Center
        condMenuContainerView.addSubview(labelCount)
        
        count1 = UIButton(frame: CGRectMake(panelCountMargin, labelCount.frame.origin.y + labelCount.frame.height + 6, panelCountWidth, panelCountWidth))
        count1!.setImage(countOffImage[1], forState: .Normal)
        count1!.setImage(countOnImage[1], forState: .Selected)
        count1!.addTarget(self, action: "count1Selected:", forControlEvents: .TouchUpInside)
        
        count2 = UIButton(frame: CGRectMake(panelCountMargin + panelCountPadding + panelCountWidth, labelCount.frame.origin.y + labelCount.frame.height + 6, panelCountWidth, panelCountWidth))
        count2!.setImage(countOffImage[2], forState: .Normal)
        count2!.setImage(countOnImage[2], forState: .Selected)
        count2!.addTarget(self, action: "count2Selected:", forControlEvents: .TouchUpInside)
        
        count3 = UIButton(frame: CGRectMake(panelCountMargin + panelCountPadding * 2 + panelCountWidth * 2, labelCount.frame.origin.y + labelCount.frame.height + 6, panelCountWidth, panelCountWidth))
        count3!.setImage(countOffImage[3], forState: .Normal)
        count3!.setImage(countOnImage[3], forState: .Selected)
        count3!.addTarget(self, action: "count3Selected:", forControlEvents: .TouchUpInside)
        
        count4 = UIButton(frame: CGRectMake(panelCountMargin + panelCountPadding * 3 + panelCountWidth * 3, labelCount.frame.origin.y + labelCount.frame.height + 6, panelCountWidth, panelCountWidth))
        count4!.setImage(countOffImage[4], forState: .Normal)
        count4!.setImage(countOnImage[4], forState: .Selected)
        count4!.addTarget(self, action: "count4Selected:", forControlEvents: .TouchUpInside)
        
        count5 = UIButton(frame: CGRectMake(panelCountMargin + panelCountPadding * 4 + panelCountWidth * 4, labelCount.frame.origin.y + labelCount.frame.height + 6, panelCountWidth, panelCountWidth))
        count5!.setImage(countOffImage[5], forState: .Normal)
        count5!.setImage(countOnImage[5], forState: .Selected)
        count5!.addTarget(self, action: "count5Selected:", forControlEvents: .TouchUpInside)
        
        condMenuContainerView.addSubview(count1!)
        condMenuContainerView.addSubview(count2!)
        condMenuContainerView.addSubview(count3!)
        condMenuContainerView.addSubview(count4!)
        condMenuContainerView.addSubview(count5!)
        
        // パネル条件
        let panelImageWidth: CGFloat = 45
        let panelImagePadding: CGFloat = 10
        let panelImageMargin: CGFloat = (sourceView.frame.width - panelImageWidth * 5 - panelImagePadding * 4)/2
        let labelPanel = UILabel(frame: CGRectMake(140, count1!.frame.origin.y + count1!.frame.height + 8, sourceView.frame.width - 280, 14))
        labelPanel.text = "パネル"
        labelPanel.font = UIFont.systemFontOfSize(14)
        labelPanel.textColor = UIColor.whiteColor()
        labelPanel.textAlignment = NSTextAlignment.Center
        condMenuContainerView.addSubview(labelPanel)
        
        let segConPanelItems = ["Include", "Included"]
        segConPanel = UISegmentedControl(items: segConPanelItems)
        segConPanel!.frame = CGRectMake(labelPanel.frame.origin.x + labelPanel.bounds.size.width + 10, labelPanel.frame.origin.y - 3, 120, 20)
        segConPanel!.tintColor = UIColor.whiteColor()
        segConPanel!.selectedSegmentIndex = 0
        segConPanel!.addTarget(self, action: "changePanelIndex:", forControlEvents: .ValueChanged)
        condMenuContainerView.addSubview(segConPanel!)
        
        panel1 = UIButton(frame: CGRectMake(panelImageMargin, labelPanel.frame.origin.y + labelPanel.frame.height + 6, panelImageWidth, panelImageWidth))
        panel1!.setImage(panelImage[panelIndex[0]], forState: .Normal)
        panel1!.setImage(UIImage(named: "disable.png"), forState: UIControlState.Disabled)
        panel1!.addTarget(self, action: "panel1Selected:", forControlEvents: .TouchUpInside)
        
        panel2 = UIButton(frame: CGRectMake(panelImageMargin + panelImagePadding + panelImageWidth, labelPanel.frame.origin.y + labelPanel.frame.height + 6, panelImageWidth, panelImageWidth))
        panel2!.setImage(panelImage[panelIndex[1]], forState: .Normal)
        panel2!.setImage(UIImage(named: "disable.png"), forState: UIControlState.Disabled)
        panel2!.addTarget(self, action: "panel2Selected:", forControlEvents: .TouchUpInside)
        
        panel3 = UIButton(frame: CGRectMake(panelImageMargin + panelImagePadding * 2 + panelImageWidth * 2, labelPanel.frame.origin.y + labelPanel.frame.height + 6, panelImageWidth, panelImageWidth))
        panel3!.setImage(panelImage[panelIndex[2]], forState: .Normal)
        panel3!.setImage(UIImage(named: "disable.png"), forState: UIControlState.Disabled)
        panel3!.addTarget(self, action: "panel3Selected:", forControlEvents: .TouchUpInside)
        
        panel4 = UIButton(frame: CGRectMake(panelImageMargin + panelImagePadding * 3 + panelImageWidth * 3, labelPanel.frame.origin.y + labelPanel.frame.height + 6, panelImageWidth, panelImageWidth))
        panel4!.setImage(panelImage[panelIndex[3]], forState: .Normal)
        panel4!.setImage(UIImage(named: "disable.png"), forState: UIControlState.Disabled)
        panel4!.addTarget(self, action: "panel4Selected:", forControlEvents: .TouchUpInside)
        
        panel5 = UIButton(frame: CGRectMake(panelImageMargin + panelImagePadding * 4 + panelImageWidth * 4, labelPanel.frame.origin.y + labelPanel.frame.height + 6, panelImageWidth, panelImageWidth))
        panel5!.setImage(panelImage[panelIndex[4]], forState: .Normal)
        panel5!.setImage(UIImage(named: "disable.png"), forState: UIControlState.Disabled)
        panel5!.addTarget(self, action: "panel5Selected:", forControlEvents: .TouchUpInside)
        
        condMenuContainerView.addSubview(panel1!)
        condMenuContainerView.addSubview(panel2!)
        condMenuContainerView.addSubview(panel3!)
        condMenuContainerView.addSubview(panel4!)
        condMenuContainerView.addSubview(panel5!)
        
        // タイプ条件
        let labelType = UILabel(frame: CGRectMake(10, panel1!.frame.origin.y + panel1!.frame.height + 8, sourceView.frame.width - 20, 14))
        labelType.text = "表示タイプ"
        labelType.font = UIFont.systemFontOfSize(14)
        labelType.textColor = UIColor.whiteColor()
        labelType.textAlignment = NSTextAlignment.Center
        condMenuContainerView.addSubview(labelType)
        
        let segConItems = ["ALL", "ATK", "単体", "全体", "HEAL"]
        segConType = UISegmentedControl(items: segConItems)
        segConType!.frame = CGRectMake(10, labelType.frame.origin.y + labelType.frame.height + 6, sourceView.frame.width - 20, 29)
        segConType!.tintColor = UIColor.whiteColor()
        segConType!.selectedSegmentIndex = 0
        segConType!.addTarget(self, action: "changeTypeIndex:", forControlEvents: .ValueChanged)
        condMenuContainerView.addSubview(segConType!)
        
        // ボトムボタン
        let buttonMargin: CGFloat = 10
        let buttonWidth: CGFloat = (sourceView.frame.width) / 2 - buttonMargin
        let buttonHeight: CGFloat = 36
        let buttonY: CGFloat = menuHeight - buttonHeight - 4
        
        let buttonClear = UIButton(frame: CGRectMake(buttonMargin, buttonY, buttonWidth, buttonHeight))
        buttonClear.setTitle("クリア", forState: .Normal)
        buttonClear.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buttonClear.setTitleColor(UIColor.lightTextColor(), forState: .Highlighted)
        buttonClear.addTarget(self, action: "clearButtonPushed:", forControlEvents: .TouchUpInside)
        buttonClear.titleLabel!.font = UIFont.boldSystemFontOfSize(UIFont.buttonFontSize())
        
        let buttonDone = UIButton(frame: CGRectMake(buttonMargin + buttonWidth, buttonClear.frame.origin.y, buttonWidth, buttonHeight))
        buttonDone.setTitle("完了", forState: .Normal)
        buttonDone.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buttonDone.setTitleColor(UIColor.lightTextColor(), forState: .Highlighted)
        buttonDone.addTarget(self, action: "doneButtonPushed:", forControlEvents: .TouchUpInside)
        buttonDone.titleLabel!.font = UIFont.boldSystemFontOfSize(UIFont.buttonFontSize())
        */
        /*
        condMenuContainerView.addSubview(buttonClear)
        condMenuContainerView.addSubview(buttonDone)
        
        let border = UIView(frame: CGRectMake(10, buttonClear.frame.origin.y - 4, sourceView.frame.width - 20, 1))
        border.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        condMenuContainerView.addSubview(border)
        */
    }
    
    
    // MARK: - action methods
    
    @IBAction func flameSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("Flame: \(selected)")
        condIndex[0] = selected
        print("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    @IBAction func aquaSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("aqua: \(selected)")
        condIndex[1] = selected
        print("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    @IBAction func windSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("Wind: \(selected)")
        condIndex[2] = selected
        print("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    @IBAction func lightSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("Light: \(selected)")
        condIndex[3] = selected
        print("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    @IBAction func darkSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("Dark: \(selected)")
        condIndex[4] = selected
        print("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    @IBAction func noneSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("None: \(selected)")
        condIndex[5] = selected
        print("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    @IBAction func count1Selected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("count1: \(selected)")
        countIndex[0] = selected
        print("countIndex: \(countIndex)")
        changePanelDisabled()
        valueChanged = true
    }
    
    @IBAction func count2Selected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("count2: \(selected)")
        countIndex[1] = selected
        print("countIndex: \(countIndex)")
        changePanelDisabled()
        valueChanged = true
    }
    
    @IBAction func count3Selected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("count3: \(selected)")
        countIndex[2] = selected
        print("countIndex: \(countIndex)")
        changePanelDisabled()
        valueChanged = true
    }
    
    @IBAction func count4Selected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("count4: \(selected)")
        countIndex[3] = selected
        print("countIndex: \(countIndex)")
        changePanelDisabled()
        valueChanged = true
    }
    
    @IBAction func count5Selected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("count5: \(selected)")
        countIndex[4] = selected
        print("countIndex: \(countIndex)")
        changePanelDisabled()
        valueChanged = true
    }
    
    @IBAction func changePanelIndex(sender: UISegmentedControl) {
        panelSearchIndex = sender.selectedSegmentIndex
        print("panelSearchIndex: \(panelSearchIndex)")
        changePanelDisabled()
        valueChanged = true
    }
    
    @IBAction func panel1Selected(sender: UIButton) {
        panelIndex[0] = (panelIndex[0] + 1) % 8
        print("panel1: \(panelIndex[0])")
        sender.setImage(panelImage[panelIndex[0]], forState: .Normal)
        print("panelIndex: \(panelIndex)")
        valueChanged = true
    }
    
    @IBAction func panel2Selected(sender: UIButton) {
        panelIndex[1] = (panelIndex[1] + 1) % 8
        print("panel1: \(panelIndex[1])")
        sender.setImage(panelImage[panelIndex[1]], forState: .Normal)
        print("panelIndex: \(panelIndex)")
        valueChanged = true
    }
    
    @IBAction func panel3Selected(sender: UIButton) {
        panelIndex[2] = (panelIndex[2] + 1) % 8
        print("panel1: \(panelIndex[2])")
        sender.setImage(panelImage[panelIndex[2]], forState: .Normal)
        print("panelIndex: \(panelIndex)")
        valueChanged = true
    }
    
    @IBAction func panel4Selected(sender: UIButton) {
        panelIndex[3] = (panelIndex[3] + 1) % 8
        print("panel1: \(panelIndex[3])")
        sender.setImage(panelImage[panelIndex[3]], forState: .Normal)
        print("panelIndex: \(panelIndex)")
        valueChanged = true
    }
    
    @IBAction func panel5Selected(sender: UIButton) {
        panelIndex[4] = (panelIndex[4] + 1) % 8
        print("panel1: \(panelIndex[4])")
        sender.setImage(panelImage[panelIndex[4]], forState: .Normal)
        print("panelIndex: \(panelIndex)")
        valueChanged = true
    }
    
    @IBAction func changeTypeIndex(sender: UISegmentedControl) {
        typeIndex = sender.selectedSegmentIndex
        print("typeIndex: \(typeIndex)")
        valueChanged = true
    }
    
    func decidePanelDisabled() -> Int {
        var enables = 0
        for bool in countIndex {
            enables++
            if bool {
                break
            }
        }
        return enables
    }
    
    func changePanelDisabled() {
        panel1!.enabled = true
        panel2!.enabled = true
        panel3!.enabled = true
        panel4!.enabled = true
        panel5!.enabled = true
        if panelSearchIndex == 0 {
            switch decidePanelDisabled() {
            case    1:
                panel2!.enabled = false
                fallthrough
            case    2:
                panel3!.enabled = false
                fallthrough
            case    3:
                panel4!.enabled = false
                fallthrough
            case    4:
                panel5!.enabled = false
                fallthrough
            default :
                break
            }
        }
    }

    func sendListConditioning() {
        if valueChanged {
            valueChanged = !valueChanged
            var panel = [0, 0, 0, 0, 0]
            if panelSearchIndex == 0 {
                for i in 0..<decidePanelDisabled() {
                    panel[i] = panelIndex[i]
                }
            } else {
                panel = panelIndex
            }
            delegate?.listConditioning(condIndex: condIndex, countIndex: countIndex, panelSearchIndex: panelSearchIndex, panelIndex: panel, typeIndex: typeIndex)
        }
    }
    
    @IBAction func clearButtonPushed(sender: UIButton) {
        flame!.selected = false
        aqua!.selected = false
        wind!.selected = false
        light!.selected = false
        dark!.selected = false
        none!.selected = false
        condIndex = [false, false, false, false, false, false]
        count1!.selected = false
        count2!.selected = false
        count3!.selected = false
        count4!.selected = false
        count5!.selected = false
        panel1!.setImage(panelImage[0], forState: .Normal)
        panel2!.setImage(panelImage[0], forState: .Normal)
            panel3!.setImage(panelImage[0], forState: .Normal)
        panel4!.setImage(panelImage[0], forState: .Normal)
        panel5!.setImage(panelImage[0], forState: .Normal)
        countIndex = [false, false, false, false, false]
        segConPanel!.selectedSegmentIndex = 0
        panelSearchIndex = 0
        panelIndex = [0, 0, 0, 0, 0]
        segConType!.selectedSegmentIndex = 0
        typeIndex = 0
        changePanelDisabled()
        valueChanged = true
    }
    
    @IBAction func doneButtonPushed(sender: UIButton) {
        delegate?.condMenuWillClose()
        sendListConditioning()
        toggleMenu(false)
    }
    
    
    // MARK: - toggle methods
    
    func handleGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .Up {
            toggleMenu(false)
        }
    }
    
    func tapOutsideGesture(gesture: UITapGestureRecognizer) {
        toggleMenu(false)
    }
    
    func toggleMenu(shouldOpen: Bool) {
        if (!shouldOpen) {
            delegate?.condMenuWillClose()
            sendListConditioning()
        }
        
        toggleOutsideView(shouldOpen)
        
        animator.removeAllBehaviors()
        isMenuOpen = shouldOpen
        let gravityDirectionY: CGFloat = shouldOpen ? 10 : -10
        let boundaryPointY: CGFloat = shouldOpen ? menuHeight + navConHeight : -menuHeight
        // 重力
        let gravityBehavior = UIGravityBehavior(items: [condMenuContainerView])
        gravityBehavior.gravityDirection = CGVectorMake(0, gravityDirectionY)
        animator.addBehavior(gravityBehavior)
        // 地面
        let collisionBehavior = UICollisionBehavior(items: [condMenuContainerView])
        collisionBehavior.addBoundaryWithIdentifier("menuBoundary",
            fromPoint: CGPointMake(0, boundaryPointY),
            toPoint: CGPointMake(sourceView.frame.size.width, boundaryPointY)
        )
        animator.addBehavior(collisionBehavior)
        // 跳ね返り
        let menuViewBehavior = UIDynamicItemBehavior(items: [condMenuContainerView])
        menuViewBehavior.elasticity = 0.1
        animator.addBehavior(menuViewBehavior)
    }
    
    func toggleOutsideView(shouldOpen: Bool) {
        if shouldOpen {
            outsideView.frame = sourceView.frame
            UIView.animateWithDuration(0.3, animations: {() in
                self.outsideView.backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 12/255, alpha: 0.5)
            })
        } else {
            UIView.animateWithDuration(0.3, animations: {() in
                self.outsideView.backgroundColor = UIColor.clearColor()
                }, completion: {Bool in
                    self.outsideView.frame = CGRectZero
            })
        }
    }
    
    func toggleMenu() {
        isMenuOpen ? toggleMenu(false) : toggleMenu(true)
    }
   
}
