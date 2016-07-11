//
//  PLModel_Device.m
//  PilotLaboratories
//
//  Created by 付亚明 on 4/1/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import "PLModel_Device.h"

@implementation PLModel_Device

- (NSString *)deviceName
{
    @synchronized(self)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *deviceNameDict = [userDefaults objectForKey:@"DeviceNameDict"];
        if (deviceNameDict)
        {
            NSString *key = [self deviceKey];
            return deviceNameDict[key];
        }
        
        return nil;
    }
}

- (void)setDeviceName:(NSString *)deviceName
{
    @synchronized(self)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *tempDict = [userDefaults objectForKey:@"DeviceNameDict"];
        NSMutableDictionary *deviceNameDict;
        if (!tempDict)
        {
            deviceNameDict = [NSMutableDictionary new];
        }
        else
        {
            deviceNameDict = [NSMutableDictionary dictionaryWithDictionary:tempDict];
        }
        
        NSString *key = [self deviceKey];
        [deviceNameDict setObject:deviceName forKey:key];
        
        [userDefaults setObject:deviceNameDict forKey:@"DeviceNameDict"];
        [userDefaults synchronize];
    }
}

- (NSString *)deviceAlertTime
{
    if (self.alertTimeList)
    {
        return self.alertTimeList[0];
    }
    
    return nil;
}

- (void)setDeviceAlertTime:(NSString *)deviceAlertTime
{
    NSMutableArray *tempArr;
    if (self.alertTimeList)
    {
        tempArr = [NSMutableArray arrayWithArray:self.alertTimeList];
    }
    else
    {
        tempArr = [NSMutableArray new];
    }
    
    if (![tempArr containsObject:deviceAlertTime])
    {
        [tempArr insertObject:deviceAlertTime atIndex:0];
    }
    
    if (tempArr.count > 4)
    {
        [tempArr removeLastObject];
    }
    
    self.alertTimeList = tempArr;
}

- (NSArray *)alertTimeList
{
    @synchronized(self)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *alertTimeListDict = [userDefaults objectForKey:@"AlertTimeListDict"];
        if (alertTimeListDict)
        {
            NSString *key = [self deviceKey];
            return alertTimeListDict[key];
        }
        
        return nil;
    }
}

- (void)setAlertTimeList:(NSArray *)alertTimeList
{
    @synchronized(self)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *tempDict = [userDefaults objectForKey:@"AlertTimeListDict"];
        NSMutableDictionary *alertTimeListDict;
        if (!tempDict)
        {
            alertTimeListDict = [NSMutableDictionary new];
        }
        else
        {
            alertTimeListDict = [NSMutableDictionary dictionaryWithDictionary:tempDict];
        }
        
        NSString *key = [self deviceKey];
        [alertTimeListDict setObject:alertTimeList forKey:key];
        
        [userDefaults setObject:alertTimeListDict forKey:@"AlertTimeListDict"];
        [userDefaults synchronize];
    }
}

- (BOOL)alertStatus
{
    @synchronized(self)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *alertStatusDict = [userDefaults objectForKey:@"AlertStatusDict"];
        if (alertStatusDict)
        {
            NSString *key = [self deviceKey];
            NSString *statusStr = alertStatusDict[key];
            if ([statusStr isEqualToString:@"1"])
            {
                return YES;
            }
            else if ([statusStr isEqualToString:@"0"])
            {
                return NO;
            }
        }
        
        //默认打开
        return YES;
    }
}

- (void)setAlertStatus:(BOOL)alertStatus
{
    @synchronized(self)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *tempDict = [userDefaults objectForKey:@"AlertStatusDict"];
        NSMutableDictionary *alertStatusDict;
        if (!tempDict)
        {
            alertStatusDict = [NSMutableDictionary new];
        }
        else
        {
            alertStatusDict = [NSMutableDictionary dictionaryWithDictionary:tempDict];
        }
        
        NSString *key = [self deviceKey];
        NSString *statusStr = alertStatus ? @"1" : @"0";
        [alertStatusDict setObject:statusStr forKey:key];
        
        [userDefaults setObject:alertStatusDict forKey:@"AlertStatusDict"];
        [userDefaults synchronize];
    }
}

- (BOOL)isAlerting
{
    @synchronized(self)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *alertStatusDict = [userDefaults objectForKey:@"IsAlertingDict"];
        if (alertStatusDict)
        {
            NSString *key = [self deviceKey];
            NSString *statusStr = alertStatusDict[key];
            if ([statusStr isEqualToString:@"1"])
            {
                return YES;
            }
            else if ([statusStr isEqualToString:@"0"])
            {
                return NO;
            }
        }
        
        //默认不报警
        return NO;
    }
}

- (void)setIsAlerting:(BOOL)isAlerting
{
    @synchronized(self)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *tempDict = [userDefaults objectForKey:@"IsAlertingDict"];
        NSMutableDictionary *alertStatusDict;
        if (!tempDict)
        {
            alertStatusDict = [NSMutableDictionary new];
        }
        else
        {
            alertStatusDict = [NSMutableDictionary dictionaryWithDictionary:tempDict];
        }
        
        NSString *key = [self deviceKey];
        NSString *statusStr = isAlerting ? @"1" : @"0";
        [alertStatusDict setObject:statusStr forKey:key];
        
        [userDefaults setObject:alertStatusDict forKey:@"IsAlertingDict"];
        [userDefaults synchronize];
    }
}

- (int)index
{
    @synchronized(self)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *deviceIndexDict = [userDefaults objectForKey:@"DeviceIndex"];
        //保存过灯
        if (deviceIndexDict)
        {
            NSString *key = [self deviceKey];
            NSString *indexStr = deviceIndexDict[key];
            if (indexStr.length > 0)
            {
                //该灯已经存在
                return indexStr.intValue;
            }
            else
            {
                //该灯不存在
                NSArray *indexArr = deviceIndexDict.allValues;
                int index = indexArr.count + 1;
                self.index = index;
                return index;
            }
        }
        
        //没有保存过灯（第一个灯）
        int index = 1;
        self.index = index;
        return index;
    }
}

- (void)setIndex:(int)index
{
    @synchronized(self)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *tempDict = [userDefaults objectForKey:@"DeviceIndex"];
        NSMutableDictionary *deviceIndexDict;
        if (!tempDict)
        {
            deviceIndexDict = [NSMutableDictionary new];
        }
        else
        {
            deviceIndexDict = [NSMutableDictionary dictionaryWithDictionary:tempDict];
        }
        
        NSString *key = [self deviceKey];
        NSString *indexStr = [NSString stringWithFormat:@"%d",index];
        [deviceIndexDict setObject:indexStr forKey:key];
        
        [userDefaults setObject:deviceIndexDict forKey:@"DeviceIndex"];
        [userDefaults synchronize];
    }
}

- (NSString *)deviceKey
{
    return [NSString stringWithFormat:@"%@",self.macAddress];
}

@end
