//
//  RootVC.swift
//  iHomewre_swift
//
//  Created by mac on 16/7/8.
//  Copyright © 2016年 mac. All rights reserved.
//

import UIKit
//连接服务器  ，依次发送 指令 203(check email ) ，204(send token )

let headV:LogoView? = NSBundle.mainBundle().loadNibNamed("LogoView", owner: nil, options: nil)[0] as? LogoView


class RootVC: UITabBarController,UITabBarControllerDelegate {

    func senndTokenEveryTime()  {
        guard NetWorkManage.sharedInstance.tcpSocket != nil else{
            NetWorkManage.sharedInstance.connectToCloudServer(nil)
            return
        }
        guard currentCredentialdata != nil && savedDeviceTokenData != nil else {return}
        
        NetWorkManage.sharedInstance.sendDeviceToken()
    }
    override func viewWillAppear(animated: Bool) {
        print("root view viewWillAppear")
        
    // 当前是本地连接，启动一个socket 连接云
        NSNotificationCenter.defaultCenter().addObserverForName(NotificationNameStr.DidConnectedToCloudServer.rawValue,
                                                                object: nil,
                                                                queue: NSOperationQueue.mainQueue()) {_ in
                                                                    print("rootvc 连接云 成功")
                                                                    NetWorkManage.sharedInstance.checkUserCredential(savedEmailCredentialInfos!.first!, passWData: savedEmailCredentialInfos!.last!, gatwayCredential: currentCredentialdata!)
                                                                   
        }
        //验证Credential 成功，发送 token
        NSNotificationCenter.defaultCenter().addObserverForName(NotificationNameStr.CheckCredentialWhenCloud.rawValue,
                                                                object: nil,
                                                                queue: NSOperationQueue.mainQueue()) {_ in
                                                                    NetWorkManage.sharedInstance.sendDeviceToken()

        }
        
        self.senndTokenEveryTime()
    }
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
        headV!.frame = CGRect(x: 0,y: 20,width: MAXW,height: 47)
        view.addSubview(headV!)
        self.delegate = self
        
        let switchVc = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("switchVc")
        let lightRvc = UIStoryboard.init(name: "Light", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
        let securityRvc = UIStoryboard.init(name: "Security", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
        let settingRvc = UIStoryboard.init(name: "Setting", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
        let item0 = UITabBarItem.init(title: "照明", image: UIImage(named:"itemLighting" ), tag: 0)
        let item1 = UITabBarItem.init(title: "安防", image: UIImage(named:"itemSensor" ), tag: 1)
        let item2 = UITabBarItem.init(title: "开关", image: UIImage(named:"itemSwitch" ), tag: 2)
        let item3 = UITabBarItem.init(title: "设置", image: UIImage(named:"itemSetting" ), tag: 3)
        lightRvc!.tabBarItem = item0
        securityRvc!.tabBarItem = item1
        switchVc.tabBarItem = item2
        settingRvc!.tabBarItem = item3

        self.viewControllers = [lightRvc!,securityRvc!,switchVc,settingRvc!];
 
    }

    
  
   
    internal func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool{
        switch Int( (self.viewControllers?.indexOf(viewController))! ) {
        case 0:
            self.tabBar.tintColor = ColorRGB(0, 122, 255)
        case 1:
            self.tabBar.tintColor = ColorRGB(255, 76, 76)
        case 2:
            self.tabBar.tintColor = ColorRGB(36, 209, 66)
        case 3:
            self.tabBar.tintColor = ColorRGB(205, 51, 255)
        default:
            break
        }
        return true
    }


}
