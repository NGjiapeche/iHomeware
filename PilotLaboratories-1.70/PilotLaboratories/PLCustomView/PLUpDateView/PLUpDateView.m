//
//  PLUpDateView.m
//  PilotLaboratories
//
//  Created by PilotLab on 15/7/3.
//  Copyright (c) 2015年 yct. All rights reserved.
//

#import "PLUpDateView.h"

@implementation PLUpDateView

-(id)initWithFrame:(CGRect)frame{
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"PLUpDateView" owner:self options:nil];
    self = tempArr[0];
    if (self) {
        self.frame = frame;
        self.titel.text = [NSString stringWithFormat:NSLocalizedString(@"Gateway version update",nil)];
        self.newlabel.text = [NSString stringWithFormat:NSLocalizedString(@"Latest version:",nil)];
        self.oldlabel.text =  [NSString stringWithFormat:NSLocalizedString(@"Current version:",nil)];
        self.cancellabel.text =  [NSString stringWithFormat:NSLocalizedString(@"Ignore",nil)];
        [self.Upbnt setTitle: [NSString stringWithFormat:NSLocalizedString(@"Update Now",nil)] forState:UIControlStateNormal];
        [self.Cancelbnt setTitle: [NSString stringWithFormat:NSLocalizedString(@"Tell me later",nil)] forState:UIControlStateNormal];
        self.layer.cornerRadius = 10;
        [self.IFbnt setImage:[UIImage imageNamed:@"_off_focused_holo_light"] forState:UIControlStateNormal];
        [self.IFbnt setImage:[UIImage imageNamed:@"_on_focused_holo_light"] forState:UIControlStateSelected];
        self.IFbnt.selected = NO;
    }
    return self;
}
-(void)setoldversion:(NSString *)oldnum newvwesion:(NSString *)newnum{
    _OldVerNumb.text =oldnum;
    _NewVerNumb.text = newnum;
}
- (IBAction)IFbntPressed:(UIButton *)sender {
    self.IFbnt.selected = !self.IFbnt.selected;
    [self.delegate IFbntPressedwithselect:self.IFbnt.selected];

}
- (IBAction)Upbntpressed:(UIButton *)sender {
    [self.delegate UpbntPressed];
}
- (IBAction)Cancelbntpressed:(UIButton *)sender {

    [self.delegate CancelPressed];

}


@end
