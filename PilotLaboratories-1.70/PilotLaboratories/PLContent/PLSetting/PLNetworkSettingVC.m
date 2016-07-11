//
//  PLNetworkSettingVC.m
//  PilotLaboratories
//
//  Created by frontier on 14-3-21.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLNetworkSettingVC.h"

@interface PLNetworkSettingVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *textfieldGataWay;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;


- (IBAction)backButtonPressed:(UIButton *)sender;
- (IBAction)saveButtonPressed:(UIButton *)sender;

@end

@implementation PLNetworkSettingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - backButtonPressed - 

- (IBAction)backButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonPressed:(UIButton *)sender
{
    [self.textfieldGataWay resignFirstResponder];
    [self.textFieldPassword resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}



#pragma mark - 隐藏键盘 -
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
