
//
//  NSViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData

protocol NSViewControllerDelegate {
    func setUpNSList() -> [NSData]
}

class NSViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, NSConditionMenuDelegate {
    
    var delegate: NSViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var conditionMenu: NSConditionMenu?
    
    var listNS: [NSData] = [NSData]()
    var list: [NSData] = [NSData]()
    
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
        tableView.estimatedRowHeight = 60   // xib上の高さ
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib = UINib(nibName: "NSCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NSCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.bounds = self.view.bounds
        let stuBarHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        let navBarHeight: CGFloat? = self.navigationController?.navigationBar.frame.size.height
        tableView.contentInset.top = stuBarHeight + navBarHeight! + navigationBar!.frame.height
        tableView.scrollIndicatorInsets.top = stuBarHeight + navBarHeight! + navigationBar!.frame.height
        
        if let del = delegate {
            listNS = del.setUpNSList()
        }
        list = listNS
        reloadList()
        
        // Set up views
        setUpnavItems()
        
        // conditionMenu
        conditionMenu = NSConditionMenu(sourceView: self.view)
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
    
    
    
    // MARK: - Set up navigation items
    
    func setUpnavItems() {
        var conditionButton = UIBarButtonItem(title: "▼", style: .Done , target: self, action: "toggleConditionMenu:")
        var searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "changeSearchMode:")
        var sortButton = UIBarButtonItem()
        switch sortIndex {
        case    0:
            sortButton = sortButtonMakeInTitle("No↑")
        case    1:
            sortButton = sortButtonMakeInTitle("No↓")
        case    2:
            sortButton = sortButtonMakeInTitle("ATK↓")
        case    3:
            sortButton = sortButtonMakeInTitle("パネル数↑")
        case    4:
            sortButton = sortButtonMakeInTitle("CRT↑")
        default :
            break
        }
        var plusButton = UIBarButtonItem(title: "+99", style: .Done, target: self, action: "changePlus:")
        plusButton.tintColor = isPlusMode == true ? accentColor : UIColor.grayColor()
        var crtButton = UIBarButtonItem(title: "CRT", style: .Done, target: self, action: "changeCRT:")
        crtButton.tintColor = isCRTMode == true ? accentColor : UIColor.grayColor()
        var aveButton = UIBarButtonItem(title: "A/P", style: .Done, target: self, action: "changeAve:")
        aveButton.tintColor = isAveMode == true ? accentColor : UIColor.grayColor()
        
        let leftButtons = [conditionButton, searchButton]
        let rightButtons = [sortButton, aveButton, crtButton, plusButton]
        
        let navItem = navigationBar!.items[0] as UINavigationItem
        
        navItem.leftBarButtonItems = leftButtons
        navItem.titleView = nil
        navItem.rightBarButtonItems = rightButtons
    }
    
    func toggleConditionMenu(sender: UIButton) {
        let stuBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let navBarHeight: CGFloat? = self.navigationController?.navigationBar.frame.size.height
        var insetTop: CGFloat?
        if !conditionMenu!.isMenuOpen { // show
            insetTop = stuBarHeight + navBarHeight! + self.conditionMenu!.menuHeight
            conditionMenu!.toggleMenu(true)
        } else {                        // hide
            insetTop = stuBarHeight + navBarHeight! + navigationBar.bounds.height
            conditionMenu!.toggleMenu(false)
        }
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut,
            animations: {() in
                self.tableView.contentInset.top = insetTop!
                self.tableView.scrollIndicatorInsets.top = insetTop!
            }, completion: nil)
    }
    
    func reloadList() {
        // Cell表示内容の変更
        changeValue()
        // リストソート
        sortAtIndex()
        // TableViewの更新
        tableView!.reloadData()
        println("List reloaded!!")
    }
    
    func changeValue() {
        for i in 0..<list.count {
            let ns = list[i]
            list[i].value = Double(isPlusMode ? ns.attack+99*5*ns.leverage : ns.attack) * Double(isCRTMode ? 1+ns.critical()/2 : 1) / Double(isAveMode ? ns.panels() : 1)
        }
    }
    
    func changePlus(sender: UIButton) {
        isPlusMode = isPlusMode ? false : true
        println("isPlusMode: \(isPlusMode)")
        println("Plus: \(isPlusMode), CRT: \(isCRTMode), Ave: \(isAveMode)")
        sender.tintColor = isPlusMode == true ? accentColor : UIColor.grayColor()
        reloadList()
    }
    
    func changeCRT(sender: UIButton) {
        isCRTMode = isCRTMode ? false : true
        println("isCRTMode: \(isCRTMode)")
        println("Plus: \(isPlusMode), CRT: \(isCRTMode), Ave: \(isAveMode)")
        sender.tintColor = isCRTMode == true ? accentColor : UIColor.grayColor()
        reloadList()
    }
    
    func changeAve(sender: UIButton) {
        isAveMode = isAveMode ? false : true
        println("isAveMode: \(isAveMode)")
        println("Plus: \(isPlusMode), CRT: \(isCRTMode), Ave: \(isAveMode)")
        sender.tintColor = isAveMode == true ? accentColor : UIColor.grayColor()
        reloadList()
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
        let NoSort = UIAlertAction(title: "No↑", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[No↑]")
                self.sortIndex = 0
                let sortButton = self.sortButtonMakeInTitle("No↑")
                navItem.rightBarButtonItems?[0] = sortButton
                self.reloadList()
        })
        let NoDownSort = UIAlertAction(title: "No↓", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[No↓]")
                self.sortIndex = 1
                let sortButton = self.sortButtonMakeInTitle("No↓")
                navItem.rightBarButtonItems?[0] = sortButton
                self.reloadList()
        })
        let ATKSort = UIAlertAction(title: "ATK↓", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[ATK↓]")
                self.sortIndex = 2
                let sortButton = self.sortButtonMakeInTitle("ATK↓")
                navItem.rightBarButtonItems?[0] = sortButton
                self.reloadList()
        })
        let PanelSort = UIAlertAction(title: "パネル数↑", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[Panels↑]")
                self.sortIndex = 3
                let sortButton = self.sortButtonMakeInTitle("パネル数↑")
                navItem.rightBarButtonItems?[0] = sortButton
                self.reloadList()
        })
        let CRTSort = UIAlertAction(title: "クリティカル率↓", style: .Default,
            handler: {(action: UIAlertAction!) in
                println("sort[CRT↓]")
                self.sortIndex = 4
                let sortButton = self.sortButtonMakeInTitle("CRT↓")
                navItem.rightBarButtonItems?[0] = sortButton
                self.reloadList()
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {(actin: UIAlertAction!) in
            println("sort[Cancel!]")
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
    
    func changeSearchMode(sender: UIButton) {
        if isSearchMode == false {
            isSearchMode = true
            var searchBar = UISearchBar()
            searchBar.delegate = self
            searchBar.showsCancelButton = false
            searchBar.placeholder = "インフィニティ・リバース"
            searchBar.barTintColor = UIColor.whiteColor()
            searchBar.tintColor = accentColor
            searchBar.searchBarStyle = UISearchBarStyle.Default
            searchBar.frame.origin = CGPointMake(-150, 22)
            var cancelButton = UIBarButtonItem(title: "戻る", style: .Plain, target: self, action: "changeSearchMode:")
            
            let navItem = navigationBar!.items[0] as UINavigationItem
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: nil,
                animations: {
                    navItem.leftBarButtonItems = nil
                    navItem.titleView = searchBar
                    navItem.rightBarButtonItems = [cancelButton]
                }, completion: nil)
            searchBar.becomeFirstResponder()
            println("isSearchMode: \(isSearchMode)")
        } else {
            isSearchMode = false
            setUpnavItems()
            println("isSearchMode: \(isSearchMode)")
        }
    }
    
    // MARK: - UISearchBar Delegate methods
    
    // 検索ボタンを押した時
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: - NSConditionMenuDelegate methods
    
    func condMenuWillClose() {
        let stuBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let navBarHeight: CGFloat? = self.navigationController?.navigationBar.frame.size.height
        let insetTop = stuBarHeight + navBarHeight! + self.navigationBar.frame.height
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
        
        reloadList()
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("NSCell") as NSCell
        let ns = list[indexPath.row]
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
