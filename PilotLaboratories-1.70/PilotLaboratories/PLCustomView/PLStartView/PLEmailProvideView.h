//
//  PLEmailProvideView.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-4-25.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PLEmailProvideViewDelegate <NSObject>

- (void)PLEmailProvideViewBtnPressed;
- (void)handleTextfieldText:(NSString *)strEmail;

@end

@interface PLEmailProvideView : UIView<UITextFieldDelegate>

@property (unsafe_unretained, nonatomic) id<PLEmailProvideViewDelegate>delegate;
@property (strong, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (strong, nonatomic) IBOutlet UIButton *btnOK;

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

@end
