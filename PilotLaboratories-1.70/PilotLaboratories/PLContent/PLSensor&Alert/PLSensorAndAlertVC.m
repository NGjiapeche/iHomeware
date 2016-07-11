//
//  PLSensorAndAlertVC.m
//  PilotLaboratories
//
//  Created by frontier on 14-3-20.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLSensorAndAlertVC.h"
#import "Reachability.h"
#import "PLAlertsVC.h"
#import "PLSecurityStateSetupVC.h"
#import "DBSphereView.h"
#import "PLShowDoorBeaconCell.h"
#import "PLCustomLongPressCellAlter.h"
#import "PLAppDelegate.h"
#import "SDLoopProgressView.h"
#import "SDPieLoopProgressView.h"
#import "HHAlertView.h"
#import "PLHelpViewController.h"
//#define isAway @"awayArm"
//#define isHome @"homeArm"
//#define isDisarm @"disam"


@interface PLSensorAndAlertVC ()<PLCustomLongPressCellAlterDelegate,PLUpDateViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *beijing;
@property (strong, nonatomic) IBOutlet UIButton *btnAwayOrArm;
@property (strong, nonatomic) IBOutlet UIButton *btnHomeOrArm;
@property (strong, nonatomic) IBOutlet UIButton *btnDisarm;

@property (assign, nonatomic) BOOL isAwayFirst;
@property (assign, nonatomic) BOOL isHomeFirst;
@property (assign, nonatomic) BOOL isDisarmFirst;
@property(assign, nonatomic)NSInteger SelectTag;

@property (strong, nonatomic) IBOutlet UILabel *labelTItle;
@property (strong, nonatomic) IBOutlet UILabel *labelAway;
@property (strong, nonatomic) IBOutlet UILabel *labelHome;
@property (strong, nonatomic) IBOutlet UILabel *labelDisam;

@property (strong, nonatomic) IBOutlet UIButton *arrowAway;
@property (strong, nonatomic) IBOutlet UIButton *arrowHome;
@property (weak, nonatomic) IBOutlet UILabel *labelAlarm;
@property (weak, nonatomic) IBOutlet UIButton *btnalarmlog;

@property (weak, nonatomic) IBOutlet UITableView *BeaconTable;

@property (weak, nonatomic) IBOutlet UITableView *DoorTable;
@property (strong, nonatomic) NSArray *arrDatasource;
@property (strong, nonatomic)NSMutableArray *DoorDatasource;
@property (strong, nonatomic) NSMutableArray *BeaconDatasource;
@property (strong, nonatomic) DBSphereView *dbsphereview;
@property (strong, nonatomic) PLShowDoorBeaconCell *moveTableViewCell;
@property (strong, nonatomic) PLCustomLongPressCellAlter *alter;
@property(strong,nonatomic)PLUpDateView *Updataview;
@property(strong ,nonatomic)UIView*shadowview;
@property(strong,nonatomic) PLAppDelegate *appd;
//@property(strong,nonatomic)   SDPieLoopProgressView *loop;
@property(strong,nonatomic)SDLoopProgressView *loop;
@property(assign,nonatomic)BOOL isdismiss;
@property(assign,nonatomic)BOOL ismyoperation;
@property(assign,nonatomic)BOOL isUpdated;
@property(assign,nonatomic)BOOL isGetOldVerson;
@property(strong,nonatomic)NSTimer *CheckTimer;
@property(assign,nonatomic)BOOL isfirsttime;

@property(strong,nonatomic)UILabel *applabel;
@end

@implementation PLSensorAndAlertVC

-(void)viewWillDisappear:(BOOL)animated{

}
-(void)viewWillAppear:(BOOL)animated{
    if (self.isCancellArm)
    {
        [self.btnAwayOrArm setBackgroundImage:[UIImage imageNamed:@"tubiao 1.png"] forState:UIControlStateSelected];
        [self.btnHomeOrArm setBackgroundImage:[UIImage imageNamed:@"tubiao 2.png"] forState:UIControlStateSelected];
        [self.btnDisarm setBackgroundImage:[UIImage imageNamed:@"tubiao 3.png"] forState:UIControlStateSelected];
        self.isCancellArm = NO;
    }
}
//版本更新方法
-(void)aboutVersionupdata{
   _appd = [[UIApplication sharedApplication]delegate];
    //获取网关版本信息用户显示选择是否更新
    [[NSNotificationCenter defaultCenter]addObserverForName:DidGetGatewayCurrentVersion object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *VersionInfoDict =[NSMutableDictionary dictionaryWithDictionary:(NSMutableDictionary *) [userDefaults objectForKey:@"VersionInfo"]];
        NSString *Gwnumber = VersionInfoDict[@"VersionGWNumber"];
        DebugLog(@"原来%@",VersionInfoDict);
        if ([Gwnumber doubleValue] != [_appd.VersionGWNumber doubleValue]) {
            [VersionInfoDict setObject:_appd.VersionGWNumber forKey:@"VersionGWNumber"];
            [userDefaults setObject:VersionInfoDict forKey:@"VersionInfo"];
            [userDefaults synchronize];
            DebugLog(@"网关新版本%@",VersionInfoDict);
        }
        _isGetOldVerson = YES;
        [[PLNetworkManager sharedManager]performSelector:@selector(GetLatesVersionWhenSecondConnect)  withObject:self afterDelay:0.4];
    }];
    [[NSNotificationCenter defaultCenter]addObserverForName:DidConnectedToCloudServerForUpDate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
        if (_appd.isformbackground ) {
            
        }else if(_isfirsttime){
            [[PLNetworkManager sharedManager] performSelector:@selector(sendUserCredentialToCloudServerWhenSecondConnect) withObject:nil afterDelay:0.0f];
        }
    }];
    if (![[PLNetworkManager sharedManager]isconnectcloundforupdate]) {
         [[PLNetworkManager sharedManager] performSelector:@selector(creatSecondConnectToCloudServer) withObject:nil afterDelay:0];
    } else if ([[PLNetworkManager sharedManager]isconnectcloundforupdate]) {
        [[PLNetworkManager sharedManager] performSelector:@selector(sendUserCredentialToCloudServerWhenSecondConnect) withObject:nil afterDelay:0];
    }
    [[NSNotificationCenter defaultCenter]addObserverForName:CredentialSucceed object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
        //发送验证成功后，再去查询网关本地版本
        if (_appd.isformbackground ) {
            
        }else if(_isfirsttime){
            [[PLNetworkManager sharedManager]performSelector:@selector(quaryGatewayCurrentVersion)  withObject:self afterDelay:0.0f];
            [[PLNetworkManager sharedManager]performSelector:@selector(sendDeviceTokenToCloudServerWhenSecondConnect)  withObject:self afterDelay:0.1f];
        }
    }];
    [[NSNotificationCenter defaultCenter]addObserverForName:DidGetLastestVersion object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *VersionInfoDict =[NSMutableDictionary dictionaryWithDictionary:(NSMutableDictionary *) [userDefaults objectForKey:@"VersionInfo"]];
        NSString *GwnumCdber = VersionInfoDict[@"VersionCdNumber"];
        if ([_appd.VersionClundNumber doubleValue] != [GwnumCdber doubleValue]) {
            [VersionInfoDict setObject:_appd.VersionClundNumber forKey:@"VersionCdNumber"];
            _appd.VerIdentifier = NO;
            [VersionInfoDict setObject:[NSNumber numberWithBool:_appd.VerIdentifier] forKey:@"VerIdentifier"];
             [userDefaults setObject:VersionInfoDict forKey:@"VersionInfo"];
            [userDefaults synchronize];
                 DebugLog(@"服务器新版本%@",VersionInfoDict);
        }
        NSUserDefaults *userDefaults2 = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *VersionInfoDict2 = [userDefaults2 objectForKey:@"VersionInfo"];
        NSNumber *numIF = VersionInfoDict2[@"VerIdentifier"];
        if (_isGetOldVerson && self.isfirsttime) {
            self.isfirsttime  = NO;
            if (![_appd.VersionGWNumber isEqualToString:_appd.VersionClundNumber] && ![numIF boolValue] && ![_appd.VersionGWNumber isEqualToString:@"0.1"] && ![_appd.VersionGWNumber isEqualToString:@"1.9"] && ![_appd.VersionGWNumber isEqualToString:@"0.18"] && ![_appd.VersionGWNumber isEqualToString:@"1.31"] && ![_appd.VersionGWNumber isEqualToString:@"1.31"]) {
                _appd.ishowbagevalue = YES;
                _appd.ishowbagevalued = YES;
                _shadowview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 500, 700)];
                _shadowview.backgroundColor = [UIColor blackColor];
                _shadowview.alpha = 0.5;
                _Updataview = [[PLUpDateView alloc]initWithFrame:CGRectMake(20, 200, 280, 175)];
                [_Updataview setoldversion:_appd.VersionGWNumber newvwesion:_appd.VersionClundNumber];
                _Updataview.center = _appd.window.center;
                _Updataview.delegate = self;
                [_appd.window addSubview:_shadowview];
                [_appd.window addSubview:_Updataview];
                [_appd.window addSubview:_loop];
                _loop.hidden = YES;
            }else{
                [[PLNetworkManager sharedManager]disConnectToClund];
                _appd.ishowbagevalue = NO;
            }
        }
    }];
    [[NSNotificationCenter defaultCenter]addObserverForName:DidAccpetTotalpage object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
        if (_ismyoperation) {
            HideHUD;
            _isUpdated = YES;
            _loop.hidden = NO;
            _loop.progress = _appd.TotalPageNumb/_appd.PageNumb;
            if (!_isdismiss && _loop.isdismiss)
            {
                [_CheckTimer invalidate];
                _CheckTimer = nil;
                _isdismiss = YES;
                HHAlertView *alertview = [[HHAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Successed",nil)] detailText:[NSString stringWithFormat:NSLocalizedString(@" Congratulations, operating successfully implemented ! \n Please restart the app instructions",nil)] addView:self.view cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"OK",nil)] otherButtonTitles:nil];
                [alertview showWithBlock:^(NSInteger index) {
                    [_shadowview removeFromSuperview];
                    [[PLNetworkManager sharedManager] disConnectToClund];
                  
                }];
            }
        }
    }];
}
#pragma mark ——PLUpDataDelegate
-(void)IFbntPressedwithselect:(BOOL)yesorno{
    _appd.VerIdentifier = yesorno;
}

-(void)UpbntPressed{
   [[PLNetworkManager sharedManager]performSelector:@selector(startUpdataGwversion)  withObject:self afterDelay:0.0];
      [[PLNetworkManager sharedManager]performSelector:@selector(disConnectToGetway)  withObject:self afterDelay:1.0];
      [[PLNetworkManager sharedManager]performSelector:@selector(stopCheckDeviceList)  withObject:self afterDelay:1.0];

    ShowHUD;
    _ismyoperation = YES;
    [_Updataview removeFromSuperview];
    _Updataview.delegate = nil;
    [self performSelector:@selector(addtimer) withObject:nil afterDelay:18.0f];
}
-(void)CancelPressed{
    DebugLog(@"以后再说");
    [[PLNetworkManager sharedManager] disConnectToClund];
    [_loop removeFromSuperview];
    [_Updataview removeFromSuperview];
    [_shadowview removeFromSuperview];
    _Updataview.delegate = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *VersionInfoDict =[NSMutableDictionary dictionaryWithDictionary:(NSMutableDictionary *) [userDefaults objectForKey:@"VersionInfo"]];
    [VersionInfoDict setObject:[NSString stringWithFormat:@"%d",_appd.VerIdentifier ] forKey:@"VerIdentifier"];
    [userDefaults setObject:VersionInfoDict forKey:@"VersionInfo"];
    [userDefaults synchronize];
    DebugLog(@"退出%@",VersionInfoDict);
}
-(void)addtimer{
    _CheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkUpadatestate) userInfo:nil repeats:YES];
    _isUpdated = YES;

}
-(void)Makeamistake{
      [[PLNetworkManager sharedManager] disConnectToClund];
}
-(void)checkUpadatestate{
    if (_isUpdated) {
        _isUpdated = !_isUpdated;
    }else{
        [_CheckTimer invalidate];
        _CheckTimer = nil;
        HideHUD;
        if ([[PLNetworkManager sharedManager] dismissconnect]) {
             _loop.hidden = YES;
            HHAlertView *alertview = [[HHAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Error",nil)] detailText:[NSString stringWithFormat:NSLocalizedString(@"Your server has been disconnected , but the gateway is being updated ! Please wait a moment to restart APP",nil)] addView:self.view cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"YES",nil)] otherButtonTitles:nil];
            alertview.mode = HHAlertViewModeWarning;
            [alertview show];
        }
        else{
            HHAlertView *alertview = [[HHAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Error",nil)] detailText:[NSString stringWithFormat:NSLocalizedString(@"An unpredictable error has occurred and how to do? Try it again ?",nil)] addView:self.view cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"NO",nil)] otherButtonTitles:@[[NSString stringWithFormat:NSLocalizedString(@"OK",nil)]]];
            alertview.mode = HHAlertViewModeWarning;
            [alertview showWithBlock:^(NSInteger index) {
                if (index == 0) {
                    [_shadowview removeFromSuperview];
                    [[PLNetworkManager sharedManager] disConnectToClund];
                }else if (index == 1){
                    [[PLNetworkManager sharedManager]performSelector:@selector(startUpdataGwversion)  withObject:self afterDelay:0.0];
                    [self performSelector:@selector(addtimer) withObject:nil afterDelay:18.0f];
                    ShowHUD;
                }
            }];
        }
        DebugLog(@"更新网关失败");
    }
}
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    yct_initNav(NO, YES, NO,nil,nil, nil,nil,nil, @"help_question.png", nil);
    self.isfirsttime = YES;
    self.isAwayFirst = NO;
    self.isHomeFirst = NO;
    self.isDisarmFirst = NO;
    self.isCancellArm = NO;
    
//    if (_appd.isformbackground) {
//        
//    }else{
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            [[PLNetworkManager sharedManager]performSelectorInBackground:@selector(creatSecondConnectToCloudServer) withObject:nil];
//            //         [[PLNetworkManager sharedManager]performSelector:@selector(creatSecondConnectToCloudServer)  withObject:self afterDelay:0.0];
//        });
//    }
        [self aboutVersionupdata];

  _loop= [SDLoopProgressView progressView];
    _loop.frame = CGRectMake(80, 200, 100, 100);
    _loop.center = _appd.window.center;
    

    if (IS_IPHONE5)
    {
        _labelTItle.font = fontCustom(15);
        _labelAway.font = fontCustom(15);
        _labelHome.font = fontCustom(15);
        _labelDisam.font = fontCustom(15);
    }
    else
    {
        _labelTItle.font = fontCustom(15);
        _labelAway.font = fontCustom(15);
        _labelHome.font = fontCustom(15);
        _labelDisam.font = fontCustom(15);
    }
    
    
    
    if (IS_IPHONE5)
    {
        
    }
    else
    {
        self.beijing.frame = CGRectMake(0, 0, 320, 120);
        self.btnAwayOrArm.frame = CGRectMake(60, 138, 80, 80);
        self.btnHomeOrArm.frame = CGRectMake(180, 138, 80, 80);
        self.btnDisarm.frame = CGRectMake(60,254, 80, 80);
        self.btnalarmlog.frame = CGRectMake(184, 254, 80, 80);
       
        
        self.labelAway.frame = CGRectMake(17, 224, 166, 18);
        self.labelHome.frame = CGRectMake(155, 224, 137, 18);
        self.labelDisam.frame = CGRectMake(19, 340, 143, 18);
        self.labelAlarm.frame = CGRectMake(155, 340, 137, 18);
        
        self.arrowAway.frame = CGRectMake(110, 125, 18, 18);
        self.arrowHome.frame = CGRectMake(230, 125, 18, 18);
     
    }
    
    [self.btnAwayOrArm setBackgroundImage:[UIImage imageNamed:@"tubiao 1.png"] forState:UIControlStateSelected];
    self.btnAwayOrArm.selected = YES;
    
    [self.btnHomeOrArm setBackgroundImage:[UIImage imageNamed:@"tubiao 2.png"] forState:UIControlStateSelected];
    [self.btnDisarm setBackgroundImage:[UIImage imageNamed:@"tubiao 3.png"] forState:UIControlStateSelected];
   
    self.arrDatasource = [NSArray array];
    self.DoorDatasource = [NSMutableArray array];
    self.BeaconDatasource = [NSMutableArray array];
    self.BeaconTable.tag = 2;
    self.DoorTable.tag = 1;
    self.BeaconTable.separatorStyle = UITableViewCellSelectionStyleNone;
     self.DoorTable.separatorStyle = UITableViewCellSelectionStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidDiscoveryDevices:)
                                                 name:DidDiscoveryDevice
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReceiveAlarmInform:)
                                                 name:ReceiveAlarmInform
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSenorState:)
                                                 name:SecurityStateRequestSucceed
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserverForName:DidRefreshDeviceStatus
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      PLAppDelegate *mydelegate = [[UIApplication sharedApplication]delegate];
                                                      
                                                      [self.DoorDatasource removeAllObjects];
                                        
                                                      self.DoorDatasource =[NSMutableArray arrayWithArray:mydelegate.DoorArray];
                                                      [mydelegate.DoorArray removeAllObjects];
                                                      [self.DoorTable reloadData];
                                                  }];
    
    //[self initBtn];
    
//    _dbsphereview = [[DBSphereView alloc] initWithFrame:CGRectMake(100, 100, 160, 120)];
//    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
//    for (NSInteger i = 0; i < 6; i ++) {
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
//        [btn setTitle:[NSString stringWithFormat:@"PQQQQQQQQ11111%ld", (long)i] forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        btn.titleLabel.font = [UIFont systemFontOfSize:24.];
//        btn.frame = CGRectMake(0, 0, 160, 20);
//        [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
//        [array addObject:btn];
//        [_dbsphereview addSubview:btn];
//    }
//    [_dbsphereview setCloudTags:array];
//    _dbsphereview.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:_dbsphereview];
    
    //测试点击推送打开app
    PLAppDelegate *mydelegate = [[UIApplication sharedApplication]delegate];
    _applabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 1000)];
    _applabel.textColor = [UIColor redColor];
    _applabel.text = mydelegate.texttuisong;
    [self.view addSubview:_applabel];
 
}
- (void)handleDidDiscoveryDevices:(NSNotification *)noti
{
    [self.BeaconDatasource removeAllObjects];
  
    self.arrDatasource = [[PLNetworkManager sharedManager] sensorArr];
    for (PLModel_Device * device in self.arrDatasource) {
        switch (device.deviceType) {
            case Becon: {
                [self.BeaconDatasource addObject:device];
                break;
            }
            default: {
                break;
            }
        }
    }
    [self.BeaconTable reloadData];
    [[PLNetworkManager sharedManager] performSelector:@selector(checkDeviceStatuswithDoor) withObject:self afterDelay:0.3];
    [[PLNetworkManager sharedManager] performSelector:@selector(securityStateRequest) withObject:self afterDelay:0.2];
   
}
#pragma - mark tabledelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1) {
          return self.DoorDatasource.count;
    
    }else{
          return self.BeaconDatasource.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLShowDoorBeaconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShowDoorBeaconCell"];
    if (!cell)
    {
        cell = [[PLShowDoorBeaconCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ShowDoorBeaconCell"];
        cell.Name.font = fontCustom(11);
    }
     NSString *deviceName;
    if (tableView.tag == 1) {
        cell.img.image = [UIImage imageNamed:@"menci.png"];
        PLModel_Device *device = self.DoorDatasource[indexPath.row];
        if (device.deviceName.length == 0)
        {
            deviceName = [NSString stringWithFormat:NSLocalizedString(@"DoorSensor%d", nil),indexPath.row + 1];
            cell.Name.text = deviceName;
        }
        else{
             cell.Name.text = [NSString stringWithFormat:@"%@",device.deviceName];
        }
    }else if (tableView.tag == 2){
        cell.img.image = [UIImage imageNamed:@"yaoshi.png"];
        PLModel_Device *device = self.BeaconDatasource[indexPath.row];
        if (device.deviceName.length == 0)
        {
         deviceName = [NSString stringWithFormat:NSLocalizedString(@"Becon%d", nil),indexPath.row + 1];
             cell.Name.text = deviceName;
        }
        else{
              cell.Name.text = [NSString stringWithFormat:@"%@",device.deviceName];
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isMemberOfClass:[_DoorTable class]]) {
        _SelectTag = 1;
    }else{
        _SelectTag = 2;
    }
    self.moveTableViewCell = (PLShowDoorBeaconCell *)[tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self longPressCell:indexPath];
}

- (void)longPressCell:(NSIndexPath *)indexPath
{
    self.alter = [PLCustomLongPressCellAlter new];
    self.alter.delegate = self;
    [self.alter show];
}
#pragma mark - PLCustomLongPressCellAlterDelegate -
- (void)btnOKPressedWithName:(NSString *)strChangeName
{
    //获取更改后开关的名字
    
    //单个cell 刷新
    if (_SelectTag == 1) {
        NSIndexPath *indexPathTemp = [self.DoorTable indexPathForCell:self.moveTableViewCell];
        PLModel_Device *device = self.DoorDatasource[indexPathTemp.row];
        device.deviceName = strChangeName;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexPathTemp.row inSection:0];
        [self.DoorTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil]
                              withRowAnimation:UITableViewRowAnimationNone];
    }else{
        NSIndexPath *indexPathTemp = [self.BeaconTable indexPathForCell:self.moveTableViewCell];
        PLModel_Device *device = self.BeaconDatasource[indexPathTemp.row];
        device.deviceName = strChangeName;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexPathTemp.row inSection:0];
        [self.BeaconTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil]
                               withRowAnimation:UITableViewRowAnimationNone];
    }
}
- (void)buttonPressed:(UIButton *)btn
{
    [_dbsphereview timerStop];
    
    [UIView animateWithDuration:0.3 animations:^{
        btn.transform = CGAffineTransformMakeScale(2., 2.);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            btn.transform = CGAffineTransformMakeScale(1., 1.);
        } completion:^(BOOL finished) {
            [_dbsphereview timerStart];
        }];
    }];
}

-(void)handleSenorState:(NSNotification *)noti{
    PLModel_SecurityStateResult *result =  (PLModel_SecurityStateResult *)noti.object;
    switch (result.type) {
        case AwayArmType:
            self.btnAwayOrArm.selected = YES;
            self.btnHomeOrArm.selected = NO;
            self.btnDisarm.selected = NO;
            self.labelAway.textColor = [UIColor blackColor];
            self.labelHome.textColor = [UIColor lightGrayColor];
            self.labelDisam.textColor = [UIColor lightGrayColor];
            break;
        case HomeArmType:
            self.btnAwayOrArm.selected = NO;
            self.btnHomeOrArm.selected = YES;
            self.btnDisarm.selected = NO;
            self.labelAway.textColor = [UIColor lightGrayColor];
            self.labelHome.textColor = [UIColor blackColor];
            self.labelDisam.textColor = [UIColor lightGrayColor];
            
            break;
        case DisArmType:
            self.btnAwayOrArm.selected = NO;
            self.btnHomeOrArm.selected = NO;
            self.btnDisarm.selected = YES;
            self.labelAway.textColor = [UIColor lightGrayColor];
            self.labelHome.textColor = [UIColor lightGrayColor];
            self.labelDisam.textColor = [UIColor blackColor];
            
            break;
            
        default:
            break;
    }
}
#pragma mark - 处理获取到的报警信息 -

- (void)handleReceiveAlarmInform:(NSNotification *)noti
{
    PLAppDelegate *mydelegate = [[UIApplication sharedApplication]delegate];
    PLModel_Device *device = (PLModel_Device *)noti.object;
    _applabel.text = mydelegate.texttuisong;
    NSString *currentTime = [self getCurrentTime];
    
    NSMutableArray *mutArrArmInfo =  [NSMutableArray arrayWithArray:[[PLSaveAlarmInfo sharedManager] mutArrAlarm]] ;
    [device setDeviceAlertTime: [NSString stringWithFormat:@"%@",currentTime]];
    for (PLModel_Device *oldDevice in mutArrArmInfo)
    {
        if ([oldDevice.macAddress isEqualToData:device.macAddress])
        {
            [mutArrArmInfo removeObject:oldDevice];
            break;
        }
    }
    [mutArrArmInfo insertObject:device atIndex:0];
    [[PLSaveAlarmInfo sharedManager] setMutArrAlarm:mutArrArmInfo];
    
    switch (device.deviceType) {
        case LightType:
        {
            
        }
            break;
        case TemperatureSensorType:
        {
            
        }
            break;
        case DoorSensorType:
        {
            
        }
            break;
        case PirSensorType:
        {
            
        }
            break;
            
        case GravitySensorType:
        {
            
        }
            break;
            
        case VibrationSensorType:
        {
            
        }
            break;
            
        default:
            break;
    }
    _isCancellArm = YES;
    
    [self.btnAwayOrArm setBackgroundImage:[UIImage imageNamed:@"APP界面 红色 01.png"] forState:UIControlStateSelected];
    [self.btnHomeOrArm setBackgroundImage:[UIImage imageNamed:@"APP界面 红色 02.png"] forState:UIControlStateSelected];
    [self.btnDisarm setBackgroundImage:[UIImage imageNamed:@"APP界面 红色 03.png"] forState:UIControlStateSelected];
}

#pragma mark - 获取当前时间 -
- (NSString *)getCurrentTime
{
    NSDate *dates = [NSDate date];
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    [formatter setTimeZone:timeZone];
    
    NSString *loctime = [formatter stringFromDate:dates];
    
    DebugLog(@"loctime = %@", loctime);
    return loctime;
}

#pragma mark - 根据当前状态判断按钮的选中情况 添加手势  -
- (void)initBtn
{
    UILongPressGestureRecognizer *longPressedAway = [[UILongPressGestureRecognizer alloc] init];
    [longPressedAway addTarget:self action:@selector(btnAwayArmLongPressed:)];
    [longPressedAway setMinimumPressDuration:0.5f];
    [self.btnAwayOrArm addGestureRecognizer:longPressedAway];
    
    UILongPressGestureRecognizer *longPressedHome = [[UILongPressGestureRecognizer alloc] init];
    [longPressedHome addTarget:self action:@selector(btnAwayArmLongPressed:)];
    [longPressedHome setMinimumPressDuration:0.5f];
    [self.btnHomeOrArm addGestureRecognizer:longPressedHome];
    
    UILongPressGestureRecognizer *longPressedDisam = [[UILongPressGestureRecognizer alloc] init];
    [longPressedDisam addTarget:self action:@selector(btnAwayArmLongPressed:)];
    [longPressedDisam setMinimumPressDuration:0.5f];
    [self.btnDisarm addGestureRecognizer:longPressedDisam];
}

- (IBAction)indicatorButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 10)
    {
        //        NSLog(@"**********self.btnaway");
        //        self.btnAwayOrArm.selected = YES;
        //        self.btnHomeOrArm.selected = NO;
        //        self.btnDisarm.selected = NO;
        //        [[PLNetworkManager sharedManager] securityStateSelectWithType:AwayArmType];
        if (!self.btnAwayOrArm.selected)
        {
            return;
        }
        [self performSegueWithIdentifier:SEG_TO_PLSecurityStateSetupVC sender:@"Away/Arm"];
    }
    else if (button.tag == 11)
    {
        //        NSLog(@"**************self home");
        //        self.btnAwayOrArm.selected = NO;
        //        self.btnHomeOrArm.selected = YES;
        //        self.btnDisarm.selected = NO;
        //        [[PLNetworkManager sharedManager] securityStateSelectWithType:HomeArmType];
        if (!self.btnHomeOrArm.selected)
        {
            return;
        }
        [self performSegueWithIdentifier:SEG_TO_PLSecurityStateSetupVC sender:@"Home/Arm"];
    }
    else if (button.tag == 12)
    {
        //        self.btnAwayOrArm.selected = NO;
        //        self.btnHomeOrArm.selected = NO;
        //        self.btnDisarm.selected = YES;
        //        [[PLNetworkManager sharedManager] securityStateSelectWithType:DisArmType];
        if (!self.btnDisarm.selected)
        {
            return;
        }
        [self performSegueWithIdentifier:SEG_TO_PLSecurityStateSetupVC sender:@"Disam"];
    }
}


#pragma mark - 长按触发方法  -

- (void)btnAwayArmLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded:
        {
            
        }
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateFailed:
            
            break;
        case UIGestureRecognizerStateBegan:
        {
            if (gestureRecognizer.view == self.btnAwayOrArm)
            {
                DebugLog(@"**********self.btnaway");
                self.btnAwayOrArm.selected = YES;
                self.btnHomeOrArm.selected = NO;
                self.btnDisarm.selected = NO;
                [[PLNetworkManager sharedManager] securityStateSelectWithType:AwayArmType];
                [self performSegueWithIdentifier:SEG_TO_PLSecurityStateSetupVC sender:@"Away/Arm"];
            }
            else if (gestureRecognizer.view == self.btnHomeOrArm)
            {
                DebugLog(@"**************self home");
                self.btnAwayOrArm.selected = NO;
                self.btnHomeOrArm.selected = YES;
                self.btnDisarm.selected = NO;
                [[PLNetworkManager sharedManager] securityStateSelectWithType:HomeArmType];
                [self performSegueWithIdentifier:SEG_TO_PLSecurityStateSetupVC sender:@"Home/Arm"];
            }
            else if (gestureRecognizer.view == self.btnDisarm)
            {
                self.btnAwayOrArm.selected = NO;
                self.btnHomeOrArm.selected = NO;
                self.btnDisarm.selected = YES;
                [[PLNetworkManager sharedManager] securityStateSelectWithType:DisArmType];
                [self performSegueWithIdentifier:SEG_TO_PLSecurityStateSetupVC sender:@"Disam"];
            }
            
        }
            break;
        case UIGestureRecognizerStateChanged:
            
            break;
        default:
            break;
    }
}
- (IBAction)bntforAlarmlog:(UIButton*)sender {
    
    [self performSegueWithIdentifier:SEG_TO_PLALERTSVC sender:@"命名一个跳转，当跳转发生时可以获得跳转的名字"];
//    sender.selected = !sender.selected;
//    [self.btnAwayOrArm setBackgroundImage:[UIImage imageNamed:@"APP界面 红色 01.png"] forState:UIControlStateSelected];
//    [self.btnHomeOrArm setBackgroundImage:[UIImage imageNamed:@"APP界面 红色 02.png"] forState:UIControlStateSelected];
//    [self.btnDisarm setBackgroundImage:[UIImage imageNamed:@"APP界面 红色 03.png"] forState:UIControlStateSelected];
    
    
}
#pragma mark -短按 Away/Arm 、 Home/Arm、 Disarm button pressed  -

- (IBAction)btnAwayOrArmPressed:(UIButton *)sender
{
    if (sender.selected)
    {
       
    }
    else
    {
        sender.selected = !sender.selected;
        if (sender.selected)
        {
            self.btnHomeOrArm.selected = NO;
            self.btnDisarm.selected = NO;
            self.labelAway.textColor = [UIColor blackColor];
            self.labelHome.textColor = [UIColor lightGrayColor];
            self.labelDisam.textColor = [UIColor lightGrayColor];
            
            
        }
    }
    [[PLNetworkManager sharedManager] securityStateSelectWithType:AwayArmType];
}

- (IBAction)btnHomeOrArmPressed:(UIButton *)sender
{
    if (sender.selected)
    {
//        [self performSegueWithIdentifier:SEG_TO_PLALERTSVC sender:isHome];
    }
    else
    {
        sender.selected = !sender.selected;
        if (sender.selected)
        {
            self.btnAwayOrArm.selected = NO;
            self.btnDisarm.selected = NO;
            self.labelAway.textColor = [UIColor lightGrayColor];
            self.labelHome.textColor = [UIColor blackColor];
            self.labelDisam.textColor = [UIColor lightGrayColor];
            
            
        }
    }
    [[PLNetworkManager sharedManager] securityStateSelectWithType:HomeArmType];
}

- (IBAction)btnDisarmPressed:(UIButton *)sender
{
    if (sender.selected)
    {
//        [self performSegueWithIdentifier:SEG_TO_PLALERTSVC sender:isDisarm];
    }
    else
    {
        sender.selected = !sender.selected;
        if (sender.selected)
        {
            self.btnAwayOrArm.selected = NO;
            self.btnHomeOrArm.selected = NO;
            
            self.labelAway.textColor = [UIColor lightGrayColor];
            self.labelHome.textColor = [UIColor lightGrayColor];
            self.labelDisam.textColor = [UIColor blackColor];
            
            
        }
    }
    [[PLNetworkManager sharedManager] securityStateSelectWithType:DisArmType];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEG_TO_PLALERTSVC]) {
        
        PLAlertsVC *vc = (PLAlertsVC *)segue.destinationViewController;
        vc.strIdentifer = [NSString stringWithFormat:@"%@",sender];
       
        
    }
    if ([[segue identifier] isEqualToString:SEG_TO_PLSecurityStateSetupVC])
    {
        PLSecurityStateSetupVC *vc = (PLSecurityStateSetupVC *)segue.destinationViewController;
        vc.strIdentifer = [NSString stringWithFormat:@"%@",sender];
        
    }
}

-(void)btnRightPressed{
    [self performSegueWithIdentifier:@"helpidentifier" sender:nil];
}

@end
