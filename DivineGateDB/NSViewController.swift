
//
//  NSViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData
import CMPopTipView

protocol NSViewControllerDelegate {
    func setUpNSList() -> [NSData]
}

class NSViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, NSConditionMenuDelegate, CMPopTipViewDelegate {
    
    var delegate: NSViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var conditionMenu: NSConditionMenu?
    var sortButtons = [UIBarButtonItem]()
    var defaultLeftButtons = [UIBarButtonItem]()
    var defaultRightButtons = [UIBarButtonItem]()
    var searchBar: UISearchBar?
    var cancelSearchButton: UIBarButtonItem?
    
    var listNS: [NSData] = [NSData]()
    var list: [NSData] = [NSData]()
    var searchResultsList = [NSData]()
    
    var isSearchMode: Bool = false
    var isPlusMode: Bool = false
    var isCRTMode: Bool = true
    var isAveMode: Bool = true
    var sortIndex: Int = 2  // 2: ATK, 3: Panels, 4: CRT, 0,1: Unit
    
    let accentColor = UIColor(red: 0.7, green: 0.1, blue: 0.8, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib = UINib(nibName: "NSCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NSCell")
        tableView.estimatedRowHeight = 60   // xib上の高さ
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
            listNS = del.setUpNSList()
        }
        list = listNS
        changeValueAndListSortAndReload()
        
        // Set up views
        setUpNavigationItems()
        setNavigationItem(false)
        
        // conditionMenu
        conditionMenu = NSConditionMenu(sourceView: self.view)
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
    
    
    
    // MARK: - Set up navigation items
    
    func setUpNavigationItems() {
        let conditionButton = UIBarButtonItem(title: "▼", style: .Done , target: self, action: "toggleConditionMenu:")
        let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchButtonTapped:")
        defaultLeftButtons = [conditionButton, searchButton]
        
        sortButtons.insert(sortButtonMakeInTitle("No順"), atIndex: 0)
        sortButtons.insert(sortButtonMakeInTitle("No逆順"), atIndex: 1)
        sortButtons.insert(sortButtonMakeInTitle("ATK順"), atIndex: 2)
        sortButtons.insert(sortButtonMakeInTitle("パネル数順"), atIndex: 3)
        sortButtons.insert(sortButtonMakeInTitle("CRT順"), atIndex: 4)
        
        // ※３ボタンを下部Viewに移行し、長押し処理を追加 {
        let plusButton = UIBarButtonItem(title: "+99", style: .Done, target: self, action: "changePlus:")
        plusButton.tintColor = isPlusMode ? accentColor : UIColor.grayColor()
        let crtButton = UIBarButtonItem(title: "CRT", style: .Done, target: self, action: "changeCRT:")
        crtButton.tintColor = isCRTMode ? accentColor : UIColor.grayColor()
        let aveButton = UIBarButtonItem(title: "A/P", style: .Done, target: self, action: "changeAve:")
        aveButton.tintColor = isAveMode ? accentColor : UIColor.grayColor()
        
        let plusLongGesture = UILongPressGestureRecognizer(target: self, action: "longPressPlusButton:")
        let crtLongGesture = UILongPressGestureRecognizer(target: self, action: "longPressCRTButton:")
        let aveLongGesture = UILongPressGestureRecognizer(target: self, action: "longPressAveButton:")
        
        // addGestureRecongnizer methods
        // }
        
        defaultRightButtons = [sortButtons[sortIndex], aveButton, crtButton, plusButton]
    }
    
    func longPressPlusButton(sender: UIButton) {
        let plusPop = CMPopTipView(message: "攻撃に＋９９を振った状態の値を計算します")
        plusPop.delegate = self
        plusPop.presentPointingAtView(sender, inView: self.view, animated: true)
    }
    
    func longPressCRTButton(sender: UIButton) {
        let crtPop = CMPopTipView(message: "NSのクリティカル率を考慮して期待値を計算します")
        crtPop.delegate = self
        crtPop.presentPointingAtView(sender, inView: self.view, animated: true)
    }
    
    func longPressAveButton(sender: UIButton) {
        let avePop = CMPopTipView(message: "計算した値をNSのパネル数で割ります")
        avePop.delegate = self
        avePop.presentPointingAtView(sender, inView: self.view, animated: true)
    }
    
    func changeValueAndListSortAndReload() {
        // Cell表示内容の変更
        changeValue()
        // リストソート
        sortAtIndex()
        // TableViewの更新
        tableView!.reloadData()
        println("NSTableView reloaded!!")
    }
    
    func toggleConditionMenu(sender: UIButton) {
        var insetTop: CGFloat = 0
        let stuBarHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        insetTop += stuBarHeight
        if let navBarHeight = self.navigationController?.navigationBar.frame.size.height {
            insetTop += navBarHeight
        }
        if !conditionMenu!.isMenuOpen { // show
            insetTop += self.conditionMenu!.menuHeight
            conditionMenu!.toggleMenu(true)
        } else {                        // hide
            insetTop += navigationBar.bounds.height
            conditionMenu!.toggleMenu(false)
        }
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut,
            animations: {() in
                self.tableView.contentInset.top = insetTop
                self.tableView.scrollIndicatorInsets.top = insetTop
            }, completion: nil)
    }
    
    func changeValue() {
        for ns in list {
            ns.value = Double(isPlusMode ? ns.attack+99*5*ns.leverage : ns.attack) * Double(isCRTMode ? 1+ns.critical()/2 : 1) / Double(isAveMode ? ns.panels() : 1)
        }
    }
    
    func changePlus(sender: UIButton) {
        isPlusMode = isPlusMode ? false : true
        println("isPlusMode: \(isPlusMode)")
        println("Plus: \(isPlusMode), CRT: \(isCRTMode), Ave: \(isAveMode)")
        sender.tintColor = isPlusMode == true ? accentColor : UIColor.grayColor()
        changeValueAndListSortAndReload()
    }
    
    func changeCRT(sender: UIButton) {
        isCRTMode = isCRTMode ? false : true
        println("isCRTMode: \(isCRTMode)")
        println("Plus: \(isPlusMode), CRT: \(isCRTMode), Ave: \(isAveMode)")
        sender.tintColor = isCRTMode == true ? accentColor : UIColor.grayColor()
        changeValueAndListSortAndReload()
    }
    
    func changeAve(sender: UIButton) {
        isAveMode = isAveMode ? false : true
        println("isAveMode: \(isAveMode)")
        println("Plus: \(isPlusMode), CRT: \(isCRTMode), Ave: \(isAveMode)")
        sender.tintColor = isAveMode == true ? accentColor : UIColor.grayColor()
        changeValueAndListSortAndReload()
    }
    
    func sortAtIndex() {
        switch  sortIndex {
        case    0:
            sortInUnit()
        case    1:
            sortInUnitDown()
        case    2:
            sortInValue()
        case    3:
            sortInPanels()
        case    4:
            sortInCRT()
        default:
            break
        }
    }
    
    func sortInUnit() {
        list.sort { (h: NSData, b: NSData) in
            h.unit != b.unit ? h.unit < b.unit
                : h.number < b.number
        }
    }
    
    func sortInUnitDown() {
        list.sort { (h: NSData, b: NSData) in
            h.unit != b.unit ? h.unit > b.unit
                : h.number < b.number
        }
    }
    
    func sortInValue() {
        list.sort { (h: NSData, b: NSData) in
            h.value != b.value ? h.value > b.value
                : h.panels() != b.panels() ? h.panels() < b.panels()
                : h.unit != b.unit ? h.unit < b.unit
                : h.number < b.number
        }
    }
    
    func sortInPanels() {
        list.sort { (h: NSData, b: NSData) in
            h.panels() != b.panels() ? h.panels() < b.panels()
                : h.value != b.value ? h.value > b.value
                : h.unit != b.unit ? h.unit < b.unit
                : h.number < b.number
        }
    }
    
    func sortInCRT() {
        list.sort { (h: NSData, b: NSData) in
            h.critical() != b.critical() ? h.critical() > b.critical()
                : h.value != b.value ? h.value > b.value
                : h.panels() != b.panels() ? h.panels() < b.panels()
                : h.unit != b.unit ? h.unit < b.unit
                : h.number < b.number
        }
    }
    
    func sortNS(sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: "並べ替え条件を選択", preferredStyle: .ActionSheet)
        let navItem = navigationBar!.items[0] as UINavigationItem
        let NoSort = UIAlertAction(title: "No順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[No↑]")
                self.sortIndex = 0
                self.defaultRightButtons[0] = self.sortButtons[self.sortIndex]
                navItem.rightBarButtonItems = self.defaultRightButtons
                self.changeValueAndListSortAndReload()
        })
        let NoDownSort = UIAlertAction(title: "No逆順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[No↓]")
                self.sortIndex = 1
                self.defaultRightButtons[0] = self.sortButtons[self.sortIndex]
                navItem.rightBarButtonItems = self.defaultRightButtons
                self.changeValueAndListSortAndReload()
        })
        let ATKSort = UIAlertAction(title: "攻撃力期待値順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[ATK↓]")
                self.sortIndex = 2
                self.defaultRightButtons[0] = self.sortButtons[self.sortIndex]
                navItem.rightBarButtonItems = self.defaultRightButtons
                self.changeValueAndListSortAndReload()
        })
        /*
        let PanelSort = UIAlertAction(title: "パネル数順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[Panels↑]")
                self.sortIndex = 3
                self.defaultRightButtons[0] = self.sortButtons[self.sortIndex]
                navItem.rightBarButtonItems = self.defaultRightButtons
                self.changeValueAndListSortAndReload()
        })
        */
        let CRTSort = UIAlertAction(title: "クリティカル率順", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[CRT↓]")
                self.sortIndex = 4
                self.defaultRightButtons[0] = self.sortButtons[self.sortIndex]
                navItem.rightBarButtonItems = self.defaultRightButtons
                self.changeValueAndListSortAndReload()
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {(actin: UIAlertAction!) in
            println("sort[Cancel!]")
        })
        actionSheet.addAction(NoSort)
        actionSheet.addAction(NoDownSort)
        actionSheet.addAction(ATKSort)
//        actionSheet.addAction(PanelSort)
        actionSheet.addAction(CRTSort)
        actionSheet.addAction(cancel)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }

    func sortButtonMakeInTitle(title: String) -> UIBarButtonItem {
        let sb = UIBarButtonItem(title: title, style: .Plain, target: self, action: "sortNS:")
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
                searchBar!.placeholder = "インフィニティ・リバース"
                searchBar!.barTintColor = UIColor.whiteColor()
                searchBar!.tintColor = accentColor
                searchBar!.searchBarStyle = UISearchBarStyle.Default
            } else {
                searchBar!.frame.origin = CGPointMake(-150, 0)
            }
            if cancelSearchButton == nil {
                cancelSearchButton = UIBarButtonItem(title: "戻る", style: .Plain, target: self, action: "cancelSearchButtonTapped:")
            }
            
            let navItem = navigationBar!.items[0] as UINavigationItem
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: nil,
                animations: {
                    navItem.leftBarButtonItems = nil
                    navItem.titleView = self.searchBar!
                    navItem.rightBarButtonItems = [self.cancelSearchButton!]
                }, completion: nil)
            searchBar!.becomeFirstResponder()
            tableView!.reloadData()
        } else {
            println("search: \(willSearchMode)")
            isSearchMode = willSearchMode
            let navItem = navigationBar!.items[0] as UINavigationItem
            navItem.leftBarButtonItems = defaultLeftButtons
            navItem.titleView = nil
            navItem.rightBarButtonItems = defaultRightButtons
            tableView!.reloadData()
        }
    }
    
    // MARK: - UISearchBar Delegate methods
    
    // 検索ボタンを押した時
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func filterContaintsWithSearchText(searchText: String) {
        println("searchText: \(searchText)")
        var predicates = [NSPredicate]()
        predicates.append(NSPredicate(format: "unitsName contains[cd] %@", searchText)!)
        predicates.append(NSPredicate(format: "name contains[cd] %@", searchText)!)
        let predicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: predicates)
        searchResultsList = (listNS as NSArray).filteredArrayUsingPredicate(predicate) as [NSData]
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContaintsWithSearchText(searchText)
        tableView!.reloadData()
    }
    
    
    // MARK: - NSConditionMenuDelegate methods
    
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
            } , completion: nil)
    }

    // 絞込処理
    func listConditioning(#condIndex: [Bool], countIndex: [Bool], panelIndex: [Int], typeIndex: Int) {
        
        var predicates = [NSPredicate]()
        
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
        
        // 対象条件
        var typePre: NSPredicate?
        if typeIndex != 0 {
            switch typeIndex {
            case    0:  // ALL
                break
            case    1:  // ATK
                typePre = NSPredicate(format: "target == %d OR target == %d", 1, 2)
            case    2:  // ATK:単体
                typePre = NSPredicate(format: "target == %d", 1)
            case    3:  // ATK:全体
                typePre = NSPredicate(format: "target == %d", 2)
            case    4:  // HEAL
                typePre = NSPredicate(format: "target == %d", 0)
            default :
                break
            }
        }
        if typePre != nil {
            predicates.append(typePre!)
        }
        
        if predicates != [] {
            let predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: predicates)
            println(predicate)
            list = (listNS as NSArray).filteredArrayUsingPredicate(predicate) as [NSData]
        } else {
            list = listNS
        }
        
        // パネル数条件
        if countIndex != [false, false, false, false, false] {
            var li = [NSData]()
            for ns in list {
                if countIndex[ns.panels() - 1] {
                    li.append(ns)
                }
            }
            list = li
        }
        
        // パネル条件
        if panelIndex != [0, 0, 0, 0, 0] {
            var li = [NSData]()
            var cond = [0, 0, 0, 0, 0, 0, 0, 0]
            for p in panelIndex {
                cond[p]++
            }
            for ns in list {
                var bool: Bool = true
                for i in 1..<cond.count {   // 1..<8    0=empty
                    if ns.condition()[i] < cond[i] {
                        bool = false
                    }
                }
                if bool {
                    li.append(ns)
                }
            }
            list = li
        }
        
        changeValueAndListSortAndReload()
    }
    
    
    // MARK: - CMPopTipViewDelegate methods
    
    func popTipViewWasDismissedByUser(popTipView: CMPopTipView!) {
        
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isSearchMode {
            // 通常時
            return list.count
        } else {
            // 検索時
            return searchResultsList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("NSCell") as NSCell
        let ns = !isSearchMode ? list[indexPath.row] : searchResultsList[indexPath.row]
        !isPlusMode ?
            !isCRTMode ?
                !isAveMode ?
                    cell.setCell(ns)
                    : cell.setOneCell(ns)
                : !isAveMode ?
                    cell.setStatisticsCell(ns)
                    : cell.setOneStatisticsCell(ns)
            : !isCRTMode ?
                !isAveMode ?
                    cell.setPlusCell(ns)
                    : cell.setOnePlusCell(ns)
                : !isAveMode ?
                    cell.setStatisticsPlusCell(ns)
                    : cell.setOneStatisticsPlusCell(ns)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate method
    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell = tableView.dequeueReusableCellWithIdentifier("NSCell") as NSCell
        var bounds = cell.bounds
        bounds.size.width = tableView.bounds.width
        cell.bounds = bounds
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell.contentView.bounds.height
    }
    */
    
}
