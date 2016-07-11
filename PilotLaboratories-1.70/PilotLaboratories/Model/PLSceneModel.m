//
//  PLSceneModel.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14/12/4.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLSceneModel.h"

@implementation PLSceneModel

//icon沙盒路径
- (NSString *)sceneIconPath
{
    NSString *resourcePath = [[PLDatabaseManager sharedManager] resourcePath];
    return [resourcePath stringByAppendingPathComponent:self.strSecenIcon];
}

//image沙盒路径
- (NSString *)sceneImagePath
{
    NSString *resourcePath = [[PLDatabaseManager sharedManager] resourcePath];
    return [resourcePath stringByAppendingPathComponent:self.strSecenBackImage];
}

@end
