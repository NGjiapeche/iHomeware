//
//  PLConfigureADeviceVC.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-8.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLConfigureADeviceVC.h"
#import "PLCustomLongPressCellAlter.h"

@interface PLConfigureADeviceVC ()<PLCustomLongPressCellAlterDelegate>

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataSourceArr;
@property (strong, nonatomic) PLCustomLongPressCellAlter *alter;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation PLConfigureADeviceVC


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.labelTitle.text = NSLocalizedString(@"Configure A Device", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidDiscoveryDevice:)
                                                 name:DidDiscoveryDevice
                                               object:nil];
    if (IS_IPHONE5)
    {
        self.labelTitle.font = fontCustom(15);
    }
    else
    {
        self.labelTitle.font = fontCustom(15);
    }
    // Do any additional setup after loading the view.
    
    self.dataSourceArr = [[PLNetworkManager sharedManager] allDeviceArr];
}

- (void)handleDidDiscoveryDevice:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (IBAction)btnBackPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Controller life cycle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.dataSourceArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"TableViewCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
	PLModel_Device *device = self.dataSourceArr[indexPath.row];
    NSString *name;
    if (device.deviceType == LightType)
    {
        name = NSLocalizedString(@"  Light", nil);
    }
    else if (device.deviceType == TemperatureSensorType)
    {
        name = NSLocalizedString(@"  TemperatureSensor", nil);
    }
    else if (device.deviceType == DoorSensorType)
    {
        name = NSLocalizedString(@"  DoorSensor", nil);
    }
    else if (device.deviceType == PirSensorType)
    {
        name = NSLocalizedString(@"  PirSensor", nil);
    }
    else if (device.deviceType == SwitchType)
    {
        name = NSLocalizedString(@"  Switch", nil);
    }
    
    if (device.deviceName)
    {
        name = [name stringByAppendingString:[NSString stringWithFormat:@" - %@",device.deviceName]];
    }
    
    cell.textLabel.text = name;
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    self.alter = [PLCustomLongPressCellAlter new];
    self.alter.delegate = self;
    [self.alter show];
}

#pragma mark - PLCustomLongPressCellAlterDelegate -

- (void)btnOKPressedWithName:(NSString *)strChangeName
{
    //获取更改后开关的名字
    PLModel_Device *device = self.dataSourceArr[self.selectedIndexPath.row];
    device.deviceName = strChangeName;
    
    [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    self.alter = nil;
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
