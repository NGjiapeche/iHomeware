//
//  PLNotiAndAlerts.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-6-27.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PLNotiAndAlerts;

@protocol PLNotiAndAlertsDelegate <NSObject>

- (void)cellOnWifiDidSelected:(NSString *)notiFrom withView:(PLNotiAndAlerts *)alterView;

@end

@interface PLNotiAndAlerts : UIView

@property (unsafe_unretained, nonatomic) id <PLNotiAndAlertsDelegate>delegate;
@property (strong, nonatomic) NSArray *arrGateways;

- (void)show;

@end
