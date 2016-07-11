//
//  PLNotiAndAlerts.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-6-27.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLNotiAndAlerts.h"

@interface PLNotiAndAlerts()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UITableView *tableVIewGateways;
@property (strong, nonatomic) IBOutlet UIView *viewBackground;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@end

@implementation PLNotiAndAlerts

- (id)initWithFrame:(CGRect)frame
{
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"PLNotiAndAlerts"
                                                     owner:self
                                                   options:nil];
    if (tempArr) {
        self = tempArr[0];
        if (self) {
            self.frame = frame;
            self.contentView.layer.cornerRadius = 8.0;
            self.tableVIewGateways.layer.borderColor = [UIColor lightGrayColor].CGColor;
            self.tableVIewGateways.layer.borderWidth = 1;
            self.tableVIewGateways.delegate = self;
            self.tableVIewGateways.dataSource = self;
            self.labelTitle.font = fontCustom(15);
            self.cancelBtn.titleLabel.font = fontCustom(15);
        }
        return self;
    }
    return nil;
    return self;
}

-(void)setArrGateways:(NSArray *)arrGateways
{
    _arrGateways = arrGateways;
    [self.tableVIewGateways reloadData];
}

- (void)show
{
    [self animateIn];
}

-(void)animateIn
{
	// UIAlertView-like pop in animation
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.center = window.center;
    [window addSubview:self];
    [window bringSubviewToFront:self];
    
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

#pragma mark - tableview datasource and delegate  -


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrGateways.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = fontCustom(15);
    }
    cell.textLabel.text = self.arrGateways[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(cellOnWifiDidSelected:withView:)])
    {
        [self.delegate cellOnWifiDidSelected:[NSString stringWithFormat:@"%@",self.arrGateways[indexPath.row]] withView:self];
    }
    [self animateOut];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
