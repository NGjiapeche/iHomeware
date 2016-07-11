//
//  PLCustomAlterView.m
//  PilotLaboratories
//
//  Created by frontier on 14-3-21.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLCustomAlterView.h"

@interface PLCustomAlterView ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIView *contenView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;

@end


@implementation PLCustomAlterView

- (id)initWithFrame:(CGRect)frame
{
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"PLCustomAlterView"
                                                     owner:self
                                                   options:nil];
    if (tempArr) {
        
        self = tempArr[0];
        
        if (self) {
            self.frame = frame;
            self.contenView.layer.cornerRadius = 5.0;
            self.labelTitle.font = fontCustom(15);
            self.okBtn.titleLabel.font = fontCustom(15);
        }
        return self;
    }
    
    return nil;
}

- (void)setTitle:(NSString *)title
{
    self.labelTitle.text = title;
}

- (void)setDataSourceArr:(NSArray *)dataSourceArr
{
    _dataSourceArr = dataSourceArr;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
//        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = fontCustom(13);
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.text = self.dataSourceArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(customSelectView:didSelectRowAtIndex:)]) {
        [self.delegate customSelectView:self didSelectRowAtIndex:indexPath.row];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if ([self.delegate respondsToSelector:@selector(baseSelectViewBackGroundDidClicked:)]) {
        [self.delegate baseSelectViewBackGroundDidClicked:self];
    }
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

//- (void)show
//{
//    self.originalFrame = self.frame;
//    self.frame = CGRectZero;
//    
//    UIWindow *window = [[UIApplication sharedApplication].delegate window];
//    self.center = window.center;
//    [window addSubview:self];
//    [window bringSubviewToFront:self];
//    
//    [UIView animateWithDuration:1 animations:^{
//        
//    } completion:^(BOOL finished) {
//        self.frame = self.originalFrame;
//    }];
//}


- (IBAction)btnOKPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(baseSelectViewBackGroundDidClicked:)]) {
        [self.delegate baseSelectViewBackGroundDidClicked:self];
    }
}



@end
