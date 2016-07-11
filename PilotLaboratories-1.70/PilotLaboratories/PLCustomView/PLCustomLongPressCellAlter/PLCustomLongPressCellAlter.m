//
//  PLCustomLongPressCellAlter.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-6-23.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLCustomLongPressCellAlter.h"

@interface PLCustomLongPressCellAlter ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *contenView;
@property (strong, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;

@end

@implementation PLCustomLongPressCellAlter

- (id)initWithFrame:(CGRect)frame
{
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"PLCustomLongPressCellAlter"
                                                     owner:self
                                                   options:nil];
    if (tempArr) {
        
        self = tempArr[0];
        
        if (self) {
//            self.frame = frame;
            self.contenView.layer.cornerRadius = 8.0;
            self.textFieldName.delegate = self;
            self.labelTitle.font = fontCustom(15);
            self.textFieldName.font = fontCustom(15);
            self.cancelBtn.titleLabel.font = fontCustom(13);
            self.okBtn.titleLabel.font = fontCustom(13);
        }
        return self;
    }
    
    return nil;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [self setCenter:window.center];
    [self.textFieldName resignFirstResponder];
    return YES;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    float xpoint = self.center.x;
      float ypoint = self.center.y;
    [self setCenter:CGPointMake(xpoint, ypoint-100)];
}
- (void)show
{
    [self animateIn];
}

-(void)animateIn
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.center = window.center;
    [window addSubview:self];
    
	self.transform = CGAffineTransformMakeScale(0.6, 0.6);
	[UIView animateWithDuration:0.2 animations:^{
		self.transform = CGAffineTransformMakeScale(1.1, 1.1);
	} completion:^(BOOL finished){
		[UIView animateWithDuration:1.0/15.0 animations:^{
			self.transform = CGAffineTransformMakeScale(0.9, 0.9);
		} completion:^(BOOL finished){
			[UIView animateWithDuration:1.0/7.5 animations:^{
				self.transform = CGAffineTransformIdentity;
			}];
		}];
	}];
}

-(void)animateOut
{
	[UIView animateWithDuration:1.0/7.5 animations:^{
		self.transform = CGAffineTransformMakeScale(0.9, 0.9);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:1.0/15.0 animations:^{
			self.transform = CGAffineTransformMakeScale(1.1, 1.1);
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.3 animations:^{
				self.transform = CGAffineTransformMakeScale(0.01, 0.01);
				self.alpha = 0.3;
			} completion:^(BOOL finished){
				// table alert not shown anymore
				[self removeFromSuperview];
			}];
		}];
	}];
}


- (IBAction)btnCancellPressed:(UIButton *)sender
{
    [self animateOut];
}

- (IBAction)btnOKPressed:(UIButton *)sender
{

    if ([self.delegate respondsToSelector:@selector(btnOKPressedWithName:)])
    {
        [self animateOut];
        [self.delegate btnOKPressedWithName:self.textFieldName.text];
    }
}


@end
