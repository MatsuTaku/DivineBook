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
    
    override func viewDidLayoutSubviews() {
        changeViewsRate()
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
    
    @IBAction func clearRates(sender: AnyObject) {
        questsRates = sourceRates
        currentRates = questsRates
        currentLevels = sourceLevels
        flameRate.text = NSString(format: "%.0f", currentLevels[0] * 100)
        aquaRate.text = NSString(format: "%.0f", currentLevels[1] * 100)
        windRate.text = NSString(format: "%.0f", currentLevels[2] * 100)
        lightRate.text = NSString(format: "%.0f", currentLevels[3] * 100)
        darkRate.text = NSString(format: "%.0f", currentLevels[4] * 100)
        noneRate.text = NSString(format: "%.0f", currentLevels[5] * 100)
        hartRate.text = NSString(format: "%.0f", currentLevels[6] * 100)
        changeViewsAnimation()
    }
    
    func percentArray() -> [Double] {
        var mother: Double = 0
        var percentArray: [Double] = [0, 0, 0, 0, 0, 0, 0]
        for rate in currentRates {
            mother += rate
        }
        for i in 0..<currentRates.count {
            percentArray[i] = currentRates[i] / mother
        }
        return percentArray
    }
    
    func changeViewsRate() {
        flamePercent.text = NSString(format: "%.0f%%", percentArray()[0] * 100)
        aquaPercent.text = NSString(format: "%.0f%%", percentArray()[1] * 100)
        windPercent.text = NSString(format: "%.0f%%", percentArray()[2] * 100)
        lightPercent.text = NSString(format: "%.0f%%", percentArray()[3] * 100)
        darkPercent.text = NSString(format: "%.0f%%", percentArray()[4] * 100)
        nonePercent.text = NSString(format: "%.0f%%", percentArray()[5] * 100)
        hartPercent.text = NSString(format: "%.0f%%", percentArray()[6] * 100)
        
        let mainWidth: CGFloat = energyBar.frame.width
        flameWidth.constant = mainWidth * CGFloat(percentArray()[0])
        aquaWidth.constant = mainWidth * CGFloat(percentArray()[1])
        windWidth.constant = mainWidth * CGFloat(percentArray()[2])
        lightWidth.constant = mainWidth * CGFloat(percentArray()[3])
        darkWidth.constant = mainWidth * CGFloat(percentArray()[4])
        noneWidth.constant = mainWidth * CGFloat(percentArray()[5])
        hartWidth.constant = mainWidth * CGFloat(percentArray()[6])
    }
    
    func changeViewsAnimation() {
        changeViewsRate()
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
            animations: {() in
                self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate methods
    
    func changeEnergyRateFromValue(index: Int, rate: String) {
        currentLevels[index - 1] = (rate as NSString).doubleValue / 100
        currentRates[index - 1] = questsRates[index - 1] * currentLevels[index - 1]
        
        changeViewsAnimation()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField {
        case    flameRate:
            changeEnergyRateFromValue(1, rate: textField.text)
        case    aquaRate:
            changeEnergyRateFromValue(2, rate: textField.text)
        case    windRate:
            changeEnergyRateFromValue(3, rate: textField.text)
        case    lightRate:
            changeEnergyRateFromValue(4, rate: textField.text)
        case    darkRate:
            changeEnergyRateFromValue(5, rate: textField.text)
        case    noneRate:
            changeEnergyRateFromValue(6, rate: textField.text)
        case    hartRate:
            changeEnergyRateFromValue(7, rate: textField.text)
        default :
            break
        }
        textField.text = NSString(format: "%3.0f", (textField.text as NSString).doubleValue)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
