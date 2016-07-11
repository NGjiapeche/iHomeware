//
//  PLSceneManager.m
//  PilotLaboratories
//
//  Created by 付亚明 on 9/18/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import "PLSceneManager.h"
#import "PLDatabaseManager.h"

#define CurrentSceneKey         @"CurrentScene"
#define SceneCountsKey          @"SceneCounts"

static PLSceneManager *manager;

@implementation PLSceneManager

+ (id)sharedManager
{
    @synchronized(self)
    {
        if (!manager)
        {
            manager = [[PLSceneManager alloc] init];
        }
        
        return manager;
    }
}

- (NSString *)currentSceneName
{
    NSString *currentSceneName = [UserDefaults objectForKey:CurrentSceneKey];
    if (currentSceneName)
    {
        return currentSceneName;
    }
    else
    {
        return @"Relax";
    }
}

- (void)setCurrentSceneName:(NSString *)currentSceneName
{
    if (currentSceneName)
    {
        //去除特殊符号
        currentSceneName = [self checkSceneName:currentSceneName];
        DebugLog(@"\n\n\n==============================setCurrentScene:%@ succeed\n\n",currentSceneName);
        [UserDefaults setObject:currentSceneName forKey:CurrentSceneKey];
        [UserDefaults synchronize];
    }
    else
    {
        DebugLog(@"\n\n\n==============================setCurrentScene:%@ failed\n\n",currentSceneName);
    }
}

- (PLSceneModel *)currentScene
{
    return [[PLDatabaseManager sharedManager] querySceneWithSceneName:self.currentSceneName];
}

//去除特殊符号
- (NSString *)checkSceneName:(NSString *)sceneName
{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"[]{}（#%-*+=_）\\|~(＜＞$%^&*)_+ "];
    return [[sceneName componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString: @""];
}

//所有的场景
- (NSArray *)allScenes
{
    return [[PLDatabaseManager sharedManager] queryAllScenes];
}

- (BOOL)addSceneWithSceneName:(NSString *)sceneName
{
    if (!sceneName)
    {
        return NO;
    }
    
    //去除特殊符号
    sceneName = [self checkSceneName:sceneName];
    return [[PLDatabaseManager sharedManager] addSceneWithSceneName:sceneName];
}

//删除场景
- (BOOL)deleteScene:(PLSceneModel *)scene
{
    if (!scene)
    {
        return NO;
    }
    
    BOOL success = [[PLDatabaseManager sharedManager] deleteScene:scene];
    if (success)
    {
        [self setCurrentSceneName:@"Relax"];
    }
    return success;
}

//修改场景名字
- (BOOL)renameSceneWithSceneName:(NSString *)sceneName newSceneName:(NSString *)newSceneName
{
    if (!sceneName || !newSceneName || [sceneName isEqualToString:newSceneName])
    {
        return NO;
    }
    
    //去除特殊符号
    sceneName = [self checkSceneName:sceneName];
    newSceneName = [self checkSceneName:newSceneName];
    return [[PLDatabaseManager sharedManager] renameSceneWithSceneName:sceneName newSceneName:newSceneName];
}

//根据场景名称查询对应的场景
- (PLSceneModel *)querySceneWithSceneName:(NSString *)sceneName
{
    if (!sceneName)
    {
        return nil;
    }
    
    return [[PLDatabaseManager sharedManager] querySceneWithSceneName:sceneName];
}

//获取某一场景的所有灯
- (NSArray *)queryAllLightsWithSceneName:(NSString *)sceneName
{
    if (!sceneName)
    {
        return nil;
    }
    
    return [[PLDatabaseManager sharedManager] queryAllLightsWithSceneName:sceneName];
}

//查询灯泡信息(默认当前场景)

- (NSArray *)queryLightsStatus:(NSArray *)lightsArr
{
    return [self queryLightsStatus:lightsArr SceneName:nil];
}

//查询某一场景灯泡信息
- (NSArray *)queryLightsStatus:(NSArray *)lightsArr SceneName:(NSString *)sceneName
{
    if (!lightsArr || lightsArr.count == 0)
    {
        return nil;
    }
    
    if (!sceneName || sceneName.length == 0)
    {
        sceneName = [self currentSceneName];
    }
    return [[PLDatabaseManager sharedManager] queryLightsStatus:lightsArr SceneName:sceneName];
}

@end
