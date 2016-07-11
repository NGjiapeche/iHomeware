//
//  PLAppDelegate.m
//  PilotLaboratories
//
//  Created by frontier on 14-3-20.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLAppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@implementation PLAppDelegate 

static SystemSoundID shake_sound_male_id = 0;
-(void) playSound
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Police_Siren" ofType:@"wav"];
    if (path) {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
        //        AudioServicesPlaySystemSound(shake_sound_male_id);//如果无法再下面播放，可以尝试在此播放
    }
    
    AudioServicesPlaySystemSound(shake_sound_male_id);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   //让手机震动
}
//版本更新信息
-(void)GWVersionInfo{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tempDict = [userDefaults objectForKey:@"VersionInfo"];
    NSMutableDictionary *VersioninfoDict;
    
    if (!tempDict)
    {
        VersioninfoDict = [NSMutableDictionary dictionary];
        self.VerIdentifier  = NO;
        self.VersionGWNumber =[NSString stringWithFormat:@"0.0"];
        self.VersionClundNumber = [NSString stringWithFormat:@"0.0"];
        [VersioninfoDict setObject:[NSString stringWithFormat:@"0.0"] forKey:@"VerIdentifier"];
        [VersioninfoDict setObject:self.VersionGWNumber forKey:@"VersionGWNumber"];
         [VersioninfoDict setObject:self.VersionClundNumber forKey:@"VersionCdNumber"];
    }
    else
    {
        VersioninfoDict = [NSMutableDictionary dictionaryWithDictionary:tempDict];
    }
    [userDefaults setObject:VersioninfoDict forKey:@"VersionInfo"];
    [userDefaults synchronize];
}
//更新对话框

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //com.pilot.PilotLaboratories
    //com.cking.PilotLaboratories
    //开启监测网络
    [[PLNetworkManager sharedManager] startCheckNetWork];
    
    //copy数据库到沙盒
    [[PLDatabaseManager sharedManager] copyNeededResourceToResourcePath];
    
    //标记App刚刚启动
    [[PLSceneManager sharedManager] setAppLaunch:YES];
  
    [self GWVersionInfo];

    [self registerForRemoteNotification];

    //推送打开应用
    if (launchOptions)
    {
        DebugLog(@"\n\n\n==============================ApplicationStartFromRemoteNotification:\n\n%@",launchOptions);
        
        NSDictionary *launchDic = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (launchDic)
        {
            [application setApplicationIconBadgeNumber:0];
            self.NotifacationDict = [NSMutableDictionary dictionaryWithDictionary:launchDic];
//            [self parserRemoteNotificationMessage:launchDic];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(CANsendRemoteressage:)
                                                         name:@"PLSensorAndAlertVCLoaded"
                                                       object:nil];
        
        }
    }
    
    [application setApplicationIconBadgeNumber:0];
    self.DoorArray = [NSMutableArray array];
    self.SwitchArray = [NSMutableArray array];
    return YES;
}
-(void)CANsendRemoteressage:(NSNotification *)noti{
     [self parserRemoteNotificationMessage:self.NotifacationDict];

}
-(void)OnNewThread{

}
-(void)delLocationNotification:(NSString *)userInfoKey userInfoValue:(NSString *)userInfoValue{
    
}
- (void)registerForRemoteNotification
{
    //消息推送支持的类型
    if (iOS8)
    {
#ifdef __IPHONE_8_0
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
        UIUserNotificationType types = (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
        UIUserNotificationSettings *notifiSetting = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notifiSetting];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
#endif
    }
    else
    {
        UIRemoteNotificationType types = (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
}

//获取DeviceToken成功，iOS8.0以下
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *tempStr = [NSString stringWithFormat:@"%@",deviceToken];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSString *tokenStr = [tempStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    DebugLog(@"\n\n\n==============================GotDeviceToken:\n\n%@\n\n",tokenStr);
    //存储token
    [[PLNetworkManager sharedManager] saveDeviceTocken:deviceToken];
}

//注册消息推送失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DebugLog(@"\n\n\n==============================Register Remote Notifications error:\n\n%@",[error localizedDescription]);
}

//处理收到的消息推送
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    DebugLog(@"\n\n\n==============================收到推送Receive remote notification:\n\n%@",userInfo);
    [application setApplicationIconBadgeNumber:0];
    [self parserRemoteNotificationMessage:userInfo];
}

- (void)parserRemoteNotificationMessage:(NSDictionary *)messageDic
{
    DebugLog(@"\n\n\n==============================解析推送ParserRemoteNotificationMessage:\n\n%@",messageDic);
    NSDictionary *tempDic = messageDic[@"aps"];
    NSString *xinxi = [NSString stringWithFormat:@"%@",tempDic[@"alert"]];
    
    NSLog(@"xinxi'=====%@",xinxi);
    if (tempDic)
    {
        NSArray *alertInfoArr = tempDic[@"alertInfo"];
        
        if (alertInfoArr.count >= 13)
        {
            PLModel_Device *device = [PLModel_Device new];
            NSString *firstShortAddr = alertInfoArr[0];
            NSString *secondShortAddr = alertInfoArr[1];
            NSString *deviceType = alertInfoArr[2];
            NSString *firstSensorStatus = alertInfoArr[3];
            NSString *secondSensorStatus = alertInfoArr[4];
            char macAddress[8];
            for (int i = 0; i < 8; i++)
            {
                NSString *tempStr = alertInfoArr[i + 5];
                macAddress[i] = (tempStr.intValue + 256) % 256;
            }
            device.firstShortAddr = firstShortAddr.intValue;
            device.secondShortAddr = secondShortAddr.intValue;
            device.deviceType = deviceType.intValue;
           
            device.firstSensorStatus = firstSensorStatus.intValue;
            device.secondSensorStatus = secondSensorStatus.intValue;
            device.macAddress = [NSData dataWithBytes:macAddress length:8];
            device.isAlerting = YES;
//            self.texttuisong = [NSString stringWithFormat:@"%@ || %@ || %@ || %@",deviceType,device.macAddress,firstSensorStatus,secondSensorStatus];
            [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveAlarmInform object:device];
        }
    }
}
+(PLAppDelegate *)GlobalAppDelagate{
    return (PLAppDelegate *)[UIApplication sharedApplication].delegate;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    
    DebugLog(@"________________applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    _isformbackground = YES;
    DebugLog(@"________________applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
        DebugLog(@"________________applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
      DebugLog(@"________________applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
