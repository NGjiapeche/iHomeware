//
//  PLModel_CheckResult.h
//  PilotLaboratories
//
//  Created by 付亚明 on 6/20/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLModel_CheckResult : NSObject

//该账户是否已存在
@property (assign, nonatomic) BOOL hasAlreadyExist;
//若该账户存在，已经存在的密码
@property (strong, nonatomic) NSData *password;

@end
