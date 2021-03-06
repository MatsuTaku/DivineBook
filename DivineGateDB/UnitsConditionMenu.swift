//
//  UnitsConditionMenu.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 2/25/15.
//  Copyright (c) 2015 TakumaMatsumoto. All rights reserved.
//

import UIKit

protocol UnitsConditionMenuDelegate {
    func condMenuWillClose()
    func listConditioning(condIndex condIndex: [Bool], raceIndex: [Bool])
}

class UnitsConditionMenu: NSObject {
    
    var menuHeight: CGFloat = 265
    let navConHeight: CGFloat = 64  // If you use NavigationController
    let toolBarHeight: CGFloat = 44 // If you use toolBar
    let sourceView: UIView!
    let condMenuContainerView = UIView()
    let outsideView = UIView()
    let scrollView = UIScrollView()
    let condMenuSubView = UIView()
    var isMenuOpen: Bool = false
    var animator: UIDynamicAnimator!
    var delegate: UnitsConditionMenuDelegate?
    
    var valueChanged: Bool = false
    
    var condIndex: [Bool] = [false, false, false, false, false, false]
    var raceIndex: [Bool] = [false, false, false, false, false, false, false, false]  // 人間、竜、神、魔物、妖精、獣、機械、強化
    
    var flame: UIButton?
    var aqua: UIButton?
    var wind: UIButton?
    var light: UIButton?
    var dark: UIButton?
    var none: UIButton?
    var human: UIButton?
    var dragon: UIButton?
    var god: UIButton?
    var devil: UIButton?
    var fairy: UIButton?
    var beast: UIButton?
    var machine: UIButton?
    var enhance: UIButton?
    
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
        condMenuContainerView.frame = CGRectMake(0, sourceView.frame.origin.y - menuHeight, sourceView.frame.width, menuHeight)
        condMenuContainerView.backgroundColor = UIColor.clearColor()
        sourceView.addSubview(condMenuContainerView)
        
        /*
        // include UnitsConditionView
        let view = UnitsConditionView(frame: condMenuContainerView.bounds)
        view.delegate = self
        condMenuContainerView.addSubview(view)
        */

        
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
        
        // Configure race buttons
        let raceImagePadding: CGFloat = 16
        let raceImageMargin: CGFloat = 16
        let raceImageWidth: CGFloat = (sourceView.frame.width - raceImageMargin * 2 - raceImagePadding) / 2
        let raceImageHeight: CGFloat = 22
//        let raceImageMargin: CGFloat = (sourceView.frame.width - raceImageWidth * 2 - raceImagePadding)/2
        let raceFlame = CGRectMake(10, flame!.frame.origin.y + flame!.bounds.height + 8, sourceView.bounds.width - 20, 14)
        let labelRace = UILabel(frame: raceFlame)
        labelRace.text = "種族"
        labelRace.font = UIFont.systemFontOfSize(14)
        labelRace.textColor = UIColor.whiteColor()
        labelRace.textAlignment = NSTextAlignment.Center
        condMenuContainerView.addSubview(labelRace)
        
        human = UINib(nibName: "DivineButton", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIButton
        human!.frame = CGRectMake(raceImageMargin, raceFlame.origin.y + raceFlame.height + 6, raceImageWidth, raceImageHeight)
        human!.setTitle("人間", forState: .Normal)
        human!.addTarget(self, action: "humanSelected:", forControlEvents: .TouchUpInside)
        condMenuContainerView.addSubview(human!)
        
        dragon = UINib(nibName: "DivineButton", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIButton
        dragon!.frame = CGRectMake(raceImageMargin + raceImageWidth + raceImagePadding, human!.frame.origin.y, raceImageWidth, raceImageHeight)
        dragon!.setTitle("竜", forState: .Normal)
        dragon!.addTarget(self, action: "dragonSelected:", forControlEvents: .TouchUpInside)
        condMenuContainerView.addSubview(dragon!)
        
        god = UINib(nibName: "DivineButton", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIButton
        god!.frame = CGRectMake(raceImageMargin, human!.frame.origin.y + human!.bounds.height + 8, raceImageWidth, raceImageHeight)
        god!.setTitle("神", forState: .Normal)
        god!.addTarget(self, action: "godSelected:", forControlEvents: .TouchUpInside)
        condMenuContainerView.addSubview(god!)
        
        devil = UINib(nibName: "DivineButton", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIButton
        devil!.frame = CGRectMake(raceImageMargin + raceImageWidth + raceImagePadding, human!.frame.origin.y + human!.bounds.height + 8, raceImageWidth, raceImageHeight)
        devil!.setTitle("魔物", forState: .Normal)
        devil!.addTarget(self, action: "devilSelected:", forControlEvents: .TouchUpInside)
        condMenuContainerView.addSubview(devil!)
        
        fairy = UINib(nibName: "DivineButton", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIButton
        fairy!.frame = CGRectMake(raceImageMargin, god!.frame.origin.y + god!.bounds.height + 8, raceImageWidth, raceImageHeight)
        fairy!.setTitle("妖精", forState: .Normal)
        fairy!.addTarget(self, action: "fairySelected:", forControlEvents: .TouchUpInside)
        condMenuContainerView.addSubview(fairy!)
        
        beast = UINib(nibName: "DivineButton", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIButton
        beast!.frame = CGRectMake(raceImageMargin + raceImageWidth + raceImagePadding, god!.frame.origin.y + god!.bounds.height + 8, raceImageWidth, raceImageHeight)
        beast!.setTitle("獣", forState: .Normal)
        beast!.addTarget(self, action: "beastSelected:", forControlEvents: .TouchUpInside)
        condMenuContainerView.addSubview(beast!)
        
        machine = UINib(nibName: "DivineButton", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIButton
        machine!.frame = CGRectMake(raceImageMargin, fairy!.frame.origin.y + fairy!.bounds.height + 8, raceImageWidth, raceImageHeight)
        machine!.setTitle("機械", forState: .Normal)
        machine!.addTarget(self, action: "machineSelected:", forControlEvents: .TouchUpInside)
        condMenuContainerView.addSubview(machine!)
        
        enhance = UINib(nibName: "DivineButton", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIButton
        enhance!.frame = CGRectMake(raceImageMargin + raceImageWidth + raceImagePadding, fairy!.frame.origin.y + fairy!.bounds.height + 8, raceImageWidth, raceImageHeight)
        enhance!.setTitle("強化合成用", forState: UIControlState.Normal)
//        enhance!.setBackgroundImage(UIImage(named: "buttonBack"), forState: .Normal)
//        enhance!.setBackgroundImage(UIImage(named: "buttonBack_on"), forState: .Selected)
        enhance!.addTarget(self, action: "enhanceSelected:", forControlEvents: .TouchUpInside)
        condMenuContainerView.addSubview(enhance!)
        
        
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
        print("Flame: \(selected)")
        condIndex[0] = selected
        print("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    func aquaSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("Aqua: \(selected)")
        condIndex[1] = selected
        print("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    func windSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("Wind: \(selected)")
        condIndex[2] = selected
        print("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    func lightSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("Light: \(selected)")
        condIndex[3] = selected
        print("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    func darkSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("Dark: \(selected)")
        condIndex[4] = selected
        print("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    func noneSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("None: \(selected)")
        condIndex[5] = selected
        print("condIndex: \(condIndex)")
        valueChanged = true
    }
    
    func humanSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("human: \(selected)")
        raceIndex[0] = selected
        print("raceIndex: \(raceIndex)")
        valueChanged = true
    }
    
    func dragonSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("dragon: \(selected)")
        raceIndex[1] = selected
        print("raceIndex: \(raceIndex)")
        valueChanged = true
    }
    
    func godSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("god: \(selected)")
        raceIndex[2] = selected
        print("raceIndex: \(raceIndex)")
        valueChanged = true
    }
    
    func devilSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("devil: \(selected)")
        raceIndex[3] = selected
        print("raceIndex: \(raceIndex)")
        valueChanged = true
    }
    
    func fairySelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("fairy: \(selected)")
        raceIndex[4] = selected
        print("raceIndex: \(raceIndex)")
        valueChanged = true
    }
    
    func beastSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("beast: \(selected)")
        raceIndex[5] = selected
        print("raceIndex: \(raceIndex)")
        valueChanged = true
    }
    
    func machineSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("machine: \(selected)")
        raceIndex[6] = selected
        print("raceIndex: \(raceIndex)")
        valueChanged = true
    }
    
    func enhanceSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        print("enhance: \(selected)")
        raceIndex[7] = selected
        print("raceIndex: \(raceIndex)")
        valueChanged = true
    }
    
    func clearButtonPushed(sender: UIButton) {
        flame!.selected = false
        aqua!.selected = false
        wind!.selected = false
        light!.selected = false
        dark!.selected = false
        none!.selected = false
        human!.selected = false
        dragon!.selected = false
        god!.selected = false
        devil!.selected = false
        fairy!.selected = false
        beast!.selected = false
        machine!.selected = false
        enhance!.selected = false
        condIndex = [false, false, false, false, false, false]
        raceIndex = [false, false, false, false, false, false, false, false]
        valueChanged = true
    }
    
    func clearButtonPushed() {
        flame!.selected = false
        aqua!.selected = false
        wind!.selected = false
        light!.selected = false
        dark!.selected = false
        none!.selected = false
        human!.selected = false
        dragon!.selected = false
        god!.selected = false
        devil!.selected = false
        fairy!.selected = false
        beast!.selected = false
        machine!.selected = false
        enhance!.selected = false
        condIndex = [false, false, false, false, false, false]
        raceIndex = [false, false, false, false, false, false, false, false]
        valueChanged = true
    }
    
    func sendListConditioning() {
        if valueChanged {
            valueChanged = !valueChanged
            delegate?.listConditioning(condIndex: condIndex, raceIndex: raceIndex)
        }
    }
    
    func doneButtonPushed(sender: UIButton) {
        delegate?.condMenuWillClose()
        sendListConditioning()
        toggleMenu(false)
    }
    
    func doneButtonPushed() {
        delegate?.condMenuWillClose()
        sendListConditioning()
        toggleMenu(false)
    }
    
    
    // MARK: - UnitsConditionViewDelegate methods
    
    func selectedElement(selected: Bool, atIndex index: Int) {
        condIndex[index] = selected
        valueChanged = true
    }
    
    func selectedRace(selected: Bool, atIndex index: Int) {
        raceIndex[index] = selected
        valueChanged = true
    }
    
    
    // MARK: - toggle methods
    
    func handleGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .Up {
            delegate?.condMenuWillClose()
            sendListConditioning()
            toggleMenu(false)
        }
    }
    
    func tapOutsideGesture(gesture: UITapGestureRecognizer) {
        delegate?.condMenuWillClose()
        sendListConditioning()
        toggleMenu(false)
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
