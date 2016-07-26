//
//  NetWorkManage.swift
//  iHomewre_swift
//
//  Created by mac on 16/7/12.
//  Copyright © 2016年 mac. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import SystemConfiguration.CaptiveNetwork
var  savedCloudServerAddress: String? {
    get{
        return NSUserDefaults.standardUserDefaults().stringForKey("savedCloudServerAddress")
    }
    set{
        print("保存 CloudServerAddress")
        NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "savedCloudServerAddress")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

enum NetAdressInfo: String {
    case ChineseCloudServerAddress = "cloud02cn.pilot-lab.com.cn"
    case EnglishCloudServerAddress = "cloud01.pilot-lab.com"
    
    case GatewayType
    case CloudServerType
    case NoneServerType
}
enum NotificationNameStr: String {
    case DidDiscoveryGateway
    case DidConnectedToGateway
    case DidConnectedToCloudServer
    case DidDealCredential
    case BindEmailCredential
    case BindedPhone
    
    case CheckCredentialWhenCloud
    
}
enum NetCID: Int {
    case GatewayCID = 0x000E
    case CredentialAskCID = 0x0010
    case BindEmailCredentialCID = 0x0014
    case SendPhoneInfoCID = 0x0018
}
enum CloudCid: Int {
    case CheckEmailCredentialCID = 0x0203
    case SendDeviceTokenCID = 0x0204
}

class NetWorkManage:NSObject, GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate{
    let UDPDiscoveryGetwayPort: UInt16 = 4156
    let GateWayPort : UInt16 = 1234
    let CloudServerPort : UInt16 = 9250
    let PackageStart:UInt8 = 0xfe
    let RequestStart:UInt8 = 0x00
    let ResponseStart:UInt8 = 0x01
    let PackageEnd:UInt8 = 0xff
    
    
    private (set) var allSearchGatwayArr: [String] = Array()
    var currentConnectedGatewayIP: String?
    var currentServerType : String?
    var connectedWithGateway :Bool = false
    var stopedSearchGateway :Bool = false
  
    lazy var currenWifiName: String? = {
        var currentSSID = ""    //模拟器会crash
        if let interfaces:CFArray! = CNCopySupportedInterfaces() {
            for i in 0..<CFArrayGetCount(interfaces){
                let interfaceName: UnsafePointer<Void> = CFArrayGetValueAtIndex(interfaces, i)
                let rec = unsafeBitCast(interfaceName, AnyObject.self)
                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)")
                if unsafeInterfaceData != nil {
                    let interfaceData = unsafeInterfaceData! as Dictionary!
                    currentSSID = interfaceData["SSID"] as! String
                }
            }
        }
        return currentSSID
    
    }()
    
    var udpSocket: GCDAsyncUdpSocket?
    var tcpSocket: GCDAsyncSocket?
    var udpTimer: NSTimer?
    var tcpTimer: NSTimer?
    
    static let sharedInstance = NetWorkManage()
    private override init() {
        super.init()
        
    }
    deinit{
        
    }
    

    // MARK: - 开始搜索网关
    func startSearchGetway() {
        printLog("=====startSearchGetway=====")
        do{
            udpSocket = GCDAsyncUdpSocket(delegate: self,delegateQueue: dispatch_get_main_queue())
            try udpSocket!.bindToPort(UDPDiscoveryGetwayPort)
        }
        catch{
            printLog("=====SearchGetwayError=====")
        }
        do{
            try udpSocket!.beginReceiving()
        }catch{
            printLog("=====checkUDPReponseError=====")
            
        }
        udpTimer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                          target: self,
                                                          selector: #selector(NetWorkManage.checkUDPResponse),
                                                          userInfo: nil,
                                                          repeats: true)
        
    }
    func checkUDPResponse()  {
        do{
            try udpSocket!.beginReceiving()
        }catch{
            printLog("===== check UDP Reponse Error =====")
            
        }
    }
    func stopSearchGatway()  {
        printLog("===== stop Search Gatway =====")
        stopedSearchGateway = true
        udpSocket?.setDelegate(nil)
        udpSocket?.close()
        udpSocket = nil
        udpTimer?.invalidate()
        udpTimer = nil
    }
    
    // MARK: 链接本地网关
    func connectToLocalGetwayWithIPAddress(ip: String) {        
        tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do{
            printLog("start \(ip)")
            try self.tcpSocket?.connectToHost(ip, onPort: self.GateWayPort, withTimeout: 10)
        }catch{
            printLog("===== didconnectTo Local Getway Error =====")
        }
       
        
        currentConnectedGatewayIP = ip
        currentServerType = NetAdressInfo.GatewayType.rawValue
        
        tcpSocket!.readDataWithTimeout(-1, tag: 0)
        tcpTimer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                          target: self,
                                                          selector: #selector(NetWorkManage.checkTCPResponse),
                                                          userInfo: nil, repeats:
            true)
    }
    func checkTCPResponse(){
       tcpSocket!.readDataWithTimeout(-1, tag: 0)
    }
    
    // MARK: 连接服务器
    func connectToCloudServer(address: String?) {
        if savedCloudServerAddress == nil {
            let language = NSUserDefaults.standardUserDefaults().arrayForKey("AppleLanguages")?.first as! String
            savedCloudServerAddress = NetAdressInfo.EnglishCloudServerAddress.rawValue
            if language.containsString("zh-Han") {
                savedCloudServerAddress = NetAdressInfo.ChineseCloudServerAddress.rawValue
            }
        }
        var newip = savedCloudServerAddress
        if  address != nil{
            newip = address
        }
        
        tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do{
            printLog("start \(newip)")
            try self.tcpSocket?.connectToHost(newip!, onPort: self.CloudServerPort, withTimeout: 8)
        }catch{
            printLog("===== didconnectTo CloudServer Error =====")
        }
        currentServerType = NetAdressInfo.CloudServerType.rawValue
        
        tcpSocket!.readDataWithTimeout(-1, tag: 0)
        tcpTimer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                          target: self,
                                                          selector: #selector(NetWorkManage.checkTCPResponse),
                                                          userInfo: nil, repeats:
            true)
        
    }
    func stopConnectToCloud()  {
        printLog("===== stop ConnectTo CloudServer =====")
        tcpSocket?.delegate = nil
        tcpSocket?.disconnect()
        tcpSocket = nil
        tcpTimer?.invalidate()
        tcpTimer = nil
    }
    
    // MARK: - GCDAsyncUdpSocketDelegate
    func udpSocket(sock: GCDAsyncUdpSocket, didReceiveData data: NSData, fromAddress address: NSData, withFilterContext filterContext: AnyObject?) {
        printLog("===== didReceive UDP Reponse =====")
        guard let arr = self.parserGetwayIPAddress(data) where arr.count != 0 else{ return }
       
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationNameStr.DidDiscoveryGateway.rawValue, object: nil)
       printLog("===== DidSearch Gateway End =====")
    }

    // MARK: GCDAsyncSocketDelegate
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16){
        guard sock == tcpSocket! else {return}
        
        if currentServerType == NetAdressInfo.GatewayType.rawValue {
            printLog("===== ConnectTo Gateway in Local=====")
            connectedWithGateway = true
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationNameStr.DidConnectedToGateway.rawValue, object: nil)
        }else if currentServerType == NetAdressInfo.CloudServerType.rawValue {
            printLog("===== ConnectTo Gateway in Cloud=====")
            connectedWithGateway = true
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationNameStr.DidConnectedToCloudServer.rawValue, object: nil)
        }
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError?){
        printLog("===== Disconnect Gateway =====\(err)")
    }
    
    func socket(sock: GCDAsyncSocket, didWriteDataWithTag tag: Int){
    
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int){
        printLog("===== onSocket didReadData =====:\n\n\(data)\n\n")
        self.parserReceivedData(data)
    }
    func parserReceivedData(data: NSData) {
        let count = data.length / sizeof(UInt8)
        var array = [UInt8](count: count, repeatedValue: 0)
        //赋值给array
        data.getBytes(&array, length:count * sizeof(UInt8))
        guard array[0] == PackageStart &&  array[1] == ResponseStart else {return}
        
        let CID:Int = Int(array[2] * 16) + Int(array[3])
        let Len:Int = Int(array[4] * 16) + Int(array[5])
        let ListLen:Int = Int(array[6] * 16) + Int(array[7])
        // 除去前面8位 后3位
        let dealdata = array[Range(8..<count - 3)]
        var result : Array = Array(dealdata)
        
        switch CID {
        case NetCID.CredentialAskCID.rawValue:
            self.credentialDealData(result, len: Len, listlen: ListLen)
        case NetCID.BindEmailCredentialCID.rawValue:
            self.CheckEmailCredentialDealData(result, len: Len, listlen: ListLen)
        case NetCID.SendPhoneInfoCID.rawValue:
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationNameStr.BindedPhone.rawValue, object: nil)
        case CloudCid.CheckEmailCredentialCID.rawValue:
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationNameStr.CheckCredentialWhenCloud.rawValue, object: nil)
        default:
            break
        }
        
    }
    
    
    func sendCommandToGateway(cID: Int,len: Int, listLen: Int8, pData: [UInt8]? )  {
        var nWriteBytes = 0
        var bytes = [UInt8]()
        bytes.append(PackageStart)
        bytes.append(RequestStart)
        bytes.append(UInt8(cID / 256))
        bytes.append(UInt8(cID % 256))
        bytes.append(UInt8(len / 256))
        bytes.append(UInt8(len % 256))
        bytes.append(0)
        bytes.append(UInt8(listLen))
        //前8位 头
        nWriteBytes = nWriteBytes + 8
        
        var FCS = bytes[2] ^ bytes[3]
        for var i in 4..<nWriteBytes {
            FCS = FCS ^ bytes[i]
        }
        if !(pData == nil) { 
            bytes = bytes + pData!
           nWriteBytes = nWriteBytes + pData!.count
            for var i in 0..<pData!.count {
                FCS = FCS ^ pData![i]
            }
        }
        //1位 校验码
        bytes.append(FCS)
        //2位 尾巴
        bytes.append(0)
        bytes.append(PackageEnd)
        nWriteBytes = nWriteBytes + 3
        
        let data2 = NSData(bytes: &bytes,length: nWriteBytes * sizeof(UInt8))
        tcpSocket?.writeData(data2, withTimeout: -1, tag: 0)
        printLog("=====onSocket writeData=====:\n\n\(data2)\n\n")
        
    }
    
    // MARK: - 从网关获取凭证 （网关 跟 凭证 一一对应）
    func credentialAsk()  {
        self.sendCommandToGateway(NetCID.CredentialAskCID.rawValue, len: 0, listLen: 0x00, pData: nil)
    }
    func credentialDealData(data: [UInt8], len: Int, listlen: Int) {
        guard len > 0 else {return}
        
        let credentialData = NSData(bytes: data, length: 12)
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationNameStr.DidDealCredential.rawValue, object: credentialData)
        printLog("=====Send credential Noti=====")
    }
    
    // MARK: 绑定(验证)邮箱
    func checkUserCredential(emailData: NSData, passWData: NSData ,gatwayCredential: NSData?){
        
        let count1 = emailData.length / sizeof(UInt8)
        var array1 = [UInt8](count: count1, repeatedValue: 0)
        emailData.getBytes(&array1, length:count1 * sizeof(UInt8))
        let count2 = passWData.length / sizeof(UInt8)
        var array2 = [UInt8](count: count2, repeatedValue: 0)
        passWData.getBytes(&array2, length:count2 * sizeof(UInt8))
        if currentServerType == NetAdressInfo.CloudServerType.rawValue {
            let count3 = gatwayCredential!.length / sizeof(UInt8)
            var array3 = [UInt8](count: count3, repeatedValue: 0)
            passWData.getBytes(&array3, length:count3 * sizeof(UInt8))
            self.sendCommandToGateway(CloudCid.CheckEmailCredentialCID.rawValue, len: 82, listLen: 0x00, pData: array1+array2+array3)
        }else{
            self.sendCommandToGateway(NetCID.BindEmailCredentialCID.rawValue, len: 70, listLen: 0x00, pData: array1+array2)
        }
    }
    func CheckEmailCredentialDealData(data: [UInt8], len: Int, listlen: Int)  {
        guard len > 0 else {return}

        printLog("===== Bind Email Credential =====")
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationNameStr.BindEmailCredential.rawValue, object: nil)
    }
    
    // MARK: 发送手机信息
    func sendPhoneInfo()  {
        //ios 0x01  android 0x02    windowsPhone 0x03   blackberry 0x04
        let ostype: UInt8 = 0x01
        //OS Version
        var osVersion: UInt8 = 0
        let arr = UIDevice.currentDevice().systemVersion.componentsSeparatedByString(".") 
        if arr.count >= 2 {
            osVersion = UInt8(arr[0])! * 16 + UInt8(arr[1])!
        }
         //en:英文  zh-Hans:简体中文   zh-Hant:繁体中文    ja:日本  ......
        let language = NSUserDefaults.standardUserDefaults().arrayForKey("AppleLanguages")?.first as! String
        var oslanguage: UInt8 = 0x01
        savedCloudServerAddress = NetAdressInfo.EnglishCloudServerAddress.rawValue
        if language.containsString("zh-Han") {
            oslanguage = 0x02
            savedCloudServerAddress = NetAdressInfo.ChineseCloudServerAddress.rawValue
        }
        
        self.sendCommandToGateway(NetCID.SendPhoneInfoCID.rawValue, len: 4, listLen: 0x00, pData: [ostype,osVersion,oslanguage,0x00])
    }
    
    // MARK: 发送 Token 给 云
    func sendDeviceToken(){
        let count = savedDeviceTokenData!.length / sizeof(UInt8)
        var array = [UInt8](count: count, repeatedValue: 0)
        savedDeviceTokenData!.getBytes(&array, length:count * sizeof(UInt8))
        let arra1 = [UInt8](count: 8, repeatedValue: 0xff)
        self.sendCommandToGateway(CloudCid.SendDeviceTokenCID.rawValue, len: 32 + 8, listLen: 0, pData: array + arra1)
    }
    
    // MARK: - 解析ip
    func parserGetwayIPAddress(data: NSData) -> [String]? {
        printLog(data.description)
        
        let count = data.length / sizeof(UInt8)
        var array = [UInt8](count: count, repeatedValue: 0)
        //赋值给array
        data.getBytes(&array, length:count * sizeof(UInt8))
        //前8位 头 , 后3位，1校验码，2尾巴 ，中间 4 位IP
        let iparr = array[Range(9..<12)]
        
        let gatwayIP = String(array[8]) + iparr.reduce("") { String($0) + "." + String($1)}
        print(gatwayIP)
        
        guard array[0] == PackageStart && array[1] == ResponseStart else { return nil}
        
        guard Int(array[2]*16) + Int(array[3]) ==  NetCID.GatewayCID.rawValue  else{ return nil}
        
        guard array[6]*16 + array[7] == 0x00 else{
            if allSearchGatwayArr.count != 0 {
                return allSearchGatwayArr
            }
            return nil
        }
        guard !allSearchGatwayArr.contains(gatwayIP) else{ return allSearchGatwayArr}
        
        allSearchGatwayArr.append(gatwayIP)
        return allSearchGatwayArr
        
        
    }
    
    
}
