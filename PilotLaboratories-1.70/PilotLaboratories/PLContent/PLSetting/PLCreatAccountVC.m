//
//  PLCreatAccountVC.m
//  PilotLaboratories
//
//  Created by frontier on 14-3-21.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLCreatAccountVC.h"

@interface PLCreatAccountVC ()

@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPSW;
@property (weak, nonatomic) IBOutlet UITextField *textFieldConfirmPSW;

- (IBAction)buttonBackPressed:(UIButton *)sender;
- (IBAction)buttonResetPasswordPressed:(UIButton *)sender;
- (IBAction)buttonEULAPressed:(UIButton *)sender;
@end

@implementation PLCreatAccountVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - backButton -
- (IBAction)buttonBackPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonResetPasswordPressed:(UIButton *)sender
{
    
}

- (IBAction)buttonEULAPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:SEG_TO_EULA sender:self];
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
