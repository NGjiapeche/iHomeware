//
//  PLUnConnectCloudSeverView.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-4-25.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLUnConnectCloudSeverView.h"

@implementation PLUnConnectCloudSeverView

- (id)initWithFrame:(CGRect)frame
{
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"PLUnConnectCloudSeverView"
                                                     owner:self
                                                   options:nil];
    if (tempArr)
    {
        self = tempArr[0];
        if (self)
        {
            self.frame = frame;
            if (IS_IPHONE5)
            {
                self.labelTitle.font = fontCustom(15);
                self.textfieldColoudServer.font = fontCustom(15);
            }
            else
            {
                self.labelTitle.font = fontCustom(15);
                self.textfieldColoudServer.font = fontCustom(15);
            }
            
//            [self makeViewRoundWithView:self.btnNO];
//            [self makeViewRoundWithView:self.btnYes];
            self.textfieldColoudServer.delegate = self;
        }
        return self;
    }
    return nil;
    
}

- (IBAction)btnCloudserverConnectYesPressed:(UIButton *)sender
{
    [self.delegate btnYesPressedOnCloudserverConnect];
}

- (IBAction)btnColoudServerConnectNOPressed:(UIButton *)sender
{
    [self.delegate btnNOPressedOnCloudserverConnect];
}

- (void)makeViewRoundWithView:(UIView *)view
{
    view.layer.cornerRadius = 5;
    view.layer.borderWidth = 2;
    view.layer.borderColor = [UIColor blueColor].CGColor;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
