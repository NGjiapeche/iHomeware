//
//  PLApplicationSettingsVC.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-8.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLApplicationSettingsVC.h"
#import "PLCustomAlterView.h"
#import "PLNotiAndAlerts.h"
#import "ZMYVersionNotes.h"

#define notiPhone NSLocalizedString(@"Mobile phone notification", nil)
#define notiEmail NSLocalizedString(@"Email notification", nil)

@interface PLApplicationSettingsVC ()<PLCustomAlterViewDelegate,PLNotiAndAlertsDelegate>
{
    NSString *url;
}
@property (strong, nonatomic) IBOutlet UILabel *labelUpdate;

//@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

//调字体大小
@property (strong, nonatomic) IBOutlet UILabel *labeleUpdateMain;
@property (strong, nonatomic) IBOutlet UILabel *labelUninstall;
@property (strong, nonatomic) IBOutlet UILabel *labelAbout;
@property (strong, nonatomic) IBOutlet UILabel *labelNoti;
@property (strong, nonatomic) IBOutlet UILabel *labelSettingTitle;

@end

@implementation PLApplicationSettingsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IS_IPHONE5)
    {
        self.labelSettingTitle.font = fontCustom(15);
        self.labelUpdate.font = fontCustom(15);
        self.labeleUpdateMain.font = fontCustom(15);
        self.labelUninstall.font = fontCustom(15);
        self.labelAbout.font = fontCustom(15);
        self.labelNoti.font = fontCustom(15);
    }
    else
    {
        self.labelSettingTitle.font = fontCustom(15);
        self.labelUpdate.font = fontCustom(15);
        self.labeleUpdateMain.font = fontCustom(15);
        self.labelUninstall.font = fontCustom(15);
        self.labelAbout.font = fontCustom(15);
        self.labelNoti.font = fontCustom(15);
    }
    
    self.labelSettingTitle.text = NSLocalizedString(@"Application Settings", nil);
    self.labelNoti.text = NSLocalizedString(@"Notifications & Alerts", nil);
    self.labeleUpdateMain.text = NSLocalizedString(@"Update -", nil);
    self.labelUpdate.text = NSLocalizedString(@"no update available", nil);
    self.labelUninstall.text = NSLocalizedString(@"Uninstall", nil);
    self.labelAbout.text = NSLocalizedString(@"About", nil);
    
    
    
}

#pragma mark - notifications & alerts  -

- (IBAction)btnNotificationsPressed:(UIButton *)sender
{
    CGRect frame = [UIScreen mainScreen].bounds;
    PLNotiAndAlerts *alter = [PLNotiAndAlerts new];
    alter.frame = frame;
    alter.arrGateways = @[notiPhone,notiEmail];
    alter.delegate =self;
    [alter show];
}

- (void)cellOnWifiDidSelected:(NSString *)notiFrom withView:(PLNotiAndAlerts *)alterView
{
    if ([notiFrom isEqualToString:notiPhone])
    {
        DebugLog(@"发送到手机");
    }
    else
    {
        DebugLog(@"发送到邮箱");
    }
}

#pragma mark - update pressed  -

- (IBAction)btnUpdatePressed:(UIButton *)sender
{
    ShowHUD;
    //https://itunes.apple.com/cn/app/pilotlaboratories/id923823120?l=en&mt=8
    [ZMYVersionNotes isOrNotTheLatestVersionInformationWithAppIdentifier:@"923823120" isOrNotTheLatestVersionCompletionBlock:^(BOOL isLatestVersion, NSString *releaseNoteText, NSString *releaseVersionText, NSDictionary *resultDic) {
        if (isLatestVersion) {
            HideHUD;
            UIAlertView *createUserResponseAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no update available", nil) message:releaseNoteText delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            createUserResponseAlert.tag = 1101;
            [createUserResponseAlert show];
        }else{
            HideHUD;
//            UIAlertView *createUserResponseAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"有新版本:%@", releaseVersionText] message:releaseNoteText delegate:self cancelButtonTitle:@"忽略" otherButtonTitles: @"进行下载", @"下次再说",nil];
            
            UIAlertView *createUserResponseAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New update available, install now?", nil) message:releaseNoteText delegate:self cancelButtonTitle:@"NO" otherButtonTitles: @"YES",nil];
            url = [resultDic objectForKey:@"trackViewUrl"];
            createUserResponseAlert.tag = 1102;
            [createUserResponseAlert show];
        }
    } completionBlockError:^(NSError *error) {
        HideHUD;
        DebugLog(@"An error occurred: %@", [error localizedDescription]);
        
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:WarmPrompt message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alter.tag = 1103;
        [alter show];
    }];

}

#pragma mark - uninstall pressed -

- (IBAction)btnUninstallPressed:(UIButton *)sender
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                    message:NSLocalizedString(@" Please uninstall this software manually", nil)
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    alter.tag = 102;
    [alter show];
}

#pragma mark - About pressed -

- (IBAction)btnAboutPressed:(UIButton *)sender
{
    CGRect frame = [UIScreen mainScreen].bounds;
    PLCustomAlterView *customView = [[PLCustomAlterView alloc] initWithFrame:frame];
    customView.title = @"About";
    customView.delegate = self;
    
    
    customView.dataSourceArr = @[NSLocalizedString(@"Home Automation Center", nil),NSLocalizedString(@"Build 1.1", nil),NSLocalizedString(@"Date 2014/11/1", nil),NSLocalizedString(@"Copyright © 2014 Pilot Laboratories", nil),@"“OK” button to clear"];
    [customView show];
}

- (void)baseSelectViewBackGroundDidClicked:(PLCustomAlterView *)view
{
    [view removeFromSuperview];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case 102:
        {
            if (buttonIndex == 1)
            {
                //经行更新操作
                DebugLog(@"*******经行uninstall*********");
            }
        }
            break;
        case 1102:
        {
            switch (buttonIndex) {
                case 1:
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)btnBackPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
