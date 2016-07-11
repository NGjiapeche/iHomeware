//
//  PLAlertsVC.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-7.
//  Copyright (c) 2014年 yct. All rights reserved.
//

//*********************************
//此出的数据源是有报警主页面处理，这里只需要获取
//NSMutableArray *mutArrArmInfo = [[PLSaveAlarmInfo sharedManager] mutArrAlarm];
//**********************************

#import "PLAlertsVC.h"
#import "PLSensorDetailVC.h"
#import "PLSensorAndAlertVC.h"
#import "PLAlertsCell.h"

@interface PLAlertsVC ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableViewAlerts;
@property (strong, nonatomic) PLModel_Device *device;
@property (strong, nonatomic) NSMutableArray *mutArrDatasource;
@property (strong, nonatomic) NSMutableArray *TimeArrDatasource;//警报按时间排序
@property (strong, nonatomic) IBOutlet UIButton *btnAlterBack;
@property (strong, nonatomic) IBOutlet UILabel *labelAlterTItle;

@end

@implementation PLAlertsVC
-(NSMutableArray *)mutArrDatasource{
    if (_mutArrDatasource == nil) {
        NSMutableArray *mutArrArmInfo = [[PLSaveAlarmInfo sharedManager] mutArrAlarm];
        _mutArrDatasource  = [NSMutableArray arrayWithArray:mutArrArmInfo];
    } 
    return _mutArrDatasource;
 
}
-(NSMutableArray *)TimeArrDatasource{
    //    if (_TimeArrDatasource == nil) {
    _TimeArrDatasource = [NSMutableArray array];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    for (int i = 0; i < self.mutArrDatasource.count;  ++i) {
        
        PLModel_Device *deviceA = self.mutArrDatasource[i];
        NSString *timestrA = deviceA.deviceAlertTime;
        NSDate *dateA = [dateFormatter dateFromString:timestrA];
        PLModel_Device *maxTimeDevice = deviceA;
        
        for (int j = 1; j < self.mutArrDatasource.count - 1; ++j)
        {
            PLModel_Device *deviceB = self.mutArrDatasource[i];
            NSString *timestrB = deviceB.deviceAlertTime;
            NSDate *dateB = [dateFormatter dateFromString:timestrB];
            
            
            NSComparisonResult result = [dateA compare:dateB];
            if (result == NSOrderedDescending || result == NSOrderedSame) {
                
            }
            else if (result == NSOrderedAscending){
                dateA = dateB;
                maxTimeDevice = deviceB;
                
            }
            
        }
        //保存最大的
        [_TimeArrDatasource addObject:maxTimeDevice];
    }
    //    }
    return _TimeArrDatasource;
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_IPHONE5)
    {
        self.labelAlterTItle.font = fontCustom(15)
    }
    else
    {
       self.labelAlterTItle.font = fontCustom(15)
        _tableViewAlerts.frame = CGRectMake(0, 72, 320, 310);
    }
    
    self.labelAlterTItle.textColor = itemSenorColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReceiveAlarmInform:)
                                                 name:ReceiveAlarmInform
                                               object:nil];
 
    /**
     *  查询传感器状态
     */
    [[PLNetworkManager sharedManager] performSelector:@selector(securityStateRequest) withObject:nil afterDelay:0.5];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableViewAlerts reloadData];
}

- (void)handleDidDiscoveryDevice:(NSNotification *)notification
{
    [self.tableViewAlerts reloadData];
}


#pragma mark - 处理获取到的报警信息 -

- (void)handleReceiveAlarmInform:(NSNotification *)noti
{
    
    [self.tableViewAlerts reloadData];
}

#pragma mark -tableView delegate and dataSource  -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mutArrDatasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLAlertsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlertCell"];
    if (!cell)
    {
        cell = [[PLAlertsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AlertCell"];
     
    }
    PLModel_Device *device = self.TimeArrDatasource[indexPath.row];
    
    if (device.isAlerting)
    {
        cell.iconImgView.image = [UIImage imageNamed:@"mark100"];
    }
    else
    {
        cell.iconImgView.image = nil;
    }
    [cell setcelldevicename:device withindex:indexPath.row];

//    if (device.deviceName)
//    {
//        cell.titleLabel.text = [NSString stringWithFormat:@"%@",device.deviceName];
//    }
//    else
//    {
//        NSString *deviceName;
//        switch (device.deviceType)
//        {
//            case TemperatureSensorType:
//            {
//                NSString *strTemp = [NSString stringWithFormat:NSLocalizedString(@"TemperatureSensor%d", nil),indexPath.row + 1];
//                deviceName = strTemp;
//            }
//                break;
//                
//            case DoorSensorType:
//            {
//                NSString *strTemp = [NSString stringWithFormat:NSLocalizedString(@"DoorSensor%d", nil),indexPath.row + 1];
//                deviceName = strTemp;
//            }
//                break;
//                
//            case PirSensorType:
//            {
//                NSString *strTemp = [NSString stringWithFormat:NSLocalizedString(@"PirSensor%d", nil),indexPath.row + 1];
//                deviceName = strTemp;
//            }
//                break;
//                
//            case VibrationSensorType:
//            {
//                NSString *strTemp = [NSString stringWithFormat:NSLocalizedString(@"CoinGuard%d", nil),indexPath.row + 1];
//                deviceName = strTemp;
//            }
//                break;
//            case SmokeSensorType:
//            {
//                NSString *strTemp = [NSString stringWithFormat:NSLocalizedString(@"SmokeSensor%d", nil),indexPath.row + 1];
//                deviceName = strTemp;
//            }
//                break;
//            case CO2SenserType:
//            {
//                NSString *strTemp = [NSString stringWithFormat:NSLocalizedString(@"CO2Senser%d", nil),indexPath.row + 1];
//                deviceName = strTemp;
//            }
//                break;
//            case COSenserType:
//            {
//                NSString *strTemp = [NSString stringWithFormat:NSLocalizedString(@"COSenser%d", nil),indexPath.row + 1];
//                deviceName = strTemp;
//            }
//                break;
//            case WaterSensorType:
//            {
//                NSString *strTemp = [NSString stringWithFormat:NSLocalizedString(@"WaterSensor%d", nil),indexPath.row + 1];
//                deviceName = strTemp;
//            }
//                break;
//            case PanicSensorType:
//            {
//                NSString *strTemp = [NSString stringWithFormat:NSLocalizedString(@"PanicSensor%d", nil),indexPath.row + 1];
//                deviceName = strTemp;
//            }
//                break;
//                
//            default:
//                break;
//        }
//        device.deviceName =deviceName;
//        cell.titleLabel.text = deviceName;
//    }
    cell.subTitleLabel.text = [NSString stringWithFormat:@"%@",device.deviceAlertTime];
    cell.titleLabel.font = fontCustom(15);
    cell.subTitleLabel.font = fontCustom(15);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.device = [[PLSaveAlarmInfo sharedManager] mutArrAlarm][indexPath.row];
    
    for (PLModel_Device *device in  [[PLNetworkManager sharedManager] sensorArr]) {
    
        if ([self.device.macAddress isEqualToData:device.macAddress]) {
            self.device=device;
      
        }

    }
    
    self.device.isAlerting = NO;
    [self performSegueWithIdentifier:SEG_TO_PLSENSORDETAILVC sender:self];
}

- (IBAction)btnBackPressed:(UIButton *)sender
{
    PLSensorAndAlertVC *vc = self.navigationController.viewControllers[0];
    vc.isCancellArm = YES;
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEG_TO_PLSENSORDETAILVC])
    {
        PLSensorDetailVC *vc = (PLSensorDetailVC *)segue.destinationViewController;
        vc.device = self.device;

        vc.strIdentifier = self.strIdentifer;
    }
}

@end
