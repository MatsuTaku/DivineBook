//
//  LSViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 2015/07/01.
//  Copyright (c) 2015年 TakumaMatsumoto. All rights reserved.
//

import UIKit
import MBProgressHUD

class LSViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var sortButtons = [UIBarButtonItem]()
    var defaultLeftButtons = [UIBarButtonItem]()
    var defaultRightButtons = [UIBarButtonItem]()
    var searchBar: UISearchBar!
    var cancelSearchButton: UIBarButtonItem?
    
    var lsTable: LSTable?
    var currentArray = [LS]()
    var filteredArray = [LS]()
    
    var isSearchMode: Bool = false
    var sortIndex: Int = 0
    
    var isLoading: Bool = false
    
    let accentColor = UIColor(red: 0.7, green: 0.1, blue: 0.8, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set up views
        setUpTableView()
        setUpNavigationItems()
        switchSearchMode(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if lsTable == nil {
            if !isLoading {
                isLoading = true
                //                SVProgressHUD.showWithMaskType(.Clear)
                let showHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                showHUD.dimBackground = true
                dispatch_async_global {
                    self.lsTable = LSTable()
                    self.dispatch_async_main {
                        if self.lsTable != nil {
                            //                            SVProgressHUD.dismiss()
                            self.currentArray = self.lsTable!.rows
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
        /*
        if conditionMenu!.isMenuOpen {
            condMenuWillClose()
            conditionMenu!.toggleMenu(false)
            //            SVProgressHUD.popActivity()
        }
        */
        if isSearchMode {
            switchSearchMode(false)
        }
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
    
    
    // MARK: - Set up view items
    
    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        let nib = UINib(nibName: "LSCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "LSCell")
        tableView.estimatedRowHeight = 44
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
        defaultRightButtons = [sortButtons[sortIndex]]
    }
    
    func sortButtonMakeInTitle(title: String) -> UIBarButtonItem {
        let sb = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: "sortLS:")
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
                print("LSTableView reloaded!")
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                if let navigationItem: UINavigationItem = self.navigationBar!.items!.first {
                    navigationItem.title = NSString(format: "%dskills", self.currentArray.count) as String
                }
            }
        }
    }
    
    func toggleConditionMenu(button: UIBarButtonItem) {
//        conditionMenu!.toggleMenu()
    }
    
    func sortAtIndex() {
        switch sortIndex {
        case    0:
            sortInNumUp()
        case    1:
            sortInNumDown()
        default :
            break
        }
    }
    
    func sortInNumUp() {
        currentArray.sortInPlace { (h: LS, b: LS) in
            h.No < b.No
        }
    }
    
    func sortInNumDown() {
        currentArray.sortInPlace { (h: LS, b: LS) in
            h.No > b.No
        }
    }
    
    func reloadListInSortAt(sortIndex: Int) {
        self.sortIndex = sortIndex
        reloadList()
    }
    
    func sortLS(sender: UIButton) {
        if let navigationItem: UINavigationItem = navigationBar!.items!.first {
            let actionSheet = UIAlertController(title: nil, message: "並べ替え条件を選択", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let numUpSort = UIAlertAction(title: "No順", style: .Default,
                handler: {(action: UIAlertAction) in
                    print("sort[↑No]")
                    self.reloadListInSortAt(0)
                    self.defaultRightButtons = [self.sortButtons[self.sortIndex]]
                    navigationItem.rightBarButtonItems = self.defaultRightButtons
            })
            let numDownSort = UIAlertAction(title: "No逆順", style: .Default,
                handler: {(action: UIAlertAction) in
                    print("sort[↓No]")
                    self.reloadListInSortAt(1)
                    self.defaultRightButtons = [self.sortButtons[self.sortIndex]]
                    navigationItem.rightBarButtonItems = self.defaultRightButtons
            })
            let cancel = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {(actin: UIAlertAction) in
                print("sort[Cancel!]")
            })
            actionSheet.addAction(numUpSort)
            actionSheet.addAction(numDownSort)
            actionSheet.addAction(cancel)
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }
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
            let navigationItem: UINavigationItem = navigationBar!.items!.first!
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: [],
                animations: {() in
                    navigationItem.leftBarButtonItems = nil
                    navigationItem.titleView = self.searchBar!
                    navigationItem.rightBarButtonItem = self.cancelSearchButton!
                }, completion: nil)
            searchBar!.becomeFirstResponder()
            tableView!.reloadData()
        } else {
            print("search: \(willSearchMode)")
            isSearchMode = willSearchMode
            let navigationItem: UINavigationItem = navigationBar!.items!.first!
            navigationItem.leftBarButtonItems = self.defaultLeftButtons
            navigationItem.titleView = nil
            navigationItem.title = NSString(format: "%dskills", self.currentArray.count) as String
            navigationItem.rightBarButtonItems = self.defaultRightButtons
            self.tableView!.reloadData()
        }
    }
    
    
    // MARK: - UISearchBarDelegate methods
    
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
        filteredArray = (lsTable!.rows as NSArray).filteredArrayUsingPredicate(predicate) as! [LS]
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContaintsWithSearchText(searchText)
        tableView!.reloadData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("LSCell") as! LSCell
        if !isSearchMode {
            // 通常時
            cell.setCell(currentArray[indexPath.row], showIcon: true)
        } else {
            // 検索時
            cell.setCell(filteredArray[indexPath.row], showIcon: true)
        }
        return cell
    }

}
