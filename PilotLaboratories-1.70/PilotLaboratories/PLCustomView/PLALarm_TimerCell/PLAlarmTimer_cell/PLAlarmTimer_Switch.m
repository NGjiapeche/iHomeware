//
//  PLAlarmTimer_Switch.m
//  PilotLaboratories
//
//  Created by Tassos on 11/26/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import "PLAlarmTimer_Switch.h"

@implementation PLAlarmTimer_Switch

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)cellSwitchAction:(id)sender
{
 
    [self.delegate operationSwitchAction:sender andCell:self];
}

@end
