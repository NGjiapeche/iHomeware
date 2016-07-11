//
//  PLSensorDetailVC.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-7.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLSensorDetailVC.h"
#import "PLCustomLongPressCellAlter.h"

@interface PLSensorDetailVC ()<PLCustomLongPressCellAlterDelegate>
@property (strong, nonatomic) IBOutlet UISwitch *switchEnableAlert;
@property (strong, nonatomic) IBOutlet UILabel *labelCurrentStatus;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *enableAlertLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentStatusTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *triggeredHistoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeNameBtn;

@end

@implementation PLSensorDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.device.isAlerting)
    {
        self.switchEnableAlert.on = YES;
        self.labelCurrentStatus.text = NSLocalizedString(@"Triggered", nil);
    }
    else
    {
        self.switchEnableAlert.on = NO;
        self.labelCurrentStatus.text = NSLocalizedString(@"untriggered", nil);
        
    }
    
    if (self.device.onOff)
    {
        self.switchEnableAlert.on = YES;
    }
    else
    {
        self.switchEnableAlert.on = NO;
    }
    
    self.labelTitle.text = self.device.deviceName;
    self.labelCurrentStatus.font = fontCustom(15);
    self.labelTitle.font = fontCustom(15);
    self.enableAlertLabel.font = fontCustom(15);
    self.currentStatusTitleLabel.font = fontCustom(15);
    self.triggeredHistoryLabel.font = fontCustom(15);
    self.changeNameBtn.titleLabel.font = fontCustom(15);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSenorState:)
                                                 name:SecurityStateRequestSucceed
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSecurityStateSelectSucceed:)
                                                 name:SecurityStateSelectSucceed
                                               object:nil];
    /**
     *  查询传感器状态
     */
    [[PLNetworkManager sharedManager] performSelector:@selector(securityStateRequest) withObject:nil afterDelay:0.5];
}
#pragma mark - 查询到传感器状态 -
- (void)handleSenorState:(NSNotification *)noti
{
    HideHUD;
}

- (void)handleSecurityStateSelectSucceed:(NSNotification *)notification
{
    HideHUD;
}
- (void)viewWillAppear:(BOOL)animated
{

}

#pragma mark -tableView delegate and dataSource  -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.device.alertTimeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",self.device.alertTimeList[indexPath.row]];
    cell.textLabel.font = fontCustom(15);;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)backBtnPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnChangeNamePressed:(UIButton *)sender
{
    PLCustomLongPressCellAlter *alter = [[PLCustomLongPressCellAlter alloc] init];
    alter.delegate = self;
    [alter show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PLCustomLongPressCellAlterDelegate -

- (void)btnOKPressedWithName:(NSString *)strChangeName
{
            self.device.deviceName = strChangeName;
            self.labelTitle.text = strChangeName;
}

- (IBAction)switchEnableAlertPressed:(UISwitch *)sender
{
    if (sender.isOn)
    {
       self.device.onOff = YES;
    }
    else
    {
        self.device.onOff = NO;
    }
    
    
    SecurityStateType typeClass;
    
    if   ([self.strIdentifier isEqualToString:isHome])
    {
        typeClass = HomeArmType;
     
    }
    else if ([self.strIdentifier isEqualToString:isAway])
    
    {
        typeClass = AwayArmType;
    }
    else
    {
        typeClass = DisArmType;
    }
    
    [[PLNetworkManager sharedManager] securityStateSelectWithType:typeClass Device:self.device];
    ShowHUD;
//     [[PLNetworkManager sharedManager] securityStateSelectWithType:DisArmType Device:model];
}
//SecurityStateRequestSucceed

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
