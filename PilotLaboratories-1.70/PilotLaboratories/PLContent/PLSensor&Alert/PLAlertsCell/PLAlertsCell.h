//
//  PLAlertsCell.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-7.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLModel_Device.h"
@interface PLAlertsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

-(void)setcelldevicename:(PLModel_Device *)device withindex:(NSInteger)index;
@end
