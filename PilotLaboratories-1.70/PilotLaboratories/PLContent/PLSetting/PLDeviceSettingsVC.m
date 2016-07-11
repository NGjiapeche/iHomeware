//
//  PLDeviceSettingsVC.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-8.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLDeviceSettingsVC.h"
#import "PLConfigureADeviceVC.h"

#define alterNewDeviceTag 101

@interface PLDeviceSettingsVC ()<MBProgressHUDDelegate,UIAlertViewDelegate>
{
    MBProgressHUD *HUD;
    id didGotNewDevice;
}

@property (strong, nonatomic) NSArray *arrNewDevices;
@property (strong, nonatomic) IBOutlet UIButton *btnConfigureADevice;
//@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelDeviceTitle;

@property (strong, nonatomic) IBOutlet UILabel *labelSearch;
@property (strong, nonatomic) IBOutlet UILabel *labelConfigure;

@end
@implementation PLDeviceSettingsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.arrNewDevices = [NSArray new];
    if (IS_IPHONE5)
    {
//        self.labelTitle.font = fontCustom(15);
        self.labelDeviceTitle.font = fontCustom(15);
        self.labelSearch.font = fontCustom(15);
        self.labelConfigure.font = fontCustom(15);
    }
    else
    {
//        self.labelTitle.font = fontCustom(15);
        self.labelDeviceTitle.font = fontCustom(15);
        self.labelSearch.font = fontCustom(15);
        self.labelConfigure.font = fontCustom(15);
    }
    
//    self.labelTitle.text = NSLocalizedString(@"Device Settings", nil);
    self.labelDeviceTitle.text = NSLocalizedString(@"Device Settings", nil);
    self.labelSearch.text = NSLocalizedString(@"Search For New Devices", nil);
    self.labelConfigure.text = NSLocalizedString(@"Configure A Device", nil);
    
    //搜索到新设备
    didGotNewDevice =[[NSNotificationCenter defaultCenter] addObserverForName:NewDeviceDiscovery
                                                                    object:nil
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification *note) {
                                                                   [HUD removeFromSuperview];
                                                                    self.arrNewDevices = note.object;
                                                                    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"Warm Prompt"
                                                                                                                    message:[NSString stringWithFormat:@"%lu X new device(s) found !",(unsigned long)self.arrNewDevices.count]
                                                                                                                   delegate:self
                                                                                                          cancelButtonTitle:nil
                                                                                                          otherButtonTitles:@"OK", nil];
                                                                    alter.tag = alterNewDeviceTag;
                                                                    [alter show];
                                                                    
                                                                } ];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSearchPressed:(UIButton *)sender
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Searching for new devices…", nil);
    [HUD show:YES];
    
    [self performSelector:@selector(judgeTimeOutSearChNewDevice) withObject:nil afterDelay:3.f];
    [[PLNetworkManager sharedManager] newDeviceDiscovery];
}

- (void)judgeTimeOutSearChNewDevice
{
    if (!self.arrNewDevices.count)
    {
        [HUD removeFromSuperview];
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                        message:NSLocalizedString(@"No new devices found", nil)
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        
        [alter show];
    }
}

- (IBAction)btnConfigureADevicePressed:(UIButton *)sender
{
//    if (!self.arrNewDevices.count) {
//        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"Warm Prompt"
//                                                        message:@"No new devices found"
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil, nil];
//        
//        [alter show];
//    }
//    else
//    {
//         [self performSegueWithIdentifier:SEG_TO_PLConfigureADeviceVC sender:self];
//    }
    [self performSegueWithIdentifier:SEG_TO_PLConfigureADeviceVC sender:self];
}
- (IBAction)btnBackPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == alterNewDeviceTag)
    {
        if (buttonIndex == 1)
        {
            [self performSegueWithIdentifier:SEG_TO_PLConfigureADeviceVC sender:self];
        }
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEG_TO_PLConfigureADeviceVC]) {
        PLConfigureADeviceVC *vc = (PLConfigureADeviceVC *)segue.destinationViewController;
        vc.arrDatasource = self.arrNewDevices;
    }
}
@end

