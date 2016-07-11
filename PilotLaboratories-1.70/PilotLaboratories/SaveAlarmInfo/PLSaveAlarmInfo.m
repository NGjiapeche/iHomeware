//
//  PLSaveAlarmInfo.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-6-25.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLSaveAlarmInfo.h"

@implementation PLSaveAlarmInfo

static PLSaveAlarmInfo *manager;

+ (id)sharedManager
{
    @synchronized(self)
    {
        if (!manager)
        {
            manager = [[PLSaveAlarmInfo alloc] init];
        }
        
        return manager;
    }
}

-(void)setMutArrAlarm:(NSMutableArray *)mutArrAlarm
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *shortAddrListArr = [NSMutableArray new];
    if (mutArrAlarm.count <= 10)
    {
        for (int i = 0; i < (int)mutArrAlarm.count; i++)
        {
            PLModel_Device *device = mutArrAlarm[i];
            NSString *macAddressStr = [NSString stringWithFormat:@"%@",device.macAddress];
            macAddressStr = [macAddressStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
            macAddressStr = [macAddressStr stringByReplacingOccurrencesOfString:@">" withString:@""];
            macAddressStr = [macAddressStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString *deviceType = [NSString stringWithFormat:@"%d",device.deviceType];
            NSMutableDictionary *deviceDict = [NSMutableDictionary new];
            [deviceDict setObject:macAddressStr forKey:@"MacAddress"];
            [deviceDict setObject:deviceType forKey:@"DeviceType"];
            [shortAddrListArr addObject:deviceDict];
        }
    }
    else
    {
        for (int i = (int)mutArrAlarm.count - 10; i < mutArrAlarm.count; i++)
        {
            PLModel_Device *device = mutArrAlarm[i];
            NSString *macAddressStr = [NSString stringWithFormat:@"%@",device.macAddress];
            macAddressStr = [macAddressStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
            macAddressStr = [macAddressStr stringByReplacingOccurrencesOfString:@">" withString:@""];
            macAddressStr = [macAddressStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString *deviceType = [NSString stringWithFormat:@"%d",device.deviceType];
            NSMutableDictionary *deviceDict = [NSMutableDictionary new];
            [deviceDict setObject:macAddressStr forKey:@"MacAddress"];
            [deviceDict setObject:deviceType forKey:@"DeviceType"];
            [shortAddrListArr addObject:deviceDict];
        }
    }
    
    [userDefaults setObject:shortAddrListArr forKey:armAllInfo];
    [userDefaults synchronize];
}

- (NSMutableArray *)mutArrAlarm
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *tempArr = [userDefaults objectForKey:armAllInfo];
    NSMutableArray *mutArrAlarm = [NSMutableArray new];
    if (tempArr)
    {
        for (int i = 0; i < tempArr.count; i++)
        {
            NSDictionary *deviceDict = tempArr[i];
            NSString *macAddressStr = deviceDict[@"MacAddress"];
            NSData *macAddress = [[PLDatabaseManager sharedManager] changeMacAddressStringToMacAddress:macAddressStr];
            int deviceType = [deviceDict[@"DeviceType"] intValue];
            PLModel_Device *device = [PLModel_Device new];
            device.macAddress = macAddress;
            device.deviceType = deviceType;
            [mutArrAlarm addObject:device];
        }
    }
    
    return mutArrAlarm;
}

@end
