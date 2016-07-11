//
//  PLGatewaySettingsVC.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-8.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLGatewaySettingsVC.h"
#import "PLAlerWithLabelBtnActivity.h"
#import "PLAlterListsGatewayView.h"
#import "PLAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "SDLoopProgressView.h"
#import "SDPieLoopProgressView.h"
#import "HHAlertView.h"
@interface PLGatewaySettingsVC ()<MBProgressHUDDelegate,
                     PLAlerWithLabelBtnActivityDelegate,
                        PLAlterListsGatewayViewDelegate,
                                    UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    PLAlerWithLabelBtnActivity *alterActivity;
    id didGotGetway;
    id didResetOrRebootGateway;
    PLAppDelegate *_appd;
    NSInteger didslectid;
    BOOL didIsDel;
}
@property (weak, nonatomic) IBOutlet UILabel *gatewayname;
@property (weak, nonatomic) IBOutlet UIView *slectV;
@property (weak, nonatomic) IBOutlet UITableView *showtable;

@property (strong, nonatomic) IBOutlet UILabel *labelUpadteGateway;
@property (strong, nonatomic) NSArray *arrGateWays;
//@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelGateWaySetting;

@property (weak, nonatomic) IBOutlet UIScrollView *scroll;
@property (strong, nonatomic) IBOutlet UILabel *labelSearch;
@property (strong, nonatomic) IBOutlet UILabel *labelSelect;
@property (strong, nonatomic) IBOutlet UILabel *labelUpdate;
@property (strong, nonatomic) IBOutlet UILabel *labelReboot;
@property (strong, nonatomic) IBOutlet UILabel *labelReset;
@property (strong, nonatomic) IBOutlet UILabel *labelSilence;
@property (weak, nonatomic) IBOutlet UILabel *labelNOtice;
@property (weak, nonatomic) IBOutlet UISwitch *SilenceFunc;
@property (weak, nonatomic) IBOutlet UISwitch *NOtifcationFunc;
@property (weak, nonatomic) IBOutlet UIButton *SilenceBnt;
@property (weak, nonatomic) IBOutlet UIButton *NotiBut;
@property (weak, nonatomic) IBOutlet UILabel *Versionlabel;
@property (weak, nonatomic) IBOutlet UILabel *newversionlabel;
@property (weak, nonatomic) IBOutlet UIButton *newbtn;
@property(strong,nonatomic)SDLoopProgressView *loop;
@property(assign,nonatomic)BOOL isdismiss;
@property (weak, nonatomic) IBOutlet UIButton *updateBnt;
@property(strong,nonatomic)UIView *shadowview;
@property(assign,nonatomic)BOOL ismyoperation;
@property(assign,nonatomic)BOOL issucceed;
@property(copy,nonatomic)NSString *currentGatwayname;
@property(strong,nonatomic)UITextField *text;
@end

@implementation PLGatewaySettingsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.arrGateWays = [NSArray new];
    if (IS_IPHONE5)
    {
//        self.labelTitle.font = fontCustom(15);
        self.labelGateWaySetting.font = fontCustom(15);
        self.labelUpadteGateway.font = fontCustom(15);
        self.labelSearch.font = fontCustom(15);
        self.labelSelect.font = fontCustom(15);
        self.labelUpdate.font = fontCustom(15);
        self.labelReboot.font = fontCustom(15);
        self.labelReset.font = fontCustom(15);
         self.labelSilence.font = fontCustom(15);
        self.Versionlabel.font = fontCustom(15);
        self.newversionlabel.font = fontCustom(13);
        self.newbtn.font =fontCustom(14);
        self.labelNOtice.font =fontCustom(15);
      
    }
    else
    {
//        self.labelTitle.font = fontCustom(15);
        self.labelGateWaySetting.font = fontCustom(15);
        self.labelUpadteGateway.font = fontCustom(15);
        self.labelSearch.font = fontCustom(15);
        self.labelSelect.font = fontCustom(15);
        self.labelUpdate.font = fontCustom(15);
        self.labelReboot.font = fontCustom(15);
        self.labelReset.font = fontCustom(15);
          self.labelSilence.font = fontCustom(15);
         self.Versionlabel.font = fontCustom(15);
        self.newversionlabel.font = fontCustom(13);
        self.newbtn.font =fontCustom(14);
          self.labelNOtice.font =fontCustom(15);
      
    }
//    NSUserDefaults *defulats = [NSUserDefaults standardUserDefaults];
//    NSString *soundtips = [defulats objectForKey:@"soundclose"];
//    if ([soundtips isEqualToString:@"YES"]) {
//        self.SilenceFunc.on = YES;
//    }else{
//        self.SilenceFunc.on = NO;
//    }
    self.slectV.hidden = YES;
    UITapGestureRecognizer *tapg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showorhiden)];
    [self.slectV addGestureRecognizer:tapg];
    self.showtable.hidden = YES;
  self.scroll.contentSize = CGSizeMake(320, 430);
    self.newbtn.layer.cornerRadius = 5;
//    self.labelTitle.text = NSLocalizedString(@"Gateway Settings", nil);
    self.labelGateWaySetting.text = NSLocalizedString(@"Gateway Settings", nil);
    self.labelSearch.text = NSLocalizedString(@"Search For A New Gateway", nil);
    self.labelSelect.text = NSLocalizedString(@"Select Gateway", nil);
    self.Versionlabel.text = NSLocalizedString(@"Update Gateway-", nil);
    self.labelReboot.text = NSLocalizedString(@"Reboot Gateway", nil);
    self.labelReset.text = NSLocalizedString(@"Reset Gateway", nil);
    self.newversionlabel.text = NSLocalizedString(@"no update available", nil);
    self.labelSilence.text = NSLocalizedString(@"Silence Gatway", nil);
    self.labelNOtice.text =NSLocalizedString(@"RemoteNotification Setting", nil);
    self.updateBnt.hidden = YES;
    self.newbtn.hidden = YES;
    _appd = [[UIApplication sharedApplication]delegate];
    self.currentGatwayname = [NSString stringWithFormat:@"%@",_appd.cINdexName];
    self.gatewayname.text = [NSString stringWithFormat:@"%@",_appd.cINdexName];
    if (_appd.ishowbagevalued) {
        self.newversionlabel.text = [NSString stringWithFormat:@"----%@",_appd.VersionClundNumber];
        self.newbtn.hidden = NO;
          self.updateBnt.hidden = NO;
        [self.updateBnt addTarget:self action:@selector(Updateversion) forControlEvents:UIControlEventTouchUpInside];
    }

    
    //搜索到网关成功的信息
    didGotGetway =[[NSNotificationCenter defaultCenter] addObserverForName:DidDiscoveryGateway
                                                                    object:nil
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification *note) {
                                                                    HideHUD;
                                                                    self.arrGateWays = note.object;
                                                                    
                                                                    alterActivity.strLabelTitle = WarmPrompt;
                                                                    alterActivity.isActivityHidden = YES;
                                                                    alterActivity.strBtnTitle = NSLocalizedString(@"Select Gateway", nil);
                                                                    alterActivity.strLabelContent = [NSString stringWithFormat:NSLocalizedString(@"%lu gateways found", nil),(unsigned long)self.arrGateWays.count];
                                                                    alterActivity.tag = 203;
                                                                    
                                                                } ];
    
    //重启网关成功的信息
    didResetOrRebootGateway =[[NSNotificationCenter defaultCenter] addObserverForName:ResetRebootSucceed
                                                                    object:nil
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification *note) {
                                                                    HideHUD;
                                                                    
                                                                } ];
    [[NSNotificationCenter defaultCenter] addObserverForName:SwitchSoundSucceed
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      HideHUD;
                                                      _SilenceFunc.on = !_SilenceFunc.on;
                                                      NSUserDefaults *defulats = [NSUserDefaults standardUserDefaults];
                                                      NSString *soundtips = @"YES";
                                                          [defulats setObject:soundtips forKey:@"soundclose"];
                                                          [defulats synchronize];
                                                    
                                                  }];
    [[NSNotificationCenter defaultCenter]addObserverForName:DidAccpetTotalpage object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
        if (_ismyoperation) {
            HideHUD;
            _loop.hidden = NO;
            _shadowview.hidden = NO;
            _loop.progress = _appd.TotalPageNumb/_appd.PageNumb;
            _issucceed = YES;
            if (!_isdismiss && _loop.isdismiss)
            {
                _isdismiss = YES;
                HHAlertView *alertview = [[HHAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Successed",nil)] detailText:[NSString stringWithFormat:NSLocalizedString(@" Congratulations, operating successfully implemented ! \n Please restart the app instructions",nil)] addView:self.view cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"OK",nil)] otherButtonTitles:nil];
                [alertview showWithBlock:^(NSInteger index) {
                    [_loop removeFromSuperview];
                    [_shadowview removeFromSuperview];
                    self.newbtn.hidden = YES;
                    self.updateBnt.hidden = YES;
                    [[PLNetworkManager sharedManager] disConnectToClund];
                    self.newversionlabel.text = NSLocalizedString(@"no update available", nil);
                }];
                
            }
        }
    }];
    
   
    [[NSNotificationCenter defaultCenter] addObserverForName:@"Deltokenbind" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        
        //成功后删除验证信息（ip可以不删，因为验证信息跟网关一一对应）和网关名
        
        
        NSUserDefaults *mydefault = [NSUserDefaults standardUserDefaults];
        NSMutableArray *arr =[NSMutableArray arrayWithArray: [mydefault objectForKey:@"gatwangname"]];
        NSString *strgatway = [NSString stringWithFormat:@"%@",[arr objectAtIndex:_appd.cINdex]];
        if ([self.currentGatwayname isEqualToString:strgatway]) {
            //删除后更名不会同步到本地
            didIsDel  = YES;
        }
        
        [arr replaceObjectAtIndex:didslectid withObject:@"-----------------------------------"];
        [mydefault setObject:arr forKey:@"gatwangname"];
        [mydefault synchronize];
        
        
        NSMutableArray *mutArrExistCredential = [[PLNetworkManager sharedManager] gatewayCredentialArr];
        NSData *credata = [mutArrExistCredential objectAtIndex:didslectid];
        NSLog(@"%@",credata);
        [[PLNetworkManager sharedManager] deleteGatewayCredential:credata];
        
        [[PLNetworkManager sharedManager]disConnectToClund];
    }];
    // Do any additional setup after loading the view.
}
-(void)showorhiden{
    self.slectV.hidden = YES;
    self.showtable.hidden = YES;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults *mydefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr =[NSMutableArray arrayWithArray: [mydefault objectForKey:@"gatwangname"]];
    NSString *gatwayname = [NSString stringWithFormat:@"%@",arr[indexPath.row]];
    if ([gatwayname isEqualToString:@"-----------------------------------"]) {
        return 0;
    }else{
        return 60;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSUserDefaults *mydefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr =[NSMutableArray arrayWithArray: [mydefault objectForKey:@"gatwangname"]];
    return arr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indefiter = @"CELL";
   UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:indefiter];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indefiter];
    }
    NSUserDefaults *mydefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr =[NSMutableArray arrayWithArray: [mydefault objectForKey:@"gatwangname"]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",arr[indexPath.row]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.slectV.hidden = YES;
    self.showtable.hidden = YES;
    NSUserDefaults *mydefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr =[NSMutableArray arrayWithArray: [mydefault objectForKey:@"gatwangname"]];
    self.currentGatwayname = [NSString stringWithFormat:@"%@",arr[indexPath.row]];
    NSString *strgatway = [NSString stringWithFormat:@"%@",[arr objectAtIndex:_appd.cINdex]];
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Serious Prompt", nil)
                                                    message:[NSString stringWithFormat:NSLocalizedString(@" Warning : You do not receive alerts on this task Gateway(:%@) push information!", nil),self.currentGatwayname,strgatway]
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    alter.tag = 310;
    [alter show];
    didslectid = indexPath.row;
    
}
//取消推送
- (IBAction)Notisetting:(id)sender {
    NetworkStatus networkStatus = [[PLNetworkManager sharedManager] currentNetworkStatus];
    if (networkStatus == 1) {
        self.slectV.hidden = NO;
        self.showtable.hidden = NO;
        [self.showtable reloadData];
    }else{
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Avoid Unknown error , please operate under wifi network", nil)
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil, nil];
        [alter show];
    }
   
  
}
-(void)Updateversion{
    _appd.ishowbagevalue = NO;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Version%@", nil),_appd.VersionClundNumber] message:[NSString stringWithFormat:NSLocalizedString(@"Smarter, more convenient and more secure! Whether the update", nil)] delegate:self cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"Cancel", nil)] otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"OK", nil)], nil];
    alert.tag =305;
    [alert show];
}

- (IBAction)SwitchForSound:(UIButton *)sender {
    NSUserDefaults *defulats = [NSUserDefaults standardUserDefaults];
    NSString *str = [defulats objectForKey:@"soundclose"];
    if (!str) {
        NSString   *soundtips = @"NO";
        [defulats setObject:soundtips forKey:@"soundclose"];
        [defulats synchronize];
    }
    
        BOOL IsOrOn = [_SilenceFunc isOn];
    if (!IsOrOn) {
        
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Mute The Gatway Sound?", nil)
                                                        message:NSLocalizedString(@"Warning : this will mute prompt tone and sirens!", nil)
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        alter.tag = 304;
        [alter show];
    }else{
      BOOL flag = !_SilenceFunc.on;
        [[PLNetworkManager sharedManager]switchGatwaySoundwithflag:flag];
        ShowHUD;
        NSString   *soundtips = @"NO";
        [defulats setObject:soundtips forKey:@"soundclose"];
        [defulats synchronize];
    }
}

- (void)showGateways
{
    
}

#pragma mark -Search For New Gateway  -
- (IBAction)btnSearPressed:(UIButton *)sender
{
    [self startSearchGateway];
}

- (void)startSearchGateway
{
    CGRect frame = [UIScreen mainScreen].bounds;
    alterActivity = [[PLAlerWithLabelBtnActivity alloc] initWithFrame:frame];
    alterActivity.strBtnTitle = NSLocalizedString(@"Cancel", nil);
    alterActivity.delegate = self;
    alterActivity.strLabelContent = NSLocalizedString(@"Searching for new devices…", nil);
    alterActivity.tag = 201;
    [alterActivity show];
    [self performSelector:@selector(judgeTimeOutSearChGateway2) withObject:nil afterDelay:15.f];
    [[PLNetworkManager sharedManager] startDiscoveryGetway];
}

- (void)judgeTimeOutSearChGateway2
{
    if (!AllGatwayFound.count)
    {
        //15秒内如果收不到这个广播包，就认为局域网没有可连接的gateway 重新连接或者手动退出  Select Gateway
        
        alterActivity.strLabelTitle = WarmPrompt;
        alterActivity.isActivityHidden = YES;
        alterActivity.strBtnTitle = @"OK";
        alterActivity.strLabelContent = NSLocalizedString(@"No new gateways found", nil);
        alterActivity.tag = 202;
    }
    
    [[PLNetworkManager sharedManager] stopDiscoveryGetway];
}


#pragma mark - PLAlterListsGatewayView delegate -
- (void)cellOnWifiDidSelected:(NSString *)gateway withView:(PLAlterListsGatewayView *)alterView
{
    DebugLog(@"asdfsafWIfi ===== %@",gateway);
//    if (alterView.tag == 101)
//    {
//        [self animateOutWithView:alterView];
//    }
//    else
//    {
//        [self animateOutWithView:alterView];
//        [[PLNetworkManager sharedManager] connectToGetwayWithIPAddress:gateway];
//    }
    [self animateOutWithView:alterView];
    [[PLNetworkManager sharedManager] connectToGetwayWithIPAddress:gateway];
}

#pragma mark - PLAlerWithLabelBtnActivity delegate -

- (void)btnPressedOnContentViewWithView:(PLAlerWithLabelBtnActivity *)view withTheBtn:(UIButton *)btn
{
    if (view.tag == 201)
    {
        [[PLNetworkManager sharedManager] stopDiscoveryGetway];
        [view removeFromSuperview];
    }
    else if (view.tag == 202)
    {
        [view removeFromSuperview];
    }
    else if (view.tag == 203)
    {
        [view removeFromSuperview];
        
        CGRect frame = [UIScreen mainScreen].bounds;
        PLAlterListsGatewayView *_alterListSearchForGateway = [PLAlterListsGatewayView new];
        _alterListSearchForGateway.tag = 101;
        _alterListSearchForGateway.frame = frame;
        _alterListSearchForGateway.arrGateways = self.arrGateWays;
        _alterListSearchForGateway.delegate =self;
        [_alterListSearchForGateway show];
    }
    
}


#pragma mark -Select Gateway  -
- (IBAction)btnSelectGatewayPressed:(id)sender
{
    if (self.arrGateWays.count)
    {
        CGRect frame = [UIScreen mainScreen].bounds;
        PLAlterListsGatewayView *_alterListSelectGateway = [PLAlterListsGatewayView new];
        _alterListSelectGateway.frame = frame;
        _alterListSelectGateway.arrGateways = self.arrGateWays;
        _alterListSelectGateway.delegate =self;
        [_alterListSelectGateway show];
    }
    else
    {
        [self startSearchGateway];
    }
    
}

#pragma mark -UpName Gateway  -
- (IBAction)UpdateName:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Assign a new name",nil)] message:nil delegate:self cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"NO",nil)] otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"YES",nil)], nil];

    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    _text=[alert textFieldAtIndex:0];
    _text.text = self.gatewayname.text;
    alert.tag = 301;
     [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 301:
        {
            if (buttonIndex) {
                NSUserDefaults *mydefault = [NSUserDefaults standardUserDefaults];
                NSMutableArray *namearr =[NSMutableArray arrayWithArray: [mydefault objectForKey:@"gatwangname"]];
                if([_text.text isEqualToString:_gatewayname.text]){
                    
                }else{
                    if (didIsDel) {
                           _gatewayname.text = _text.text;
                    }else{
                        [namearr replaceObjectAtIndex:_appd.cINdex withObject:_text.text];
                        _gatewayname.text = _text.text;
                        [mydefault setObject:namearr forKey:@"gatwangname"];
                        [mydefault synchronize];
                        [self.showtable reloadData];
                        DebugLog(@"新数组%@",namearr);
                    }
                }
            }
        }
            break;
        case 303:
        {
            if (buttonIndex) {
                
                DebugLog(@"进行Reset gateway");
                ShowHUD;
                [self performSelector:@selector(judgeTimeOutResetGateway) withObject:nil afterDelay:15.f];
                [[PLNetworkManager sharedManager] resetOrRebootWithType:ResetGatewayType Device:nil];
                
            }
        }
            break;
        case 304:
        {
            if (buttonIndex) {
                
                DebugLog(@"屏蔽声");
                
                BOOL flag = !_SilenceFunc.on;
                [[PLNetworkManager sharedManager]switchGatwaySoundwithflag:flag];
                ShowHUD;
            }
        }
            break;
        case 305:
        {
            if (buttonIndex) {
                _shadowview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 500, 700)];
                _shadowview.backgroundColor = [UIColor blackColor];
                _shadowview.alpha = 0.5;
                _loop= [SDLoopProgressView progressView];
                _loop.frame = CGRectMake(80, 200, 100, 100);
                _loop.center = _appd.window.center;
                [self.view addSubview:_loop];
                [_appd.window addSubview:_shadowview];
                _loop.hidden = YES;
                _shadowview.hidden = YES;
                _ismyoperation = YES;
                [self tryupdate];
      
            }
        }
            break;
        case 310:
        {
            if (buttonIndex) {
                [[PLNetworkManager sharedManager]disConnectToClund];
                [[PLAppDelegate GlobalAppDelagate]setIsformbackground:YES];
                [[PLNetworkManager sharedManager]performSelector:@selector(creatSecondConnectToCloudServer) withObject:nil afterDelay:0.2f];
      
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                        [[PLNetworkManager sharedManager] gatewayChooseWithGatewayID:[NSString stringWithFormat:@"%ld",(long)didslectid] ];
                });
                [[PLNetworkManager sharedManager] performSelector:@selector(sendUserCredentialToCloudServerWhenSecondConnect) withObject:nil afterDelay:1.5f];
                [[PLNetworkManager sharedManager]performSelector:@selector(sendDidDeltokenbind) withObject:nil afterDelay:2.5f];
      
            }
        }
            break;
            
        default:
            break;
    }
}
-(void)tryupdate{
    
    [[PLNetworkManager sharedManager]performSelector:@selector(creatSecondConnectToCloudServer) withObject:nil afterDelay:0.f];
    [[PLNetworkManager sharedManager]performSelector:@selector(sendUserCredentialToCloudServerWhenSecondConnect) withObject:nil afterDelay:1.f];
    [[PLNetworkManager sharedManager]performSelector:@selector(sendDeviceTokenToCloudServerWhenSecondConnect)  withObject:self afterDelay:2.f];
    [[PLNetworkManager sharedManager]performSelector:@selector(startUpdataGwversion)  withObject:nil   afterDelay:2.5f];
    [self performSelector:@selector(cheecksucceed) withObject:nil afterDelay:18];
              ShowHUD;
}
-(void)cheecksucceed{
    if (_issucceed) {
        ;
    }else
    {
        HHAlertView *alertview = [[HHAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Error",nil)] detailText:[NSString stringWithFormat:NSLocalizedString(@"An unpredictable error has occurred and how to do? Try it again ?",nil)] addView:self.view cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"NO",nil)] otherButtonTitles:@[[NSString stringWithFormat:NSLocalizedString(@"OK",nil)]]];
        alertview.mode = HHAlertViewModeWarning;
        [alertview showWithBlock:^(NSInteger index){
            [[PLNetworkManager sharedManager]disConnectToClund];
            [self tryupdate];
        }];
    }
}

#pragma mark -Reset Gateway  -
- (IBAction)btnResetGatewayPressed:(id)sender
{
    
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Reset the gateway to factory defaults?", nil)
                                                    message:NSLocalizedString(@"Warning : this will erase all settings!", nil)
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    alter.tag = 303;
    [alter show];
   
}

- (void)judgeTimeOutRebootGateway
{
    HideHUD;
}

- (void)judgeTimeOutResetGateway
{
    HideHUD;
}

- (IBAction)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)animateOutWithView:(PLAlterListsGatewayView *)view
{
	[UIView animateWithDuration:1.0/7.5 animations:^{
		view.transform = CGAffineTransformMakeScale(0.9, 0.9);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:1.0/15.0 animations:^{
			view.transform = CGAffineTransformMakeScale(1.1, 1.1);
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.3 animations:^{
				view.transform = CGAffineTransformMakeScale(0.01, 0.01);
				view.alpha = 0.3;
			} completion:^(BOOL finished){
				// table alert not shown anymore
				[view removeFromSuperview];
			}];
		}];
	}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
