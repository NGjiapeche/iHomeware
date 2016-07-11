//
//  PLAlerWithLabelBtnActivity.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-9.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLAlerWithLabelBtnActivity;
@protocol PLAlerWithLabelBtnActivityDelegate <NSObject>

- (void)btnPressedOnContentViewWithView:(PLAlerWithLabelBtnActivity *)view withTheBtn:(UIButton *)btn;

@end

@interface PLAlerWithLabelBtnActivity : UIView

@property (unsafe_unretained, nonatomic) id<PLAlerWithLabelBtnActivityDelegate>delegate;
@property (strong, nonatomic) NSString *strLabelContent;
@property (strong, nonatomic) NSString *strBtnTitle;
@property (strong, nonatomic) NSString *strLabelTitle;
//@property (assign, nonatomic) CGRect labelContentFrame;
//@property (assign, nonatomic) CGRect btnShowFrame;
//@property (assign, nonatomic) CGRect viewContentFrame;
@property (assign, nonatomic) BOOL isActivityHidden;

- (void)show;

@end
