//
//  PLAlterListsGatewayCell.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-9.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLAlterListsGatewayCell.h"

@implementation PLAlterListsGatewayCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PLAlterListsGatewayCell" owner:self options:nil];
    if (nib)
    {
        self = nib[0];
        return self;
    }
    return nil;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
