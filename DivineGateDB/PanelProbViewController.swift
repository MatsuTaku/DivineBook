//
//  PanelProbViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 3/20/15.
//  Copyright (c) 2015 TakumaMatsumoto. All rights reserved.
//

import UIKit

class PanelProbViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var energyBar: UIView!
    @IBOutlet weak var flameWidth: NSLayoutConstraint!
    @IBOutlet weak var aquaWidth: NSLayoutConstraint!
    @IBOutlet weak var windWidth: NSLayoutConstraint!
    @IBOutlet weak var lightWidth: NSLayoutConstraint!
    @IBOutlet weak var darkWidth: NSLayoutConstraint!
    @IBOutlet weak var noneWidth: NSLayoutConstraint!
    @IBOutlet weak var hartWidth: NSLayoutConstraint!
    @IBOutlet weak var flamePercent: UILabel!
    @IBOutlet weak var aquaPercent: UILabel!
    @IBOutlet weak var windPercent: UILabel!
    @IBOutlet weak var lightPercent: UILabel!
    @IBOutlet weak var darkPercent: UILabel!
    @IBOutlet weak var nonePercent: UILabel!
    @IBOutlet weak var hartPercent: UILabel!
    @IBOutlet weak var flameRate: UITextField!
    @IBOutlet weak var aquaRate: UITextField!
    @IBOutlet weak var windRate: UITextField!
    @IBOutlet weak var lightRate: UITextField!
    @IBOutlet weak var darkRate: UITextField!
    @IBOutlet weak var noneRate: UITextField!
    @IBOutlet weak var hartRate: UITextField!
    
    var activeTextField = UITextField()
    var toolBar: UIToolbar?
    
    let sourceRates: [Double] = [7, 7, 7, 7, 7, 7, 8]
    var questsRates: [Double] = []
    var currentRates: [Double] = []
    var sourceLevels: [Double] = [1, 1, 1, 1, 1, 1, 1]
    var currentLevels: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        flameRate.delegate = self
        aquaRate.delegate = self
        windRate.delegate = self
        lightRate.delegate = self
        darkRate.delegate = self
        noneRate.delegate = self
        hartRate.delegate = self

        questsRates = sourceRates
        currentRates = questsRates
        currentLevels = sourceLevels
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        changeViewsRate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - CalcPanelAppearancive methods
    
    @IBAction func clearRates(sender: AnyObject) {
        questsRates = sourceRates
        currentRates = questsRates
        currentLevels = sourceLevels
        flameRate.text = NSString(format: "%.0f", currentLevels[0] * 100) as String
        aquaRate.text = NSString(format: "%.0f", currentLevels[1] * 100) as String
        windRate.text = NSString(format: "%.0f", currentLevels[2] * 100) as String
        lightRate.text = NSString(format: "%.0f", currentLevels[3] * 100) as String
        darkRate.text = NSString(format: "%.0f", currentLevels[4] * 100) as String
        noneRate.text = NSString(format: "%.0f", currentLevels[5] * 100) as String
        hartRate.text = NSString(format: "%.0f", currentLevels[6] * 100) as String
        changeViewsAnimation()
    }
    
    func percentArrayFromRates(rates: [Double]) -> [Double] {
        var percents = [Double]()
        var mother: Double = 0
        for rate in rates {
            mother += rate
        }
        for rate in rates {
            percents.append(rate / mother)
        }
        return percents
    }
    
    func percentColors() -> [UIColor] {
        var colors = [UIColor]()
        let muchColor = UIColor(red: 1, green: 0.6, blue: 0.6, alpha: 1)
        let fewColor = UIColor(red: 0.6, green: 0.6, blue: 1, alpha: 1)
        let currentPercents = percentArrayFromRates(currentRates)
        let defaultPercents = percentArrayFromRates(sourceRates)
        for i in 0..<currentPercents.count {
            if currentPercents[i] == defaultPercents[i] {
                colors.append(UIColor.whiteColor())
            } else {
                colors.append(currentPercents[i] > defaultPercents[i] ? muchColor : fewColor)
            }
        }
        return colors
    }
    
    func rateColors() -> [UIColor] {
        var colors = [UIColor]()
        let nonActiveColor = UIColor(red: 161/255, green: 184/255, blue: 235/255, alpha: 1)
        let activeColor = UIColor(red: 255/255, green: 216/255, blue: 179/255, alpha: 1)
        for level in currentLevels {
            if level == 1 {
                colors.append(nonActiveColor)
            } else {
                colors.append(activeColor)
            }
        }
        return colors
    }
    
    func changeViewsRate() {
        let mainWidth: CGFloat = energyBar.frame.width
        let percents = percentArrayFromRates(currentRates)
        flameWidth.constant = mainWidth * CGFloat(percents[0])
        aquaWidth.constant = mainWidth * CGFloat(percents[1])
        windWidth.constant = mainWidth * CGFloat(percents[2])
        lightWidth.constant = mainWidth * CGFloat(percents[3])
        darkWidth.constant = mainWidth * CGFloat(percents[4])
        noneWidth.constant = mainWidth * CGFloat(percents[5])
        hartWidth.constant = mainWidth * CGFloat(percents[6])
        
        flamePercent.text = NSString(format: "%.0f%%", percents[0] * 100) as String
        aquaPercent.text = NSString(format: "%.0f%%", percents[1] * 100) as String
        windPercent.text = NSString(format: "%.0f%%", percents[2] * 100) as String
        lightPercent.text = NSString(format: "%.0f%%", percents[3] * 100) as String
        darkPercent.text = NSString(format: "%.0f%%", percents[4] * 100) as String
        nonePercent.text = NSString(format: "%.0f%%", percents[5] * 100) as String
        hartPercent.text = NSString(format: "%.0f%%", percents[6] * 100) as String
        
        let pColors = percentColors()
        flamePercent.textColor = pColors[0]
        aquaPercent.textColor = pColors[1]
        windPercent.textColor = pColors[2]
        lightPercent.textColor = pColors[3]
        darkPercent.textColor = pColors[4]
        nonePercent.textColor = pColors[5]
        hartPercent.textColor = pColors[6]
        
        let rColors = rateColors()
        flameRate.textColor = rColors[0]
        aquaRate.textColor = rColors[1]
        windRate.textColor = rColors[2]
        lightRate.textColor = rColors[3]
        darkRate.textColor = rColors[4]
        noneRate.textColor = rColors[5]
        hartRate.textColor = rColors[6]
    }
    
    func changeViewsAnimation() {
        changeViewsRate()
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
            animations: {() in
                self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    // MARK: - ShowingKeyboard methods
    
    func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            let screenSize = UIScreen.mainScreen().bounds.size
            
            let textFieldBottom = activeTextField.frame.origin.y + activeTextField.bounds.height + 8
            let keyboardTop = screenSize.height - keyboardSize.height - toolBar!.bounds.height
            
            let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
            let curve = info[UIKeyboardAnimationCurveUserInfoKey] as! UInt
            let options = UIViewAnimationOptions(rawValue: curve)
            
            UIView.animateWithDuration(duration, delay: 0, options: options,
                animations: {() in
                    if textFieldBottom > keyboardTop {
                        self.view.frame.origin.y = keyboardTop - textFieldBottom
                    }
                    self.toolBar!.frame.origin.y = keyboardTop - self.view.frame.origin.y
                }, completion: nil)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let info = notification.userInfo {
            let screenSize = UIScreen.mainScreen().bounds.size
            
            let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
            let curve = info[UIKeyboardAnimationCurveUserInfoKey] as! UInt
            let options = UIViewAnimationOptions(rawValue: curve)
            
            UIView.animateWithDuration(duration, delay: 0, options: options,
                animations: {() in
                    self.view.frame.origin.y = 0
                    self.toolBar!.frame.origin.y = screenSize.height
                }, completion: {Bool in
                    if self.toolBar!.frame.origin.y >= screenSize.height {
                        self.toolBar!.removeFromSuperview()
                    }
            })
        }
    }
    
    
    // MARK: - UITextFieldDelegate methods
    
    func hideKeyboard(button: UIBarButtonItem) {
        activeTextField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        activeTextField = textField
        
        if toolBar == nil {
            let screenSize = UIScreen.mainScreen().bounds.size
            let barHeight: CGFloat = 44
            toolBar = UIToolbar(frame: CGRectMake(0, screenSize.height - barHeight, screenSize.width, barHeight))
            toolBar!.barTintColor = UIColor(red: 28/255, green: 28/255, blue: 28/255, alpha: 1)
            toolBar!.tintColor = UIColor(red: 195/255, green: 8/255, blue: 234/255, alpha: 1)
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            let closeButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Done, target: self, action: "hideKeyboard:")
            toolBar!.items = [flexibleSpace, closeButton]
        }
        self.view.addSubview(toolBar!)
        
        return true
    }
    
    func changeEnergyRateFromValue(index: Int, rate: String) {
        currentLevels[index] = (rate as NSString).doubleValue / 100
        currentRates[index] = questsRates[index] * currentLevels[index]
        
        changeViewsAnimation()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField {
        case    flameRate:
            changeEnergyRateFromValue(0, rate: textField.text!)
        case    aquaRate:
            changeEnergyRateFromValue(1, rate: textField.text!)
        case    windRate:
            changeEnergyRateFromValue(2, rate: textField.text!)
        case    lightRate:
            changeEnergyRateFromValue(3, rate: textField.text!)
        case    darkRate:
            changeEnergyRateFromValue(4, rate: textField.text!)
        case    noneRate:
            changeEnergyRateFromValue(5, rate: textField.text!)
        case    hartRate:
            changeEnergyRateFromValue(6, rate: textField.text!)
        default :
            break
        }
        textField.text = NSString(format: "%3.0f", (textField.text! as NSString).doubleValue) as String
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
