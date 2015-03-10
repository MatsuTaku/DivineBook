//
//  DataViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData
//import PageMenu
import NTYCSVTable

class DataViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate, UnitsViewControllerDelegate, NSViewControllerDelegate {
    
    @IBOutlet weak var contentsView: UIView!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
//    var pageMenu: CAPSPageMenu?
    
    var controllerArray: [UIViewController]!
    var currentViewController: UIViewController!
    
    var listUnits: [UnitsData] = []
    var listNS: [NSData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        saveUnitsData()
//        saveNSData()
        
        loadUnitsDataObject()
        loadNSDataObject()
        
        // Setup views
        let unitsViewController = storyboard?.instantiateViewControllerWithIdentifier("Units") as UnitsViewController
        unitsViewController.delegate = self
        let nsViewController = storyboard?.instantiateViewControllerWithIdentifier("NS") as NSViewController
        nsViewController.delegate = self
        controllerArray = [unitsViewController, nsViewController]
        
        let viewController = controllerArray[segmentedController.selectedSegmentIndex]
        self.addChildViewController(viewController)
        contentsView.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
        currentViewController = viewController
        println(currentViewController)
        
        /*
        // Set up PageMenu
        if pageMenu == nil {
            let accentColor = UIColor(red: 99.0/255.0, green: 8.0/255.0, blue: 132.0/255.0, alpha: 1)
            var parameters: [String: AnyObject] = [
                "viewBackgroundColor": UIColor.blackColor(),
                "scrollMenuBackgroundColor": accentColor,
                "selectionIndicatorColor": UIColor.whiteColor(),
                "selectedMenuItemLabelColor": UIColor.whiteColor(),
                "unselectedmenuItemLabelColor": UIColor.grayColor(),
                "useMenuLikeSegmentedControll": true,
                "addBottomMenuHairline": false,
                "enablehorizontalBounce": false,
                "centerMenuItems": true,
                "scrolAnimationDurationOnMenuItemtap": 200
            ]
            var pageMenuY: CGFloat = 0
            pageMenuY += UIApplication.sharedApplication().statusBarFrame.height
            if let navConHeight: CGFloat = self.navigationController?.navigationBar.frame.height {
                pageMenuY += navConHeight
            }
            pageMenu = CAPSPageMenu(controllerArray: controllerArray, frame: CGRectMake(0, pageMenuY, contentsView.frame.width, contentsView.frame.height - pageMenuY), options: parameters)
            pageMenu!.delegate = self
            contentsView.addSubview(pageMenu!.view)
        }
        */
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
    
    
    // MARK: - CoreData methods
    
    func loadUnitsDataObject() {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "UnitsData")
        request.returnsObjectsAsFaults = false
        
        var results = context.executeFetchRequest(request, error: nil) as? [UnitsData]
        if results != nil {
            listUnits = results!
        }
    }
    
    func loadNSDataObject() {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "NSData")
        
        var results = context.executeFetchRequest(request, error: nil) as? [NSData]
        if results != nil {
            listNS = results!
        }
    }
    
    
    // MARK: - Changing View Controller methods
    
    @IBAction func changeSegmentIndex(sender: UISegmentedControl) {
        let viewController = controllerArray[sender.selectedSegmentIndex]
        animateWithChangingViewController(toViewController: viewController)
    }
    
    func animateWithChangingViewController(toViewController viewController: UIViewController)
    {
        currentViewController.willMoveToParentViewController(nil)
        self.addChildViewController(viewController)
        self.transitionFromViewController(currentViewController, toViewController: viewController, duration: 0.1, options: UIViewAnimationOptions.TransitionCrossDissolve,
            animations: {() in
                // 動的アニメーション
            }, completion: {Bool in
                self.currentViewController.removeFromParentViewController()
                viewController.didMoveToParentViewController(self)
                self.currentViewController = viewController
                println(self.currentViewController)
        })
    }
    
    /*
    // MARK: - CAPSPageMenuDelegate methods
    
    func willMoveToPage(controller: UIViewController, index: Int) {
        
    }
    
    func didMoveToPage(controller: UIViewController, index: Int) {
        
    }
    */

    // MARK: - Units mehods
    
    func saveUnitsData() {
        if let path = NSBundle.mainBundle().pathForResource("units", ofType: "csv") {
            let url = NSURL.fileURLWithPath(path)
            let table = NTYCSVTable(contentsOfURL: url)
            if !table.rows.isEmpty {
                let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                let context: NSManagedObjectContext = appDel.managedObjectContext!
                
                let request = NSFetchRequest(entityName: "UnitsData")
                let results = context.executeFetchRequest(request, error: nil) as [UnitsData]
                
                for unit in table.rows {
                    let predicate = NSPredicate(format: "unit = %d", unit["No"] as Int)
                    let sameNo = (results as NSArray).filteredArrayUsingPredicate(predicate!) as? [UnitsData]
                    if sameNo?.count == 0 {
                        let ent = NSEntityDescription.entityForName("UnitsData", inManagedObjectContext: context)
                        
                        let unitData = UnitsData(entity: ent!, insertIntoManagedObjectContext: context)
                        unitData.initUnitsDataFromCSV(unit as NSDictionary)
                        
                        var error: NSError?
                        if !context.save(&error) {
                            println("Could not save \"\(unitData.name)\", error: \(error), userInfo: \(error?.userInfo)")
                        } else {
                            println("Saved \(unitData.unit):\(unitData.name)")
                        }
                    } else {
                        let name = unit["Name"] as? String
                        println("\(name) is already saved!")
                    }
                }
            } else {
                println("CSVFile isn't encoded!!!")
            }
        }
    }
    
    func saveUnitsDataFromCSV(data: NSDictionary) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        let request = NSFetchRequest(entityName: "UnitsData")
        request.predicate = NSPredicate(format: "unit = %d", data["No"] as Int)
        let results = context.executeFetchRequest(request, error: nil)
        if results?.count == 0 {
            let ent = NSEntityDescription.entityForName("UnitsData", inManagedObjectContext: context)
            let units = UnitsData(entity: ent!, insertIntoManagedObjectContext: context)
            units.initUnitsDataFromCSV(data)
            var error: NSError?
            if !context.save(&error) {
                println("Could not save \"\(units.name)\" \(error), \(error?.userInfo)")
            } else {
                println("save \(units.name)")
            }
        } else {
            let name = data["Name"] as? String
            println("\(name) is already saved!")
        }
    }
    
    func setUnitsDammyData() {
        /*
        *ダミーデータ
        */
        saveUnitsDataFromValues(1, name: "アカネ", element: 1, rare: 3, race: ["人間"], cost: 2, lv: 5, hp: 152, atk: 77)
        saveUnitsDataFromValues(5, name: "アオト", element: 2, rare: 3, race: ["人間"], cost: 2, lv: 5, hp: 167, atk: 69)
        saveUnitsDataFromValues(9, name: "ミドリ", element: 3, rare: 3, race: ["人間"], cost: 2, lv: 5, hp: 162, atk: 62)
        saveUnitsDataFromValues(725, name: "元気を歌う少年：鏡音レン", element: 4, rare: 5, race: ["機械"], cost: 20, lv: 99, hp: 2204, atk: 1752)
        saveUnitsDataFromValues(894, name: "炎咎甲士アカネ", element: 1, rare: 7, race: ["人間"], cost: 30, lv: 99, hp: 2371, atk: 2208)
        saveUnitsDataFromValues(899, name: "無英斧士ギンジ", element: 6, rare: 7, race: ["人間"], cost: 30, lv: 99, hp: 2515, atk: 2161)
        saveUnitsDataFromValues(1011, name: "教祖クロウリー", element: 4, rare: 6, race: ["人間"], cost: 40, lv: 99, hp: 3850, atk: 2850)
        saveUnitsDataFromValues(1062, name: "死医者ネクロス", element: 5, rare: 6, race: ["神"], cost: 50, lv: 99, hp: 2715, atk: 2511)
        saveUnitsDataFromValues(1064, name: "炎聖人ダンテ", element: 1, rare: 6, race: ["神"], cost: 40, lv: 99, hp: 3734, atk: 3187)
    }
    
    func saveUnitsDataFromValues(unit: Int, name: String, element: Int, rare: Int, race: [String], cost: Int, lv: Int, hp: Double, atk: Double) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        let request = NSFetchRequest(entityName: "UnitsData")
        request.predicate = NSPredicate(format: "unit = %d", unit)
        let results = context.executeFetchRequest(request, error: nil)
        if results?.count > 0 {
            println("\(name) is already saved!")
        } else {
            let ent = NSEntityDescription.entityForName("UnitsData", inManagedObjectContext: context)
            let Units = UnitsData(entity: ent!, insertIntoManagedObjectContext: context)
            Units.initUnitsData(unit, Name: name, Element: element, Rare: rare, Race: race, Cost: cost, Lv: lv, Hp: hp, Atk: atk)
            
            var error: NSError?
            if !context.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            } else {
                println("save \(Units.name)")
            }
        }
    }
    
    
    // MARK: - NS methods
    
    func saveNSData() {
        if let path = NSBundle.mainBundle().pathForResource("ns", ofType: "csv") {
            let url = NSURL.fileURLWithPath(path)
            let table = NTYCSVTable(contentsOfURL: url)
            if !table.rows.isEmpty {
                let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                let context: NSManagedObjectContext = appDel.managedObjectContext!
                
                let request = NSFetchRequest(entityName: "NSData")
                let results = context.executeFetchRequest(request, error: nil) as [NSData]
                
                for ns in table.rows {
                    for i in 0..<2 {
                        let nsnameKey = NSString(format: "Name%d", i + 1)
                        var nameString: String?
                        if let nsName = ns[nsnameKey] as? String {
                            nameString = nsName
                        } else if let nsName = (ns[nsnameKey] as? NSNumber)?.description {
                            nameString = nsName
                        }
                        if nameString != "0" {
                            let predicate = NSPredicate(format: "unit = %d AND number = %d", ns["No"] as Int, i + 1)
                            let sameNo = (results as NSArray).filteredArrayUsingPredicate(predicate!) as? [NSData]
                            if sameNo?.count == 0 {
                                let ent = NSEntityDescription.entityForName("NSData", inManagedObjectContext: context)
                                
                                let nsData = NSData(entity: ent!, insertIntoManagedObjectContext: context)
                                
                                var NS = [String: AnyObject]()
                                NS["Unit"] = ns["No"]
                                NS["Unit'sName"] = ns["Unit'sName"]
                                NS["Number"] = i + 1
                                NS["Name"] = ns[NSString(format: "Name%d", i + 1)]
                                NS["Type"] = ns[NSString(format: "Type%d", i + 1)]
                                var panels = [String]()
                                for p in 0..<5 {
                                    let panelKey = NSString(format: "P%d%d", p + 1, i + 1)
                                    if let nowPanel = ns[panelKey] as? String {
                                        panels.append(nowPanel)
                                    }
                                }
                                NS["Panel"] = panels
                                NS["Target"] = ns[NSString(format: "Tage%d", i + 1)]
                                NS["Leverage"] = ns[NSString(format: "Lev%d", i + 1)]
                                NS["Critical"] = ns[NSString(format: "Crt%d", i + 1)]
                                NS["Boost"] = ns[NSString(format: "Boost%d", i + 1)]
                                NS["Detail"] = ns[NSString(format: "Detail%d", i + 1)]
                                
                                nsData.initNSDataFromCSV(NS)
                                
                                var error: NSError?
                                if !context.save(&error) {
                                    println("Could not save \"\(nsData.name)\", error: \(error), userInfo: \(error?.userInfo)")
                                } else {
                                    println("Saved \(nsData.unit):\(nsData.name)")
                                }
                            } else {
                                let name = ns["Unit'sName"] as? String
                                println("\(name) is already saved!")
                            }
                        }
                    }
                }
            } else {
                println("CSVFile isn't encoded!!!")
            }
        }
    }
    
    func setNSDammyData() {
        /*
        * NSダミーデータ
        */
        saveNSDataFromValues(296, number: 2, name: "ディバイン・クラウン", detail: nil, boost: nil, panel: [4, 4, 4, 4], target: 2, element: 4, leverage: 2.8, critical: nil)
        saveNSDataFromValues(343, number: 1, name: "サヴァト・メア", detail: nil, boost: nil, panel: [5, 5], target: 2, element: 5, leverage: 1.6, critical: nil)
        saveNSDataFromValues(534, number: 1, name: "セレスライタラア", detail: nil, boost: nil, panel: [4, 4], target: 1, element: 4, leverage: 1.6, critical: nil)
        saveNSDataFromValues(534, number: 2, name: "ビューティ・サンライズ", detail: nil, boost: nil, panel: [7, 7, 7, 7], target: 2, element: 4, leverage: 1.8, critical: nil)
        saveNSDataFromValues(595, number: 1, name: "テラ・アーク", detail: nil, boost: nil, panel: [1, 1, 1], target: 1, element: 1, leverage: 3, critical: nil)
        saveNSDataFromValues(595, number: 2, name: "イリス", detail: nil, boost: nil, panel: [1, 1, 1, 2, 3], target: 1, element: 1, leverage: 4.5, critical: nil)
        saveNSDataFromValues(625, number: 1, name: "ソロウ：セカンド", detail: nil, boost: nil, panel: [3, 3], target: 2, element: 3, leverage: 1.8, critical: nil)
        saveNSDataFromValues(893, number: 1, name: "無の波動", detail: nil, boost: nil, panel: [6, 6], target: 1, element: 6, leverage: 2.3, critical: nil)
        saveNSDataFromValues(864, number: 1, name: "ナンバーナイン：ナイン", detail: nil, boost: nil, panel: [1, 1], target: 1, element: 1, leverage: 2.3, critical: nil)
        saveNSDataFromValues(963, number: 1, name: "コンプ・ウィンドミル", detail: nil, boost: nil, panel: [3, 3, 3, 3, 3], target: 1, element: 3, leverage: 8, critical: nil)
        saveNSDataFromValues(963, number: 2, name: "ドラスチック", detail: nil, boost: nil, panel: [7, 7, 7, 7, 7], target: 2, element: 3, leverage: 3, critical: nil)
        saveNSDataFromValues(1009, number: 1, name: "ベルセルク：ゴア", detail: nil, boost: nil, panel: [6, 6, 6], target: 1, element: 6, leverage: 4.5, critical: nil)
        saveNSDataFromValues(1062, number: 1, name: "デス：シザーズ", detail: nil, boost: nil, panel: [5, 5], target: 1, element: 5, leverage: 1.6, critical: nil)
        saveNSDataFromValues(1110, number: 1, name: "ラグナ・メイルストロム", detail: nil, boost: nil, panel: [2, 3, 6], target: 1, element: 2, leverage: 6, critical: nil)
        saveNSDataFromValues(630, number: 1, name: "エナジーヒール：アクアⅡ", detail: nil, boost: nil, panel: [2, 2], target: 0, element: 2, leverage: 0.1, critical: nil)
        saveNSDataFromValues(725, number: 1, name: "フレッシュソング", detail: "敵単体を光属性の歌で凄く魅了する", boost: nil, panel: [4, 4], target: 1, element: 4, leverage: 2.3, critical: 0)
        saveNSDataFromValues(899, number: 1, name: "インフィニティ・リバース", detail: nil, boost: nil, panel: [1, 2, 3, 4, 5], target: 1, element: 6, leverage: 8, critical: 0)
        saveNSDataFromValues(1062, number: 1, name: "オペレーションリヴァイブ", detail: nil, boost: nil, panel: [1, 2, 3, 6], target: 2, element: 5, leverage: 3, critical: 0.44)
        saveNSDataFromValues(1064, number: 1, name: "トリオ：フォルテ", detail: nil, boost: nil, panel: [1, 1], target: 1, element: 1, leverage: 3, critical: 0.13)
        saveNSDataFromValues(296, number: 1, name: "エクスカリバー：リボルブ", detail: nil, boost: nil, panel: [4, 4], target: 1, element: 4, leverage: 3, critical: nil)
        saveNSDataFromValues(1058, number: 2, name: "セイント・クラウン", detail: nil, boost: nil, panel: [4, 4, 4, 4], target: 1, element: 4, leverage: 6, critical: nil)
        saveNSDataFromValues(1011, number: 1, name: "ビリトル", detail: nil, boost: nil, panel: [4], target: 1, element: 4, leverage: 1, critical: nil)
        saveNSDataFromValues(1011, number: 2, name: "トリリオンアイズ", detail: nil, boost: nil, panel: [4, 4, 4, 4, 4], target: 2, element: 4, leverage: 3, critical: nil)
        saveNSDataFromValues(1112, number: 1, name: "アサルトディフェンス", detail: nil, boost: nil, panel: [3, 3], target: 1, element: 3, leverage: 3, critical: nil)
        saveNSDataFromValues(893, number: 2, name: "黄昏の審判", detail: nil, boost: nil, panel: [4, 4, 6, 5, 5], target: 1, element: 6, leverage: 8, critical: nil)
        saveNSDataFromValues(965, number: 1, name: "サマーナイツドリーム", detail: nil, boost: nil, panel: [5, 5], target: 1, element: 5, leverage: 3, critical: nil)
        saveNSDataFromValues(965, number: 2, name: "ザ・ホールネス", detail: nil, boost: nil, panel: [4, 6], target: 2, element: 4, leverage: 3, critical: nil)
        saveNSDataFromValues(750, number: 1, name: "アウェイク：マキナ", detail: nil, boost: nil, panel: [4, 4, 4], target: 2, element: 4, leverage: 4, critical: nil)
        saveNSDataFromValues(750, number: 2, name: "ユナイティリィ・ラフ", detail: nil, boost: nil, panel: [1, 3, 6], target: 1, element: 4, leverage: 6, critical: nil)
        saveNSDataFromValues(1012, number: 1, name: "レイク・キス", detail: nil, boost: nil, panel: [2, 4], target: 1, element: 2, leverage: 4.5, critical: nil)
        saveNSDataFromValues(1012, number: 2, name: "カリブルヌス", detail: nil, boost: nil, panel: [7, 7], target: 2, element: 2, leverage: 2.8, critical: nil)
        saveNSDataFromValues(1115, number: 1, name: "エクス：ベドウィル", detail: nil, boost: nil, panel: [1, 1], target: 1, element: 1, leverage: 3, critical: nil)
        saveNSDataFromValues(752, number: 1, name: "ワダツミ：グスク", detail: nil, boost: nil, panel: [2, 5], target: 1, element: 2, leverage: 3, critical: nil)
        saveNSDataFromValues(559, number: 1, name: "アポカリプス・マリア", detail: nil, boost: nil, panel: [3], target: 1, element: 3, leverage: 1, critical: nil)
        saveNSDataFromValues(559, number: 2, name: "デスディレクション", detail: nil, boost: nil, panel: [3, 3, 3], target: 2, element: 3, leverage: 2.5, critical: nil)
        saveNSDataFromValues(610, number: 1, name: "エビルカリバー：バースト", detail: nil, boost: nil, panel: [5, 5], target: 1, element: 5, leverage: 3, critical: nil)
        saveNSDataFromValues(778, number: 1, name: "クズノハ・カムイ", detail: nil, boost: nil, panel: [1], target: 1, element: 1, leverage: 1, critical: nil)
        saveNSDataFromValues(778, number: 2, name: "キュウビノゴウカ", detail: nil, boost: nil, panel: [1, 1], target: 1, element: 1, leverage: 3, critical: nil)
        saveNSDataFromValues(678, number: 2, name: "ハイスコティッシュ・プレイ", detail: nil, boost: nil, panel: [1, 1, 1, 1], target: 1, element: 1, leverage: 6, critical: nil)
        saveNSDataFromValues(894, number: 1, name: "イグナイト：リート", detail: nil, boost: nil, panel: [1, 1], target: 1, element: 1, leverage: 2.3, critical: nil)
        saveNSDataFromValues(866, number: 1, name: "イン・ザ・ブランク", detail: nil, boost: nil, panel: [6, 6], target: 1, element: 6, leverage: 3, critical: nil)
        saveNSDataFromValues(650, number: 1, name: "レイク・ヒール", detail: nil, boost: nil, panel: [7], target: 0, element: 2, leverage: 0.12, critical: nil)
        saveNSDataFromValues(650, number: 2, name: "カリブルヌス", detail: nil, boost: nil, panel: [7, 7], target: 2, element: 2, leverage: 2.8, critical: nil)
        saveNSDataFromValues(1114, number: 1, name: "スノウボイス", detail: "敵単体を水属性の歌で少し魅了する", boost: nil, panel: [7], target: 1, element: 2, leverage: 1, critical: nil)
        saveNSDataFromValues(1114, number: 2, name: "スノウソング", detail: "敵単体を水属性の歌でメロメロにする", boost: nil, panel: [7, 7, 7], target: 1, element: 2, leverage: 3, critical: nil)
        saveNSDataFromValues(1122, number: 1, name: "パーフェクト・エール", detail: nil, boost: nil, panel: [3, 3], target: 2, element: 3, leverage: 2.5, critical: nil)
        saveNSDataFromValues(1123, number: 1, name: "ピョン・オプタルモス", detail: nil, boost: nil, panel: [4, 4], target: 1, element: 4, leverage: 3, critical: nil)
        saveNSDataFromValues(1017, number: 1, name: "コード：A'", detail: nil, boost: nil, panel: [2, 2], target: 1, element: 2, leverage: 1.6, critical: 0.07)
        saveNSDataFromValues(1017, number: 2, name: "アクアゴスペル", detail: nil, boost: nil, panel: [2, 2, 2, 2], target: 1, element: 2, leverage: 6, critical: 0.13)
        saveNSDataFromValues(819, number: 1, name: "コンプアイズノーン", detail: nil, boost: nil, panel: [6, 6], target: 1, element: 6, leverage: 2.3, critical: nil)
        saveNSDataFromValues(897, number: 1, name: "リュミエール：ウィスプ", detail: nil, boost: nil, panel: [4, 4], target: 1, element: 4, leverage: 2.3, critical: nil)
        saveNSDataFromValues(897, number: 2, name: "ビューティ・ビューティ", detail: nil, boost: nil, panel: [7, 7], target: 2, element: 4, leverage: 1.8, critical: nil)
        saveNSDataFromValues(1038, number: 1, name: "させるかっ", detail: nil, boost: nil, panel: [1, 1], target: 0, element: 1, leverage: 0.15, critical: nil)
        saveNSDataFromValues(1164, number: 2, name: "フレイムウォール", detail: nil, boost: "さらに、敵全体に攻撃力×2.0倍の炎属性攻撃", panel: [1, 1, 2, 2], target: 1, element: 1, leverage: 4.5, critical: nil)
        saveNSDataFromValues(1160, number: 1, name: "アンナ", detail: nil, boost: nil, panel: [4, 4], target: 0, element: 4, leverage: 0.1, critical: nil)
        saveNSDataFromValues(1160, number: 2, name: "アナスタシヤ", detail: nil, boost: nil, panel: [4, 4, 4, 4], target: 1, element: 4, leverage: 4.5, critical: 0.44)
        saveNSDataFromValues(1036, number: 1, name: "ここが貴様の死地だ", detail: nil, boost: nil, panel: [4, 4], target: 1, element: 4, leverage: 2.3, critical: nil)
        saveNSDataFromValues(436, number: 1, name: "フェアウェル：バースト", detail: nil, boost: nil, panel: [6, 6, 6], target: 1, element: 6, leverage: 2.3, critical: nil)
        saveNSDataFromValues(436, number: 2, name: "ディザスター・クライ", detail: nil, boost: nil, panel: [1, 2, 3, 5, 6], target: 2, element: 6, leverage: 4, critical: nil)
    }
    
    func saveNSDataFromValues(unit: Int, number: Int, name: String, detail: String?, boost: String?, panel: [Int], target: Int, element: Int, leverage: Double, critical: Double?) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        let request = NSFetchRequest(entityName: "NSData")
        request.predicate = NSPredicate(format: "unit = %d AND number = %d", unit, number)
        let results = context.executeFetchRequest(request, error: nil)
        if results?.count > 0  {
            println("\(name) is already saved!")
        } else {
            let ent = NSEntityDescription.entityForName("NSData", inManagedObjectContext: context)
            let NS = NSData(entity: ent!, insertIntoManagedObjectContext: context)
            NS.initNSData(unit, Number: number, Name: name, Detail: detail?, Boost: boost?, Panel: panel, Target: target, Element: element, Leverage: leverage, Critical: critical?)
            
            var error: NSError?
            if !context.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            } else {
                println("save \(NS.name)")
            }
        }
    }
    
    
    // MARK: - ChildViewControllersDelegate methods
    
    // MARK: UnitsViewController
    
    func setUpUnitsList() -> [UnitsData] {
        return listUnits
    }
    
    // MARK: NSViewController
    
    func setUpNSList() -> [NSData] {
        return listNS
    }
    
}
