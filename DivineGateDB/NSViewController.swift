
//
//  NSViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData

class NSViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var listNS: [NSData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.bounds = self.view.bounds
        let stuBarHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        let navBarHeight: CGFloat? = self.navigationController?.navigationBar.frame.size.height
        tableView.contentInset.top = stuBarHeight + navBarHeight! * 2
        tableView.scrollIndicatorInsets.top = stuBarHeight + navBarHeight! * 2
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let nib = UINib(nibName: "NSCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NSCell")
        
        /*
        *ダミーデータ
        */
        initNSDataObject(1, number: 1, name: "イグナイト", detail: nil, panel: [1, 1], target: 1, element: 1, leverage: 1, type: "d", critical: 0)
        initNSDataObject(5, number: 1, name: "ワダツミ", detail: nil, panel: [2, 2], target: 1, element: 2, leverage: 1, type: "d", critical: 0)
        initNSDataObject(9, number: 1, name: "フォンシェン", detail: nil, panel: [3, 3], target: 1, element: 3, leverage: 1, type: "d", critical: 0)
        initNSDataObject(630, number: 1, name: "エナジーヒール：アクアⅡ", detail: nil, panel: [2, 2], target: 0, element: 2, leverage: 0.1, type: "h", critical: nil)
        initNSDataObject(725, number: 1, name: "フレッシュソング", detail: "敵単体を光属性の歌で凄く魅了する", panel: [4, 4], target: 1, element: 4, leverage: 2.3, type: "d", critical: 0)
        initNSDataObject(899, number: 1, name: "インフィニティ・リバース", detail: nil, panel: [1, 2, 3, 4, 5], target: 1, element: 6, leverage: 8, type: "d", critical: 0)
        initNSDataObject(1062, number: 1, name: "オペレーションリヴァイブ", detail: nil, panel: [1, 2, 3, 6], target: 2, element: 5, leverage: 3, type: "d", critical: 0.44)
        initNSDataObject(1064, number: 1, name: "トリオ：フォルテ", detail: nil, panel: [1, 1], target: 1, element: 1, leverage: 3, type: "d", critical: 0.13)
        
        listNS = loadNSDataObject()
        
    }
    
    func initNSDataObject(unit: Int, number: Int, name: String, detail: String?, panel: [Int], target: Int, element: Int, leverage: Double, type: String, critical: Double?) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "NSData")
        request.predicate = NSPredicate(format: "unit = %d", unit)
         var results = context.executeFetchRequest(request, error: nil)
        
        if results?.count == 0 {
            let ent = NSEntityDescription.entityForName("NSData", inManagedObjectContext: context)
            var NS = NSData(entity: ent!, insertIntoManagedObjectContext: context)
            NS.initNSData(unit, Number: number, Name: name, Detail: detail?, Panel: panel, Target: target, Element: element, Leverage: leverage, Type: type, Critical: critical?)
            
            var error: NSError?
            if !context.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            } else {
                println("save \(NS.name)")
            }
        } else {
            println("\(name) is already saved!")
        }
    }
    
    func loadNSDataObject() -> [NSData]? {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "NSData")
        request.returnsObjectsAsFaults = false
//        request.predicate = NSPredicate(format: "%@ = %d", <<keys[]>>, <<values[]>>)
        
        var results = context.executeFetchRequest(request, error: nil)!
        return  results as? [NSData]
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
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listNS!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("NSCell") as NSCell
        cell.setCell(listNS![indexPath.row])
        
        return cell
    }
    
    
    
    // MARK: - UITableViewDelegate method
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell = tableView.dequeueReusableCellWithIdentifier("NSCell") as NSCell
        var bounds = cell.bounds
        bounds.size.width = tableView.bounds.width
        cell.bounds = bounds
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell.contentView.bounds.height
    }
    
}
