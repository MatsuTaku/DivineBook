//
//  UnitsViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData

protocol UnitsViewControllerDelegate  {
    func setUpUnitsList() -> [UnitsData]
}

class UnitsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UnitsConditionMenuDelegate {
    
    var delegate: UnitsViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var conditionMenu: UnitsConditionMenu?
    
    var listUnits: [UnitsData] = []
    var list: [UnitsData] = []
    
    var isSearchMode: Bool = false
    var sortIndex: Int = 0 // 0: ↑num, 1: ↓num, 2: hp, 3: atk, 4: plus
    
    let accentColor = UIColor(red: 0.7, green: 0.1, blue: 0.8, alpha: 1)
    
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
        
        if let del = delegate {
            listUnits = del.setUpUnitsList()
        }
        list = listUnits
        reloadList()
        
        // Set up views
        setUpNavigationItems()
        
        conditionMenu = UnitsConditionMenu(sourceView: self.view)
        conditionMenu!.delegate = self
        
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
    
    
    // Set up navigation items
    
    func setUpNavigationItems() {
        // ButtonItems
        var conditionButton = UIBarButtonItem(title: "▼", style: .Done , target: self, action: "toggleConditionMenu:")
        var searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "changeSearchMode:")
        var sortButton = UIBarButtonItem()
        switch sortIndex {
        case    0:
            sortButton = sortButtonMakeInTitle("No↑")
        case    1:
            sortButton = sortButtonMakeInTitle("No↓")
        case    2:
            sortButton = sortButtonMakeInTitle("HP↓")
        case    3:
            sortButton = sortButtonMakeInTitle("ATK↓")
        case    4:
            sortButton = sortButtonMakeInTitle("+換算↓")
        default :
            break
        }
        
        let leftButtons = [conditionButton, searchButton]
        let rightButtons = [sortButton]
        
        let navigationItem = navigationBar!.items[0] as UINavigationItem
        
        navigationItem.leftBarButtonItems = leftButtons
        navigationItem.titleView = nil
        navigationItem.rightBarButtonItems = rightButtons
    }
    
    func reloadList() {
        sortAtIndex()
        tableView.reloadData()
        println("TableView reloaded!")
    }
    
    func toggleConditionMenu(sender: UIButton) {
        let stuBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let navBarHeight: CGFloat? = self.navigationController?.navigationBar.frame.size.height
        var insetTop: CGFloat?
        if !conditionMenu!.isMenuOpen {
            insetTop = stuBarHeight + navBarHeight! + self.conditionMenu!.menuHeight
            conditionMenu!.toggleMenu(true)
        } else {
            insetTop = stuBarHeight + navBarHeight!
            conditionMenu!.toggleMenu(false)
        }
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut,
            animations: {() in
                self.tableView.contentInset.top = insetTop!
                self.tableView.scrollIndicatorInsets.top = insetTop!
            }, completion: nil)
    }
    
    func sortAtIndex() {
        switch sortIndex {
        case    0:
            sortInNumUp()
        case    1:
            sortInNumDown()
        case    2:
            sortInHp()
        case    3:
            sortInAtk()
        case    4:
            sortInPlus()
        default :
            break
        }
    }
    
    func changeSortMode(index: Int) {
        if sortIndex != index {
            sortIndex = index
        }
        sortAtIndex()
        reloadList()
    }
    
    func sortInNumUp() {
        list.sort { (h: UnitsData, b: UnitsData) in
            h.unit < b.unit
        }
    }
    
    func sortInNumDown() {
        list.sort { (h: UnitsData, b: UnitsData) in
            h.unit > b.unit
        }
    }
    
    func sortInHp() {
        list.sort { (h: UnitsData, b: UnitsData) in
            h.hp > b.hp
        }
    }
    
    func sortInAtk() {
        list.sort { (h: UnitsData, b: UnitsData) in
            h.atk > b.atk
        }
    }
    
    func sortInPlus() {
        list.sort { (h: UnitsData, b: UnitsData) in
            h.stusOfPlus() > b.stusOfPlus()
        }
    }
    
    func sortUnits(sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: "並べ替え条件を選択", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let navigationItem = navigationBar!.items[0] as UINavigationItem
        let numUpSort = UIAlertAction(title: "No↑", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↑No]")
                self.changeSortMode(0)
                let sortButton = self.sortButtonMakeInTitle("No↑")
                navigationItem.rightBarButtonItems?[0] = sortButton
        })
        let numDownSort = UIAlertAction(title: "No↓", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↓No]")
                self.changeSortMode(1)
                let sortButton = self.sortButtonMakeInTitle("No↓")
                navigationItem.rightBarButtonItems?[0] = sortButton
        })
        let hpSort = UIAlertAction(title: "HP↓", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↓HP]")
                self.changeSortMode(2)
                let sortButton = self.sortButtonMakeInTitle("HP↓")
                navigationItem.rightBarButtonItems?[0] = sortButton
        })
        let atkSort = UIAlertAction(title: "ATK↓", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↓ATK]")
                self.changeSortMode(3)
                let sortButton = self.sortButtonMakeInTitle("ATK↓")
                navigationItem.rightBarButtonItems?[0] = sortButton
        })
        let plusSort = UIAlertAction(title: "+換算↓", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↓+換算]")
                self.changeSortMode(4)
                let sortButton = self.sortButtonMakeInTitle("+換算↓")
                navigationItem.rightBarButtonItems?[0] = sortButton
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        actionSheet.addAction(numUpSort)
        actionSheet.addAction(numDownSort)
        actionSheet.addAction(hpSort)
        actionSheet.addAction(atkSort)
        actionSheet.addAction(plusSort)
        actionSheet.addAction(cancel)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func sortButtonMakeInTitle(title: String) -> UIBarButtonItem {
        let sb = UIBarButtonItem(title: title, style: .Bordered, target: self, action: "sortUnits:")
        return sb
    }
    
    func changeSearchMode(sender: UIButton) {
        if isSearchMode == false {
            isSearchMode = true
            // SearchBar
            var searchBar = UISearchBar()
            searchBar.delegate = self
            searchBar.showsCancelButton = false
            searchBar.placeholder = "無英斧士ギンジ"
            searchBar.barTintColor = UIColor.whiteColor()
            searchBar.tintColor = accentColor
            searchBar.searchBarStyle = UISearchBarStyle.Default
            searchBar.frame.origin = CGPointMake(-150, 22)
            var cancelButton = UIBarButtonItem(title: "戻る", style: .Plain, target: self, action: "changeSearchMode:")
            
            let navigationItem = navigationBar!.items[0] as UINavigationItem
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: nil,
                animations: {
                    navigationItem.leftBarButtonItems = nil
                    navigationItem.titleView = searchBar
                    navigationItem.rightBarButtonItems = [cancelButton]
                }, completion: nil)
            searchBar.becomeFirstResponder()
        } else {
            isSearchMode = false
            setUpNavigationItems()
        }
    }
    
    // 検索ボタンを押した時
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
    }
    
    
    // MARK: - UnitsConditionMenuDelegate methods
    
    func condMenuWillClose() {
        let stuBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let navBarHeight: CGFloat? = self.navigationController?.navigationBar.frame.size.height
        let insetTop = stuBarHeight + navBarHeight! + navigationBar.bounds.height
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut,
            animations: {() in
                self.tableView.contentInset.top = insetTop
                self.tableView.scrollIndicatorInsets.top = insetTop
            }, completion: nil)
    }
    
    func listConditioning(#condIndex: [Bool], raceIndex: [Bool]) {
        var predicates = [NSPredicate] ()
        
        // 属性条件
        if condIndex != [false, false, false, false, false, false] {
            var energyArray = [NSPredicate]()
            for i in 0..<condIndex.count {
                if condIndex[i] == true {
                    energyArray.append(NSPredicate(format: "element == %d", i + 1)!)
                }
            }
            let energyPre = NSCompoundPredicate(type: .OrPredicateType, subpredicates: energyArray)
            predicates.append(energyPre)
        }
        
        // 種族条件
        if raceIndex != [] {
            
        }
        
        if predicates != [] {
            let predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: predicates)
            println(predicate)
            list = (listUnits as NSArray).filteredArrayUsingPredicate(predicate) as [UnitsData]
        } else {
            list = listUnits
        }
        
        reloadList()
    }
    
    
    // MARK: - UITableViewDataSource method
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("UnitCell") as UnitsCell
        cell.setCell(list[indexPath.row])
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
