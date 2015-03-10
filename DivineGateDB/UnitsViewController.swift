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
    var sortButtons = [UIBarButtonItem]()
    var defaultLeftButtons = [UIBarButtonItem]()
    var defaultRightButtons = [UIBarButtonItem]()
    var searchBar: UISearchBar?
//    var unitsSearchDisplayController: UISearchDisplayController?
    var cancelSearchButton: UIBarButtonItem?
    
    var listUnits = [UnitsData]()
    var list = [UnitsData]()
    var searchResultsList = [UnitsData]()
    
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
        tableView.estimatedRowHeight = 55.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.bounds = self.view.bounds
        
        var insetTop: CGFloat = 0
        let stuBarHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        insetTop += stuBarHeight
        if let navBarHeight = self.navigationController?.navigationBar.frame.size.height {
            insetTop += navBarHeight
        }
        insetTop += navigationBar.bounds.height
        tableView.contentInset.top = insetTop
        tableView.scrollIndicatorInsets.top = insetTop
        
        if let del = delegate {
            listUnits = del.setUpUnitsList()
        }
        list = listUnits
        listSortAndReload()
        
        // Set up views
        setUpNavigationItems()
        setNavigationItem(false)
        
        conditionMenu = UnitsConditionMenu(sourceView: self.view)
        conditionMenu!.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        let conditionButton = UIBarButtonItem(title: "▼", style: .Done , target: self, action: "toggleConditionMenu:")
        let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "searchButtonTapped:")
        defaultLeftButtons = [conditionButton, searchButton]
        
        sortButtons.insert(sortButtonMakeInTitle("No順"), atIndex: 0)
        sortButtons.insert(sortButtonMakeInTitle("No逆順"), atIndex: 1)
        sortButtons.insert(sortButtonMakeInTitle("HP順"), atIndex: 2)
        sortButtons.insert(sortButtonMakeInTitle("ATK順"), atIndex: 3)
        sortButtons.insert(sortButtonMakeInTitle("+換算順"), atIndex: 4)
        defaultRightButtons = [sortButtons[sortIndex]]
    }
    
    func listSortAndReload() {
        sortAtIndex()
        tableView.reloadData()
        println("UnitsTableView reloaded!")
    }
    
    func toggleConditionMenu(sender: UIButton) {
        var insetTop: CGFloat = 0
        let stuBarHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        insetTop += stuBarHeight
        if let navBarHeight = self.navigationController?.navigationBar.frame.size.height {
            insetTop += navBarHeight
        }
        if !conditionMenu!.isMenuOpen {
            insetTop += self.conditionMenu!.menuHeight
            conditionMenu!.toggleMenu(true)
        } else {
            insetTop += navigationBar!.bounds.height
            conditionMenu!.toggleMenu(false)
        }
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut,
            animations: {() in
                self.tableView.contentInset.top = insetTop
                self.tableView.scrollIndicatorInsets.top = insetTop
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
        let numUpSort = UIAlertAction(title: "No順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↑No]")
                self.sortIndex = 0
                self.defaultRightButtons = [self.sortButtons[self.sortIndex]]
                navigationItem.rightBarButtonItems = self.defaultRightButtons
                self.listSortAndReload()
        })
        let numDownSort = UIAlertAction(title: "No逆順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↓No]")
                self.sortIndex = 1
                self.defaultRightButtons = [self.sortButtons[self.sortIndex]]
                navigationItem.rightBarButtonItems = self.defaultRightButtons
                self.listSortAndReload()
        })
        let hpSort = UIAlertAction(title: "HP順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↓HP]")
                self.sortIndex = 2
                self.defaultRightButtons = [self.sortButtons[self.sortIndex]]
                navigationItem.rightBarButtonItems = self.defaultRightButtons
                self.listSortAndReload()
        })
        let atkSort = UIAlertAction(title: "ATK順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↓ATK]")
                self.sortIndex = 3
                self.defaultRightButtons = [self.sortButtons[self.sortIndex]]
                navigationItem.rightBarButtonItems = self.defaultRightButtons
                self.listSortAndReload()
        })
        let plusSort = UIAlertAction(title: "+換算順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↓+換算]")
                self.sortIndex = 4
                self.defaultRightButtons = [self.sortButtons[self.sortIndex]]
                navigationItem.rightBarButtonItems = self.defaultRightButtons
                self.listSortAndReload()
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {(actin: UIAlertAction!) in
            println("sort[Cancel!]")
        })
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
    
    func searchButtonTapped(sender: UIBarButtonItem) {
        setNavigationItem(true)
    }
    
    func cancelSearchButtonTapped(sender: UIBarButtonItem) {
        setNavigationItem(false)
    }
    
    func setNavigationItem(willSearchMode: Bool) {
        if willSearchMode {
            println("search: \(willSearchMode)")
            isSearchMode = willSearchMode
            if searchBar == nil {
                searchBar = UISearchBar()
                searchBar!.frame.origin = CGPointMake(-150, 22)
                searchBar!.delegate = self
                searchBar!.showsCancelButton = false
                searchBar!.placeholder = "無英斧士ギンジ"
                searchBar!.barTintColor = UIColor.whiteColor()
                searchBar!.tintColor = accentColor
                searchBar!.searchBarStyle = UISearchBarStyle.Default
            } else {
                searchBar!.frame.origin = CGPointMake(-150, 0)
            }
            if cancelSearchButton == nil {
                cancelSearchButton = UIBarButtonItem(title: "戻る", style: .Plain, target: self, action: "cancelSearchButtonTapped:")
            }
            let navigationItem = navigationBar!.items[0] as UINavigationItem
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: nil,
                animations: {() in
                    navigationItem.leftBarButtonItems = nil
                    navigationItem.titleView = self.searchBar!
                    navigationItem.rightBarButtonItem = self.cancelSearchButton!
                }, completion: nil)
            searchBar!.becomeFirstResponder()
            tableView!.reloadData()
        } else {
            println("search: \(willSearchMode)")
            isSearchMode = willSearchMode
            let navigationItem = navigationBar!.items[0] as UINavigationItem
            navigationItem.leftBarButtonItems = defaultLeftButtons
            navigationItem.titleView = nil
            navigationItem.rightBarButtonItems = defaultRightButtons
            tableView!.reloadData()
        }
    }
    
    
    // MARK: - UISearchBarDelegate methods
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func filterContaintsWithSearchText(searchText: String) {
        println("searchText: \(searchText)")
        var predicates = [NSPredicate]()
        predicates.append(NSPredicate(format: "name contains[cd] %@", searchText)!)
        if let no = searchText.toInt() {
            predicates.append(NSPredicate(format: "unit == %d", no)!)
        }
        let predicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: predicates)
        searchResultsList = (listUnits as NSArray).filteredArrayUsingPredicate(predicate) as [UnitsData]
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContaintsWithSearchText(searchText)
        tableView!.reloadData()
    }
    
    /*
    // MARK: - UISearchDisplayDelegate methods
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        if searchString != "" {
            filterContaintsWithSearchText(searchString)
            tableView!.reloadData()
            return true
        } else {
            return false
        }
    }
    */
    
    // MARK: - UnitsConditionMenuDelegate methods
    
    func condMenuWillClose() {
        var insetTop: CGFloat = 0
        let stuBarHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        insetTop += stuBarHeight
        if let navBarHeight = self.navigationController?.navigationBar.frame.size.height {
            insetTop += navBarHeight
        }
        insetTop += navigationBar.bounds.height
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
        
        listSortAndReload()
    }
    
    
    // MARK: - UITableViewDataSource method
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if !isSearchMode {
            // 通常時
            return list.count
        } else {
            // 検索時
            return searchResultsList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("UnitCell") as UnitsCell
        if !isSearchMode {
            // 通常時
            cell.setCell(list[indexPath.row])
        } else {
            // 検索時
            cell.setCell(searchResultsList[indexPath.row])
        }
        return cell
    }
    
    
    // MARK: - UITableViewDelegate method
    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell = tableView.dequeueReusableCellWithIdentifier("UnitCell") as UnitsCell
        var bounds = cell.bounds
        bounds.size.width = tableView.bounds.width
        cell.bounds = bounds
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell.contentView.bounds.height
    }
    */
    
}
