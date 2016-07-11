//
//  PLCustomButton.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-29.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLModel_Device.h"

@interface PLCustomButton : UIButton

@property (assign, nonatomic) unsigned char firstShortAddress;
@property (assign, nonatomic) unsigned char secondShortAddress;
@property (strong, nonatomic) PLModel_Device *light;
@property (strong, nonatomic) NSString *deviceKey;
@property (assign, nonatomic) BOOL on;

@end
