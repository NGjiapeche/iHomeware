//
//  PLALarm_TimerVC.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14/11/25.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLALarm_TimerVC.h"
#import "PLAlarm_TimerCell.h"
#import "PLModel_Alarm_Timer.h"
#import "HuangConstants.h"
#import "PLDatabaseManager.h"

#define Cell_Hight 55.0f


// 0 关 1 开

@interface PLALarm_TimerVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,PLAlarm_TimerCellDetegate>
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (strong , nonatomic) NSMutableArray *dataAlarmMArray;// 闹钟
@property (strong , nonatomic) NSMutableArray *dataTimerMArray;// 时间
@property (assign) BOOL isCanDelete;


@end

@implementation PLALarm_TimerVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
    self.isCanDelete = NO;
    
//    self.dataAlarmMArray = [[PLDatabaseManager sharedManager] queryAllAlarmTable];
//    self.dataTimerMArray = [[PLDatabaseManager sharedManager] queryAllTimerTable];
    if ([self.dataTimerMArray count] < 1)
    {
        self.dataTimerMArray = [NSMutableArray new];
        
        
//        临时数据
        PLModel_Alarm_Timer * model1 = [PLModel_Alarm_Timer new];
        model1.titleName = @"Timer 1";
        model1.alarmTimerstate = @"0";
        [self.dataTimerMArray addObject:model1];
        
        PLModel_Alarm_Timer * model2 = [PLModel_Alarm_Timer new];
        model2.titleName = @"Timer 2";
        model2.alarmTimerstate = @"1";
        [self.dataTimerMArray addObject:model2];
    }
    
    if ([self.dataAlarmMArray count] < 1)
    {
        self.dataAlarmMArray = [NSMutableArray new];

//        临时数据
        PLModel_Alarm_Timer * model1 = [PLModel_Alarm_Timer new];
        model1.titleName = @"Alarm 1";
        model1.alarmTimerstate = @"1";
        [self.dataAlarmMArray addObject:model1];
        
        PLModel_Alarm_Timer * model2 = [PLModel_Alarm_Timer new];
        model2.titleName = @"Alarm 2";
        model2.alarmTimerstate = @"0";
        [self.dataAlarmMArray addObject:model2];

    }

    
    [self tableViewFrameWithCellNum:[self.dataAlarmMArray count]+[self.dataTimerMArray count]];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    yct_initNav(YES, YES, YES, @"Alarm Timer", nil, nil, nil, @"arrowLight.png", @"添加.png",@"删除.png");
    
//    [[PLDatabaseManager sharedManager] createTimerTable];
//    [[PLDatabaseManager sharedManager] createAlarmTable];
    
}

- (void)btnMiddlePressed
{
    if(!self.isCanDelete)
    {
        self.isCanDelete = YES;
        //删除
        [self.dataTableView setEditing:YES animated:YES];

        yct_initNav(YES, YES, NO, @"Alarm Timer", nil, @"Done",nil,@"arrowLight.png",nil,nil);
    }else
    {
        self.isCanDelete = NO;
        [self.dataTableView setEditing:NO animated:YES];
         yct_initNav(YES, YES, YES, @"Alarm Timer", nil, nil, nil, @"arrowLight.png", @"添加.png",@"删除.png");
    }

    [self.dataTableView reloadData];
}

- (void)btnRightPressed
{
    if (self.isCanDelete)
    {
        self.isCanDelete = NO;
        [self.dataTableView setEditing:NO animated:YES];
        [self.dataTableView reloadData];
        yct_initNav(YES, YES, YES, @"Alarm Timer", nil, nil, nil, @"arrowLight.png", @"添加.png",@"删除.png");
    }else
    {
        //添加
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Alarm",@"Timer", nil];
        [actionSheet showInView:self.view];

    }
}

//- (void)btnBackPressed
//{
//    
//}

#pragma mark -ActionSheet 代理 


- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subViwe in actionSheet.subviews) {
        if ([subViwe isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)subViwe;
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.titleLabel.font = fontCustom(17);
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self performSegueWithIdentifier:SEG_TO_PLAlarmVC sender:nil];
    
    }else if(buttonIndex == 1)
    {

        [self performSegueWithIdentifier:SEG_TO_PLTimerVC sender:nil];
        
    }
    
}

#pragma mark - uitableView的fame
- (void)tableViewFrameWithCellNum:(NSInteger )cellNum
{
    if ([UIScreen mainScreen].bounds.size.height > 500)
    {
        if (cellNum > 7)
        {
            self.dataTableView.frame = CGRectMake(0, 67, 320, [UIScreen mainScreen].bounds.size.height - 68);
        }else
        {
            self.dataTableView.frame = CGRectMake(0, 67, 320, cellNum * Cell_Hight);
        }
    }else
    {
        if (cellNum > 6)
        {
            self.dataTableView.frame = CGRectMake(0, 67, 320, [UIScreen mainScreen].bounds.size.height - 68);
        }else
        {
            self.dataTableView.frame = CGRectMake(0, 67, 320, cellNum * Cell_Hight);
        }
    }
    [self.dataTableView reloadData];
}
#pragma mark - cell Swicth 开关
- (void)operationSwitchAction:(UISwitch *)operationSwitch andCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.dataTableView indexPathForCell:cell];
     if (indexPath.row < [self.dataAlarmMArray count])
     {
            PLModel_Alarm_Timer *model = [self.dataAlarmMArray objectAtIndex:indexPath.row];
         if ([operationSwitch isOn])
         {
             model.alarmTimerstate = @"1";
//             [[PLDatabaseManager sharedManager] ModifyAlarmTableWith:model withState:model.alarmTimerstate];
             DebugLog(@"开");
             
         }else
         {
             model.alarmTimerstate = @"0";
//            [[PLDatabaseManager sharedManager] ModifyAlarmTableWith:model withState:model.alarmTimerstate];
             DebugLog(@"关");
         }
         
     }else
     {
            PLModel_Alarm_Timer *model = [self.dataTimerMArray objectAtIndex:indexPath.row - [self.dataAlarmMArray count]];
         if ([operationSwitch isOn])
         {
             model.alarmTimerstate = @"1";
//            [[PLDatabaseManager sharedManager] ModifyAlarmTableWith:model withState:model.alarmTimerstate];
            DebugLog(@"开");
         }else
         {
             model.alarmTimerstate = @"0";
//            [[PLDatabaseManager sharedManager] ModifyAlarmTableWith:model withState:model.alarmTimerstate];
            DebugLog(@"关");
         }
         
     }
}

#pragma mark - uitableView 代理
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    DebugLog(@"accessoryButton的响应事件");
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isCanDelete)
    {
      return UITableViewCellEditingStyleDelete;
    }else
    {
        return UITableViewCellEditingStyleNone;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    return @"Delete";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        DebugLog(@"删除按钮");
        if (indexPath.row < [self.dataAlarmMArray count])
        {
            PLModel_Alarm_Timer *model = [self.dataAlarmMArray objectAtIndex:indexPath.row];
//            [[PLDatabaseManager sharedManager] deleteAlarmWith:model.alarmTimerID];
            
            
//            临时数据
            [self.dataAlarmMArray removeObject:model];
            
        }else
        {
            PLModel_Alarm_Timer *model = [self.dataTimerMArray objectAtIndex:indexPath.row - [self.dataAlarmMArray count]];
//            [[PLDatabaseManager sharedManager] deleteTimerWith:model.alarmTimerID];
            
//            临时数据
            [self.dataTimerMArray removeObject:model];
            
        }
//      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
    

    [self tableViewFrameWithCellNum:[self.dataAlarmMArray count]+[self.dataTimerMArray count]];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataAlarmMArray count]+[self.dataTimerMArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINib *nib = [UINib nibWithNibName:@"PLAlarm_TimerCell" bundle:nil];
    [_dataTableView registerNib:nib forCellReuseIdentifier:@"PLAlarm_TimerCell"];
    
    static NSString *cellIdentifier  = @"PLAlarm_TimerCell";
    PLAlarm_TimerCell *cell          = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle              = UITableViewCellSelectionStyleNone;
    cell.backgroundColor             = [UIColor clearColor];
    cell.delegate                    = self;
    
    
    cell.nameLabel.font = fontCustom(17);
    cell.expatiationLabel.font = fontCustom(13);
    cell.operationLabel.font = fontCustom(13);
    if (indexPath.row < [self.dataAlarmMArray count])
    {
        PLModel_Alarm_Timer *model = [self.dataAlarmMArray objectAtIndex:indexPath.row];
        cell.nameLabel.text = model.titleName;
        
        cell.expatiationLabel.text = @"1 lamp off at 1:14 a.m.";
        cell.operationLabel.text = @"No-repeat";
        
        
        cell.alarmOrTimeImageView.image = [UIImage imageNamed:@"alarm_timer1.png"];
        if([model.alarmTimerstate intValue] == 0)
        {
            [cell.operationSwitch setOn:NO];
        }else
        {
            [cell.operationSwitch setOn:YES];
        }
        
        
    }else{
    
        PLModel_Alarm_Timer *model = [self.dataTimerMArray objectAtIndex:indexPath.row - [self.dataAlarmMArray count]];
        cell.nameLabel.text = model.titleName;
        cell.alarmOrTimeImageView.image = [UIImage imageNamed:@"alarm_timer3.png"];
        cell.expatiationLabel.text = @"\"Read\" open";
        cell.operationLabel.text = @"After 1 minutes";
        
        cell.alarmOrTimeImageView.frame = CGRectMake(9, 10, 36, 36);
        
        if([model.alarmTimerstate intValue] == 0)
        {
            [cell.operationSwitch setOn:NO];
        }else
        {
            [cell.operationSwitch setOn:YES];
        }

        
    }
    
    
    
    
    if (self.isCanDelete)
    {
        cell.operationSwitch.frame = CGRectMake(220, 5, 30, 30);
    }
    else
    {
        cell.operationSwitch.frame = CGRectMake(260, 5, 30, 30);
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Cell_Hight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
