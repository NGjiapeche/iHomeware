//
//  PLClickedBigButton.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-6-30.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLClickedBigButton.h"

@interface PLClickedBigButton ()

@end

@implementation PLClickedBigButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)buttonWithType:(UIButtonType)buttonType
{
    PLClickedBigButton *button = [super buttonWithType:buttonType];
    return button;
}

- (void)setMutArrClickedLights:(NSMutableArray *)mutArrClickedLights
{
    _mutArrClickedLights = mutArrClickedLights;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //[self.tableView reloadData];
}


@end
