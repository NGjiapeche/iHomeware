//
//  PLModel_Alarm_Timer.h
//  PilotLaboratories
//
//  Created by Tassos on 11/26/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLModel_Alarm_Timer : NSObject

@property (strong , nonatomic) NSString *alarmTimerID;
@property (strong , nonatomic) NSString *titleName;
@property (strong , nonatomic) NSString *descriptionTitle;
@property (strong , nonatomic) NSString *time;


@property (strong , nonatomic) NSString *intervalTime;



//状态  0 关  1 开
@property (strong , nonatomic) NSString *alarmTimerstate;

@end
