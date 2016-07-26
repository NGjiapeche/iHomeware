//
//  AppDelegate.swift
//  iHomewre_swift
//
//  Created by mac on 16/7/8.
//  Copyright © 2016年 mac. All rights reserved.
//

import UIKit

var savedDeviceTokenData: NSData? {
    set{
        print(" 保存 token ")
        NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "savedDeviceTokenStr")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    get{
        return NSUserDefaults.standardUserDefaults().objectForKey("savedDeviceTokenStr") as! NSData?
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static func GlobalAppDelagate() -> AppDelegate{
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let types = UIUserNotificationType.Alert.rawValue | UIUserNotificationType.Sound.rawValue | UIUserNotificationType.Badge.rawValue
        let setting = UIUserNotificationSettings(forTypes: UIUserNotificationType(rawValue: types), categories: nil)
        application.registerUserNotificationSettings(setting)
        application.registerForRemoteNotifications()
        
        
        return true
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var temstr = deviceToken.description
        temstr.removeAtIndex(temstr.startIndex)
        temstr.removeAtIndex(temstr.endIndex)
        
        savedDeviceTokenData = deviceToken
        printLog("\n==============================GotDeviceToken: \(temstr) \n")
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        printLog("\n=========================Fail RemoteNotifications Error: \(error.localizedDescription) \n")
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("收到推送 \(userInfo)")
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillResignActive(application: UIApplication) {
      
    }

    func applicationDidEnterBackground(application: UIApplication) {
       
    }

    func applicationWillEnterForeground(application: UIApplication) {
       
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    func applicationWillTerminate(application: UIApplication) {
        
    }


}

