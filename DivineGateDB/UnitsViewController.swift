//
//  UnitsViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData

class UnitsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var listUnit: [UnitsData]?
    
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
        tableView.contentInset.top = stuBarHeight + navBarHeight! * 2
        tableView.scrollIndicatorInsets.top = stuBarHeight + navBarHeight! * 2
        
        /*
        *ダミーデータ
        */
        initUnitsDataObject(1, name: "アカネ", element: 1, rare: 3, race: "人間", cost: 2, lv: 5, hp: 152, atk: 77)
        initUnitsDataObject(5, name: "アオト", element: 2, rare: 3, race: "人間", cost: 2, lv: 5, hp: 167, atk: 69)
        initUnitsDataObject(9, name: "ミドリ", element: 3, rare: 3, race: "人間", cost: 2, lv: 5, hp: 162, atk: 62)
        initUnitsDataObject(725, name: "元気を歌う少年：鏡音レン", element: 4, rare: 5, race: "機械", cost: 20, lv: 99, hp: 2204, atk: 1752)
        initUnitsDataObject(894, name: "炎咎甲士アカネ", element: 1, rare: 7, race: "人間", cost: 30, lv: 99, hp: 2371, atk: 2208)
        initUnitsDataObject(899, name: "無英斧士ギンジ", element: 6, rare: 7, race: "人間", cost: 30, lv: 99, hp: 2515, atk: 2161)
        initUnitsDataObject(1011, name: "教祖クロウリー", element: 4, rare: 6, race: "人間", cost: 40, lv: 99, hp: 3850, atk: 2850)
        initUnitsDataObject(1062, name: "死医者ネクロス", element: 5, rare: 6, race: "神", cost: 50, lv: 99, hp: 2715, atk: 2511)
        initUnitsDataObject(1064, name: "炎聖人ダンテ", element: 1, rare: 6, race: "神", cost: 40, lv: 99, hp: 3734, atk: 3187)
        
        listUnit = loadUnitsDataObject()
        
    }
    
    func initUnitsDataObject(unit: Int, name: String, element: Int, rare: Int, race: String, cost: Int, lv: Int, hp: Double, atk: Double) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "UnitsData")
        request.predicate = NSPredicate(format: "unit = %d", unit)
        var results = context.executeFetchRequest(request, error: nil)
        
        if results?.count == 0 {
            let ent = NSEntityDescription.entityForName("UnitsData", inManagedObjectContext: context)
            var Units = UnitsData(entity: ent!, insertIntoManagedObjectContext: context)
            Units.initUnitsData(unit, Name: name, Element: element, Rare: rare, Race: race, Cost: cost, Lv: lv, Hp: hp, Atk: atk)
            
            var error: NSError?
            if !context.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            } else {
                println("save \(Units.name)")
            }
        } else {
            println("\(name) is already saved!")
        }
    }
    
    func loadUnitsDataObject() -> [UnitsData]? {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "UnitsData")
        request.returnsObjectsAsFaults = false
        //        request.predicate = NSPredicate(format: "%@ = %d", <<keys[]>>, <<values[]>>)
        
        var results = context.executeFetchRequest(request, error: nil)!
        return  results as? [UnitsData]
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
        return listUnit!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("UnitCell") as UnitsCell
        cell.setCell(listUnit![indexPath.row])
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
