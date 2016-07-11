//
//  CustomSecurityStateSetupCell.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-8.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomSecurityStateSetupCell;
@protocol CustomSecurityStateSetupCellDelegate <NSObject>

- (void)swichPressedOnCell:(CustomSecurityStateSetupCell *)cell andSwichStatus:(BOOL)status;

@end

@interface CustomSecurityStateSetupCell : UITableViewCell

@property (unsafe_unretained, nonatomic) id<CustomSecurityStateSetupCellDelegate>delegate;
@property (strong, nonatomic) IBOutlet UILabel *labelSensor;
@property (strong, nonatomic) IBOutlet UILabel *labelState;
@property (strong, nonatomic) IBOutlet UISwitch *switchOnOrOff;
@property (weak, nonatomic) IBOutlet UIImageView *issiimg;
-(void)setcellinfo:(PLModel_Device*)device withindex:(NSInteger)index;
@end
