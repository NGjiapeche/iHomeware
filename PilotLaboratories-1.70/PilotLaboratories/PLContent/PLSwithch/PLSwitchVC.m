//
//  PLSwitchVC.m
//  PilotLaboratories
//
//  Created by frontier on 14-3-20.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLSwitchVC.h"
#import "FMMoveTableView.h"
#import "FMMoveTableViewCell.h"
#import "PLSwitchModel.h"
#import "PLCustomLongPressCellAlter.h"
#import "MJRefreshNormalHeader.h"
// 自定义的header
#import "MJChiBaoZiHeader.h"
#import "PLAppDelegate.h"


@interface PLSwitchVC ()<FMMoveTableViewCellDelegate,PLCustomLongPressCellAlterDelegate,UITableViewDataSource,UITableViewDelegate>
{
    id getDevicesListsNoti;
    id getDevicesStatusNoti;
}
@property (strong, nonatomic) IBOutlet UITableView *tableViewDeviceSwitches;
@property (nonatomic, strong) NSMutableArray *movies;
@property (nonatomic, strong) NSMutableArray *mutArrDeviecesList;
@property (strong, nonatomic) FMMoveTableViewCell *moveTableViewCell;
@property (nonatomic, strong) NSMutableArray *SwitchDatasource;
@property (strong, nonatomic) IBOutlet UILabel *labelTItle;
@property(nonatomic,strong)MJRefreshNormalHeader *header;
@end

@implementation PLSwitchVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.SwitchDatasource.count == 0){
        return;
    }else{
           [self exampleHeader]; 
    }

//    //获取等和传感器
//    getDevicesListsNoti = [[NSNotificationCenter defaultCenter] addObserverForName:DidRefreshDeviceStatus
//                                                      object:nil
//                                                       queue:[NSOperationQueue mainQueue]
//                                                  usingBlock:^(NSNotification *note) {
//                                                      
//                                                      self.mutArrDeviecesList = note.object;
//                                                  }];
////    getDevicesStatusNoti = [[NSNotificationCenter defaultCenter] addObserverForName:DidRefreshDeviceStatus
////                                                      object:nil queue:[NSOperationQueue mainQueue]
////                                                  usingBlock:^(NSNotification *note) {
////                                                      
////                                                      
////                                                  }];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
       [_header endRefreshing];
//    [[NSNotificationCenter defaultCenter] removeObserver:getDevicesListsNoti];
//    [[NSNotificationCenter defaultCenter] removeObserver:getDevicesStatusNoti];
}
- (void)exampleHeader
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
   _header  = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    // 设置文字
    [_header setTitle:[NSString stringWithFormat:NSLocalizedString(@"Pull down to refresh", nil)] forState:MJRefreshStateIdle];
    [_header setTitle:[NSString stringWithFormat:NSLocalizedString(@"Release to refresh", nil)] forState:MJRefreshStatePulling];
    [_header setTitle:[NSString stringWithFormat:NSLocalizedString(@"Querying switch status", nil)] forState:MJRefreshStateRefreshing];
    // 设置字体
    _header.stateLabel.font = [UIFont systemFontOfSize:15];
    _header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
    
    // 设置颜色
    _header.stateLabel.textColor = [UIColor redColor];
    _header.lastUpdatedTimeLabel.textColor = [UIColor blueColor];
    
    // 马上进入刷新状态
    [self beginRefresh];
    
    // 设置刷新控件
    self.tableViewDeviceSwitches.header = _header;
}
-(void)beginRefresh{
    [_header beginRefreshing];


}
- (void)loadNewData
{
    NSArray *switchArr = [[PLNetworkManager sharedManager] switchArr];
    if (switchArr.count)
    {
        [[PLNetworkManager sharedManager] checkDeviceStatuswithSwitch];
        DebugLog(@"查询");

    }
    else
    {
        [self.tableViewDeviceSwitches reloadData];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.tableViewDeviceSwitches.header endRefreshing];
    });
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    if (IS_IPHONE5)
    {
        self.labelTItle.font = fontCustom(15);
    }
    else
    {
        self.labelTItle.font = fontCustom(15);
    }
    
    _movies = [NSMutableArray new];
    _SwitchDatasource = [NSMutableArray new];
    _SwitchDatasource = [[PLNetworkManager sharedManager] switchArr];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidRefreshDeviceStatus:)
                                                 name:@"SwitchRefresh"
                                               object:nil];
   

}

- (void)handleDidDiscoveryDevice:(NSNotification *)notification
{
    NSArray *switchArr = [[PLNetworkManager sharedManager] switchArr];
    if (switchArr.count)
    {
        [[PLNetworkManager sharedManager] checkDeviceStatusWithDeviceList:switchArr];
    }
    else
    {
        [self.tableViewDeviceSwitches reloadData];
    }
}

- (void)handleDidRefreshDeviceStatus:(NSNotification *)notification
{
    PLAppDelegate *mydelegate = [[UIApplication sharedApplication]delegate];
    self.SwitchDatasource =[NSMutableArray arrayWithArray:mydelegate.SwitchArray];
    
    [self.tableViewDeviceSwitches reloadData];
     [mydelegate.SwitchArray removeAllObjects];
    DebugLog(@"刷新了");
}

#pragma mark -
#pragma mark Controller life cycle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _SwitchDatasource.count;
//    return 10;

}


- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"FMMoveTableViewCell";
	FMMoveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell)
    {
        cell = [[FMMoveTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.labelName.font = fontCustom(15);
    }
        PLModel_Device *model = [PLModel_Device new];
        model = self.SwitchDatasource[indexPath.row];
        if (model.deviceName.length == 0)
        {
            NSString *locatiostr = [NSString stringWithFormat:NSLocalizedString(@"Switch", nil)];
            cell.labelName.text = [NSString stringWithFormat:@"%@%ld",locatiostr,(long)indexPath.row];
        }
        else
        {
            cell.labelName.text = [NSString stringWithFormat:@"%@",model.deviceName];
        }
        if (model.onOff)
        {
            cell.switchOnOrOff.on = YES;
        }
        else
        {
            cell.switchOnOrOff.on = NO;
        }
		[cell setShouldIndentWhileEditing:NO];
		[cell setShowsReorderControl:NO];
        cell.delegate =self;
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.moveTableViewCell = (FMMoveTableViewCell *)[self.tableViewDeviceSwitches cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self longPressCell:indexPath];
}

- (void)swichPressedOnCell:(FMMoveTableViewCell *)cell andSwichStatus:(BOOL)status
{
    //开关数据借口请求 连接数据后才可以再刷新的情况下不会改变switch的状态
    
    NSIndexPath *indexPath = [self.tableViewDeviceSwitches indexPathForCell:cell];
    PLModel_Device *model = [PLModel_Device new];
    model = self.SwitchDatasource[indexPath.row];
    DebugLog(@"%@,%@...%d...%d",cell,model.macAddress,model.onOff,model.deviceType);
    if (status)
    {
        DebugLog(@" 走了 on");
        DebugLog(@"cell.labelState.text == %@",cell.labelName.text);
 
        [[PLNetworkManager sharedManager] lightSwitchWithLight:model switchOn:YES];
        
    }
    else
    {
        DebugLog(@" 走了 off");
        DebugLog(@"cell.labelState.text == %@",cell.labelName.text);
        [[PLNetworkManager sharedManager] lightSwitchWithLight:model switchOn:NO];
    }
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
    NSIndexPath *indexPathTemp = [self.tableViewDeviceSwitches indexPathForCell:self.moveTableViewCell];
    
    PLModel_Device *device = self.SwitchDatasource[indexPathTemp.row];
    device.deviceName = strChangeName;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexPathTemp.row inSection:0];
    [self.tableViewDeviceSwitches reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil]
                                        withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -
#pragma mark Table view data source

//- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
//{
//    PLModel_Device *model = [PLModel_Device new];
//    model = [self.SwitchDatasource objectAtIndex:fromIndexPath.row];
//	[self.SwitchDatasource removeObjectAtIndex:[fromIndexPath row]];
//	[self.SwitchDatasource insertObject:model atIndex:[toIndexPath row]];
//}


- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if ([sourceIndexPath section] != [proposedDestinationIndexPath section]) {
		proposedDestinationIndexPath = sourceIndexPath;
	}
	return proposedDestinationIndexPath;
}





//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
//	NSLog(@"Did select row at %d", indexPath.row);
//}



#pragma mark -
#pragma mark Accessor methods

//- (NSMutableArray *)movies
//{
//	if (!_movies)
//	{
//			}
//
//	return self.movies;
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
