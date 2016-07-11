//
//  PLModel_SecurityStateResult.h
//  PilotLaboratories
//
//  Created by 付亚明 on 8/19/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import <Foundation/Foundation.h>

//SecurityStateType
typedef NS_ENUM (NSInteger,SecurityStateType);

@interface PLModel_SecurityStateResult : NSObject

@property (assign, nonatomic) SecurityStateType type;
@property (strong, nonatomic) NSArray *sensorsArr;

@end
