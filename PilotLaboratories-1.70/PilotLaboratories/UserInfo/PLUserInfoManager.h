//
//  PLUserInfoManager.h
//  PilotLaboratories
//
//  Created by 付亚明 on 6/11/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLUserInfoManager : NSObject

@property (strong, nonatomic) NSString *userCredentialStr;
@property (strong, nonatomic) NSString *passwordStr;
//64Byte
@property (strong, nonatomic, readonly) NSData *userCredentialData;
//6Byte
@property (strong, nonatomic, readonly) NSData *passwordData;
//6Byte
//第二台手机登陆同一个账号时，网关会将第一台手机的password返回回来
@property (strong, nonatomic) NSData *previousPasswordData;

//修改邮箱时临时使用
@property (strong, nonatomic) NSString *tempUserCredentialStr;
@property (strong, nonatomic) NSString *tempPasswordStr;
//64Byte
@property (strong, nonatomic, readonly) NSData *tempUserCredentialData;
//6Byte
@property (strong, nonatomic, readonly) NSData *tempPasswordData;

@property (strong, nonatomic) NSString *strRemTag;



+ (id)sharedManager;

@end
