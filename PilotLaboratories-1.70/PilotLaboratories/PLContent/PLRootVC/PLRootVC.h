//
//  PLRootVC.h
//  PilotLaboratories
//
//  Created by frontier on 14-3-24.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLRootVC : UIViewController

@property (strong, nonatomic) UIView *viewBackground;

@property (assign, nonatomic) BOOL isLeft;
@property (assign, nonatomic) BOOL isRight;
@property (assign, nonatomic) BOOL isMiddle;

@property (strong, nonatomic) NSString *strTitle;
@property (strong, nonatomic) NSString *strRightTitle;
@property (strong, nonatomic) NSString *strLeftTitle;
@property (strong, nonatomic) NSString *strMiddleTitle;

@property (strong, nonatomic) NSString *strRightImage;
@property (strong, nonatomic) NSString *strLeftImage;
@property (strong, nonatomic) NSString *strMiddleImage;
@property (strong, nonatomic) UIButton *btnRight;
@property (strong, nonatomic) UIImageView *logo1;

- (void)btnRightPressed;
- (void)btnBackPressed;
//- (void)btnMiddlePressed;
- (void)btnMiddlePressedWithBtn:(UIButton *)btn;

@end
