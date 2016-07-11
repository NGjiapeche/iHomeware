//
//  PLAlarmTimer_Switch.h
//  PilotLaboratories
//
//  Created by Tassos on 11/26/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PLAlarmTimer_SwitchDelegate <NSObject>
- (void)operationSwitchAction:(UISwitch *)operationSwitch andCell:(UITableViewCell *)cell;
@end

@interface PLAlarmTimer_Switch : UITableViewCell
@property (weak, nonatomic) id<PLAlarmTimer_SwitchDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *cellSwitch;

@end
