//
//  PLEULAVC.m
//  PilotLaboratories
//
//  Created by frontier on 14-3-24.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLEULAVC.h"

@interface PLEULAVC ()

- (IBAction)backButtonPressed:(UIButton *)sender;
@end

@implementation PLEULAVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)backButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
