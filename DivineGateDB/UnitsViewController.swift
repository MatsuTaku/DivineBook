//
//  UnitsViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD
import MBProgressHUD

class UnitsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UnitsConditionMenuDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var conditionMenu: UnitsConditionMenu?
    var sortButtons = [UIBarButtonItem]()
    var defaultLeftButtons = [UIBarButtonItem]()
    var defaultRightButtons = [UIBarButtonItem]()
    var searchBar: UISearchBar?
    var cancelSearchButton: UIBarButtonItem?
    
    var unitsTable: UnitsTable?
    var currentArray = [Unit]()
    var filteredArray = [Unit]()
    
    var isSearchMode: Bool = false
    var sortIndex: Int = 0 // 0: ↑num, 1: ↓num, 2: hp, 3: atk, 4: plus, 5: all
    
    var isLoading: Bool = false
    
    let accentColor = UIColor(red: 0.7, green: 0.1, blue: 0.8, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        // Set up views
        setUpTableView()
        setUpNavigationItems()
        switchSearchMode(false)
        
        conditionMenu = UnitsConditionMenu(sourceView: self.view)
        conditionMenu!.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if unitsTable == nil {
            if !isLoading {
                isLoading = true
//                SVProgressHUD.showWithMaskType(.Clear)
                let showHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                showHUD.dimBackground = true
                dispatch_async_global {
                    self.unitsTable = UnitsTable()
                    self.dispatch_async_main {
                        if self.unitsTable != nil {
//                            SVProgressHUD.dismiss()
                            self.currentArray = self.unitsTable!.rows
                            self.reloadList()
                        } else {
                            self.isLoading = false
//                            SVProgressHUD.showErrorWithStatus("ERROR!")
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if conditionMenu!.isMenuOpen {
            condMenuWillClose()
            conditionMenu!.toggleMenu(false)
//            SVProgressHUD.popActivity()
        }
        if isSearchMode {
            switchSearchMode(false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
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
    
    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        var nib = UINib(nibName: "UnitsCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "UnitCell")
        tableView.estimatedRowHeight = 55.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.bounds = self.view.bounds
        
        var inset = tableView.contentInset
        let stuBarHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        inset.top += stuBarHeight
        if let navBarHeight = self.navigationController?.navigationBar.frame.size.height {
            inset.top += navBarHeight
        }
        inset.top += navigationBar.bounds.height
        if let insetBottom: CGFloat = self.tabBarController?.tabBar.frame.height {
            inset.bottom = insetBottom
        }
        tableView.contentInset = inset
        tableView.scrollIndicatorInsets = inset
    }
    
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
        sortButtons.insert(sortButtonMakeInTitle("HP+ATK順"), atIndex: 5)
        defaultRightButtons = [sortButtons[sortIndex]]
    }
    
    func sortButtonMakeInTitle(title: String) -> UIBarButtonItem {
        let sb = UIBarButtonItem(title: title, style: .Bordered, target: self, action: "sortUnits:")
        return sb
    }
    
    func reloadList() {
        if !isLoading {
            isLoading = true
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        dispatch_async_global {
            self.sortAtIndex()
            self.dispatch_async_main {
                self.isLoading = false
                self.tableView.reloadData()
                println("UnitsTableView reloaded!")
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            }
        }
    }
    
    func toggleConditionMenu(button: UIBarButtonItem) {
        conditionMenu!.toggleMenu()
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
            sortInStatus()
        case    5:
            sortInSum()
        default :
            break
        }
    }
    
    func sortInNumUp() {
        currentArray.sort { (h: Unit, b: Unit) in
            h.No < b.No
        }
    }
    
    func sortInNumDown() {
        currentArray.sort { (h: Unit, b: Unit) in
            h.No > b.No
        }
    }
    
    func sortInHp() {
        currentArray.sort {(h: Unit, b: Unit) in
            h.hp > b.hp
        }
    }
    
    func sortInAtk() {
        currentArray.sort {(h: Unit, b: Unit) in
            h.atk > b.atk
        }
    }
    
    func sortInStatus() {
        currentArray.sort {(h: Unit, b: Unit) in
            h.status() > b.status()
        }
    }
    
    func sortInSum() {
        currentArray.sort {(h: Unit, b: Unit) in
            h.sum() > b.sum()
        }
    }
    
    func reloadListInSortAt(sortIndex: Int) {
        self.sortIndex = sortIndex
        reloadList()
    }
    
    func sortUnits(sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: "並べ替え条件を選択", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let navigationItem = navigationBar!.items[0] as UINavigationItem
        let numUpSort = UIAlertAction(title: "No順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↑No]")
                self.reloadListInSortAt(0)
                self.defaultRightButtons = [self.sortButtons[self.sortIndex]]
                navigationItem.rightBarButtonItems = self.defaultRightButtons
        })
        let numDownSort = UIAlertAction(title: "No逆順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↓No]")
                self.reloadListInSortAt(1)
                self.defaultRightButtons = [self.sortButtons[self.sortIndex]]
                navigationItem.rightBarButtonItems = self.defaultRightButtons
        })
        let hpSort = UIAlertAction(title: "HP順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↓HP]")
                self.reloadListInSortAt(2)
                self.defaultRightButtons = [self.sortButtons[self.sortIndex]]
                navigationItem.rightBarButtonItems = self.defaultRightButtons
        })
        let atkSort = UIAlertAction(title: "ATK順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↓ATK]")
                self.reloadListInSortAt(3)
                self.defaultRightButtons = [self.sortButtons[self.sortIndex]]
                navigationItem.rightBarButtonItems = self.defaultRightButtons
        })
        let plusSort = UIAlertAction(title: "+換算順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[↓+換算]")
                self.reloadListInSortAt(4)
                self.defaultRightButtons = [self.sortButtons[self.sortIndex]]
                navigationItem.rightBarButtonItems = self.defaultRightButtons
        })
        let sumSort = UIAlertAction(title: "HP+ATK順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[HP+ATK順]")
                self.reloadListInSortAt(5)
                self.defaultRightButtons = [self.sortButtons[self.sortIndex]]
                navigationItem.rightBarButtonItems = self.defaultRightButtons
            })
        let cancel = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {(actin: UIAlertAction!) in
            println("sort[Cancel!]")
        })
        actionSheet.addAction(numUpSort)
        actionSheet.addAction(numDownSort)
        actionSheet.addAction(hpSort)
        actionSheet.addAction(atkSort)
        actionSheet.addAction(plusSort)
        actionSheet.addAction(sumSort)
        actionSheet.addAction(cancel)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func searchButtonTapped(sender: UIBarButtonItem) {
        switchSearchMode(true)
    }
    
    func cancelSearchButtonTapped(sender: UIBarButtonItem) {
        switchSearchMode(false)
    }
    
    func switchSearchMode(willSearchMode: Bool) {
        if willSearchMode {
            println("search: \(willSearchMode)")
            isSearchMode = willSearchMode
            if searchBar == nil {
                searchBar = UISearchBar()
                searchBar!.frame.origin = CGPointMake(-150, 22)
                searchBar!.delegate = self
                searchBar!.showsCancelButton = false
                searchBar!.placeholder = "例：無英斧士ギンジ、899"
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
            navigationItem.leftBarButtonItems = self.defaultLeftButtons
            navigationItem.titleView = nil
            navigationItem.rightBarButtonItems = self.defaultRightButtons
            self.tableView!.reloadData()
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
        if let num = searchText.toInt() {
            predicates.append(NSPredicate(format: "showNo == %d", num)!)
        }
        let predicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: predicates)
        filteredArray = (unitsTable!.rows as NSArray).filteredArrayUsingPredicate(predicate) as [Unit]
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContaintsWithSearchText(searchText)
        tableView!.reloadData()
    }
    
    // MARK: - UnitsConditionMenuDelegate methods
    
    func condMenuWillClose() {
    }
    
    func listConditioning(#condIndex: [Bool], raceIndex: [Bool]) {
        isLoading = true
        let showHud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        showHud.labelText = "検索中だぼん"
        dispatch_async_global {
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
                //            list = (listUnits as NSArray).filteredArrayUsingPredicate(predicate) as [UnitsData]
                self.currentArray = (self.unitsTable!.rows as NSArray).filteredArrayUsingPredicate(predicate) as [Unit]
            } else {
                //            list = listUnits
                self.currentArray = self.unitsTable!.rows
            }
            
            self.dispatch_async_main {
                self.reloadList()
            }
        }
        
    }
    
    
    // MARK: - UITableViewDataSource method
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if !isSearchMode {
            // 通常時
            return currentArray.count
        } else {
            // 検索時
            return filteredArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("UnitCell") as UnitsCell
        if !isSearchMode {
            // 通常時
            cell.setCell(currentArray[indexPath.row])
        } else {
            // 検索時
            cell.setCell(filteredArray[indexPath.row])
        }
        return cell
    }
    
    
    // MARK: - UITableViewDelegate method
    
}
