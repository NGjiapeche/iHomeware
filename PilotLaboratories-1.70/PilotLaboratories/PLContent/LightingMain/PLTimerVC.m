//
//  PLTimerVC.m
//  PilotLaboratories
//
//  Created by Tassos on 11/26/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import "PLTimerVC.h"
#import "PLAlarmTimer_NoSwitch.h"

@interface PLTimerVC ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>//,UIPickerViewDataSource,UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (weak, nonatomic) IBOutlet UIView *contentView;



//选择场景
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIPickerView *scenePickerView;
@property (weak, nonatomic) IBOutlet UIButton *enSurePickerButton;
@property (assign , nonatomic) NSInteger selectedNum;


@end

@implementation PLTimerVC

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.selectedNum = 0;
    
    yct_initNav(YES, YES, YES, @"Timer", @"Cancell", @"Save", nil, nil, nil,nil);

    self.bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    self.bgView.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);
    self.bgView.hidden = YES;
    
    self.contentView.frame = CGRectMake(0, 67, 320, [UIScreen mainScreen].bounds.size.height - 67);
    
    self.titleLabel.frame = CGRectMake(0, 20, 320, 40);
    self.titleLabel.clearButtonMode =     UITextFieldViewModeAlways;
    self.titleLabel.backgroundColor = [UIColor colorWithRed:109/255.0f green:109/255.0f blue:109/255.0f alpha:0.5];
    self.datePicker.frame = CGRectMake(0, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 20, 320, 150);
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.frame = CGRectMake(10, self.datePicker.frame.origin.y + self.datePicker.frame.size.height + 20, 300, 30);
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"CenturyGothic"size:14],NSFontAttributeName,nil];
    [self.segmentedControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    
    [self.segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    
    self.dataTableView.frame = CGRectMake(0, self.segmentedControl.frame.origin.y+self.segmentedControl.frame.size.height + 20, 320, 90);
    
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
    yct_initNav(YES, YES, YES, @"Timer", @"Cancel", @"Save", nil, nil, nil,nil);
    self.bgView.hidden = YES;
    
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
    if (indexPath.row == 0)
    {
        yct_initNav(NO, YES, YES, @"Timer", nil, nil, nil, nil, nil,nil);
        self.bgView.hidden = NO;
//        self.scenePickerView.delegate = self;
//        self.scenePickerView.dataSource = self;
        self.scenePickerView.backgroundColor = [UIColor whiteColor];
        self.scenePickerView.frame = CGRectMake(20, [UIScreen mainScreen].bounds.size.height/2 - 100, 280, 200);
        [self.scenePickerView.layer setCornerRadius:10];
        [self.scenePickerView.layer setMasksToBounds:YES];
        self.enSurePickerButton.backgroundColor = [UIColor whiteColor];
        self.enSurePickerButton.frame = CGRectMake(self.scenePickerView.frame.origin.x,
                                                   self.scenePickerView.frame.size.height +
                                                   self.scenePickerView.frame.origin.y + 30,
                                                   self.scenePickerView.frame.size.width,
                                                   40);
        [self.enSurePickerButton.layer setCornerRadius:10];
        [self.enSurePickerButton.layer setMasksToBounds:YES];
        DebugLog(@"dadadadadadadadadad");
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINib *nib = [UINib nibWithNibName:@"PLAlarmTimer_NoSwitch" bundle:nil];
    [self.dataTableView registerNib:nib forCellReuseIdentifier:@"PLAlarmTimer_NoSwitch"];
    
    static NSString *cellIdentifier  = @"PLAlarmTimer_NoSwitch";
    PLAlarmTimer_NoSwitch *cell      = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle              = UITableViewCellSelectionStyleNone;
    cell.backgroundColor             = [UIColor clearColor];
    
    if (indexPath.row == 0)
    {
        cell.cellImageView.image = [UIImage imageNamed:@"alarm_timer7.png"];
        cell.nameLabel.text = @"Scene";

    }else
    {
       cell.nameLabel.text = @"Gradual";
    }
        cell.nameLabel.font = fontCustom(17);
        cell.cellOpertionLabel.text = @"none";
        cell.cellOpertionLabel.font = fontCustom(17);
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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
    NSDate *theDate = self.datePicker.date;
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
