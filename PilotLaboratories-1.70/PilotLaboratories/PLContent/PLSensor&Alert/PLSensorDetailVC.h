//
//  PLSensorDetailVC.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-7.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLRootVC.h"

@interface PLSensorDetailVC : PLRootVC

@property (strong, nonatomic) PLModel_Device *device;
@property (strong, nonatomic) NSString *strIdentifier;
@property (strong, nonatomic) NSString *cunruntdevicename;
@end
