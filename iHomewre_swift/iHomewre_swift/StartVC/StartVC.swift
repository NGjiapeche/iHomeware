//
//  StartVC.swift
//  iHomewre_swift
//
//  Created by mac on 16/7/12.
//  Copyright © 2016年 mac. All rights reserved.
//
/*************************************************

 ***************************************************/
import UIKit
import Reachability

let isFirstStartBoolen:Bool = {
    if  NSUserDefaults.standardUserDefaults().boolForKey("firstStart") {
        printLog("已经启动过至少一次")
         return false
    }else{
        printLog("第一次启动")
         return true
        
    }
}()

var  savedConnectedGatwayIPs:[String: [String]]? {
    get{
       return NSUserDefaults.standardUserDefaults().dictionaryForKey("savedConnectedGatwayIPs") as! [String: [String]]?
    }

    set{
        print("保存 wifi 及 网关ip")
        NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "savedConnectedGatwayIPs")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

var  savedCredentialInfos:[String : NSData]? {
    get{
        return NSUserDefaults.standardUserDefaults().dictionaryForKey("savedCredentialInfos") as! [String : NSData]?
    }

    set{
        print("保存 网关name 及 认证信息")
        NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "savedCredentialInfos")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

//userCredential
var  savedEmailCredentialInfos: [NSData]?{
    get{
        return NSUserDefaults.standardUserDefaults().arrayForKey("savedEmailCredentialInfos") as! [NSData]?
    }

    set{
        print("保存 邮箱信息 ")
        NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "savedEmailCredentialInfos")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

var currentCredentialdata: NSData?

class StartVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

    @IBOutlet weak var gatwayTab: UITableView!{
        didSet{
            gatwayTab.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var connectv: UIView!
    @IBOutlet weak var emailV: UIView!
    @IBOutlet weak var emailTextFile: UITextField!
    @IBOutlet weak var NotFoundedV: UIView!
    @IBOutlet weak var NotFoudLab: UILabel!
    @IBOutlet weak var addresstextfile: UITextField!
    
    @IBAction func dissUIKeyBoard(sender: UITapGestureRecognizer) {
        emailTextFile.resignFirstResponder()
        addresstextfile.resignFirstResponder()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        emailTextFile.resignFirstResponder()
        addresstextfile.resignFirstResponder()
        return true
    }

    var keysname: [String]? //走网络连接时，网关name
    var willConnectIP:String?
    var NetStr:String?
    var failedlinkCloud: Bool = false
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard NetWorkManage.sharedInstance.currentServerType == NetAdressInfo.CloudServerType.rawValue else {
              return NetWorkManage.sharedInstance.allSearchGatwayArr.count
        }
        return savedCredentialInfos!.keys.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = gatwayTab.dequeueReusableCellWithIdentifier("SearchedCell") as! SearchedGatwayCell;
        if NetWorkManage.sharedInstance.currentServerType == NetAdressInfo.CloudServerType.rawValue {
             cell.gatwayIPlab.text = keysname![indexPath.row]
        }else{
            cell.gatwayIPlab.text = "Gatway\(indexPath.row + 1):" + NetWorkManage.sharedInstance.allSearchGatwayArr[indexPath.row]
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if NetWorkManage.sharedInstance.currentServerType == NetAdressInfo.CloudServerType.rawValue {
            self.gatwayTab.hidden = true
            let key = keysname![indexPath.row]
            let gatwayCredential = savedCredentialInfos![key]
            NetWorkManage.sharedInstance.checkUserCredential(savedEmailCredentialInfos!.first!, passWData: savedEmailCredentialInfos!.last!, gatwayCredential:gatwayCredential)
        }else{
            self.willConnectIP = NetWorkManage.sharedInstance.allSearchGatwayArr[indexPath.row]
            self.gatwayTab.hidden = true
            self.connectv.hidden = false
        }

    }
    
    var searchTimer: NSTimer?
    override func viewDidLoad() {
        super.viewDidLoad()
       gatwayTab.hidden = true
        connectv.hidden = true
        emailV.hidden = true
        NotFoundedV.hidden = true
        addresstextfile.hidden = true
        
        let origincenter = view.center
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification,
                                                                object: nil,
                                                                queue: NSOperationQueue.mainQueue()) {_ in
                                                                    self.view.center = CGPoint(x: self.view.center.x,y: self.view.center.y - 180)
                                                                    
        }
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification,
                                                                object: nil,
                                                                queue: NSOperationQueue.mainQueue()) {_ in
                                                                    self.view.center  = origincenter
        }
  
        self.checkNet()
        //搜索网关成功
        NSNotificationCenter.defaultCenter().addObserverForName(NotificationNameStr.DidDiscoveryGateway.rawValue,
                                                                object: nil,
                                                                queue: NSOperationQueue.mainQueue()) {_ in
                                                                    self.afterDidDiscoveryGatewayNoti()
        }
        //链接网关成功
        NSNotificationCenter.defaultCenter().addObserverForName(NotificationNameStr.DidConnectedToGateway.rawValue,
                                                                object: nil,
                                                                queue: NSOperationQueue.mainQueue()) {_ in
                                                                   self.afterDidConnectedToGatewayNoti()
        }
        //收到认证信息成功
        NSNotificationCenter.defaultCenter().addObserverForName(NotificationNameStr.DidDealCredential.rawValue,
                                                                object: nil,
                                                                queue: NSOperationQueue.mainQueue()) { noti in
                                                                    self.afterDidDealCredentialNoti(savedData: noti.object as! NSData)
        }
        //第一次使用APP，绑定邮箱，关联手机
        NSNotificationCenter.defaultCenter().addObserverForName(NotificationNameStr.BindEmailCredential.rawValue,
                                                                object: nil,
                                                                queue: NSOperationQueue.mainQueue()) {_ in
                                                                    NetWorkManage.sharedInstance.sendPhoneInfo()
        }
        //第一次使用APP，关联手机后，进入主页面
        NSNotificationCenter.defaultCenter().addObserverForName(NotificationNameStr.BindedPhone.rawValue,
                                                                object: nil,
                                                                queue: NSOperationQueue.mainQueue()) {_ in
                                                                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstStart")
                                                                    NSUserDefaults.standardUserDefaults().synchronize()
                                                                    self.performSegueWithIdentifier("mianvcIdentifier", sender: nil)

        }
        //当前网络下没发现网关，连接云端成功
        NSNotificationCenter.defaultCenter().addObserverForName(NotificationNameStr.DidConnectedToCloudServer.rawValue,
                                                                object: nil,
                                                                queue: NSOperationQueue.mainQueue()) {_ in
                                                                    self.afterConnectedCloud()
                                                                    print("startvc 连接 云 成功")
        }
        //通过云端 连接网关成功
        NSNotificationCenter.defaultCenter().addObserverForName(NotificationNameStr.CheckCredentialWhenCloud.rawValue,
                                                                object: nil,
                                                                queue: NSOperationQueue.mainQueue()) {_ in
                                                                    self.performSegueWithIdentifier("mianvcIdentifier", sender: nil)
        }
       
        
    }
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print(" 移除 StartVC 所有 广播通知 ")
    }

    
    //MARK: checkNet
    func checkNet()  {
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        reachability.whenReachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    print("Reachable via WiFi")
                    self.startSearchGateway()
                } else {
                    print("Reachable via Cellular")
                    self.judgeTimeOutSearchGateway() //移动网络下忽略搜寻网关
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                print("Not reachable")
                self.NetStr = "NotNet"
                self.NotFoudLab.text = "Not Available Network Service. Try again?"
                self.NotFoundedV.hidden = false
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    //MARK: 开始搜索网关
    func startSearchGateway()  {
        NetWorkManage.sharedInstance.startSearchGetway()
        self.performSelector(#selector(StartVC.judgeTimeOutSearchGateway), withObject: nil, afterDelay: 8)
    }
    func judgeTimeOutSearchGateway() {
        NetWorkManage.sharedInstance.stopSearchGatway()
        guard savedConnectedGatwayIPs != nil else {
            NotFoundedV.hidden = false
            return
        }
        print("此网络下未发现设备，正在连接云端")
        self.startConnectToCloud(newaddress: nil)
    }
    
    @IBAction func ContinueSearch(sender: UIButton) {
        NotFoundedV.hidden = true
        guard failedlinkCloud == false else {
            addresstextfile.hidden = true
            self.startConnectToCloud(newaddress: addresstextfile.text!) //重连
            return
        }
        guard let nets = NetStr where nets == "NotNet" else{
             self.startSearchGateway() //有网情况下搜寻
            return
        }
        self.checkNet()
    }
    
    @IBAction func EscApp(sender: UIButton) {
        NotFoundedV.hidden = true
        exit(0)
    }
    
    
    //MARK: 搜索网关成功后-链接
    func afterDidDiscoveryGatewayNoti(){
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(StartVC.judgeTimeOutSearchGateway), object: nil)
        
        NetWorkManage.sharedInstance.stopSearchGatway()
        if isFirstStartBoolen {
            print("第一次打开APP链接网关，显示点击网关中间建提示")
            if NetWorkManage.sharedInstance.allSearchGatwayArr.count>1 {
                self.gatwayTab .reloadData()
                gatwayTab.hidden = false
            }else{
                willConnectIP = NetWorkManage.sharedInstance.allSearchGatwayArr.first!
                connectv.hidden = false
            }
            
        }else{
            print("不是第一次打开，直接连接 或者 按键连接新网关")
            if NetWorkManage.sharedInstance.allSearchGatwayArr.count>1 {
                self.gatwayTab .reloadData()
                gatwayTab.hidden = false
            }else{
                willConnectIP = NetWorkManage.sharedInstance.allSearchGatwayArr.first!
                let isExsit =   savedConnectedGatwayIPs?.contains({ (str,arr: [String]) -> Bool in
                    if arr.contains(willConnectIP!){
                        return true
                    }
                    return false
                })

                guard isExsit! else{
                    connectv.hidden = false
                    return
                }
                self.AgainConectToLocalGetway()
            }
        }

    }
    @IBAction func clickToConnectGatway(sender: UIButton) {
        connectv.hidden = true
        self.AgainConectToLocalGetway()
    }
    
    //MARK: 开始链接网关
    func AgainConectToLocalGetway() {
        NetWorkManage.sharedInstance.connectToLocalGetwayWithIPAddress(self.willConnectIP!)
   
        NetWorkManage.sharedInstance.performSelector(#selector(NetWorkManage.sharedInstance.connectToLocalGetwayWithIPAddress), withObject: nil, afterDelay: 2)
        NetWorkManage.sharedInstance.performSelector(#selector(NetWorkManage.sharedInstance.connectToLocalGetwayWithIPAddress), withObject: nil, afterDelay: 4)
        
         self.performSelector(#selector(StartVC.judgeTimeOutConnectLocalGateway), withObject: nil, afterDelay: 5)
    }
    func judgeTimeOutConnectLocalGateway(){
        connectv.hidden = false
    }
 
    
    //MARK: 链接网关成功后--（保存网关信息）--获取认证
    func afterDidConnectedToGatewayNoti() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(StartVC.judgeTimeOutConnectLocalGateway), object: nil)
        
        let wifiname = "pilotlab1"
        let dict: [String: [String]] = [wifiname : [willConnectIP!]]
        if savedConnectedGatwayIPs == nil
        {
            savedConnectedGatwayIPs = dict
        }else{
            guard savedConnectedGatwayIPs![wifiname] != nil else {
                savedConnectedGatwayIPs![wifiname] = [willConnectIP!]
                NetWorkManage.sharedInstance.credentialAsk()
                return
            }
            guard savedConnectedGatwayIPs![wifiname]?.contains(willConnectIP!) == true else {
                savedConnectedGatwayIPs![wifiname]?.append(willConnectIP!)
                NetWorkManage.sharedInstance.credentialAsk()
                return
            }
   
        }
        NetWorkManage.sharedInstance.credentialAsk()
    }
    
    //MARK: 获取认证后---（保存网关 及对应 凭证）--进入主页面
    func afterDidDealCredentialNoti(savedData data: NSData)  {
        if isFirstStartBoolen{
            emailV.hidden = false
        }else{
            //进入主页面
            currentCredentialdata = data
            self.performSegueWithIdentifier("mianvcIdentifier", sender: nil)
            
        }
        guard savedCredentialInfos != nil else{
            savedCredentialInfos = ["GatWay1" : data];
            return
        }
        guard savedCredentialInfos?.values.contains(data) == true else {
            let i = savedCredentialInfos?.keys.count
            savedCredentialInfos!["Gatway\(i!+1)"] = data
            return
        }
        print(savedCredentialInfos)
       
    }
    @IBAction func clickToemailV(sender: UIButton) {
        emailV.removeFromSuperview()
        if emailTextFile.text! =~ emailPattern {
            print("有效的邮箱地址")
        }else{
            
        }
        let emailstr = emailTextFile.text!
        let psw = "123456"
        let data : (NSData,NSData) = self.createUserCredentialData(email: emailstr, password: psw)
         NetWorkManage.sharedInstance.checkUserCredential(data.0, passWData: data.1,gatwayCredential: nil)
        //存储邮箱信息 用于 远程连接
        savedEmailCredentialInfos = [data.0,data.1]
    }
    func createUserCredentialData(email emailStr: String, password: String) -> (NSData,NSData) {
        let len0 = emailStr.characters.count
        let arr0 = [UInt8](count: 64-len0, repeatedValue: 0xff)
        let data0 = NSMutableData(data: emailStr.dataUsingEncoding(NSUTF8StringEncoding)!)
        data0.appendBytes(arr0, length: 64-len0 * sizeof(UInt8))
        
        let len1 = password.characters.count
        let data1 = NSMutableData(data: password.dataUsingEncoding(NSUTF8StringEncoding)!)
        if len1<6 {
            let arr1 = [UInt8](count: 6-len1, repeatedValue: 0xff)
            data1.appendBytes(arr1, length: 6-len1 * sizeof(UInt8))
        }
        return (data0,data1)
    }
    
    //MARK: 开始链接云端
    func startConnectToCloud(newaddress ip: String? ){
        NetWorkManage.sharedInstance.connectToCloudServer(ip)
        self.performSelector(#selector(StartVC.judgeTimeOutconnectToCloudServer), withObject: nil, afterDelay: 8)
    }
    func judgeTimeOutconnectToCloudServer(){
        NetWorkManage.sharedInstance.stopConnectToCloud()
        failedlinkCloud = true
        NotFoudLab.text = "Unable to connect to the cloud. Try again?"
        addresstextfile.text = savedCloudServerAddress
        NotFoundedV.hidden = false
        addresstextfile.hidden = false
    }
    
    //MARK: 链接云端后---选择本地存好的网关连接
    func afterConnectedCloud(){
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(StartVC.judgeTimeOutconnectToCloudServer), object: nil)
        //因为之前保存过才会走云端
        print(savedCredentialInfos)
//        keysname = savedCredentialInfos!.keys.map({ (let name) -> String in
//            return name
//        })
       keysname = [String](savedCredentialInfos!.keys)
        gatwayTab.hidden = false
        gatwayTab.reloadData()
    }
}
