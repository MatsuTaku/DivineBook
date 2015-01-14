//
//  DataViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit

class DataViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var segmentedControlData: UISegmentedControl!
    @IBOutlet var contentView: UIView!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var currentViewController: UIViewController!
    var skillIndex: NSInteger = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // selectedView
        let viewController = self.viewControllerForSegmentedIndex(segmentedControlData.selectedSegmentIndex)
        self.addChildViewController(viewController)
        self.changeView(viewController)
        currentViewController = viewController
        println(currentViewController)
    }
    
    func changeView(viewController: UIViewController) {
        viewController.view.frame = self.contentView.frame
        self.contentView.addSubview(viewController.view)
        self.contentView.bringSubviewToFront(self.navBar)
    }
    
    @IBAction func changeSegmentIndex(sender: UISegmentedControl) {
        let viewController = self.viewControllerForSegmentedIndex(segmentedControlData.selectedSegmentIndex)
        self.currentViewController.willMoveToParentViewController(nil)
        self.animationOfChangingViewController(toViewController: viewController)
    }
    
    func changeSkillIndex(sender: UISegmentedControl) {
        self.skillIndex = sender.selectedSegmentIndex
        let viewController = self.skillViewControllerForSegmentedIndex(self.skillIndex)
        self.currentViewController.willMoveToParentViewController(nil)
        self.animationOfChangingViewController(toViewController: viewController)
    }
    
    func animationOfChangingViewController(toViewController viewController: UIViewController)
    {
        self.addChildViewController(viewController)
        self.transitionFromViewController(currentViewController, toViewController: viewController, duration: 0.25, options: UIViewAnimationOptions.TransitionCrossDissolve,
            animations: {() in
                self.currentViewController.view.removeFromSuperview()
                self.changeView(viewController)
                println("Animations did end.")
            }, completion: {Bool in
                self.currentViewController.removeFromParentViewController()
                viewController.didMoveToParentViewController(self)
                self.currentViewController = viewController
                println(self.currentViewController)
                println("Completion did end.")
            })
        println("ViewControllerDidChanged!")
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
    
    
    // MARK: - selectedViewController method
    
    func viewControllerForSegmentedIndex(index: NSInteger) -> UIViewController
    {
        // 切り替えるViewの指定
        var vc: UIViewController?
        switch index {
        case 0 : // Units
            vc = self.storyboard?.instantiateViewControllerWithIdentifier("Units") as UnitsViewController
            self.setBarItemsOfUnits()
        case 1 :
            vc = self.storyboard?.instantiateViewControllerWithIdentifier("NS") as NSViewController
            self.setBarItemsOfNS()
        case 2 : // Skills
            vc = self.skillViewControllerForSegmentedIndex(self.skillIndex)
            self.setBarItemsOfSkills()
        default :
            break
        }
        return vc!
    }
    
    func skillViewControllerForSegmentedIndex(index: NSInteger) -> UIViewController
    {
        var vc: UIViewController?
        switch index {
        case 0 :
            vc = self.storyboard?.instantiateViewControllerWithIdentifier("PS") as PSViewController
        case 1 :
            vc = self.storyboard?.instantiateViewControllerWithIdentifier("LS") as LSViewController
        case 2 :
            vc = self.storyboard?.instantiateViewControllerWithIdentifier("AS") as ASViewController
        default :
            break
        }
        return vc!
    }
    
    func setBarItemsOfUnits() {
        var leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: "sortUnits:")
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "searchUnits:")
        var searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBar.placeholder = "例：無英斧士ギンジ"
        searchBar.bounds.size.width = self.view.frame.size.width - 120
        searchBar.showsCancelButton = false
        navItem!.leftBarButtonItem = leftButton
        navItem!.titleView = searchBar
        navItem!.rightBarButtonItem = rightButton
    }
    
    func sortUnits(sender: UIButton) {
        
    }
    
    func searchUnits(sender: UIButton) {
        
    }
    
    func setBarItemsOfNS() {
        var leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: "sortNS:")
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "searchNS:")
        var searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBar.placeholder = "例：インフィニティ・リバース"
        searchBar.bounds.size.width = self.view.frame.size.width - 120
        searchBar.showsCancelButton = false
        navItem!.leftBarButtonItem = leftButton
        navItem!.titleView = searchBar
        navItem!.rightBarButtonItem = rightButton
    }
    
    func sortNS(sender: UIButton) {
        
    }
    
    func sesarchNS(sender: UIButton) {
        
    }
    
    func setBarItemsOfSkills() {
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "searchSkills")
        let skillItems = ["PS", "LS", "AS"]
        let segConSkill = UISegmentedControl(items: skillItems)
        segConSkill.frame.size.width = self.navBar.bounds.size.width
        segConSkill.addTarget(self, action: "changeSkillIndex:", forControlEvents: UIControlEvents.ValueChanged)
        segConSkill.selectedSegmentIndex = self.skillIndex
        navItem!.leftBarButtonItem = nil
        navItem!.titleView = segConSkill
        navItem!.rightBarButtonItem = rightButton
    }
    
    func searchSkills() {
        
    }
    
}
