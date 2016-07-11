//
//  PLAppDelegate.h
//  PilotLaboratories
//
//  Created by frontier on 14-3-20.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLUpDateView.h"
@interface PLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//打开的门
@property(strong,nonatomic)NSMutableArray *DoorArray;
//查询到的switch
@property(strong,nonatomic)NSMutableArray *SwitchArray;
//当前版本是否更新标识符
@property(assign,nonatomic)BOOL VerIdentifier;
//网关当前版本号
@property(strong,nonatomic)NSString* VersionGWNumber;
//服务器可更新版本号
@property(strong,nonatomic)NSString *VersionClundNumber;
@property (assign, nonatomic) BOOL isTheFirstStart;
@property(assign,nonatomic) double PageNumb;
@property(assign,nonatomic) double TotalPageNumb;
@property(assign ,nonatomic)BOOL  isformbackground;
@property(assign ,nonatomic)BOOL  ishowbagevalue;
@property(strong ,nonatomic)NSData  *gatwaycretail;
@property(copy ,nonatomic)NSString  *helperpath;
@property(assign,nonatomic)BOOL ishowbagevalued;

@property(copy ,nonatomic)NSString  *texttuisong;
@property(copy ,nonatomic)NSMutableDictionary  *NotifacationDict;

@property NSInteger cINdex;
@property(copy ,nonatomic)NSString  *cINdexName;
//移动网络控制网关情况下，判断是否已经发送过验证）（开启软件会发一次，判断是否可以控制网关，检测新版本又会发一次），避免多次发送
@property(assign,nonatomic)BOOL ISsendUserCredential;

+(PLAppDelegate *)GlobalAppDelagate;
@end
