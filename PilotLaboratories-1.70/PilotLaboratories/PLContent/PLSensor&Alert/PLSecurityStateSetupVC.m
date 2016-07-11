//
//  PLSecurityStateSetupVC.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-7.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLSecurityStateSetupVC.h"
#import "CustomSecurityStateSetupCell.h"
#import "PLCustomLongPressCellAlter.h"

@interface PLSecurityStateSetupVC ()<CustomSecurityStateSetupCellDelegate,PLCustomLongPressCellAlterDelegate>
{
    id didSecutySetup;
}

//@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelSetup;
@property (strong, nonatomic) NSArray *arrDatasource;
@property (strong, nonatomic) CustomSecurityStateSetupCell *moveTableViewCell;
@property (strong, nonatomic) IBOutlet UITableView *tableViewSetup;
@property (strong, nonatomic) PLCustomLongPressCellAlter *alter;
@end

@implementation PLSecurityStateSetupVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.arrDatasource = [NSArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidDiscoveryDevice:)
                                                 name:DidDiscoveryDevice
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSenorState:)
                                                 name:SecurityStateRequestSucceed
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSecurityStateSelectSucceed:)
                                                 name:SecurityStateSelectSucceed
                                               object:nil];
//    NSString *strTemp = NSLocalizedString(@"Away/Arm", nil);
    
    NSString *strTemp;
    if ([self.strIdentifer isEqualToString:@"Away/Arm"])
    {
        strTemp = NSLocalizedString(@"Away/Arm", nil);
    }
    else if ([self.strIdentifer isEqualToString:@"Home/Arm"])
    {
        strTemp = NSLocalizedString(@"Home/Arm", nil);
    }
    else if ([self.strIdentifer isEqualToString:@"Disam"])
    {
        strTemp = NSLocalizedString(@"Disarm", nil);
    }
    NSString *strTempTwo = NSLocalizedString(@"Setup", nil);
    
    self.labelSetup.text = [NSString stringWithFormat:@"%@%@",strTemp,strTempTwo];
    
    if (IS_IPHONE5)
    {
        self.labelSetup.font = fontCustom(15);
    }
    else
    {
        _tableViewSetup.frame = CGRectMake(0, 70, 320,300);
        self.labelSetup.font= fontCustom(15);
    }
    
    //对键盘的处理
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock: ^(NSNotification *note)
     {
         [UIView animateWithDuration:.25 animations:^
          {
              // 上移刷新UI
              self.alter.frame = CGRectMake(self.alter.frame.origin.x,
                                            self.alter.frame.origin.y - 100,
                                            self.alter.frame.size.width,
                                            self.alter.frame.size.height);
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
              //              self.view.frame = self.frameRect;
              
              // 上移刷新UI
              self.alter.frame = CGRectMake(self.alter.frame.origin.x,
                                            self.alter.frame.origin.y + 100,
                                            self.alter.frame.size.width,
                                            self.alter.frame.size.height);
          }];
     }];
    
    ShowHUD;
    /**
     *  查询传感器状态
     */
    [[PLNetworkManager sharedManager] performSelector:@selector(securityStateRequest) withObject:nil afterDelay:1];
}

- (void)handleDidDiscoveryDevice:(NSNotification *)noti
{
    ShowHUD;
    [[PLNetworkManager sharedManager] performSelector:@selector(securityStateRequest) withObject:nil afterDelay:1];
}

#pragma mark - 查询到传感器状态 -
- (void)handleSenorState:(NSNotification *)noti
{
    self.arrDatasource = [[PLNetworkManager sharedManager] sensorArr];
    [self.tableViewSetup reloadData];
    HideHUD;
}

- (void)handleSecurityStateSelectSucceed:(NSNotification *)notification
{
    HideHUD;
}

#pragma mark - tableview datasource and delegate  -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrDatasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomSecurityStateSetupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomSecurityStateSetupCell"];
    if (!cell)
    {
        cell = [[CustomSecurityStateSetupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomSecurityStateSetupCell"];
        cell.labelSensor.font = fontCustom(15);
    }
    
    PLModel_Device *device = self.arrDatasource[indexPath.row];
    [cell setcellinfo:device withindex:indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.moveTableViewCell = (CustomSecurityStateSetupCell *)[self.tableViewSetup cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self longPressCell:indexPath];
}

- (void)longPressCell:(NSIndexPath *)indexPath
{
    PLCustomLongPressCellAlter *alter = [PLCustomLongPressCellAlter new];
    alter.delegate = self;
    [alter show];
}

#pragma mark - PLCustomLongPressCellAlterDelegate -
- (void)btnOKPressedWithName:(NSString *)strChangeName
{
    //获取更改后开关的名字
    
    //单个cell 刷新
    NSIndexPath *indexPathTemp = [self.tableViewSetup indexPathForCell:self.moveTableViewCell];
    
    PLModel_Device *device = self.arrDatasource[indexPathTemp.row];
    device.deviceName = strChangeName;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexPathTemp.row inSection:0];
    [self.tableViewSetup reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil]
                               withRowAnimation:UITableViewRowAnimationNone];
}


- (void)swichPressedOnCell:(CustomSecurityStateSetupCell *)cell andSwichStatus:(BOOL)status
{
    NSIndexPath *indexPath = [self.tableViewSetup indexPathForCell:cell];
    PLModel_Device *model = self.arrDatasource[indexPath.row];
    if (status)
    {
        model.onOff = 1;
    }
    else
    {
        model.onOff = 0;
    }
    
    
    
    ShowHUD;
    if ([self.strIdentifer isEqual:NSLocalizedString(@"Away/Arm", nil)])
    {
        [[PLNetworkManager sharedManager] securityStateSelectWithType:AwayArmType Device:model];
    }
    else if ([self.strIdentifer isEqual:NSLocalizedString(@"Home/Arm", nil)])
    {
        [[PLNetworkManager sharedManager] securityStateSelectWithType:HomeArmType Device:model];
    }
    else
    {
        [[PLNetworkManager sharedManager] securityStateSelectWithType:DisArmType Device:model];
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
