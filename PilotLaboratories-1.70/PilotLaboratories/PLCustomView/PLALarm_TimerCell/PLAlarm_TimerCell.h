//
//  PLAlarm_TimerCell.h
//  PilotLaboratories
//
//  Created by Tassos on 11/25/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PLAlarm_TimerCellDetegate <NSObject>
- (void)operationSwitchAction:(UISwitch *)operationSwitch andCell:(UITableViewCell *)cell;

@end


@interface PLAlarm_TimerCell : UITableViewCell
@property (weak, nonatomic) id<PLAlarm_TimerCellDetegate>delegate;
@property (weak, nonatomic) IBOutlet UIImageView *alarmOrTimeImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *expatiationLabel;
@property (weak, nonatomic) IBOutlet UILabel *operationLabel;
@property (weak, nonatomic) IBOutlet UISwitch *operationSwitch;

@end
