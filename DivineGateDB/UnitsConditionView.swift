//
//  UnitsConditionView.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 2015/08/24.
//  Copyright (c) 2015年 TakumaMatsumoto. All rights reserved.
//

import UIKit

protocol UnitsConditionViewDelegate {
    func selectedElement(selected: Bool, atIndex index: Int)
    func selectedRace(selected: Bool, atIndex index: Int)
    func clearButtonPushed()
    func doneButtonPushed()
}

class UnitsConditionView: UIView {
    
    var delegate: UnitsConditionViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let view: UIView = NSBundle.mainBundle().loadNibNamed("UnitsConditionView", owner: self, options: nil).first as! UnitsConditionView
        view.frame = self.bounds
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.addSubview(view)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let view: UIView = NSBundle.mainBundle().loadNibNamed("UnitsConditionView", owner: self, options: nil).first as! UnitsConditionView
        view.frame = self.bounds
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.addSubview(view)
    }
    
    
    override func awakeFromNib() {
        let view: UIView = NSBundle.mainBundle().loadNibNamed("UnitsConditionView", owner: self, options: nil).first as! UIView
        addSubview(view)
    }
    
    @IBAction func flameSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 1)
    }
    
    @IBAction func aquaSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 2)
    }
    
    @IBAction func windSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 3)
    }
    
    @IBAction func lightSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 4)
    }
    
    @IBAction func darkSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 5)
    }
    
    @IBAction func noneSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 6)
    }
    
    @IBAction func humanSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 0)
    }
    
    @IBAction func dragonSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 1)
    }
    
    @IBAction func godSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 2)
    }
    
    @IBAction func devilSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 3)
    }
    
    @IBAction func fairySelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 4)
    }
    
    @IBAction func beastSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 5)
    }
    
    @IBAction func machineSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 6)
    }
    
    @IBAction func enhanceSelected(sender: UIButton) {
        let selected = !sender.selected
        sender.selected = selected
        delegate?.selectedElement(selected, atIndex: 7)
    }
    
    @IBAction func clearButtonPushed(sender: UIButton) {
        delegate?.clearButtonPushed()
    }
    
    @IBAction func doneButtonPushed(sender: UIButton) {
        delegate?.doneButtonPushed()
    }
    
}