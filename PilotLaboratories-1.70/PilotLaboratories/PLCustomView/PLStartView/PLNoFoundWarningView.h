//
//  PLNoFoundWarningView.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-4-25.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PLNoFoundWarningViewDelegate <NSObject>

- (void)PLNoFoundWarningViewYesBtnPressed;
- (void)PLNoFoundWarningViewNOBtnPressed;

@end


@interface PLNoFoundWarningView : UIView

@property (unsafe_unretained, nonatomic) id<PLNoFoundWarningViewDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIButton *btnYES;
@property (strong, nonatomic) IBOutlet UIButton *btnNO;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;


@end
