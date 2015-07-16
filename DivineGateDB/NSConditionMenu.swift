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
    func listConditioning(#condIndex: [Bool], countIndex: [Bool], panelIndex: [Int], typeIndex: Int)
}

class NSConditionMenu: NSObject {
    
    var menuHeight: CGFloat = 320
    let navConHeight: CGFloat = 64  // If you use NavigationController
    let toolBarHeight: CGFloat = 44 // If you use toolBar
    let sourceView: UIView!
    var delegate: NSConditionMenuDelegate?
    let condMenuContainerView = UIView()
    let outsideView = UIView()
    var isMenuOpen: Bool = false
    var animator: UIDynamicAnimator!
    
    var valueChanged: Bool = false

    var condIndex: [Bool] = [false, false, false, false, false, false]
    var countIndex: [Bool] = [false, false, false, false, false]
    var panelIndex: [Int] = [0, 0, 0, 0, 0]   // 8進数で選択中のパネル条件を格納(5桁)
    var typeIndex: Int = 0
    
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
    var panel1: UIButton?
    var panel2: UIButton?
    var panel3: UIButton?
    var panel4: UIButton?
    var panel5: UIButton?
    var segConType: UISegmentedControl?
    
    let panelImage = [
        UIImage(named: "empty.png"), // 0 空
        UIImage(named: "flame.png"), // 1 炎
        UIImage(named: "aqua.png"),  // 2 水
        UIImage(named: "wind.png"),  // 3 風
        UIImage(named: "light.png"), // 4 光
        UIImage(named: "dark.png"),  // 5 闇
        UIImage(named: "none.png"),  // 6 無
        UIImage(named: "hart.png"),  // 7 回復
    ]
    
    init(sourceView: UIView) {
        self.sourceView = sourceView
        super.init()
        
        self.setUpMenuView()
        
        animator = UIDynamicAnimator(referenceView: sourceView)
        
        // Add hide gesture recognizer
        var hideGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        condMenuContainerView.addGestureRecognizer(hideGestureRecognizer)
        
        var tapOutsideGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapOutsideGesture:")
        outsideView.addGestureRecognizer(tapOutsideGestureRecognizer)
    }
    
    func setUpMenuView() {
        // tapOutsideGestureRecognizer
        outsideView.frame = CGRectZero
        sourceView.addSubview(outsideView)
        
        // Configure condtion menu container
        condMenuContainerView.frame = CGRectMake(0, sourceView.frame.origin.y - menuHeight, sourceView.frame.width, menuHeight)
        condMenuContainerView.backgroundColor = UIColor.clearColor()
        
        sourceView.addSubview(condMenuContainerView)
        
        // Add blur View
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
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
        flame!.setImage(UIImage(named: "flame_dis.png"), forState: .Normal)
        flame!.addTarget(self, action: "flameSelected:", forControlEvents: .TouchUpInside)
        
        aqua = UIButton(frame: CGRectMake(elementImagePadding * 2 + elementImageWidth, labelFrame.origin.y + labelFrame.height + 6, elementImageWidth, elementImageWidth))
        aqua!.setImage(panelImage[2], forState: .Selected)
        aqua!.setImage(UIImage(named: "aqua_dis.png"), forState: .Normal)
        aqua!.addTarget(self, action: "aquaSelected:", forControlEvents: .TouchUpInside)
        
        wind = UIButton(frame: CGRectMake(elementImagePadding * 3 + elementImageWidth * 2, labelFrame.origin.y + labelFrame.height + 6, elementImageWidth, elementImageWidth))
        wind!.setImage(panelImage[3], forState: .Selected)
        wind!.setImage(UIImage(named: "wind_dis.png"), forState: .Normal)
        wind!.addTarget(self, action: "windSelected:", forControlEvents: .TouchUpInside)
        
        light = UIButton(frame: CGRectMake(elementImagePadding * 4 + elementImageWidth * 3, labelFrame.origin.y + labelFrame.height + 6, elementImageWidth, elementImageWidth))
        light!.setImage(panelImage[4], forState: .Selected)
        light!.setImage(UIImage(named: "light_dis.png"), forState: .Normal)
        light!.addTarget(self, action: "lightSelected:", forControlEvents: .TouchUpInside)
        
        dark = UIButton(frame: CGRectMake(elementImagePadding * 5 + elementImageWidth * 4, labelFrame.origin.y + labelFrame.height + 6, elementImageWidth, elementImageWidth))
        dark!.setImage(panelImage[5], forState: .Selected)
        dark!.setImage(UIImage(named: "dark_dis.png"), forState: .Normal)
        dark!.addTarget(self, action: "darkSelected:", forControlEvents: .TouchUpInside)
        
        none = UIButton(frame: CGRectMake(elementImagePadding * 6 + elementImageWidth * 5, labelFrame.origin.y + labelFrame.height + 6, elementImageWidth, elementImageWidth))
        none!.setImage(panelImage[6], forState: .Selected)
        none!.setImage(UIImage(named: "none_dis.png"), forState: .Normal)
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
        count1!.setImage(UIImage(named: "panel_off_one.png"), forState: .Normal)
        count1!.setImage(UIImage(named: "panel_on_one.png"), forState: .Selected)
        count1!.addTarget(self, action: "count1Selected:", forControlEvents: .TouchUpInside)
        
        count2 = UIButton(frame: CGRectMake(panelCountMargin + panelCountPadding + panelCountWidth, labelCount.frame.origin.y + labelCount.frame.height + 6, panelCountWidth, panelCountWidth))
        count2!.setImage(UIImage(named: "panel_off_two.png"), forState: .Normal)
        count2!.setImage(UIImage(named: "panel_on_two.png"), forState: .Selected)
        count2!.addTarget(self, action: "count2Selected:", forControlEvents: .TouchUpInside)
        
        count3 = UIButton(frame: CGRectMake(panelCountMargin + panelCountPadding * 2 + panelCountWidth * 2, labelCount.frame.origin.y + labelCount.frame.height + 6, panelCountWidth, panelCountWidth))
        count3!.setImage(UIImage(named: "panel_off_three.png"), forState: .Normal)
        count3!.setImage(UIImage(named: "panel_on_three.png"), forState: .Selected)
        count3!.addTarget(self, action: "count3Selected:", forControlEvents: .TouchUpInside)
        
        count4 = UIButton(frame: CGRectMake(panelCountMargin + panelCountPadding * 3 + panelCountWidth * 3, labelCount.frame.origin.y + labelCount.frame.height + 6, panelCountWidth, panelCountWidth))
        count4!.setImage(UIImage(named: "panel_off_four.png"), forState: .Normal)
        count4!.setImage(UIImage(named: "panel_on_four.png"), forState: .Selected)
        count4!.addTarget(self, action: "count4Selected:", forControlEvents: .TouchUpInside)
        
        count5 = UIButton(frame: CGRectMake(panelCountMargin + panelCountPadding * 4 + panelCountWidth * 4, labelCount.frame.origin.y + labelCount.frame.height + 6, panelCountWidth, panelCountWidth))
        count5!.setImage(UIImage(named: "panel_off_five.png"), forState: .Normal)
        count5!.setImage(UIImage(named: "panel_on_five.png"), forState: .Selected)
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
        let labelPanel = UILabel(frame: CGRectMake(10, count1!.frame.origin.y + count1!.frame.height + 8, sourceView.frame.width - 20, 14))
        labelPanel.text = "パネル"
        labelPanel.font = UIFont.systemFontOfSize(14)
        labelPanel.textColor = UIColor.whiteColor()
        labelPanel.textAlignment = NSTextAlignment.Center
        condMenuContainerView.addSubview(labelPanel)
        
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
        segConType!.frame.origin.y = labelType.frame.origin.y + labelType.frame.height + 6
        segConType!.frame = CGRectMake(10, labelType.frame.origin.y + labelType.frame.height + 6, sourceView.frame.width - 20, 29)
        segConType!.tintColor = UIColor.whiteColor()
        segConType!.selectedSegmentIndex = 0
        segConType!.addTarget(self, action: "changeTypeIndex:", forControlEvents: UIControlEvents.ValueChanged)
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
        
        condMenuContainerView.addSubview(buttonClear)
        condMenuContainerView.addSubview(buttonDone)
        
        let border = UIView(frame: CGRectMake(10, buttonClear.frame.origin.y - 4, sourceView.frame.width - 20, 1))
        border.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        condMenuContainerView.addSubview(border)
    }
    
    
    // MARK: - action methods
    
    func flameSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        println("Flame: \(selected)")
        condIndex[0] = selected
        println("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    func aquaSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        println("aqua: \(selected)")
        condIndex[1] = selected
        println("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    func windSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        println("Wind: \(selected)")
        condIndex[2] = selected
        println("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    func lightSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        println("Light: \(selected)")
        condIndex[3] = selected
        println("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    func darkSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        println("Dark: \(selected)")
        condIndex[4] = selected
        println("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    func noneSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        println("None: \(selected)")
        condIndex[5] = selected
        println("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    func count1Selected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        println("count1: \(selected)")
        countIndex[0] = selected
        println("countIndex: \(countIndex)")
        changePanelDisabled()
        valueChanged = true
    }
    
    func count2Selected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        println("count2: \(selected)")
        countIndex[1] = selected
        println("countIndex: \(countIndex)")
        changePanelDisabled()
        valueChanged = true
    }
    
    func count3Selected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        println("count3: \(selected)")
        countIndex[2] = selected
        println("countIndex: \(countIndex)")
        changePanelDisabled()
        valueChanged = true
    }
    
    func count4Selected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        println("count4: \(selected)")
        countIndex[3] = selected
        println("countIndex: \(countIndex)")
        changePanelDisabled()
        valueChanged = true
    }
    
    func count5Selected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        println("count5: \(selected)")
        countIndex[4] = selected
        println("countIndex: \(countIndex)")
        changePanelDisabled()
        valueChanged = true
    }
    func panel1Selected(sender: UIButton) {
        panelIndex[0] = (panelIndex[0] + 1) % 8
        println("panel1: \(panelIndex[0])")
        sender.setImage(panelImage[panelIndex[0]], forState: .Normal)
        println("panelIndex: \(panelIndex)")
        valueChanged = true
    }
    
    func panel2Selected(sender: UIButton) {
        panelIndex[1] = (panelIndex[1] + 1) % 8
        println("panel1: \(panelIndex[1])")
        sender.setImage(panelImage[panelIndex[1]], forState: .Normal)
        println("panelIndex: \(panelIndex)")
        valueChanged = true
    }
    
    func panel3Selected(sender: UIButton) {
        panelIndex[2] = (panelIndex[2] + 1) % 8
        println("panel1: \(panelIndex[2])")
        sender.setImage(panelImage[panelIndex[2]], forState: .Normal)
        println("panelIndex: \(panelIndex)")
        valueChanged = true
    }
    
    func panel4Selected(sender: UIButton) {
        panelIndex[3] = (panelIndex[3] + 1) % 8
        println("panel1: \(panelIndex[3])")
        sender.setImage(panelImage[panelIndex[3]], forState: .Normal)
        println("panelIndex: \(panelIndex)")
        valueChanged = true
    }
    
    func panel5Selected(sender: UIButton) {
        panelIndex[4] = (panelIndex[4] + 1) % 8
        println("panel1: \(panelIndex[4])")
        sender.setImage(panelImage[panelIndex[4]], forState: .Normal)
        println("panelIndex: \(panelIndex)")
        valueChanged = true
    }
    
    func changeTypeIndex(sender: UISegmentedControl) {
        typeIndex = sender.selectedSegmentIndex
        println("typeIndex: \(typeIndex)")
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

    func sendListConditioning() {
        if valueChanged {
            valueChanged = !valueChanged
            var panel = [0, 0, 0, 0, 0]
            for i in 0..<decidePanelDisabled() {
                panel[i] = panelIndex[i]
            }
            delegate?.listConditioning(condIndex: condIndex, countIndex: countIndex, panelIndex: panel, typeIndex: typeIndex)
        }
    }
    
    func clearButtonPushed(sender: UIButton) {
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
        panelIndex = [0, 0, 0, 0, 0]
        segConType!.selectedSegmentIndex = 0
        typeIndex = 0
        changePanelDisabled()
        valueChanged = true
    }
    
    func doneButtonPushed(sender: UIButton) {
        delegate?.condMenuWillClose()
        toggleMenu(false)
        sendListConditioning()
    }
    
    
    // MARK: - toggle methods
    
    func handleGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .Up {
            delegate?.condMenuWillClose()
            toggleMenu(false)
            sendListConditioning()
        }
    }
    
    func tapOutsideGesture(gesture: UITapGestureRecognizer) {
        delegate?.condMenuWillClose()
        toggleMenu(false)
        if valueChanged {
            valueChanged = !valueChanged
            delegate?.listConditioning(condIndex: condIndex, countIndex: countIndex, panelIndex: panelIndex, typeIndex: typeIndex)
        }
    }
    
    func toggleMenu(shouldOpen: Bool) {
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
