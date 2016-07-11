//
//  PLAlerWithLabelBtnActivity.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-9.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLAlerWithLabelBtnActivity.h"

@interface PLAlerWithLabelBtnActivity()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityShow;
@property (strong, nonatomic) IBOutlet UILabel *labelShow;
@property (strong, nonatomic) IBOutlet UIButton *btnShow;
@property (strong, nonatomic) IBOutlet UILabel *labelTitleShow;

@end

@implementation PLAlerWithLabelBtnActivity

- (id)initWithFrame:(CGRect)frame
{
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"PLAlerWithLabelBtnActivity"
                                                     owner:self
                                                   options:nil];
    if (tempArr) {
        
        self = tempArr[0];
        
        if (self) {
            self.frame = frame;
            self.contentView.layer.cornerRadius = 5.0;
        }
        return self;
    }
    
    return nil;
}

-(void)setStrLabelContent:(NSString *)strLabelContent
{
    self.labelShow.text = strLabelContent;
}

- (void)setStrBtnTitle:(NSString *)strBtnTitle
{
//    self.btnShow.titleLabel.text = strBtnTitle;
    [self.btnShow setTitle:[NSString stringWithFormat:@"%@",strBtnTitle] forState:UIControlStateNormal];
}

-(void)setStrLabelTitle:(NSString *)strLabelTitle
{
    self.labelTitleShow.text = strLabelTitle;
}

//-(void)setLabelContentFrame:(CGRect)labelContentFrame
//{
//    self.labelShow.frame = labelContentFrame;
//}
//
//- (void)setBtnShowFrame:(CGRect)btnShowFrame
//{
//    self.btnShow.frame = btnShowFrame;
//}
//
//- (void)setViewContentFrame:(CGRect)viewContentFrame
//{
//    self.contentView.frame = viewContentFrame;
//}

- (void)setIsActivityHidden:(BOOL)isActivityHidden
{
    self.activityShow.hidden = isActivityHidden;
    self.labelTitleShow.hidden = !isActivityHidden;
}

- (void)show
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.center = window.center;
    [window addSubview:self];
    [window bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            self.alpha = 0.8;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                self.alpha = 1.0;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }];
}

- (IBAction)btnShowPressed:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(btnPressedOnContentViewWithView:withTheBtn:)]) {
        [self.delegate btnPressedOnContentViewWithView:self withTheBtn:sender];
    }
}

@end
