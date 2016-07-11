//
//  PLModel_Group.h
//  PilotLaboratories
//
//  Created by 付亚明 on 4/26/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLModel_Group : NSObject

//Group ID
@property (assign, nonatomic) char groupID;
//最大成员数
@property (assign, nonatomic) char maxMember;
//成员数 默认0
@property (assign, nonatomic) char memNum;

@end
