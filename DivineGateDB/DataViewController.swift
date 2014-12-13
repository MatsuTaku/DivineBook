//
//  DataViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {
    
    @IBOutlet weak var segmentedControlData: UISegmentedControl!
    @IBOutlet var contentView: UIView!
    
    var currentViewController: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // selectedView
        let viewController = self.viewControllerForSegmentedIndex(segmentedControlData.selectedSegmentIndex)
        self.addChildViewController(viewController)
        
        viewController.view.bounds = self.contentView.bounds
        self.contentView.addSubview(viewController.view)
        self.currentViewController = viewController
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
    
    
    @IBAction func changeSegmentedIndex(sender: UISegmentedControl) {
        let viewController = self.viewControllerForSegmentedIndex(segmentedControlData.selectedSegmentIndex)
        self.addChildViewController(viewController)
        
        self.currentViewController.view.removeFromSuperview()
        viewController.view.bounds = self.contentView.bounds
        self.contentView.addSubview(viewController.view)
        
        self.currentViewController.didMoveToParentViewController(self)
        self.currentViewController.removeFromParentViewController()
        self.currentViewController = viewController
    }
    
    // MARK: - selectedViewController method
    
    func viewControllerForSegmentedIndex(index: NSInteger) -> UIViewController
    {
        var vc: UIViewController?
        switch index {
        case 0 :
            vc = self.storyboard?.instantiateViewControllerWithIdentifier("Units") as UnitsViewController
        case 1 :
            vc = self.storyboard?.instantiateViewControllerWithIdentifier("LS") as LSViewController
        case 2 :
            vc = self.storyboard?.instantiateViewControllerWithIdentifier("AS") as ASViewController
        case 3 :
            vc = self.storyboard?.instantiateViewControllerWithIdentifier("NS") as NSViewController
        case 4 :
            vc = self.storyboard?.instantiateViewControllerWithIdentifier("PS") as PSViewController
        default :
            break
        }
        return vc!
    }

}
