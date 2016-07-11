//
//  PLShowDoorBeaconCell.m
//  PilotLaboratories
//
//  Created by PilotLab on 15/6/24.
//  Copyright (c) 2015年 yct. All rights reserved.
//

#import "PLShowDoorBeaconCell.h"

@implementation PLShowDoorBeaconCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PLShowDBCell" owner:self options:nil];
    if (nib)
    {
        self = nib[0];
        return self;
    }
    return nil;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
