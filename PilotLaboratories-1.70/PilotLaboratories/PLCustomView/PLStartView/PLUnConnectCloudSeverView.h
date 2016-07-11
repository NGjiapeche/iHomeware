//
//  PLUnConnectCloudSeverView.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-4-25.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PLUnConnectCloudSeverViewDelegate <NSObject>

- (void)btnYesPressedOnCloudserverConnect;
- (void)btnNOPressedOnCloudserverConnect;

@end

@interface PLUnConnectCloudSeverView : UIView<UITextFieldDelegate>

@property (unsafe_unretained, nonatomic)id<PLUnConnectCloudSeverViewDelegate>delegate;
@property (strong, nonatomic) IBOutlet UITextField *textfieldColoudServer;
@property (strong, nonatomic) IBOutlet UIButton *btnYes;
@property (strong, nonatomic) IBOutlet UIButton *btnNO;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

@end
