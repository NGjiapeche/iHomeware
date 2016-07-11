//
//  PLEmailProvideView.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-4-25.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLEmailProvideView.h"

@implementation PLEmailProvideView

- (id)initWithFrame:(CGRect)frame
{
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"PLEmailProvideView"
                                                     owner:self
                                                   options:nil];
    if (tempArr)
    {
        self = tempArr[0];
        if (self)
        {
            if (IS_IPHONE5)
            {
                self.labelTitle.font = fontCustom(15);
                self.textFieldEmail.font = fontCustom(15)
                self.textFieldEmail.frame = CGRectMake(20, 109, 240, 40);
                self.btnOK.frame = CGRectMake(110, 164, 75, 75);
            }
            else
            {
              self.labelTitle.font = fontCustom(15);
                self.textFieldEmail.font = fontCustom(15)
                self.labelTitle.frame = CGRectMake(0, -10, 284, 94);
                self.textFieldEmail.frame  = CGRectMake(20, 74, 240, 40);
                self.btnOK.frame = CGRectMake(110, 134, 65, 65);
            }
            
            self.frame = frame;
//            [self makeViewRoundWithView:self.btnOK];
            self.textFieldEmail.delegate = self;
        }
        return self;
    }
    return nil;
    
}

- (IBAction)btnEmailOKPressed:(UIButton *)sender
{
    if (self.textFieldEmail.text.length == 0 || ![self validateEmail:self.textFieldEmail.text])
    {
        [self alterWarning];
    }
    else
    {
        [self textFieldDidEndEditing:self.textFieldEmail];
        [self.delegate PLEmailProvideViewBtnPressed];
    }
}

- (void)makeViewRoundWithView:(UIView *)view
{
    view.layer.cornerRadius = 5;
    view.layer.borderWidth = 2;
    view.layer.borderColor = [UIColor blueColor].CGColor;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.textFieldEmail resignFirstResponder];
    if ([self validateEmail:textField.text])
    {
        [self.delegate handleTextfieldText:textField.text];
    }
    else
    {
        [self alterWarning];

    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textFieldEmail resignFirstResponder];
    return YES;
}

- (BOOL)validateEmail:(NSString *) candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

- (void)alterWarning
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                    message:NSLocalizedString(@"The email address you entered was invalid, please try again", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alter.delegate = self;
    [alter show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        self.textFieldEmail.text = nil;
    }
}




@end
