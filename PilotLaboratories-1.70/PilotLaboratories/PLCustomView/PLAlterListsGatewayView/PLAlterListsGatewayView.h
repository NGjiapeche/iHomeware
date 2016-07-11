//
//  PLAlterListsGatewayView.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-9.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLAlterListsGatewayView;
@protocol PLAlterListsGatewayViewDelegate <NSObject>

- (void)cellOnWifiDidSelected:(NSString *)gateway withView:(PLAlterListsGatewayView *)alterView;

@end


@interface PLAlterListsGatewayView : UIView

@property (unsafe_unretained, nonatomic) id <PLAlterListsGatewayViewDelegate>delegate;
@property (strong, nonatomic) NSArray *arrGateways;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

- (void)show;

@end
