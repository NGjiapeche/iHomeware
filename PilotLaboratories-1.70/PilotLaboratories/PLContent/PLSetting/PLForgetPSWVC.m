//
//  PLForgetPSWVC.m
//  PilotLaboratories
//
//  Created by frontier on 14-3-21.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLForgetPSWVC.h"

@interface PLForgetPSWVC ()

@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;

- (IBAction)buttonBackPressed:(UIButton *)sender;
- (IBAction)buttonResetPSW:(UIButton *)sender;

@end

@implementation PLForgetPSWVC

#pragma mark - 设置状态栏的字体颜色 -
- (UIStatusBarStyle)preferredStatusBarStyle

{
    
    return UIStatusBarStyleLightContent;
    
}

- (BOOL)prefersStatusBarHidden

{
    
    return NO;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - backButton pressed -
- (IBAction)buttonBackPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonResetPSW:(UIButton *)sender
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
