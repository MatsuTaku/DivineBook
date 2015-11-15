
//
//  NSViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData
//import CMPopTipView
//import SVProgressHUD
import MBProgressHUD

class NSViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, NSConditionMenuDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var passiveButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var crtButton: UIButton!
    @IBOutlet weak var aveButton: UIButton!
    
    var conditionMenu: NSConditionMenu?
    var sortButtons = [UIBarButtonItem]()
    var defaultLeftButtons = [UIBarButtonItem]()
    var defaultRightButtons = [UIBarButtonItem]()
    var searchBar: UISearchBar?
    var cancelSearchButton: UIBarButtonItem?
    
    var nsTable: NSTable?
    var currentArray = [NS]()
    var filteredArray = [NS]()
    
    var isPassiveMode: Bool = false
    var isSearchMode: Bool = false
    var isPlusMode: Bool = false
    var isCRTMode: Bool = true
    var isAveMode: Bool = true
    var sortIndex: Int = 0  // 2: ATK, 3: Panels, 4: CRT, 0,1: Unit
    
    var changedValueInSearch: Bool = false
    
    var isLoading: Bool = false
    
    let accentColor = UIColor(red: 0.7, green: 0.1, blue: 0.8, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Set up views
        setUpTableView()
        setUpNavigationItems()
        switchSearchMode(false)
        
        // conditionMenu
        conditionMenu = NSConditionMenu(sourceView: self.view)
        conditionMenu!.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if nsTable == nil {
            if !isLoading {
                isLoading = true
//                SVProgressHUD.showWithStatus("少しだけ待ってぼん", maskType: .Clear)
                let showHud: MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                showHud.dimBackground = true
                showHud.labelText = "少しだけ待ってぼん"
                dispatch_async_global {
                    self.nsTable = NSTable()
                    self.dispatch_async_main {
                        if self.nsTable != nil {
//                            SVProgressHUD.dismiss()
                            self.currentArray = self.nsTable!.rows
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
    
    
    
    // MARK: - Set up navigation items
    
    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib = UINib(nibName: "NSCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NSCell")
        tableView.estimatedRowHeight = 60   // xib上の高さ
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.bounds = self.view.bounds
        tableView.layoutMargins = UIEdgeInsetsZero
        
        var inset = tableView.contentInset
        let stuBarHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        inset.top += stuBarHeight
        if let navBarHeight = self.navigationController?.navigationBar.frame.size.height {
            inset.top += navBarHeight
        }
        inset.top += navigationBar.bounds.height
        if let insetBottom: CGFloat = self.tabBarController?.tabBar.frame.height {
            inset.bottom += insetBottom
        }
        tableView.scrollIndicatorInsets = inset
        inset.bottom += passiveButton.bounds.height + 3
        tableView.contentInset = inset
    }
    
    func setUpNavigationItems() {
        let conditionButton = UIBarButtonItem(title: "▼", style: .Done , target: self, action: "toggleConditionMenu:")
        let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "searchButtonTapped:")
        defaultLeftButtons = [conditionButton, searchButton]
        
        sortButtons.insert(sortButtonMakeInTitle("No順"), atIndex: 0)
        sortButtons.insert(sortButtonMakeInTitle("No逆順"), atIndex: 1)
        sortButtons.insert(sortButtonMakeInTitle("数値順"), atIndex: 2)
        sortButtons.insert(sortButtonMakeInTitle("パネル数順"), atIndex: 3)
        sortButtons.insert(sortButtonMakeInTitle("CRT順"), atIndex: 4)
        
        // ※３ボタンを下部Viewに移行し、長押し処理を追加 {
        /*
        let plusButton = UIBarButtonItem(title: "+99", style: .Done, target: self, action: "changePlus:")
        plusButton.tintColor = isPlusMode ? accentColor : UIColor.grayColor()
        let crtButton = UIBarButtonItem(title: "CRT", style: .Done, target: self, action: "changeCRT:")
        crtButton.tintColor = isCRTMode ? accentColor : UIColor.grayColor()
        let aveButton = UIBarButtonItem(title: "A/P", style: .Done, target: self, action: "changeAve:")
        aveButton.tintColor = isAveMode ? accentColor : UIColor.grayColor()
        
        let plusLongGesture = UILongPressGestureRecognizer(target: self, action: "longPressPlusButton:")
        let crtLongGesture = UILongPressGestureRecognizer(target: self, action: "longPressCRTButton:")
        let aveLongGesture = UILongPressGestureRecognizer(target: self, action: "longPressAveButton:")
        */
        
        // addGestureRecongnizer methods
        // }
        
//        defaultRightButtons = [sortButtons[sortIndex], aveButton, crtButton, plusButton]
        defaultRightButtons = [sortButtons[sortIndex]]
        
        passiveButton.selected = isPassiveMode
        plusButton.selected = isPlusMode
        crtButton.selected = isCRTMode
        aveButton.selected = isAveMode
    }
    
    /*
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
    */
    
    func reloadList() {
        if !isLoading {
            isLoading = true
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        dispatch_async_global {
            // Cell表示内容の変更
            self.changeValue()
            // リストソート
            self.sortAtIndex()
            self.dispatch_async_main {
                self.isLoading = false
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                // TableViewの更新
                self.tableView!.reloadData()
                print("NSTableView reloaded!!")
                let navigationItem: UINavigationItem = self.navigationBar!.items!.first!
                navigationItem.title = NSString(format: "%dskills", self.currentArray.count) as String
            }
        }
    }
    
    func toggleConditionMenu(button: UIBarButtonItem) {
        conditionMenu!.toggleMenu()
    }
    
    @IBAction func changePassive(sender: UIButton) {
        isPassiveMode = !isPassiveMode
        passiveButton.selected = isPassiveMode
    }
    
    func changeValue() {
        var array = [NS]()
        if !isSearchMode {
            array = currentArray
        } else {
            changedValueInSearch = true
            array = filteredArray
        }
        for ns in array {
            // change value method
            ns.changeValue(plusIs: isPlusMode, crtIs: isCRTMode, averageIs: isAveMode)
        }
    }
    
    @IBAction func changePlus(sender: UIButton) {
        isPlusMode = !isPlusMode
        sender.selected = isPlusMode
        reloadList()
        print("isPlusMode: \(isPlusMode)")
        print("Plus: \(isPlusMode), CRT: \(isCRTMode), Ave: \(isAveMode)")
        sender.tintColor = isPlusMode == true ? accentColor : UIColor.grayColor()
    }
    
    @IBAction func changeCRT(sender: UIButton) {
        isCRTMode = !isCRTMode
        sender.selected = isCRTMode
        reloadList()
        print("isCRTMode: \(isCRTMode)")
        print("Plus: \(isPlusMode), CRT: \(isCRTMode), Ave: \(isAveMode)")
        sender.tintColor = isCRTMode == true ? accentColor : UIColor.grayColor()
    }
    
    @IBAction func changeAve(sender: UIButton) {
        isAveMode = !isAveMode
        sender.selected = isAveMode
        reloadList()
        print("isAveMode: \(isAveMode)")
        print("Plus: \(isPlusMode), CRT: \(isCRTMode), Ave: \(isAveMode)")
        sender.tintColor = isAveMode == true ? accentColor : UIColor.grayColor()
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
        currentArray.sortInPlace {(h: NS, b: NS) in
            h.No != b.No ? h.No < b.No
                : h.number < b.number
        }
    }
    
    func sortInUnitDown() {
        currentArray.sortInPlace {(h: NS, b: NS) in
            h.No != b.No ? h.No > b.No
                : h.number < b.number
        }
    }
    
    func sortInValue() {
        currentArray.sortInPlace { (h: NS, b: NS) in
            h.value != b.value ? h.value > b.value
                : h.panels != b.panels ? h.panels < b.panels
                : h.No != b.No ? h.No > b.No
                : h.number < b.number
        }
    }
    
    func sortInPanels() {
        currentArray.sortInPlace {(h: NS, b: NS) in
            h.panels != b.panels ? h.panels < b.panels
                : h.value != b.value ? h.value > b.value
                : h.No != b.No ? h.No > b.No
                : h.number < b.number
        }
    }
    
    func sortInCRT() {
        currentArray.sortInPlace {(h: NS, b: NS) in
            h.critical != b.critical ? h.critical > b.critical
                : h.No != b.No ? h.No > b.No
                : h.number < b.number
        }
    }
    
    func reloadListInSortAt(sortIndex: Int) {
        self.sortIndex = sortIndex
        reloadList()
    }
    
    func sortNS(sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: "並べ替え条件を選択", preferredStyle: .ActionSheet)
        let navItem: UINavigationItem = navigationBar!.items!.first!
        let NoSort = UIAlertAction(title: "No順", style: .Default,
            handler: {(action: UIAlertAction) in
                print("sort[No↑]")
                self.reloadListInSortAt(0)
                self.defaultRightButtons[0] = self.sortButtons[self.sortIndex]
                navItem.rightBarButtonItems = self.defaultRightButtons
        })
        let NoDownSort = UIAlertAction(title: "No逆順", style: .Default,
            handler: {(action: UIAlertAction) in
                print("sort[No↓]")
                self.reloadListInSortAt(1)
                self.defaultRightButtons[0] = self.sortButtons[self.sortIndex]
                navItem.rightBarButtonItems = self.defaultRightButtons
        })
        let ATKSort = UIAlertAction(title: "数値順", style: .Default,
            handler: {(action: UIAlertAction) in
                print("sort[ATK↓]")
                self.reloadListInSortAt(2)
                self.defaultRightButtons[0] = self.sortButtons[self.sortIndex]
                navItem.rightBarButtonItems = self.defaultRightButtons
        })
        let PanelSort = UIAlertAction(title: "パネル数順", style: .Default,
            handler: {(action: UIAlertAction) in
                print("sort[Panels↑]")
                self.reloadListInSortAt(3)
                self.defaultRightButtons[0] = self.sortButtons[self.sortIndex]
                navItem.rightBarButtonItems = self.defaultRightButtons
        })
        let CRTSort = UIAlertAction(title: "クリティカル率順", style: .Default,
            handler: {(action: UIAlertAction) in
                print("sort[CRT↓]")
                self.reloadListInSortAt(4)
                self.defaultRightButtons[0] = self.sortButtons[self.sortIndex]
                navItem.rightBarButtonItems = self.defaultRightButtons
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {(actin: UIAlertAction) in
            print("sort[Cancel!]")
        })
        actionSheet.addAction(NoSort)
        actionSheet.addAction(NoDownSort)
        actionSheet.addAction(ATKSort)
        actionSheet.addAction(PanelSort)
        actionSheet.addAction(CRTSort)
        actionSheet.addAction(cancel)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func sortButtonMakeInTitle(title: String) -> UIBarButtonItem {
        let sb = UIBarButtonItem(title: title, style: .Plain, target: self, action: "sortNS:")
        return sb
    }
    
    func searchButtonTapped(sender: UIBarButtonItem) {
        switchSearchMode(true)
    }
    
    func cancelSearchButtonTapped(sender: UIBarButtonItem) {
        switchSearchMode(false)
    }

    func switchSearchMode(willSearchMode: Bool) {
        if willSearchMode {
            print("search: \(willSearchMode)")
            isSearchMode = willSearchMode
            tableView!.reloadData()
            if searchBar == nil {
                searchBar = UISearchBar()
                searchBar!.frame.origin = CGPointMake(-150, 22)
                searchBar!.delegate = self
                searchBar!.showsCancelButton = false
                searchBar!.placeholder = "例：インフィニティ、ギンジ、899"
                searchBar!.barTintColor = UIColor.whiteColor()
                searchBar!.tintColor = accentColor
                searchBar!.searchBarStyle = UISearchBarStyle.Default
            } else {
                searchBar!.frame.origin = CGPointMake(-150, 0)
            }
            if cancelSearchButton == nil {
                cancelSearchButton = UIBarButtonItem(title: "戻る", style: .Plain, target: self, action: "cancelSearchButtonTapped:")
            }
            
            let navItem: UINavigationItem = navigationBar!.items!.first!
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: [],
                animations: {
                    navItem.leftBarButtonItems = nil
                    navItem.titleView = self.searchBar!
                    navItem.rightBarButtonItems = [self.cancelSearchButton!]
                }, completion: nil)
            searchBar!.becomeFirstResponder()
        } else {
            print("search: \(willSearchMode)")
            isSearchMode = willSearchMode
            if changedValueInSearch {
                changedValueInSearch = false
                reloadList()
            } else {
                tableView.reloadData()
            }
            let navItem: UINavigationItem = navigationBar!.items!.first!
            navItem.leftBarButtonItems = self.defaultLeftButtons
            navItem.titleView = nil
            navItem.rightBarButtonItems = self.defaultRightButtons
            navItem.title = NSString(format: "%dskills", self.currentArray.count) as String
        }
    }
    
    // MARK: - UISearchBar Delegate methods
    
    // 検索ボタンを押した時
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func filterContaintsWithSearchText(searchText: String) {
        print("searchText: \(searchText)")
        var predicates = [NSPredicate]()
        predicates.append(NSPredicate(format: "unitsName contains[cd] %@", searchText))
        predicates.append(NSPredicate(format: "name contains[cd] %@", searchText))
        if let num = Int(searchText) {
            predicates.append(NSPredicate(format: "showNo == %d", num))
        }
        let predicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: predicates)
        filteredArray = (nsTable!.rows as NSArray).filteredArrayUsingPredicate(predicate) as! [NS]
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContaintsWithSearchText(searchText)
        tableView!.reloadData()
    }
    
    
    // MARK: - NSConditionMenuDelegate methods
    
    func condMenuWillClose() {
        /*
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
        */
    }
    
    // 絞込処理
    func listConditioning(condIndex condIndex: [Bool], countIndex: [Bool], panelIndex: [Int], typeIndex: Int) {
        isLoading = true
        let showHud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        showHud.labelText = "検索中だぼん"
        dispatch_async_global {
            var predicates = [NSPredicate]()
            
            // 属性条件
            if condIndex != [false, false, false, false, false, false] {
                var energyArray = [NSPredicate]()
                for i in 0..<condIndex.count {
                    if condIndex[i] == true {
                        energyArray.append(NSPredicate(format: "element == %d", i + 1))
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
                print(predicate)
                //            list = (listNS as NSArray).filteredArrayUsingPredicate(predicate) as [NSData]
                self.currentArray = (self.nsTable!.rows as NSArray).filteredArrayUsingPredicate(predicate) as! [NS]
            } else {
                //            list = listNS
                self.currentArray = self.nsTable!.rows
            }
            
            // パネル数条件
            if countIndex != [false, false, false, false, false] {
                //            var li = [NSData]()
                var list = [NS]()
                for ns in self.currentArray {
                    if countIndex[ns.panels - 1] {
                        list.append(ns)
                    }
                }
                self.currentArray = list
            }
            
            // パネル条件
            if panelIndex != [0, 0, 0, 0, 0] {
                var list = [NS]()
                var cond = [0, 0, 0, 0, 0, 0, 0, 0]
                for p in panelIndex {
                    cond[p]++
                }
                for ns in self.currentArray {
                    var isMatch: Bool = true
                    for i in 1..<cond.count {   // 1..<8    0=empty
                        if ns.condition()[i] < cond[i] {
                            isMatch = false
                        }
                    }
                    if isMatch {
                        list.append(ns)
                    }
                }
                self.currentArray = list
            }
            
            self.dispatch_async_main {
                self.reloadList()
            }
        }
    }
    
    /*
    // MARK: - CMPopTipViewDelegate methods
    
    func popTipViewWasDismissedByUser(popTipView: CMPopTipView!) {
        
    }
    */
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isSearchMode {
            // 通常時
            return currentArray.count
        } else {
            // 検索時
            return filteredArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NSCell") as! NSCell
        let ns = !isSearchMode ? currentArray[indexPath.row] : filteredArray[indexPath.row]
        cell.setCell(ns, plusIs: isPlusMode, crtIs: isCRTMode, averageIs: isAveMode)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate method
    
}
