//
//  UnitsViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit

class UnitsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var listUnit = [UnitsData]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        var nib = UINib(nibName: "UnitsCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "UnitCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.bounds = self.view.bounds
        let stuBarHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        let navBarHeight: CGFloat? = self.navigationController?.navigationBar.frame.size.height
        let toolBarHeight: CGFloat? = self.navigationController?.toolbar.frame.size.height
        tableView.contentInset.top = stuBarHeight + navBarHeight! + toolBarHeight!
        
        /*
         *ダミーデータ
         */
        let listNumber = [1, 2, 3, 1011, 894]
        let listName = ["アカネ", "アオト", "ミドリ", "教祖クロウリー", "炎咎甲士アカネ"]
        let listType = [0, 1, 2, 4, 0]
        let listRare = [3, 3, 3, 6, 7]
        let listRace = ["人間", "人間", "人間", "人間", "人間"]
        let listCost = [2, 2, 2, 40, 30]
        let listLevel = [5, 5, 5, 99, 99]
        let listHP = [152, 167, 162, 3850, 2371]
        let listATK = [77, 69, 62, 2850, 2208]
        for i in 0..<listName.count {
            let unit = (UnitsData(num: listNumber[i], name: listName[i], type: listType[i], rare: listRare[i], race: listRace[i], cost: listCost[i], lv: listLevel[i], hp: listHP[i], atk: listATK[i]))
            listUnit.append(unit)
        }

        
        let userDefault = NSUserDefaults.standardUserDefaults()
        let data = NSKeyedArchiver.archivedDataWithRootObject(listUnit)
        userDefault.setObject(data, forKey: "Unit")

    }
    
    override func viewWillAppear(animated: Bool) {
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
    
    
    
    // MARK: - UITableViewDataSource method
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listUnit.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("UnitCell") as UnitsCell
        cell.setCell(listUnit[indexPath.row], atIndexPath: indexPath)
//        let userDefault = NSUserDefaults.standardUserDefaults()
//        let data = userDefault.objectForKey("Unit") as NSData
//        var unit = NSKeyedUnarchiver.unarchiveObjectWithData(data) as [UnitsData]
//        cell.setCell(unit[indexPath.row], atIndexPath: indexPath)
        return cell
    }
    
    
    
    // MARK: - UITableViewDelegate method
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell = tableView.dequeueReusableCellWithIdentifier("UnitCell") as UnitsCell
        var bounds = cell.bounds
        bounds.size.width = tableView.bounds.width
        cell.bounds = bounds
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell.contentView.bounds.height
    }

}
