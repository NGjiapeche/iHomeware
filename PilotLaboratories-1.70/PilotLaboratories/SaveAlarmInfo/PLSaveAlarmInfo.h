//
//  PLSaveAlarmInfo.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-6-25.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLModel_Device.h"

@interface PLSaveAlarmInfo : NSObject

//存储报警设备信息
@property (strong, nonatomic) NSMutableArray *mutArrAlarm;

+ (id)sharedManager;

@end
