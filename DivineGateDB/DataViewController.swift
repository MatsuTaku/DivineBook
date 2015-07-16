//
//  DataViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData
import NTYCSVTable

class DataViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var contentsView: UIView!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    var controllerArray: [UIViewController]!
    var currentIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setup views
        let unitsViewController = storyboard?.instantiateViewControllerWithIdentifier("Units") as! UnitsViewController
        let nsViewController = storyboard?.instantiateViewControllerWithIdentifier("NS") as! NSViewController
        let lsViewController = storyboard?.instantiateViewControllerWithIdentifier("LS") as! LSViewController
        controllerArray = [unitsViewController, nsViewController, lsViewController]
        let index = segmentedController.selectedSegmentIndex
        let viewController = controllerArray[index]
        self.addChildViewController(viewController)
        contentsView.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
        currentIndex = index
        println(controllerArray[index])
        
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidLayoutSubviews() {
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
    
    // MARK: - Changing View Controller methods
    
    @IBAction func changeSegmentIndex(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let viewController = controllerArray[index]
        changeViewController(index)
    }
    
    func changeViewController(toIndex: Int) {
        let currentViewController = controllerArray[currentIndex]
        let toViewController = controllerArray[toIndex]
        currentViewController.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        let options: UIViewAnimationOptions = (toIndex < currentIndex ? .TransitionFlipFromLeft : .TransitionFlipFromRight)
        self.transitionFromViewController(currentViewController, toViewController: toViewController, duration: 0.2, options: options,
            animations: {() in
                // 動的アニメーション
            }, completion: {Bool in
                currentViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
                self.currentIndex = toIndex
                println(self.controllerArray[self.currentIndex])
        })
    }
    
}
