//
//  DataViewController.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 12/13/14.
//  Copyright (c) 2014 TakumaMatsumoto. All rights reserved.
//

import UIKit
import CoreData

class DataViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate, UnitsViewControllerDelegate, NSViewControllerDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var segmentedControlData: UISegmentedControl!
    
    var currentViewController: UIViewController!
//    var skillIndex: NSInteger = 0
    
    var listUnits: [UnitsData] = []
    var listNS: [NSData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUnitsData()
//        setNSDammyData()
        
        loadUnitsDataObject()
        loadNSDataObject()
        
        // Setup views
        
        // Show content view's container view
        let viewController = self.viewControllerForSegmentedIndex(segmentedControlData.selectedSegmentIndex)
        self.addChildViewController(viewController)
        self.changeView(viewController)
        currentViewController = viewController
        println(currentViewController)
        
        segmentedControlData.bounds.size.width = self.view.bounds.size.width
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
        //        request.predicate = NSPredicate(format: "%@ = %d", <<keys[]>>, <<values[]>>)
        
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
        let viewController = viewControllerForSegmentedIndex(segmentedControlData.selectedSegmentIndex)
        currentViewController.willMoveToParentViewController(nil)
        animationOfChangingViewController(toViewController: viewController)
    }
    
    func animationOfChangingViewController(toViewController viewController: UIViewController)
    {
        self.addChildViewController(viewController)
        self.transitionFromViewController(currentViewController, toViewController: viewController, duration: 0.1, options: UIViewAnimationOptions.TransitionCrossDissolve,
            animations: {() in
                self.currentViewController.view.removeFromSuperview()
                self.changeView(viewController)
            }, completion: {Bool in
                self.currentViewController.removeFromParentViewController()
                viewController.didMoveToParentViewController(self)
                self.currentViewController = viewController
                println(self.currentViewController)
        })
    }
    
    func changeView(viewController: UIViewController) {
        viewController.view.frame = self.contentView.frame
        self.contentView.addSubview(viewController.view)
    }
    
    
    // MARK: - selectedViewController
    
    func viewControllerForSegmentedIndex(index: NSInteger) -> UIViewController
    {
        // 切り替えるViewの指定
        var vc: UIViewController?
        switch index {
        case 0:    // Units
            let view = self.storyboard?.instantiateViewControllerWithIdentifier("Units") as UnitsViewController
            view.delegate = self
            vc = view
        case 1:    // NS
            let view = self.storyboard?.instantiateViewControllerWithIdentifier("NS") as NSViewController
            view.delegate = self
            vc = view
        default :
            break
        }
        return vc!
    }


    // MARK: - Units mehods
    
    func setUnitsData() {
        if let path = NSBundle.mainBundle().pathForResource("units", ofType: "csv") {
            println("Found units.csv file!")
            let url = NSURL.fileURLWithPath(path)
            let table = NTYCSVTable(contentsOfURL: url)
            println(table.headers)
            println(table.rows)
            for unit in table.rows {
                saveUnitsDataFromCSV(unit as NSDictionary)
            }
        }
    }
    
    func saveUnitsDataFromCSV(data: NSDictionary) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        let request = NSFetchRequest(entityName: "UnitsData")
        request.predicate = NSPredicate(format: "unit = %d", data["No"] as Int)
        
        if let results = context.executeFetchRequest(request, error: nil) {
            let ent = NSEntityDescription.entityForName("UnitsData", inManagedObjectContext: context)
            let Units = UnitsData(entity: ent!, insertIntoManagedObjectContext: context)
            Units.initUnitsDataFromCSV(data)
                var error: NSError?
                if !context.save(&error) {
                println("Could not save \"\(Units.name)\" \(error), \(error?.userInfo)")
                } else {
                println("save \(Units.name)")
            }
        } else {
            let name = data["Name"] as String
            println("\(name) is already saved!")
        }
    }
    
    func saveUnitsDataFromValues(unit: Int, name: String, element: Int, rare: Int, race: [String], cost: Int, lv: Int, hp: Double, atk: Double) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        let request = NSFetchRequest(entityName: "UnitsData")
        request.predicate = NSPredicate(format: "unit = %d", unit)
        
        if let results = context.executeFetchRequest(request, error: nil) {
            let ent = NSEntityDescription.entityForName("UnitsData", inManagedObjectContext: context)
            let Units = UnitsData(entity: ent!, insertIntoManagedObjectContext: context)
            Units.initUnitsData(unit, Name: name, Element: element, Rare: rare, Race: race, Cost: cost, Lv: lv, Hp: hp, Atk: atk)
            
            var error: NSError?
            if !context.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            } else {
                println("save \(Units.name)")
            }
        } else {
            println("\(name) is already saved!")
        }
    }
    
    // MARK: - NS methods
    
    func setNSDammyData() {
        /*
        * NSダミーデータ
        */
        initNSDataObject(296, number: 2, name: "ディバイン・クラウン", detail: nil, boost: nil, panel: [4, 4, 4, 4], target: 2, element: 4, leverage: 2.8, critical: nil)
        initNSDataObject(343, number: 1, name: "サヴァト・メア", detail: nil, boost: nil, panel: [5, 5], target: 2, element: 5, leverage: 1.6, critical: nil)
        initNSDataObject(534, number: 1, name: "セレスライタラア", detail: nil, boost: nil, panel: [4, 4], target: 1, element: 4, leverage: 1.6, critical: nil)
        initNSDataObject(534, number: 2, name: "ビューティ・サンライズ", detail: nil, boost: nil, panel: [7, 7, 7, 7], target: 2, element: 4, leverage: 1.8, critical: nil)
        initNSDataObject(595, number: 1, name: "テラ・アーク", detail: nil, boost: nil, panel: [1, 1, 1], target: 1, element: 1, leverage: 3, critical: nil)
        initNSDataObject(595, number: 2, name: "イリス", detail: nil, boost: nil, panel: [1, 1, 1, 2, 3], target: 1, element: 1, leverage: 4.5, critical: nil)
        initNSDataObject(625, number: 1, name: "ソロウ：セカンド", detail: nil, boost: nil, panel: [3, 3], target: 2, element: 3, leverage: 1.8, critical: nil)
        initNSDataObject(893, number: 1, name: "無の波動", detail: nil, boost: nil, panel: [6, 6], target: 1, element: 6, leverage: 2.3, critical: nil)
        initNSDataObject(864, number: 1, name: "ナンバーナイン：ナイン", detail: nil, boost: nil, panel: [1, 1], target: 1, element: 1, leverage: 2.3, critical: nil)
        initNSDataObject(963, number: 1, name: "コンプ・ウィンドミル", detail: nil, boost: nil, panel: [3, 3, 3, 3, 3], target: 1, element: 3, leverage: 8, critical: nil)
        initNSDataObject(963, number: 2, name: "ドラスチック", detail: nil, boost: nil, panel: [7, 7, 7, 7, 7], target: 2, element: 3, leverage: 3, critical: nil)
        initNSDataObject(1009, number: 1, name: "ベルセルク：ゴア", detail: nil, boost: nil, panel: [6, 6, 6], target: 1, element: 6, leverage: 4.5, critical: nil)
        initNSDataObject(1062, number: 1, name: "デス：シザーズ", detail: nil, boost: nil, panel: [5, 5], target: 1, element: 5, leverage: 1.6, critical: nil)
        initNSDataObject(1110, number: 1, name: "ラグナ・メイルストロム", detail: nil, boost: nil, panel: [2, 3, 6], target: 1, element: 2, leverage: 6, critical: nil)
        initNSDataObject(630, number: 1, name: "エナジーヒール：アクアⅡ", detail: nil, boost: nil, panel: [2, 2], target: 0, element: 2, leverage: 0.1, critical: nil)
        initNSDataObject(725, number: 1, name: "フレッシュソング", detail: "敵単体を光属性の歌で凄く魅了する", boost: nil, panel: [4, 4], target: 1, element: 4, leverage: 2.3, critical: 0)
        initNSDataObject(899, number: 1, name: "インフィニティ・リバース", detail: nil, boost: nil, panel: [1, 2, 3, 4, 5], target: 1, element: 6, leverage: 8, critical: 0)
        initNSDataObject(1062, number: 1, name: "オペレーションリヴァイブ", detail: nil, boost: nil, panel: [1, 2, 3, 6], target: 2, element: 5, leverage: 3, critical: 0.44)
        initNSDataObject(1064, number: 1, name: "トリオ：フォルテ", detail: nil, boost: nil, panel: [1, 1], target: 1, element: 1, leverage: 3, critical: 0.13)
        initNSDataObject(296, number: 1, name: "エクスカリバー：リボルブ", detail: nil, boost: nil, panel: [4, 4], target: 1, element: 4, leverage: 3, critical: nil)
        initNSDataObject(1058, number: 2, name: "セイント・クラウン", detail: nil, boost: nil, panel: [4, 4, 4, 4], target: 1, element: 4, leverage: 6, critical: nil)
        initNSDataObject(1011, number: 1, name: "ビリトル", detail: nil, boost: nil, panel: [4], target: 1, element: 4, leverage: 1, critical: nil)
        initNSDataObject(1011, number: 2, name: "トリリオンアイズ", detail: nil, boost: nil, panel: [4, 4, 4, 4, 4], target: 2, element: 4, leverage: 3, critical: nil)
        initNSDataObject(1112, number: 1, name: "アサルトディフェンス", detail: nil, boost: nil, panel: [3, 3], target: 1, element: 3, leverage: 3, critical: nil)
        initNSDataObject(893, number: 2, name: "黄昏の審判", detail: nil, boost: nil, panel: [4, 4, 6, 5, 5], target: 1, element: 6, leverage: 8, critical: nil)
        initNSDataObject(965, number: 1, name: "サマーナイツドリーム", detail: nil, boost: nil, panel: [5, 5], target: 1, element: 5, leverage: 3, critical: nil)
        initNSDataObject(965, number: 2, name: "ザ・ホールネス", detail: nil, boost: nil, panel: [4, 6], target: 2, element: 4, leverage: 3, critical: nil)
        initNSDataObject(750, number: 1, name: "アウェイク：マキナ", detail: nil, boost: nil, panel: [4, 4, 4], target: 2, element: 4, leverage: 4, critical: nil)
        initNSDataObject(750, number: 2, name: "ユナイティリィ・ラフ", detail: nil, boost: nil, panel: [1, 3, 6], target: 1, element: 4, leverage: 6, critical: nil)
        initNSDataObject(1012, number: 1, name: "レイク・キス", detail: nil, boost: nil, panel: [2, 4], target: 1, element: 2, leverage: 4.5, critical: nil)
        initNSDataObject(1012, number: 2, name: "カリブルヌス", detail: nil, boost: nil, panel: [7, 7], target: 2, element: 2, leverage: 2.8, critical: nil)
        initNSDataObject(1115, number: 1, name: "エクス：ベドウィル", detail: nil, boost: nil, panel: [1, 1], target: 1, element: 1, leverage: 3, critical: nil)
        initNSDataObject(752, number: 1, name: "ワダツミ：グスク", detail: nil, boost: nil, panel: [2, 5], target: 1, element: 2, leverage: 3, critical: nil)
        initNSDataObject(559, number: 1, name: "アポカリプス・マリア", detail: nil, boost: nil, panel: [3], target: 1, element: 3, leverage: 1, critical: nil)
        initNSDataObject(559, number: 2, name: "デスディレクション", detail: nil, boost: nil, panel: [3, 3, 3], target: 2, element: 3, leverage: 2.5, critical: nil)
        initNSDataObject(610, number: 1, name: "エビルカリバー：バースト", detail: nil, boost: nil, panel: [5, 5], target: 1, element: 5, leverage: 3, critical: nil)
        initNSDataObject(778, number: 1, name: "クズノハ・カムイ", detail: nil, boost: nil, panel: [1], target: 1, element: 1, leverage: 1, critical: nil)
        initNSDataObject(778, number: 2, name: "キュウビノゴウカ", detail: nil, boost: nil, panel: [1, 1], target: 1, element: 1, leverage: 3, critical: nil)
        initNSDataObject(678, number: 2, name: "ハイスコティッシュ・プレイ", detail: nil, boost: nil, panel: [1, 1, 1, 1], target: 1, element: 1, leverage: 6, critical: nil)
        initNSDataObject(894, number: 1, name: "イグナイト：リート", detail: nil, boost: nil, panel: [1, 1], target: 1, element: 1, leverage: 2.3, critical: nil)
        initNSDataObject(866, number: 1, name: "イン・ザ・ブランク", detail: nil, boost: nil, panel: [6, 6], target: 1, element: 6, leverage: 3, critical: nil)
        initNSDataObject(650, number: 1, name: "レイク・ヒール", detail: nil, boost: nil, panel: [7], target: 0, element: 2, leverage: 0.12, critical: nil)
        initNSDataObject(650, number: 2, name: "カリブルヌス", detail: nil, boost: nil, panel: [7, 7], target: 2, element: 2, leverage: 2.8, critical: nil)
        initNSDataObject(1114, number: 1, name: "スノウボイス", detail: "敵単体を水属性の歌で少し魅了する", boost: nil, panel: [7], target: 1, element: 2, leverage: 1, critical: nil)
        initNSDataObject(1114, number: 2, name: "スノウソング", detail: "敵単体を水属性の歌でメロメロにする", boost: nil, panel: [7, 7, 7], target: 1, element: 2, leverage: 3, critical: nil)
        initNSDataObject(1122, number: 1, name: "パーフェクト・エール", detail: nil, boost: nil, panel: [3, 3], target: 2, element: 3, leverage: 2.5, critical: nil)
        initNSDataObject(1123, number: 1, name: "ピョン・オプタルモス", detail: nil, boost: nil, panel: [4, 4], target: 1, element: 4, leverage: 3, critical: nil)
        initNSDataObject(1017, number: 1, name: "コード：A'", detail: nil, boost: nil, panel: [2, 2], target: 1, element: 2, leverage: 1.6, critical: 0.07)
        initNSDataObject(1017, number: 2, name: "アクアゴスペル", detail: nil, boost: nil, panel: [2, 2, 2, 2], target: 1, element: 2, leverage: 6, critical: 0.13)
        initNSDataObject(819, number: 1, name: "コンプアイズノーン", detail: nil, boost: nil, panel: [6, 6], target: 1, element: 6, leverage: 2.3, critical: nil)
        initNSDataObject(897, number: 1, name: "リュミエール：ウィスプ", detail: nil, boost: nil, panel: [4, 4], target: 1, element: 4, leverage: 2.3, critical: nil)
        initNSDataObject(897, number: 2, name: "ビューティ・ビューティ", detail: nil, boost: nil, panel: [7, 7], target: 2, element: 4, leverage: 1.8, critical: nil)
        initNSDataObject(1038, number: 1, name: "させるかっ", detail: nil, boost: nil, panel: [1, 1], target: 0, element: 1, leverage: 0.15, critical: nil)
        initNSDataObject(1164, number: 2, name: "フレイムウォール", detail: nil, boost: "さらに、敵全体に攻撃力×2.0倍の炎属性攻撃", panel: [1, 1, 2, 2], target: 1, element: 1, leverage: 4.5, critical: nil)
        initNSDataObject(1160, number: 1, name: "アンナ", detail: nil, boost: nil, panel: [4, 4], target: 0, element: 4, leverage: 0.1, critical: nil)
        initNSDataObject(1160, number: 2, name: "アナスタシヤ", detail: nil, boost: nil, panel: [4, 4, 4, 4], target: 1, element: 4, leverage: 4.5, critical: 0.44)
        initNSDataObject(1036, number: 1, name: "ここが貴様の死地だ", detail: nil, boost: nil, panel: [4, 4], target: 1, element: 4, leverage: 2.3, critical: nil)
        initNSDataObject(436, number: 1, name: "フェアウェル：バースト", detail: nil, boost: nil, panel: [6, 6, 6], target: 1, element: 6, leverage: 2.3, critical: nil)
        initNSDataObject(436, number: 2, name: "ディザスター・クライ", detail: nil, boost: nil, panel: [1, 2, 3, 5, 6], target: 2, element: 6, leverage: 4, critical: nil)
    }
    
    func initNSDataObject(unit: Int, number: Int, name: String, detail: String?, boost: String?, panel: [Int], target: Int, element: Int, leverage: Double, critical: Double?) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        let request = NSFetchRequest(entityName: "NSData")
        request.predicate = NSPredicate(format: "unit = %d AND number = %d", unit, number)
        
        if let results = context.executeFetchRequest(request, error: nil) {
            let ent = NSEntityDescription.entityForName("NSData", inManagedObjectContext: context)
            let NS = NSData(entity: ent!, insertIntoManagedObjectContext: context)
            NS.initNSData(unit, Number: number, Name: name, Detail: detail?, Boost: boost?, Panel: panel, Target: target, Element: element, Leverage: leverage, Critical: critical?)
            
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
    
    // MARK: - UnitsViewControllerDelegate methods
    
    func setUpUnitsList() -> [UnitsData] {
        return listUnits
    }
    
    // MARK: - NSViewControllerDelegate methods
    
    func setUpNSList() -> [NSData] {
        return listNS
    }
    
}
