//
//  PLLightingCell.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14/12/2.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLLightingCell.h"

@implementation PLLightingCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnSelectedPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(btnSelectedPressedOnLightingCell: andBtn:)])
    {
        [self.delegate btnSelectedPressedOnLightingCell:self andBtn:sender];
    }
}

- (IBAction)sliderPressed:(UISlider *)sender
{
    if ([self.delegate respondsToSelector:@selector(sliderClickedOnLightingCell:andSlider:)])
    {
        [self.delegate sliderClickedOnLightingCell:self andSlider:sender];
//        [self.delegate updateValue:sender];
    }
}

@end
