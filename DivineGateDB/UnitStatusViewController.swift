//
//  UnitStatusViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/14/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import MBProgressHUD

class UnitStatusViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var progressHud: MBProgressHUD!
    
    var unitNo: Int!
    var unit: Unit?
    var ns: [NS]?
    var ls: LS?
    var ps: PS?
    
    override func loadView() {
        super.loadView()
        /*
        if let view = UINib(nibName: "UnitStatusView", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
        */
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        progressHud = MBProgressHUD(view: self.view)
        self.view.addSubview(progressHud)
        
        loadProfile()
        
        setUpTableView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.bringSubviewToFront(progressHud)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - GCD
    
    func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    func dispatch_async_global(block: () -> ()) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue, block)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Set up methods
    
    func loadProfile() {
        progressHud.show(true)
        progressHud.dimBackground = true
        
        dispatch_async_global {
            self.unit = UnitsTable(units: [self.unitNo]).rows.first
            self.ns = NSTable(units: [self.unitNo]).rows
            for skill in self.ns! {
                skill.changeValue(plusIs: false, crtIs: true, averageIs: false)
            }
            self.ls = LSTable(units: [self.unitNo]).rows.first
            self.ps = PSTable(units: [self.unitNo]).rows.first
            
            self.dispatch_async_main {
                self.progressHud.hide(true)
                self.title = self.unit!.name
                self.tableView.reloadData()
            }
        }
    }
    
    func setUpTableView() {
        tableView.dataSource  = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        var inset = tableView.contentInset
        inset.top = UIApplication.sharedApplication().statusBarFrame.height
        if let navBarHeight = self.navigationController?.navigationBar.bounds.height {
            inset.top += navBarHeight
        }
        if let tabBarHeight = self.tabBarController?.tabBar.bounds.height {
            inset.bottom = tabBarHeight
        }
        tableView.contentInset = inset
        tableView.scrollIndicatorInsets = inset
        
        let imageNib = UINib(nibName: "UnitImageCell", bundle: nil)
        tableView.registerNib(imageNib, forCellReuseIdentifier: "UnitImageCell")
        let UnitsNib = UINib(nibName: "UnitsCell", bundle: nil)
        tableView.registerNib(UnitsNib, forCellReuseIdentifier: "UnitsCell")
        let NSNib = UINib(nibName: "NSCell", bundle: nil)
        tableView.registerNib(NSNib, forCellReuseIdentifier: "NSCell")
        let LSNib = UINib(nibName: "LSCell", bundle: nil)
        tableView.registerNib(LSNib, forCellReuseIdentifier: "LSCell")
        let PSNib = UINib(nibName: "PSCell", bundle: nil)
        tableView.registerNib(PSNib, forCellReuseIdentifier: "PSCell")
    }
    
    
    // MARK: - UITableViewDataSource methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // image
            return 1
        case 1: // unit
            if unit != nil {
                return 1
            } else {
                return 0
            }
        case 2: // LS
            if ls != nil {
                return 1
            } else {
                return 0
            }
        case 3: // NS
            if ns != nil {
                return ns!.count
            } else {
                return 0
            }
        case 4: // PS
            if ps != nil {
                return 1
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("UnitImageCell") as! UnitImageCell
            cell.setCell(unitNo)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("UnitsCell") as! UnitsCell
            if let unit = unit {
                cell.setCell(unit)
            } else {
                cell.setEmptyCell()
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("LSCell") as! LSCell
            if let ls = ls {
                cell.setCell(ls, showIcon: false)
            } else {
                cell.setEmptyCell()
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("NSCell") as! NSCell
            if !ns!.isEmpty {
                cell.setCell(ns![indexPath.row], showIcon: false, plusIs: false, crtIs: true, averageIs: false)
            } else {
                cell.setEmptyCell()
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("PSCell") as! PSCell
            if let ps = ps {
                cell.setCell(ps, showIcon: false)
            } else {
                cell.setEmptyCell()
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
            return cell!
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 283
        case 1:
            return 55
        case 2:
            return 44
        case 3:
            fallthrough
        case 4:
            return 60
        default:
            return 44
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section >= 2 {
            return 22
        }
        return 0
    }

}
