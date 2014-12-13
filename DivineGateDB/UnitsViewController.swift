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
        
        println("\(self.view.bounds.height) : \(tableView.bounds.height)")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        var nib = UINib(nibName: "UnitsCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "UnitCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.bounds = self.view.bounds
        
        // ダミーデータ
        let listName: [String] = ["アカネ", "アオト", "ミドリ", "クロウリー"]
        let listType: [Int] = [0, 1, 2, 4]
        let listRare: [Int] = [3, 3, 3, 6]
        let listRace: [String] = ["人間", "人間", "人間", "人間"]
        let listCost: [Int] = [2, 2, 2, 40]
        for i in 0..<listName.count {
            listUnit.append(UnitsData(num: i + 1, name: listName[i], type: listType[i], rare: listRare[i], race: listRace[i], cost: listCost[i]))
        }

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
