//
//  PLStartVC.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-4-25.
//  Copyright (c) 2014年 yct. All rights reserved.
/*************************************************
 1.如果是第一次启动app：
 （1）搜索网关：[self startSearchGateway];
 （2）成功走：通知didGotGetway ；失败走：judgeTimeOutSearChGateway
 （3）成功获取网关后 (存 wifiname 和 网关 IP )；点击连接 进行连接网关 ”需要点击“ 走 - (void)btnConnectGatewaPressed
 （4）成功连接将接收消息通知 DidConnectedToGateway，填写邮件地址即用户名，随即产生密码，储存在本地，发送到后台，跳转到tabbar （连接服务器  ，依次发送 指令 203 ，204，205）
 （5）连接网关失败，会弹出alter提示取消或者重连：方法- (void)startConnectGateway 里面else（ connectedGatewayArrCount == 0 ）
 2.假如不是第一次启动：
 （1）先判断手机有没有连接wifi
（2.1）如果连接上wifi，判断自wifi下是否保存过网关，如果没有 就是搜寻，发送checkUserCredential 连接，1，（搜索不到提示 搜不到）2，（连接上了是本地连接,(存 wifiname 和 网关 IP )）
（2.2）如果连接上wifi，判断自wifi下是否保存过网关，如果有 就是搜寻，发送checkUserCredential 连接，1，（搜索不到提示 搜不到）2，（连接上了是本地连接）
 
（2.3）如果连接上wifi，判断自wifi下是否保存过网关，（如保存多个网关，选一个连接）如果没有走服务器连接（连接服务器  ，依次发送 指令 203 ，204，205）
    4）先判断手机有没有连接wifi，如果没连wifi，直接服务器连接（如保存多个网关，选一个连接）如果没有走服务器连接（连接服务器  ，依次发送 指令 203 ，204，205）
 ***************************************************/


#import "PLStartVC.h"
#import "PLConnectGatewayView.h"
#import "PLEmailProvideView.h"
#import "PLNoFoundWarningView.h"
#import "PLMutipleGatewaysView.h"
#import "PLUnConnectCloudSeverView.h"
#import "PLUserInfoManager.h"
#import "PLNotiAndAlerts.h"
#import "PLAppDelegate.h"
#define BothConnect @"continue"
#define DisableOne  @"disable"

@interface PLStartVC ()<PLConnectGatewayViewDelegate,
PLEmailProvideViewDelegate,
PLNoFoundWarningViewDelegate,
PLMutipleGatewaysViewDelegate,
PLUnConnectCloudSeverViewDelegate,
PLNotiAndAlertsDelegate>
{
    id didGotGetway;
    id didConnectedToGetway;
    id didConnectColoudServer;
    id didGotGatewayNum;
    id didGotCredential;
}

@property (strong, nonatomic) PLConnectGatewayView *connectGatewayV;
@property (strong, nonatomic) PLEmailProvideView *emailProvideV;
@property (strong, nonatomic) PLNoFoundWarningView *noFoundWaringV;
@property (strong, nonatomic) PLMutipleGatewaysView *mutipleGatewaysV;
@property (strong, nonatomic) PLUnConnectCloudSeverView *unConnectCloudSeverV;
@property (strong, nonatomic) NSString *strIP;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) int iConnectGatewayTimes;
@property (assign, nonatomic) int gatewayNum;
@property (assign, nonatomic) BOOL isTheFirstStart;
@property (strong, nonatomic) NSString *strIPExsit;
@property (assign, nonatomic) BOOL isConnectToCloudServer;
@property (assign, nonatomic) BOOL isConnectColoudserver;
@property (assign, nonatomic) BOOL isDidDiscoveryDevice;

@property (assign, nonatomic) BOOL isDidFoundGateway;//判断是否搜索到网关
@property (assign, nonatomic) CGRect frameRect;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewBg;

@property (strong, nonatomic) NSString *strRemberPsw; //从gateway获取到的密码

@property (strong, nonatomic) NSData *dataPsw;
@property(strong,nonatomic)PLAppDelegate *APP;
@property(assign,nonatomic)BOOL isCanask;
@property(assign,nonatomic)BOOL isfirstdiddiscover;//连接服务器第一次查询设备检测是否有数据返回判断是否可以控制网关
@end

@implementation PLStartVC

- (void)viewWillAppear:(BOOL)animated
{
  
    ShowHUD;
    [self performSelector:@selector(judgeTimeOut) withObject:nil afterDelay:2.f];
    
    
//    //[[PLSceneManager sharedManager] setShouldSyncScene:YES];
//    [[PLNetworkManager sharedManager] startTestModel];
//    [self performSelector:@selector(startHomeware) withObject:nil afterDelay:2.f];
}

- (void)judgeTimeOut
{
    HideHUD;
    NSString *str = [[PLUserInfoManager sharedManager] userCredentialStr];
    if (!str.length)
    {
        self.isTheFirstStart = YES;
    }
    else
    {
        self.isTheFirstStart = NO;
    }
    
    //判断是不是第一次启动app 并且曾经连接上过网关
    if (self.isTheFirstStart)
    {
        DebugLog(@"app 第一次启动");
        //开始搜索网关
        ShowHUD;
        [self startSearchGateway];
    }
    else
    {
        DebugLog(@"app 不是第一次启动");
        NetworkStatus networkStatus = [[PLNetworkManager sharedManager] currentNetworkStatus];
        DebugLog(@"networkStatus:%ld",(long)networkStatus);
        if (networkStatus != ReachableViaWiFi)
        {
            DebugLog(@"连接WiFi失败启动服务器连接");
            //连接wifi失败
            self.isConnectColoudserver = YES;
            ShowHUD;
            [self performSelector:@selector(judgeTimeOutConnectCloudserver)
                       withObject:nil
                       afterDelay:8.f];
            
            //连接coloudserver
            [[PLNetworkManager sharedManager] connectToCloudServer];
        }
        else
        {
            DebugLog(@"连接WiFi成功");
            ShowHUD;
            [self startSearchGateway];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.connectGatewayV = [[PLConnectGatewayView alloc] init];
    self.emailProvideV = [[PLEmailProvideView alloc] init];
    _noFoundWaringV = [[PLNoFoundWarningView alloc] init];
    self.unConnectCloudSeverV = [[PLUnConnectCloudSeverView alloc] init];
    
    self.iConnectGatewayTimes = 0;
    self.isConnectToCloudServer = NO;
    self.isConnectColoudserver = NO;
    
    self.isDidFoundGateway = NO;
    self.strIPExsit = nil;
    self.frameRect = self.view.frame;
    
    if (IS_IPHONE5)
    {
        self.connectGatewayV.frame = CGRectMake(20, 315, 280, 200);
        self.emailProvideV.frame = CGRectMake(20, 315, 280, 200);
        self.noFoundWaringV.frame = CGRectMake(20,295,280,240);
        self.unConnectCloudSeverV.frame = CGRectMake(20, 275, 280, 280);
    }
    else
    {
        self.imageViewBg.image = [UIImage imageNamed:@"Default.png"];
        self.connectGatewayV.frame = CGRectMake(20, 270, 280, 200);
        self.emailProvideV.frame = CGRectMake(20, 275, 280, 200);
        self.noFoundWaringV.frame = CGRectMake(20,250,280,240);
        self.unConnectCloudSeverV.frame = CGRectMake(20, 230, 280, 280);
    }

    self.connectGatewayV.delegate =self;
    [self.view addSubview:self.connectGatewayV];

    self.emailProvideV.delegate = self;
    [self.view addSubview:self.emailProvideV];

    self.noFoundWaringV.delegate = self;
    [self.view addSubview:_noFoundWaringV];

    self.unConnectCloudSeverV.delegate = self;
    [self.view addSubview:self.unConnectCloudSeverV];
    
    self.noFoundWaringV.hidden = YES;
    self.connectGatewayV.hidden = YES;
    self.emailProvideV.hidden = YES;
    self.unConnectCloudSeverV.hidden = YES;
    
    //对键盘的处理
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock: ^(NSNotification *note)
     {
         [UIView animateWithDuration:.25 animations:^
          {
              // 上移刷新UI
              self.view.frame = CGRectMake(self.frameRect.origin.x,
                                           self.frameRect.origin.y - 160,
                                           self.frameRect.size.width,
                                           self.frameRect.size.height);
          }];
         
     }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock: ^(NSNotification *note)
     {
         [UIView animateWithDuration:.25 animations:^
          {
              // 下移刷新UI
              self.view.frame = self.frameRect;
          }];
     }];
    
    //搜索到网关成功的信息
    didGotGetway =[[NSNotificationCenter defaultCenter] addObserverForName:DidDiscoveryGateway
                                                                    object:nil
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification *note) {
                                                                    NSLog(@"搜索网关成功！！！！！！！！");
                                                                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(judgeTimeOutSearChGateway) object:nil];
                                                                    if (self.isTheFirstStart && !self.isDidFoundGateway)
                                                                    {
                                                                        HideHUD;
                                                                        DebugLog(@"第一次启动弹出点击链接网关提示");
                                                                        self.connectGatewayV.hidden = NO;
                                                                        self.isDidFoundGateway = YES;
                                                                    }
                                                                    else if(!self.isTheFirstStart &&!self.isDidFoundGateway)
                                                                    {
                                                                        HideHUD;
                                                                        self.isDidFoundGateway = YES;
                                                                        
                                                                        //判断是否连接上网关
                                                                        BOOL isDidConnectGateway = [[PLNetworkManager sharedManager] connectedWithGateway];
                                                                        if (isDidConnectGateway)
                                                                        {
                                                                            return ;
                                                                          
                                                                        }
                                                                        else
                                                                        {
                                                                      
                                                                            //连接上要判断wifiName 在不在以前存储的列表中
                                                                            NSString *strCurrentWifiName = [[PLNetworkManager sharedManager] currentConnectWifiName];
                                                                            NSArray *arrAllWifiNameConnected = [[PLNetworkManager sharedManager] connectedWifiArr];
                                                                            BOOL isExsit = [arrAllWifiNameConnected containsObject:strCurrentWifiName];
                                                                            if (isExsit)
                                                                            {
                                                                                self.strIPExsit = AllGatwayFound[0];
                                                                                ShowHUD;
                                                                                [self connectGatewayAgain];
                                                                            }
                                                                            else
                                                                            {
                                                                               
                                                                                self.connectGatewayV.hidden = NO;
                                                                                  DebugLog(@"链接新的wifi弹出点击链接网关提示");
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                } ];
    //连接网关成功
    didConnectedToGetway = [[NSNotificationCenter defaultCenter] addObserverForName:DidConnectedToGateway
                                                                             object:nil
                                                                              queue:[NSOperationQueue mainQueue]
                                                                         usingBlock:^(NSNotification *note) {
                                                                         
                                                                             [self.timer invalidate];
                                                                             [self setTimer:nil];
                                                                             self.connectGatewayV.hidden = YES;
                                                                             //停止搜索网关
                                                                             [[PLNetworkManager sharedManager] stopDiscoveryGetway];
                                                                             //保存wifi信息
                                                                             [[PLNetworkManager sharedManager] saveWifiNameAndGateWayIPAddress];
                                                                             //从网关获取凭证
                                                                             DebugLog(@"验证能否连接");
                                                                             [[PLNetworkManager sharedManager] credentialAsk];
                                                                             [self performSelector:@selector(checkCantalk) withObject:nil afterDelay:3.0f];
                                                                             
                                                                         }];
    
    
    //DidGetCredential
    didGotCredential = [[NSNotificationCenter defaultCenter] addObserverForName:DidGetCredential
                                                                         object:nil
                                                                          queue:[NSOperationQueue mainQueue]
                                                                     usingBlock:^(NSNotification *note) {
                                                                    
                                                                         _isCanask = YES;
                                                                         NSData *data = note.object;
                                                                         [[PLNetworkManager sharedManager]setGatewayCredential:data];
                                                                         PLAppDelegate *app = [[UIApplication sharedApplication]delegate];
//                                                                         [app setGatwaycretail:data];
                                                                         app.gatwaycretail = [NSData dataWithData:data];
                                                                         if (self.isTheFirstStart)
                                                                         {
                                                                             HideHUD;
                                                                             self.emailProvideV.hidden = NO;
                                                                             self.isTheFirstStart = NO;
                                                                             NSUserDefaults *userdefalut = [NSUserDefaults standardUserDefaults];
                                                                             NSMutableArray *gatwayname = [NSMutableArray array];
                                                                             NSString *gatestr = @"Gateway0";
                                                                             [gatwayname insertObject:gatestr atIndex:gatwayname.count];
                                                                             [userdefalut setObject:gatwayname forKey:@"gatwangname"];
                                                                             [userdefalut synchronize];
                                                                             NSMutableArray *gatwayname1 = [userdefalut objectForKey:@"gatwangname"];
                                                                             DebugLog(@"存新网关的名字和凭证");
                                                                             [[PLNetworkManager sharedManager] saveGatewayCredential:data];
                                                                             //设置需要同步场景
                                                                             [[PLSceneManager sharedManager] setShouldSyncScene:YES];
                                                                         }
                                                                         else
                                                                         {
                                                                       
                                                                             HideHUD;
                                                                             /**
                                                                              *  判断连接的是不是新的gateway
                                                                              1.先获取到所有连接过的网关的Credential
                                                                              2.便利看时候已经连接过
                                                                              */
                                                                             NSMutableArray *mutArrExistCredential = [[PLNetworkManager sharedManager] gatewayCredentialArr];

                                                                             if ([mutArrExistCredential containsObject:data])
                                                                             {
                                                                                
                                                                                 app.cINdex =[mutArrExistCredential indexOfObject:data];
                                                                                 DebugLog(@"当前有几个网关%lu",(unsigned long)mutArrExistCredential.count);
                                                                                 DebugLog(@"dang前是第%ld个网关",(long)app.cINdex);
                                                                                 //获取设备列表
                                                                                 [[PLNetworkManager sharedManager] startCheckDeviceList];
                                                                                 //存在
                                                                                 
                                                                                 NSString *str = [NSString stringWithFormat:@"%@",[[PLUserInfoManager sharedManager] userCredentialStr]];
                                                                                 
                                                                                 if ([str isEqualToString:@"(null)"])
                                                                                 {
                                                                                     
                                                                                 }
                                                                                 else
                                                                                 {
                                                                                    [self performSelector:@selector(startHomeware) withObject:nil afterDelay:1.0];
//                                                                                     [[PLNetworkManager sharedManager] performSelectorInBackground:@selector(creatSecondConnectToCloudServer) withObject:nil];
                                                                                     DebugLog(@"1是在主线程么%d",[NSThread isMainThread]);
                                                                                 }
                                                                                
                                                                                 self.iConnectGatewayTimes = 0;
                                                                             }
                                                                             else
                                                                             {
                                                                                 ShowHUD;
                                                                                 app.cINdex =mutArrExistCredential.count;
                                                                                  DebugLog(@"dang前是第%ld个网关",(long)app.cINdex);
                                                                                 DebugLog(@"存新网关的名字和凭证");
                                                                                 //不存在 保存credential   发送用户名密码
                                                                                 [[PLNetworkManager sharedManager] saveGatewayCredential:data];
                                                                                 NSUserDefaults *userdefalut = [NSUserDefaults standardUserDefaults];
                                                                                 NSMutableArray *gatwayname =[NSMutableArray arrayWithArray:[userdefalut objectForKey:@"gatwangname"]];
                                                                            
                                                                                 [gatwayname insertObject:[NSString stringWithFormat:@"Gateway%ld",(unsigned long)gatwayname.count] atIndex:gatwayname.count];
                                                                                 [userdefalut setObject:gatwayname forKey:@"gatwangname"];
                                                                                 [userdefalut synchronize];
                                                                                 NSMutableArray *gatwayname1 = [userdefalut objectForKey:@"gatwangname"];
                                                                               
                                                                        
                                                                                 //CheckUserName
                                                                                 [[PLNetworkManager sharedManager] checkUserCredential];
                                                                                 //设置需要同步场景
                                                                                 //[[PLSceneManager sharedManager] setShouldSyncScene:YES];
                                                                             }
                                                                         }
                                                                     }];
    //用户信息唯一
    [[NSNotificationCenter defaultCenter] addObserverForName:UserCredentialIsUnique
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      HideHUD;
                                                      ServerType type = [[PLNetworkManager sharedManager] currentServerType];
                                                      if (type == CloudServerType)
                                                      {
                                                          //发送deviceTocken给cloudserver
                                                          [[PLNetworkManager sharedManager] sendDeviceTokenToCloudServer];
                                                          self.gatewayNum = (int)[[[PLNetworkManager sharedManager] gatewayCredentialArr] count];
                                                          if (self.gatewayNum == 1)
                                                          {
                                                              [[PLNetworkManager sharedManager] gatewayChooseWithGatewayID:@"0"];
                                                              [[PLNetworkManager sharedManager] startCheckDeviceList];
                                                              [self performSelector:@selector(startHomeware) withObject:nil afterDelay:1.0];
                                                               [[PLNetworkManager sharedManager] performSelectorInBackground:@selector(creatSecondConnectToCloudServer) withObject:nil];
                                                              DebugLog(@"2是在主线程么%d",[NSThread isMainThread]);
                                                          }
                                                          else
                                                          {
                                                              _mutipleGatewaysV = [[PLMutipleGatewaysView alloc]
                                                                                   initWithFrame:CGRectMake(20,155,280,240)];
                                                              _mutipleGatewaysV.delegate = self;
                                                          
                                                              NSUserDefaults *userdefalut = [NSUserDefaults standardUserDefaults];
                                                              NSMutableArray *gatwayname = [userdefalut objectForKey:@"gatwangname"];
                                                              DebugLog(@"用户信息唯一gatwangname:%@",gatwayname);
                                                              _mutipleGatewaysV.mutArrGateway = gatwayname;
                                                              [self.view addSubview:_mutipleGatewaysV];
                                                              [self makeViewRoundWithView:_mutipleGatewaysV];
                                                              [_mutipleGatewaysV reloaddata];
                                                          }
                                                      }
                                                      else
                                                      {
                                                          //发送CellPhoneInfo
                                                          [[PLNetworkManager sharedManager] sendCellPhoneInfoToGateWay];
                                                             DebugLog(@"============每次都检测手机系统语言");
                                                      }
                                                  }];
    //用户信息已经存在
    [[NSNotificationCenter defaultCenter] addObserverForName:UserCredentialHasAlreadyExist
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      HideHUD;
                                                      DebugLog(@"服务器连接发送用户信息成功");
                                                      PLModel_CheckResult *result = note.object;
                                                      NSData *dataPsw = result.password;
                                                      
                                                      self.dataPsw = dataPsw;
                                                      
                                                      NSString *strPsw = [[NSString alloc] initWithData:dataPsw encoding:NSUTF8StringEncoding];
                                                      self.strRemberPsw = strPsw;
                                                      
                                                      CGRect frame = [UIScreen mainScreen].bounds;
                                                      PLNotiAndAlerts *alter = [PLNotiAndAlerts new];
                                                      alter.frame = frame;
                                                      alter.arrGateways = @[BothConnect,DisableOne];
                                                      alter.delegate =self;
                                                      [alter show];
                                                  }];
    
    //发送UserCredentialGM给网关成功
    [[NSNotificationCenter defaultCenter] addObserverForName:DidSendUserCredentialGM
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      HideHUD;
                                                      ServerType type = [[PLNetworkManager sharedManager] currentServerType];
                                                      if (type == CloudServerType)
                                                      {
                                                          //发送deviceTocken给cloudserver
                                                          [[PLNetworkManager sharedManager] sendDeviceTokenToCloudServer];
                                                          self.gatewayNum = (int)[[[PLNetworkManager sharedManager] gatewayCredentialArr] count];
                                                          if (self.gatewayNum == 1)
                                                          {
                                                              [[PLNetworkManager sharedManager] gatewayChooseWithGatewayID:@"0"];
                                                              [[PLNetworkManager sharedManager] startCheckDeviceList];
                                                              [self performSelector:@selector(startHomeware) withObject:nil afterDelay:1.0];
                                                               [[PLNetworkManager sharedManager] performSelectorInBackground:@selector(creatSecondConnectToCloudServer) withObject:nil];
                                                     DebugLog(@"3是在主线程么%d",[NSThread isMainThread]);
                                                          }
                                                          else
                                                          {
                                                              _mutipleGatewaysV = [[PLMutipleGatewaysView alloc]
                                                                                   initWithFrame:CGRectMake(20,155,280,240)];
                                                              _mutipleGatewaysV.delegate = self;
                                                              NSUserDefaults *userdefalut = [NSUserDefaults standardUserDefaults];
                                                              NSMutableArray *gatwayname = [userdefalut objectForKey:@"gatwangname"];
                                                              DebugLog(@"发送UserCredentialGM给网关成功gatwangname:%@",gatwayname);
                                                              _mutipleGatewaysV.mutArrGateway = gatwayname;
                                                              [self.view addSubview:_mutipleGatewaysV];
                                                              [self makeViewRoundWithView:_mutipleGatewaysV];
                                                              [_mutipleGatewaysV reloaddata];
                                                          }
                                                      }
                                                      else
                                                      {
                                                          //发送CellPhoneInfo
                                                          [[PLNetworkManager sharedManager] sendCellPhoneInfoToGateWay];
                                                          DebugLog(@"============每次都检测手机系统语言");
                                                      }
                                                  }];
    
    //发送CellPhoneInfo成功
    [[NSNotificationCenter defaultCenter] addObserverForName:DidSendCellPhoneInfo
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {\
                                                      
                                                    
                                                      PLNetworkManager *networkManager = [PLNetworkManager sharedManager];
                                                      if (networkManager.currentServerType == GatewayType)
                                                      {
                                                          //连接cloudserver，发送用户名密码、device tocken
                                                          [networkManager performSelectorInBackground:@selector(creatSecondConnectToCloudServer) withObject:nil];
                                                       
                                                           DebugLog(@"4是在主线程么%d",[NSThread isMainThread]);
                                                      }
                                                      
                                                      //获取设备列表
                                                      [networkManager startCheckDeviceList];
                                                      [self performSelector:@selector(startHomeware) withObject:nil afterDelay:1.0];                                              
                                                  }];
    
    //连接CloudSever接收消息
    didConnectColoudServer = [[NSNotificationCenter defaultCenter] addObserverForName:DidConnectedToCloudServer
                                                                               object:nil
                                                                                queue:[NSOperationQueue mainQueue]
                                                                           usingBlock:^(NSNotification *note) {
                                                                               //连接成功的时候，手机将gateway 的credential的列表发给cloud server
                                                                               self.isConnectToCloudServer = YES;
                                                    
                                                                               HideHUD;
                                                                            
                                                                               self.gatewayNum = (int)[[[PLNetworkManager sharedManager] gatewayCredentialArr] count];
                                                                            
                                                                               [[PLNetworkManager sharedManager] stopDiscoveryGetway];
                                                                             
                                                                               if (self.gatewayNum == 1)
                                                                               {
                                                                                   DebugLog(@"其他网络连接gatway");
                                                                                   //CheckUserName
                                                                                   PLNetworkManager *networkManager = [PLNetworkManager sharedManager];
                                                                                   [networkManager checkUserCredential];
                                                                                   //发送deviceTocken给cloudserver
//                                                                                   [networkManager performSelector:@selector(sendDeviceTokenToCloudServer)
//                                                                                                        withObject:nil
//                                                                                                        afterDelay:0.5f];
                                                                                   [[PLNetworkManager sharedManager] gatewayChooseWithGatewayID:@"0"];
                                                                
                                                                                   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                                                   [[NSNotificationCenter defaultCenter]addObserverForName:CredentialSucceed object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                                                                                       [[PLNetworkManager sharedManager] startCheckDeviceList];
                                                                                         [self performSelector:@selector(startHomeware) withObject:nil afterDelay:0.5];

                                                                                   }];
                                                                                 
                                                                                   DebugLog(@"5是在主线程么%d",[NSThread isMainThread]);
                                                                                  

                                                                               }
                                                                               else
                                                                               {
                                                                                   _mutipleGatewaysV = [[PLMutipleGatewaysView alloc]
                                                                                                        initWithFrame:CGRectMake(20,155,280,240)];
                                                                                   _mutipleGatewaysV.delegate = self;
                                                                                   NSUserDefaults *userdefalut = [NSUserDefaults standardUserDefaults];
                                                                                   NSMutableArray *gatwayname = [userdefalut objectForKey:@"gatwangname"];
                                                                                   DebugLog(@"发送UserCredentialGM给网关成功gatwangname:%@",gatwayname);
                                                                                   _mutipleGatewaysV.mutArrGateway = gatwayname;
                                                                                   [self.view addSubview:_mutipleGatewaysV];
                                                                                   [self makeViewRoundWithView:_mutipleGatewaysV];
                                                                                   [_mutipleGatewaysV reloaddata];
                                                                               }
                                                                               
                                                                           }];
    
    //进入后台
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [[PLNetworkManager sharedManager] disConnectToGetway];
                                                  }];
    
    //进入前台 激活程序
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      if ([[PLNetworkManager sharedManager] currentServerType] == CloudServerType)
                                                      {
                                                          [[PLNetworkManager sharedManager] connectToCloudServer];
                                                      }
                                                      else if ([[PLNetworkManager sharedManager] currentServerType] == GatewayType)
                                                      {
                                                          NSString *currentIP = [[PLNetworkManager sharedManager] currentConnectedGatewayIP];
                                                          [[PLNetworkManager sharedManager] connectToGetwayWithIPAddress:currentIP];
                                                      }
                                                      else
                                                      {
                                                          DebugLog(@"无法连接cloudsever 和 网关");
                                                      }
                                                      
                                                  }];
}
//通过服务器访问控制网关是否成功
-(void)checkdiddiscovered{
  
    if (_isDidDiscoveryDevice) {
        
    }else{
          HideHUD;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Warm Prompt", nil)] message:[NSString stringWithFormat:NSLocalizedString(@"Please confirm whether the power and impose gateway available in the network ! Try connecting again", nil)] delegate:self cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"YES", nil)] otherButtonTitles:nil, nil];
        alert.tag = 102;
        [alert show];
    }
    
}
//同一网络下，判断是否能够控制网关
-(void)checkCantalk{
    DebugLog(@"有返回信息");
    if (_isCanask) {
    
    }else{
        HideHUD;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Warm Prompt", nil)] message:[NSString stringWithFormat:NSLocalizedString(@"Press the button on the gateway and restart APP", nil)] delegate:self cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"YES", nil)] otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - PLNotiAndAlerts delegate 用户信息已经存在 -

- (void)cellOnWifiDidSelected:(NSString *)notiFrom withView:(PLNotiAndAlerts *)alterView
{
    if ([notiFrom isEqualToString:BothConnect])
    {
        ShowHUD;
        //同意两台同时登陆
        [[PLUserInfoManager sharedManager] setPreviousPasswordData:self.dataPsw];
        [[PLNetworkManager sharedManager] userCredentialGM:YES];
        
    }
    else
    {
        ShowHUD;
        //只允许一台登陆
        [[PLUserInfoManager sharedManager] setPasswordStr:self.strRemberPsw];
        [[PLNetworkManager sharedManager] userCredentialGM:NO];
        
    }
}

//***********第一次启动**************//

#pragma mark - 开始搜索网关 -
- (void)startSearchGateway
{
    [self performSelector:@selector(judgeTimeOutSearChGateway) withObject:nil afterDelay:6.f];
    [[PLNetworkManager sharedManager] startDiscoveryGetway];
}

- (void)judgeTimeOutSearChGateway
{
    //根据保存的网关来判断是不是第一次启动
    NSMutableArray *dictarr = [[PLNetworkManager sharedManager] gatewayCredentialArr];

    if (!dictarr.count)
    {
        HideHUD;
        [[PLNetworkManager sharedManager] stopDiscoveryGetway];
        
        _noFoundWaringV.hidden = NO;
    }
    else
    {
        //如果发现没有可以连接的gateway，就去连接cloudsever
        [self startConnectCloudserver];
        DebugLog(@"发现没有可连接的网关，去连接服务器");
    }
}

#pragma mark - Press the Connect button on the gateway to begin  点击ok触发方法 -
- (void)btnConnectGatewaPressed
{
    ShowHUD;
    if (self.isTheFirstStart)
    {
        
        [self connectGatewayAgain];
    }
    else
    {
        [self connectGatewayAgain];
    }
}

#pragma mark - 定时连接网关 -
- (void)connectGatewayAgain
{
    self.connectGatewayV.hidden =  YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                  target:self
                                                selector:@selector(startConnectGateway)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)startConnectGateway
{
    DebugLog(@"123startConnectGateway");
    //第一次启动
    self.iConnectGatewayTimes ++;
    if (self.iConnectGatewayTimes < 5)
    {
        DebugLog(@"此wifi下的所有网关%@",AllGatwayFound);
        NSString *theFistIP = [NSString stringWithFormat:@"%@",AllGatwayFound[0]];
        [[PLNetworkManager sharedManager] connectToGetwayWithIPAddress:theFistIP];
    }
    else
    {
        [self.timer invalidate];
        [self setTimer:nil];
        //连接网关失败
        if (self.isTheFirstStart)
        {
            HideHUD;
            
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                            message:NSLocalizedString(@"Unable to connect the gateway.Connect again?", nil)
                                                           delegate:self
                                                  cancelButtonTitle:@"NO"
                                                  otherButtonTitles:@"YES", nil];
            alter.tag = 101;
            [alter show];
        }
        else if(self.isConnectColoudserver)
        {
            //手机加入了另一个wifi想控制另一个gateway,连接网关失败后，就开始直接连接coloudserver
            DebugLog(@"");
            [self startConnectCloudserver];
        }
        else
        {
            HideHUD;
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                            message:NSLocalizedString(@"Unable to connect the gateway.Connect again?", nil)
                                                           delegate:self
                                                  cancelButtonTitle:@"NO"
                                                  otherButtonTitles:@"YES", nil];
            alter.tag = 101;
            [alter show];
            
        }
        
    }
}

- (void)startConnectCloudserver
{
    [self performSelector:@selector(judgeTimeOutConnectCloudserver)
               withObject:nil
               afterDelay:8.0f];
    [[PLNetworkManager sharedManager] connectToCloudServer];
}

#pragma mark - 填写邮件信息页面代理 -

- (void)PLEmailProvideViewBtnPressed
{
    ShowHUD;
    NSString *struserName = [[PLUserInfoManager sharedManager] userCredentialStr];
    NSString *strPSW = [[PLUserInfoManager sharedManager] passwordStr];
    
    NSData *userCredentialData = [[PLUserInfoManager sharedManager] userCredentialData];
    NSData *passWordData = [[PLUserInfoManager sharedManager] passwordData];
    
    //CheckUserName
    [[PLNetworkManager sharedManager] checkUserCredential];
    DebugLog(@"\n\nusername === %@  psw === %@",struserName,strPSW);
    DebugLog(@"\n\nuserCredentialData:%@  passWordData:%@\n\n",userCredentialData,passWordData);
}

- (void)handleTextfieldText:(NSString *)strEmail
{
    DebugLog(@"stremail === %@",strEmail);
    [[PLUserInfoManager sharedManager] setUserCredentialStr:strEmail];
    
//    NSString *strPSW = [self randomPassword];
    
    NSString *strPSW = @"123456";
    [[PLUserInfoManager sharedManager] setPasswordStr:strPSW];
}


#pragma mark - alter delegate -
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 101:
        {
            if (buttonIndex == 1)
            {
                self.iConnectGatewayTimes = 0;
                ShowHUD;
                [self connectGatewayAgain];
            }
            else
            {
                [self.timer invalidate];
                self.iConnectGatewayTimes = 0;
            }
        }
            break;
        case 102:{

        }
            break;
        default:
            break;
    }
}



#pragma mark - 连接cloudSever 超时 -
- (void)judgeTimeOutConnectCloudserver
{
    HideHUD;
    if (self.isConnectToCloudServer)
    {
        return;
    }
    else
    {
        //断开丑陋的server连接
        [[PLNetworkManager sharedManager] disConnectToGetway];
        self.unConnectCloudSeverV.textfieldColoudServer.text = [[PLNetworkManager sharedManager] cloudServerAddress];
        self.unConnectCloudSeverV.hidden = NO;
    }
    
}

#pragma mark - no gateway device found  delegate -
- (void)PLNoFoundWarningViewYesBtnPressed
{
    ShowHUD;
    _noFoundWaringV.hidden = YES;
    
    [self startSearchGateway];
}

- (void)PLNoFoundWarningViewNOBtnPressed
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                    message:NSLocalizedString(@"Manual Override App", nil)
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    alter.tag = 102;
    [alter show];
}
-(PLAppDelegate *)APP{
    if (!_APP) {
        _APP = [UIApplication sharedApplication].delegate;
    }
    return _APP;
}
#pragma mark - 点击获取单个网关delegate -
- (void)getGateWay:(NSInteger )strGateway
{
    //发送token
    [[PLNetworkManager sharedManager] performSelector:@selector(sendDeviceTokenToCloudServer)
                                           withObject:nil
                                           afterDelay:0.f];
    
    _mutipleGatewaysV.hidden = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    DebugLog(@"Whenyouconnectcloundselectegatway=======%ld",(long)strGateway);
    [self.APP setCINdex:strGateway];
    DebugLog(@"dang前是第%lu个网关",strGateway);

    [[PLNetworkManager sharedManager] gatewayChooseWithGatewayID:[NSString stringWithFormat:@"%ld",(long)strGateway] ];
    //CheckUserName
    PLNetworkManager *networkManager = [PLNetworkManager sharedManager];
    [networkManager checkUserCredential];
    [[NSNotificationCenter defaultCenter]addObserverForName:CredentialSucceed object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
    
        [[PLNetworkManager sharedManager] startCheckDeviceList];
      
    }];
      [self performSelector:@selector(startHomeware) withObject:nil afterDelay:0.5];
  
//    [self performSelector:@selector(checkdiddiscovered) withObject:nil afterDelay:6.0f];
//  
//    [[NSNotificationCenter defaultCenter]addObserverForName:DidDiscoveryDevice object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
//           _isDidDiscoveryDevice = YES;
//        
//        if(!_isfirstdiddiscover){
//            
//            _isfirstdiddiscover = YES;}
//    }];

}


#pragma mark - unableConnect cloud sever  choice  delegate-

- (void)btnNOPressedOnCloudserverConnect
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                    message:NSLocalizedString(@"Manual Override App", nil)
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alter show];
}

- (void)btnYesPressedOnCloudserverConnect
{
    ShowHUD;
    self.unConnectCloudSeverV.hidden = YES;
    [self startConnectCloudserver];
}

#pragma mark - 圆角化view -

- (void)makeViewRoundWithView:(UIView *)view
{
    view.layer.cornerRadius = 5;
    view.layer.borderWidth = 5;
    view.layer.borderColor = [UIColor colorWithRed:78/255.f
                                             green:189/255.f
                                              blue:249/255.f
                                             alpha:1].CGColor;
}

#pragma mark - 长生随机密码 -
-(NSString *)randomPassword{
    //自动生成6位随机密码
    NSTimeInterval random=[NSDate timeIntervalSinceReferenceDate];
    DebugLog(@"now:%.6f",random);
    NSString *randomString = [NSString stringWithFormat:@"%.6f",random];
    NSString *randompassword = [[randomString componentsSeparatedByString:@"."]objectAtIndex:1];
    DebugLog(@"randompassword:%@",randompassword);
    return randompassword;
}

- (void)startHomeware
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:SEG_TO_TABBAR sender:nil];
    });
}

#pragma mark - 16进制字符串转nsdata类型 -
-(NSData*)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    
    return bytes;
}


@end

