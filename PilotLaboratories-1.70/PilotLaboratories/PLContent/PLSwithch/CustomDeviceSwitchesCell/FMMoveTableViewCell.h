//
//  FMMoveTableViewCell.h
//  TestMoveTableview
//
//  Created by yuchangtao on 14-5-12.
//  Copyright (c) 2014年 yuchangtao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLSwitch.h"

@class FMMoveTableViewCell;
@protocol FMMoveTableViewCellDelegate <NSObject>

- (void)swichPressedOnCell:(FMMoveTableViewCell *)cell andSwichStatus:(BOOL)status;
//- (void)longPressCell:(FMMoveTableViewCell *)cell;

@end

@interface FMMoveTableViewCell : UITableViewCell
@property (unsafe_unretained, nonatomic) id<FMMoveTableViewCellDelegate>delegate;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UISwitch *switchOnOrOff;
@property (strong, nonatomic) IBOutlet KLSwitch *customSwithch;

- (void)prepareForMove;

@end
