//
//  PLAlarm_TimerCell.m
//  PilotLaboratories
//
//  Created by Tassos on 11/25/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import "PLAlarm_TimerCell.h"


@implementation PLAlarm_TimerCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)operationSwitchAction:(id)sender
{
    [self.delegate operationSwitchAction:sender andCell:self];
}

@end
