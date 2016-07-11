//
//  PLLogOutVC.m
//  PilotLaboratories
//
//  Created by frontier on 14-3-21.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLLogOutVC.h"

@interface PLLogOutVC ()

@property (weak, nonatomic) IBOutlet UIImageView *iamgeViewWel;
@property (weak, nonatomic) IBOutlet UIView *viewNameAndPsw;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignIn;
@property (weak, nonatomic) IBOutlet UIButton *buttonNewAccount;
@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPSW;

- (IBAction)buttonSignInPressed:(UIButton *)sender;
- (IBAction)backButtonPressed:(UIButton *)sender;
- (IBAction)buttonForgetPSWPressed:(UIButton *)sender;
- (IBAction)buttonNewAccountPressed:(UIButton *)sender;

@end

@implementation PLLogOutVC

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
    
    self.iamgeViewWel.backgroundColor = COLOR_RGB(1, 190, 254);
    self.buttonSignIn.backgroundColor = COLOR_RGB(255, 102, 102);
    
    [self makeUIRoundedCornersWithView:self.viewNameAndPsw];
    [self makeUIRoundedCornersWithView:self.buttonNewAccount];
    [self makeUIRoundedCornersWithView:self.buttonSignIn];
}

- (IBAction)buttonSignInPressed:(UIButton *)sender
{
    [self.textFieldName resignFirstResponder];
    [self.textFieldPSW resignFirstResponder];
}

- (IBAction)backButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonForgetPSWPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:SEG_TO_FORGET_PSW sender:self];
}

- (IBAction)buttonNewAccountPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:SEG_TO_CREAT_ACCOUNT sender:self];
}

- (void)makeUIRoundedCornersWithView:(UIView *)view
{
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
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
