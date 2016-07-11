//
//  PLCloudSettingsVC.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-9.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLCloudSettingsVC.h"
#import "PLMutipleGatewaysView.h"

@interface PLCloudSettingsVC ()<PLMutipleGatewaysViewDelegate>
{
    id didConnectColoudServer;
    id didGotGatewayNum;
}
@property (strong, nonatomic) IBOutlet UILabel *labelCloudServer;
@property (assign, nonatomic) BOOL isConnectToCloudServer;
@property (strong, nonatomic) PLMutipleGatewaysView *mutipleGatewaysV;
@property (assign, nonatomic) int gatewayNum;
//@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

@property (strong, nonatomic) IBOutlet UILabel *labelAD;
@property (strong, nonatomic) IBOutlet UILabel *labelReset;
@property (strong, nonatomic) IBOutlet UILabel *labelCloudSetting;


@end

@implementation PLCloudSettingsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isConnectToCloudServer = NO;
    if (IS_IPHONE5)
    {
//        self.labelTitle.font = fontCustom(15);
        self.labelCloudSetting.font = fontCustom(15);
        self.labelAD.font = fontCustom(15);
        self.labelCloudServer.font = fontCustom(15);
        self.labelReset.font = fontCustom(15);
        
    }
    else
    {
//        self.labelTitle.font = fontCustom(15);
        self.labelCloudSetting.font = fontCustom(15);
        self.labelAD.font = fontCustom(15);
        self.labelCloudServer.font = fontCustom(15);
        self.labelReset.font = fontCustom(15);
    }
    
//    self.labelTitle.text = NSLocalizedString(@"Cloud Settings", nil);
    self.labelCloudSetting.text = NSLocalizedString(@"Cloud Settings", nil);
    self.labelAD.text = NSLocalizedString(@"Address- ", nil);
    self.labelReset.text = NSLocalizedString(@"Reset Cloud", nil);
    

    NSString *strCloudServer = [[PLNetworkManager sharedManager] cloudServerAddress];
    if (strCloudServer.length)
    {
        self.labelCloudServer.text = [[PLNetworkManager sharedManager] cloudServerAddress];
    }
    else
    {
        self.labelCloudServer.text = @"cloud.cloudServier.com";
    }
    
    
    //接收到CredentialSendResponse 获取到gateway的个数
    //连接CloudSever接收消息
    didConnectColoudServer = [[NSNotificationCenter defaultCenter] addObserverForName:DidConnectedToCloudServer
                                                                               object:nil
                                                                                queue:[NSOperationQueue mainQueue]
                                                                           usingBlock:^(NSNotification *note) {
                                                                               
                                                                               self.isConnectToCloudServer = YES;
                                                                               [[PLNetworkManager sharedManager] sendDeviceTokenToCloudServer];
                                                                           }];
    
    //接收到CredentialSendResponse 获取到gateway的个数
    didGotGatewayNum = [[NSNotificationCenter defaultCenter] addObserverForName:ReceiveCredentialSendResponse
                                                                         object:nil
                                                                          queue:[NSOperationQueue mainQueue]
                                                                     usingBlock:^(NSNotification *note) {
                                                                         
                                                                         HideHUD;
                                                                        self.gatewayNum = (int)[note.object integerValue];
                                                                         
                                                                         _mutipleGatewaysV = [[PLMutipleGatewaysView alloc]
                                                                                              initWithFrame:CGRectMake(20,155,280,240)];
                                                                         _mutipleGatewaysV.delegate = self;
                                                                         NSMutableArray *dataSoruceArr = [NSMutableArray new];
                                                                         for (int i = 0 ; i < self.gatewayNum; i ++)
                                                                         {
                                                                             NSString *strGatwayName = [NSString stringWithFormat:@"Gateway-%d",i];
                                                                             [dataSoruceArr addObject:strGatwayName];
                                                                         }
                                                                         _mutipleGatewaysV.mutArrGateway = dataSoruceArr;
                                                                         [self.view addSubview:_mutipleGatewaysV];
                                                                         [self makeViewRoundWithView:_mutipleGatewaysV];
                                                                     }];
    

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

#pragma mark - PLMutipleGatewaysViewDelegate  method -
- (void)getGateWay:(NSInteger )strGateway
{
    [[PLNetworkManager sharedManager] gatewayChooseWithGatewayID:[NSString stringWithFormat:@"%ld",(long)strGateway]];
    [[PLNetworkManager sharedManager] startCheckDeviceList];
}


- (IBAction)btnAddressPressed:(UIButton *)sender
{
    // 点击修改cloudServer
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                        message:NSLocalizedString(@"Please input your new Cloudserver", nil)
                                       delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                              otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textFieldEmail = [alert textFieldAtIndex:0];
    textFieldEmail.placeholder = NSLocalizedString(@"Please input your new Cloudserver", nil);
    alert.tag = 101;
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101)
    {
//        UITextField *textFieldClod = [alertView textFieldAtIndex:0];
//        if (buttonIndex)
//        {
//            ShowHUD;
//            self.labelCloudServer.text = textFieldClod.text;
//            [self performSelector:@selector(judgeTimeOutConnectCloudserver)
//                       withObject:nil
//                       afterDelay:15.f];
//            [[PLNetworkManager sharedManager] setCloudServerAddress:textFieldClod.text];
//            
//            if ([[PLNetworkManager sharedManager] currentServerType] == CloudServerType)
//            {
//                [[PLNetworkManager sharedManager] connectToCloudServer];
//            }
//            else
//            {
//                
//            }
//            
//            
//            
//        }
//        else
//        {
//            self.labelCloudServer.text = nil;
//        }
        UITextField *textFieldClod = [alertView textFieldAtIndex:0];
        if (buttonIndex)
        {
            ShowHUD;
            if (!textFieldClod.text.length)
            {
                
            }
            else
            {
                self.labelCloudServer.text = textFieldClod.text;
            }
            
            [self performSelector:@selector(judgeTimeOutConnectCloudserver)
                       withObject:nil
                       afterDelay:15.f];
            [[PLNetworkManager sharedManager] setCloudServerAddress:textFieldClod.text];
            
            if ([[PLNetworkManager sharedManager] currentServerType] == CloudServerType)
            {
                [[PLNetworkManager sharedManager] connectToCloudServer];
            }
            else
            {
                
            }
            
            
            
        }
        else
        {
            //            self.labelCloudServer.text = nil;
        }
    }
    else if (alertView.tag == 102)
    {
        if (buttonIndex)
        {
            self.labelCloudServer.text = [[PLNetworkManager sharedManager] cloudServerAddress];
        }
    }
}


- (void)judgeTimeOutConnectCloudserver
{
    HideHUD;
    if (!self.isConnectToCloudServer)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                        message:NSLocalizedString(@" Connection to cloud server failed！", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                        message:NSLocalizedString(@"Connect the cloud server successfully !", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}


- (IBAction)btnResetCloudPressed:(UIButton *)sender
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Reset the cloud to factory defaults?", nil)
                                                    message:NSLocalizedString(@" Warning : this will erase all settings!", nil)
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES", nil];
    alter.tag = 102;
    [alter show];
}


- (IBAction)btnBackPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
