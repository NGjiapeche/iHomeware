//
//  PLUserInfoManager.m
//  PilotLaboratories
//
//  Created by 付亚明 on 6/11/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import "PLUserInfoManager.h"

static PLUserInfoManager *manager;

@implementation PLUserInfoManager

+ (id)sharedManager
{
    @synchronized(self)
    {
        if (!manager)
        {
            manager = [[PLUserInfoManager alloc] init];
        }
        
        return manager;
    }
}

- (void)setStrRemTag:(NSString *)strRemTag
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:strRemTag forKey:@"RemberTag"];
    [userDefaults synchronize];
}

- (NSString *)strRemTag
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"RemberTag"];
}

- (void)setUserCredentialStr:(NSString *)userCredentialStr
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userCredentialStr forKey:@"UserCredential"];
    [userDefaults synchronize];
}

- (NSString *)userCredentialStr
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"UserCredential"];
}

- (void)setPasswordStr:(NSString *)passwordStr
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:passwordStr forKey:@"UserPassword"];
    [userDefaults synchronize];
}

- (NSString *)passwordStr
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"UserPassword"];
}

- (NSData *)userCredentialData
{
    if (self.userCredentialStr)
    {
        NSMutableData *data = [NSMutableData dataWithData:[self.userCredentialStr dataUsingEncoding:NSUTF8StringEncoding]];
        DebugLog(@"TempUserCredentialData:%@",data);
        if (data.length < 64)
        {
            int length = 64 - (int)data.length;
            char appendData[length];
            memset(appendData, 0xFF, length);
            [data appendBytes:appendData length:length];
        }
        
        DebugLog(@"FinallyUserCredentialData:%@",data);
        return data;
    }
    
    return nil;
}

- (NSData *)passwordData
{
    if (self.passwordStr)
    {
        NSMutableData *data = [NSMutableData dataWithData:[self.passwordStr dataUsingEncoding:NSUTF8StringEncoding]];
        DebugLog(@"TempPasswordData:%@",data);
        if (data.length < 6)
        {
            int length = 6 - (int)data.length;
            char appendData[length];
            memset(appendData, 0xFF, length);
            [data appendBytes:appendData length:length];
        }
        
        DebugLog(@"FinallyPasswordData:%@",data);
        return data;
    }
    
    return nil;
}

- (NSData *)tempUserCredentialData
{
    if (self.tempUserCredentialStr)
    {
        NSMutableData *data = [NSMutableData dataWithData:[self.tempUserCredentialStr dataUsingEncoding:NSUTF8StringEncoding]];
        DebugLog(@"TempUserCredentialData:%@",data);
        if (data.length < 64)
        {
            int length = 64 - (int)data.length;
            char appendData[length];
            memset(appendData, 0xFF, length);
            [data appendBytes:appendData length:length];
        }
        
        DebugLog(@"FinallyUserCredentialData:%@",data);
        return data;
    }
    
    return nil;
}

- (NSData *)tempPasswordData
{
    if (self.tempPasswordStr)
    {
        NSMutableData *data = [NSMutableData dataWithData:[self.tempPasswordStr dataUsingEncoding:NSUTF8StringEncoding]];
        DebugLog(@"TempPasswordData:%@",data);
        if (data.length < 6)
        {
            int length = 6 - (int)data.length;
            char appendData[length];
            memset(appendData, 0xFF, length);
            [data appendBytes:appendData length:length];
        }
        
        DebugLog(@"FinallyPasswordData:%@",data);
        return data;
    }
    
    return nil;
}

@end
