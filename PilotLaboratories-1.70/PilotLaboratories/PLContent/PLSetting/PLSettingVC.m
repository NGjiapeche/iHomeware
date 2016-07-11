//
//  PLSettingVC.m
//  PilotLaboratories
//
//  Created by frontier on 14-3-20.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLSettingVC.h"
#import "PLCustomAlterView.h"
#import "PLHelper.h"

@interface PLSettingVC ()<PLCustomAlterViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableViewSetup;
@property (strong, nonatomic) NSArray *arrDatasource;
@property (strong, nonatomic) IBOutlet UILabel *labelSetupTItle;

@end

@implementation PLSettingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.tabBarController.tabBar.selectedImageTintColor = COLOR_RGB(205, 51, 255);
    if (IS_IPHONE5)
    {
       self.labelSetupTItle.font = fontCustom(15);
    }
    else
    {
       self.labelSetupTItle.font = fontCustom(15);
    }
    

    self.labelSetupTItle.text = NSLocalizedString(@"Setup", nil);
//    self.arrDatasource = @[NSLocalizedString(@"User Preferences", nil),NSLocalizedString(@"Device Settings", nil),NSLocalizedString(@"Gateway Settings", nil),NSLocalizedString(@"Cloud Settings", nil),NSLocalizedString(@"Application Settings", nil)];
    self.arrDatasource = @[NSLocalizedString(@"User Email", nil),NSLocalizedString(@"Gateway Settings", nil),NSLocalizedString(@"Cloud Settings", nil),NSLocalizedString(@"Application Settings", nil)];
    
}

#pragma mark -tableView delegate and dataSource  -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrDatasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifer];
        cell.textLabel.font = fontCustom(15);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",self.arrDatasource[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    switch (indexPath.row)
//    {
//        case 0:
//        {
//            //SEG_TO_PLUserPreferencesVC
//            [self performSegueWithIdentifier:SEG_TO_PLUserPreferencesVC sender:self];
//        }
//            break;
//        case 1:
//        {
//            [self performSegueWithIdentifier:SEG_TO_PLDeviceSettingsVC sender:self];
//        }
//            break;
//        case 2:
//        {
//            [self performSegueWithIdentifier:SEG_TO_PLGatewaySettingsVC sender:self];
//        }
//            break;
//        case 3:
//        {
//            [self performSegueWithIdentifier:SEG_TO_PLCloudSettingsVC sender:self];
//        }
//            break;
//        case 4:
//        {
//            [self performSegueWithIdentifier:SEG_TO_PLApplicationSettingsVC sender:self];
//        }
//            break;
//            
//        default:
//            break;
//    }
    
    switch (indexPath.row)
    {
        case 0:
        {
            [self performSegueWithIdentifier:SEG_TO_PLUserPreferencesVC sender:self];
        }
            break;
        case 1:
        {
            [self performSegueWithIdentifier:SEG_TO_PLGatewaySettingsVC sender:self];
        }
            break;
        case 2:
        {
            [self performSegueWithIdentifier:SEG_TO_PLCloudSettingsVC sender:self];
        }
            break;
        case 3:
        {
            //[self performSegueWithIdentifier:SEG_TO_PLApplicationSettingsVC sender:self];
            CGRect frame = [UIScreen mainScreen].bounds;
            PLCustomAlterView *customView = [[PLCustomAlterView alloc] initWithFrame:frame];
            customView.title = @"About";
            customView.delegate = self;
            customView.dataSourceArr = @[NSLocalizedString(@"Home Automation Center", nil),NSLocalizedString(@"Build 1.1", nil),NSLocalizedString(@"Date 2014/11/1", nil),NSLocalizedString(@"Copyright © 2014 Pilot Laboratories", nil),@"“OK” button to clear"];
            [customView show];
        }
            break;
            
        default:
            break;
    }
}

- (void)baseSelectViewBackGroundDidClicked:(PLCustomAlterView *)view
{
    [view removeFromSuperview];
}


@end
