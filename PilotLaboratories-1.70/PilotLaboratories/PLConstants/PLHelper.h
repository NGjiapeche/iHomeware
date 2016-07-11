//
//  PLHelper.h
//  PilotLaboratories
//
//  Created by frontier on 14-3-26.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#ifndef PilotLaboratories_PLHelper_h
#define PilotLaboratories_PLHelper_h

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_IPHONE4 (([[UIScreen mainScreen] bounds].size.height-480)?NO:YES)
#define iOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define COLOR_RGB(R,G,B) \
[UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1]

#define itemLightColor \
[UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1]

#define itemSenorColor \
[UIColor colorWithRed:255/255.0f green:76/255.0f blue:76/255.0f alpha:1]

#define itemSwitchColor \
[UIColor colorWithRed:36/255.0f green:209/255.0f blue:66/255.0f alpha:1]

#define itemSettingColor \
[UIColor colorWithRed:205/255.0f green:51/255.0f blue:255/255.0f alpha:1]


// 已经连接wifi的数量
#define connectedWifiArrCount \
[[[PLNetworkManager sharedManager] connectedWifiArr] count]

//单利简单调用
#define PLSHARE(Property)\
[[PLNetworkManager sharedManager] connectedWifiArr]

//已经存储wifiname
#define arrExistedConnectWifiName \
[[PLNetworkManager sharedManager] connectedWifiArr]

//当前连接wifiname
#define CurrentConnectWifiName \
[[PLNetworkManager sharedManager] currentConnectWifiName]

//连接网关所发现的所有网关
#define AllGatwayFound \
[[PLNetworkManager sharedManager] allGatewayArr]

#define HideHUD \
[MBProgressHUD hideHUDForView:self.view animated:YES];
#define ShowHUD \
if ([[PLNetworkManager sharedManager] currentServerType] != 1) {\
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];\
}



/**
 *  设置字体大小
 */
#define fontCustom(sizeFont) [UIFont fontWithName:@"CenturyGothic" size:sizeFont];

#define UserDefaults [NSUserDefaults standardUserDefaults]

#define yct_initNav(isSHowLeftBtn,isSHowRightBtn,isMiddleBtn,title,leftTitle,rightTitle,middleTitle,leftImage,rightImage,middleImage)\
self.isLeft = !isSHowLeftBtn;\
self.isRight = !isSHowRightBtn;\
self.isMiddle =! isMiddleBtn;\
self.strTitle = title;\
self.strLeftTitle = leftTitle;\
self.strRightTitle = rightTitle;\
self.strMiddleTitle = middleTitle;\
self.strLeftImage = leftImage;\
self.strRightImage = rightImage;\
self.strMiddleImage = middleImage;


#define MainScreenHeight                [UIScreen mainScreen].bounds.size.height
#define MainScreenWidth                 [UIScreen mainScreen].bounds.size.width


#endif
