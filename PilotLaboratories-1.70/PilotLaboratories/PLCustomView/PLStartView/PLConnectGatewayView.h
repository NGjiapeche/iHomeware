//
//  PLConnectGatewayView.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-4-25.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLConnectGatewayView;

@protocol PLConnectGatewayViewDelegate <NSObject>

- (void)btnConnectGatewaPressed;

@end

@interface PLConnectGatewayView : UIView

@property (unsafe_unretained, nonatomic) id<PLConnectGatewayViewDelegate>delegate;
@property (strong, nonatomic) IBOutlet UIButton *btnOK;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

@end
