//
//  PLRootTabBarController.m
//  PilotLaboratories
//
//  Created by frontier on 14-3-20.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLRootTabBarController.h"
#import "PLLightingMainVC.h"
#import "PLAppDelegate.h"
@interface PLRootTabBarController ()<UITabBarControllerDelegate>
{
//    UIViewController *lightingVC;
    PLLightingMainVC *lightingMain;
    UIViewController *sensorAndAlertVC;
    UIViewController *switchVC;
    UIViewController *settingVC;
    PLAppDelegate *_appd;
}

@end

@implementation PLRootTabBarController
- (void)viewDidAppear:(BOOL)animated
{
    //如果是点击推送消息打开app的，进入这个页面通知他来解析存推送消息
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PLSensorAndAlertVCLoaded" object:nil];
    
    NSUserDefaults *mydefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr =[NSMutableArray arrayWithArray: [mydefault objectForKey:@"gatwangname"]];
   _appd.cINdexName = [NSString stringWithFormat:@"---%@",[arr objectAtIndex:_appd.cINdex]];
   
}
-(void)viewWillAppear:(BOOL)animated{
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    _appd = [[UIApplication sharedApplication]delegate];
//    [[PLNetworkManager sharedManager]saveWifiNameAndGateWayIPAddress];
    
//    UIStoryboard *PLLightingStoryBoard = [UIStoryboard storyboardWithName:STORYBOARD_PLLIGHTING
//                                                                   bundle:[NSBundle mainBundle]];
//    
//    lightingVC = PLLightingStoryBoard.instantiateInitialViewController;
//    UITabBarItem *tabBarItemOne = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Lighting", nil) image:[UIImage imageNamed:@"itemLighting.png"] tag:0];
//    lightingVC.tabBarItem = tabBarItemOne;
    
    UIStoryboard *PLLightingMainStoryBoard = [UIStoryboard storyboardWithName:@"PLLightingMainVC"
                                                                   bundle:[NSBundle mainBundle]];
    
    lightingMain = PLLightingMainStoryBoard.instantiateInitialViewController;
    UITabBarItem *tabBarItemOne = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Lighting", nil) image:[UIImage imageNamed:@"itemLighting.png"] tag:0];
    lightingMain.tabBarItem = tabBarItemOne;
    
    
    UIStoryboard *PLSensorAndAlertStoryBoard = [UIStoryboard storyboardWithName:STORYBOARD_PLSENSOR_AND_ALERT
                                                                   bundle:[NSBundle mainBundle]];
    sensorAndAlertVC = PLSensorAndAlertStoryBoard.instantiateInitialViewController;
    UITabBarItem *tabBarItemTwo = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Sensor&Alert", nil) image:[UIImage imageNamed:@"itemSensor.png"] tag:1];
    sensorAndAlertVC.tabBarItem = tabBarItemTwo;
    
    UIStoryboard *PLSwitchBoard = [UIStoryboard storyboardWithName:STORYBOARD_PLSWITCH
                                                                   bundle:[NSBundle mainBundle]];
    switchVC = PLSwitchBoard.instantiateInitialViewController;
    UITabBarItem *tabBarItemThree = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"SwitchBoard", nil) image:[UIImage imageNamed:@"itemSwitch.png"] tag:2];
    switchVC.tabBarItem = tabBarItemThree;
    
    
    UIStoryboard *PLSettingBoard = [UIStoryboard storyboardWithName:STORYBOARD_PLSETTING
                                                                   bundle:[NSBundle mainBundle]];
    settingVC = PLSettingBoard.instantiateInitialViewController;
    UITabBarItem *tabBarItemFour = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Setting", nil) image:[UIImage imageNamed:@"itemSetting.png"] tag:3];
    settingVC.tabBarItem = tabBarItemFour;
    
    NSString *ligntcountst = [NSString stringWithFormat:@"%lu",(unsigned long)[[[PLNetworkManager sharedManager]lightsArr]count]];
    lightingMain.tabBarItem.badgeValue = ligntcountst;
    NSString *sensorcountst = [NSString stringWithFormat:@"%lu",(unsigned long)[[[PLNetworkManager sharedManager]sensorArr]count]];
    sensorAndAlertVC.tabBarItem.badgeValue = sensorcountst;
    NSString *Switchcountst = [NSString stringWithFormat:@"%lu",(unsigned long)[[[PLNetworkManager sharedManager]switchArr]count]];
    switchVC.tabBarItem.badgeValue = Switchcountst;
    
    NSArray *viewControllers = [NSArray arrayWithObjects:lightingMain,sensorAndAlertVC,switchVC,settingVC, nil];
    self.viewControllers = viewControllers;
    self.selectedIndex = 1;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kvolikeselector:) name:@"Thebadgevalue" object:nil];

}
-(void)kvolikeselector:(NSNotification *)noti{
    NSArray *arr = (NSArray*)noti.object;
    lightingMain.tabBarItem.badgeValue = arr[0];
    sensorAndAlertVC.tabBarItem.badgeValue = arr[1];
    switchVC.tabBarItem.badgeValue = arr[2];
    if (_appd.ishowbagevalue) {
        settingVC.tabBarItem.badgeValue = @"!";
    }else{
        settingVC.tabBarItem.badgeValue = nil;

    }
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    if (selectedIndex == 1)
    {
        [self.tabBar.selectedItem setTitle:NSLocalizedString(@"Security", nil)];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (viewController == lightingMain)
    {
        self.tabBar.selectedImageTintColor = COLOR_RGB(0, 122, 255);
    }
    else if (viewController == sensorAndAlertVC)
    {
        self.tabBar.selectedImageTintColor = COLOR_RGB(255, 76, 76);
    }
    else if (viewController == switchVC)
    {
        self.tabBar.selectedImageTintColor = COLOR_RGB(36, 209, 66);
    }
    else if (viewController == settingVC)
    {
      self.tabBar.selectedImageTintColor = COLOR_RGB(205, 51, 255);
    }
}



@end
