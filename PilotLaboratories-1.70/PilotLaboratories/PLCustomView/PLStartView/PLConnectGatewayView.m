//
//  PLConnectGatewayView.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-4-25.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLConnectGatewayView.h"

@implementation PLConnectGatewayView

- (id)initWithFrame:(CGRect)frame
{
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"PLConnectGatewayView" owner:self options:nil];
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
            self.btnOK.frame = CGRectMake(110, 110, 65, 65);
        }
        
//        [self makeViewRoundWithView:self.btnOK];
    }
    return self;
}
- (IBAction)btnConnectPressed:(UIButton *)sender
{
    [self.delegate btnConnectGatewaPressed];
}


- (void)makeViewRoundWithView:(UIView *)view
{
    view.layer.cornerRadius = 5;
    view.layer.borderWidth = 2;
    view.layer.borderColor = [UIColor blueColor].CGColor;
}

@end
