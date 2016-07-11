//
//  PLNoFoundWarningView.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-4-25.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLNoFoundWarningView.h"

@implementation PLNoFoundWarningView

- (id)initWithFrame:(CGRect)frame
{
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"PLNoFoundWarningView"
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
            }
            else
            {
              self.labelTitle.font = fontCustom(15);
                self.labelTitle.frame = CGRectMake(0, 63, 280, 66);
                self.btnYES.frame = CGRectMake(39, 149, 65, 65);
                self.btnNO.frame = CGRectMake(168, 149, 65, 65);
            }
            
//            [self makeViewRoundWithView:self.btnNO];
//            [self makeViewRoundWithView:self.btnYES];
        }
        return self;
    }
    return nil;
    
}

- (IBAction)btnYesPressed:(UIButton *)sender
{
    [self.delegate PLNoFoundWarningViewYesBtnPressed];
}

- (IBAction)btnNoPressed:(UIButton *)sender
{
    [self.delegate PLNoFoundWarningViewNOBtnPressed];
}

- (void)makeViewRoundWithView:(UIView *)view
{
    view.layer.cornerRadius = 5;
    view.layer.borderWidth = 2;
    view.layer.borderColor = [UIColor blueColor].CGColor;
}


@end
