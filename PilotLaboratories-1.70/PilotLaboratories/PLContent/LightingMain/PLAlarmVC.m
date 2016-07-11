//
//  PLAlarmVC.m
//  PilotLaboratories
//
//  Created by Tassos on 11/26/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import "PLAlarmVC.h"
#import "PLAlarmTimer_NoSwitch.h"
#import "PLAlarmTimer_Switch.h"

@interface PLAlarmVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UITextField *alarmNameTextField;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePick;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControler;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@property (strong , nonatomic) UILabel *dataLabel;

//弹窗
@property (weak, nonatomic) IBOutlet UIView *pickBGView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickView;
@property (weak, nonatomic) IBOutlet UIButton *ensurePickView;
@property (assign , nonatomic) NSInteger selectedNum;

@end


@implementation PLAlarmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    yct_initNav(YES, YES, YES, @"Alarm", @"Cancel", @"Save", nil, nil, nil,nil);
    
    self.dataLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, [UIScreen mainScreen].bounds.size.height - 30, 310, 40)];
    self.dataLabel.font = fontCustom(17);
    self.dataLabel.textColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
    self.dataLabel.text = @"Random trigger 0 to 30 mintues";
    [self.view addSubview:self.dataLabel];

    if([UIScreen mainScreen].bounds.size.height > 500)
    {
        self.pickBGView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        self.pickBGView.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);
        self.pickBGView.hidden = YES;
        
        self.bgView.frame = CGRectMake(0, 67, 320, [UIScreen mainScreen].bounds.size.height - 67);
        
        self.alarmNameTextField.frame = CGRectMake(0, 20, 320, 40);
        self.alarmNameTextField.clearButtonMode =  UITextFieldViewModeAlways;
        self.alarmNameTextField.backgroundColor = [UIColor colorWithRed:109/255.0f green:109/255.0f blue:109/255.0f alpha:0.5];
        self.datePick.frame = CGRectMake(0, self.alarmNameTextField.frame.origin.y + self.alarmNameTextField.frame.size.height + 20, 320, 150);
        self.datePick.backgroundColor = [UIColor whiteColor];
        self.segmentControler.frame = CGRectMake(10, self.datePick.frame.origin.y + self.datePick.frame.size.height + 20, 300, 30);
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"CenturyGothic"size:14],NSFontAttributeName,nil];
        [self.segmentControler setTitleTextAttributes:dic forState:UIControlStateNormal];
        
        [self.segmentControler addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
        
        self.dataTableView.frame = CGRectMake(0, self.segmentControler.frame.origin.y+self.segmentControler.frame.size.height + 20, 320, 160);
    }else
    {
        self.pickBGView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        self.pickBGView.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);
        self.pickBGView.hidden = YES;
        
        self.bgView.frame = CGRectMake(0, 67, 320, [UIScreen mainScreen].bounds.size.height - 67);
        
        self.alarmNameTextField.frame = CGRectMake(0, 0, 320, 40);
        self.alarmNameTextField.clearButtonMode =     UITextFieldViewModeAlways;
        self.alarmNameTextField.backgroundColor = [UIColor colorWithRed:109/255.0f green:109/255.0f blue:109/255.0f alpha:0.5];
        self.datePick.frame = CGRectMake(0, self.alarmNameTextField.frame.origin.y + self.alarmNameTextField.frame.size.height, 320, 150);
        self.datePick.backgroundColor = [UIColor whiteColor];
        self.segmentControler.frame = CGRectMake(10, self.datePick.frame.origin.y + self.datePick.frame.size.height , 300, 30);
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"CenturyGothic"size:14],NSFontAttributeName,nil];
        [self.segmentControler setTitleTextAttributes:dic forState:UIControlStateNormal];
        
        [self.segmentControler addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
        
        self.dataTableView.frame = CGRectMake(0, self.segmentControler.frame.origin.y+self.segmentControler.frame.size.height , 320, 160);
    }
    

}



#pragma mark - segmentedControl
- (void)segmentedControlAction:(UISegmentedControl *)segmentedControl
{
    NSInteger index = segmentedControl.selectedSegmentIndex;
    if (index == 0 )
    {
        //    open scenen
        
        
    }else
    {
        //    close lamp
        
    }
    
}

#pragma mark - 确定 选择 按钮 存储
- (IBAction)ensurePickAction:(id)sender
{
    yct_initNav(YES, YES, YES, @"Alarm", @"Cancel", @"Save", nil, nil, nil,nil);
    self.pickBGView.hidden = YES;
    
}

#pragma mark - pickView 代理
- (NSInteger)numberOfRowsInComponent:(NSInteger)component
{
    return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    self.selectedNum = row;
    
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    [self pickerView:pickerView titleForRow:row forComponent:component];
    return nil;
}



#pragma mark -tableView 代理

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 2)
    {
        yct_initNav(NO, YES, YES, @"Alarm", nil, nil, nil, nil, nil,nil);
        self.pickBGView.hidden = NO;
        //        self.scenePickerView.delegate = self;
        //        self.scenePickerView.dataSource = self;
        self.pickView.backgroundColor = [UIColor whiteColor];
        self.pickView.frame = CGRectMake(20, [UIScreen mainScreen].bounds.size.height/2 - 100, 280, 200);
        [self.pickView.layer setCornerRadius:10];
        [self.pickView.layer setMasksToBounds:YES];
        self.ensurePickView.backgroundColor = [UIColor whiteColor];
        self.ensurePickView.frame = CGRectMake(self.pickView.frame.origin.x,
                                                   self.pickView.frame.size.height +
                                                   self.pickView.frame.origin.y + 30,
                                                   self.pickView.frame.size.width,
                                                   40);
        [self.ensurePickView.layer setCornerRadius:10];
        [self.ensurePickView.layer setMasksToBounds:YES];
        NSLog(@"dadadadadadadadadad");
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row < 3)
    {
        UINib *nib = [UINib nibWithNibName:@"PLAlarmTimer_NoSwitch" bundle:nil];
        [self.dataTableView registerNib:nib forCellReuseIdentifier:@"PLAlarmTimer_NoSwitch"];
        
        static NSString *cellIdentifier  = @"PLAlarmTimer_NoSwitch";
        PLAlarmTimer_NoSwitch *cell      = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.selectionStyle              = UITableViewCellSelectionStyleNone;
        cell.backgroundColor             = [UIColor clearColor];
        
        cell.cellImageView.image = [UIImage imageNamed:@"alarm_timer7.png"];
        cell.cellOpertionLabel.text = @"none";
        //数据
        if (indexPath.row == 0)
        {
            cell.nameLabel.text = @"Scene";
            
        }else if(indexPath.row == 1)
        {
            cell.nameLabel.text = @"Gradual";
        }else
        {
        
            cell.nameLabel.text = @"Repeat";
            cell.cellOpertionLabel.text = @"no-repeat";
        }
        
        
        cell.nameLabel.font = fontCustom(17);

        cell.cellOpertionLabel.font = fontCustom(17);
        
        return cell;

    }else
    {
        
        UINib *nib = [UINib nibWithNibName:@"PLAlarmTimer_Switch" bundle:nil];
        [self.dataTableView registerNib:nib forCellReuseIdentifier:@"PLAlarmTimer_Switch"];
        
        static NSString *cellIdentifier  = @"PLAlarmTimer_Switch";
        PLAlarmTimer_Switch *cell      = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.selectionStyle              = UITableViewCellSelectionStyleNone;
        cell.backgroundColor             = [UIColor clearColor];
        cell.nameLabel.text = @"Random";
        cell.nameLabel.font = fontCustom(17);
        [cell.cellSwitch setOn:NO];
        
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

#pragma mark - textField代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)btnRightPressed
{
    //    截取 当前 datePicker 时间
    NSDate *theDate = self.datePick.date;
    DebugLog(@"the date picked is %@",[theDate descriptionWithLocale:[NSLocale currentLocale]]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HH:mm"];
    DebugLog(@"the date format is %@",[dateFormatter stringFromDate:theDate]);
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
