//
//  PLDatabaseManager.h
//  PilotLaboratories
//
//  Created by 付亚明 on 9/18/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLModel_Alarm_Timer.h"
#import "PLSceneModel.h"

@class PLModel_Device;

@interface PLDatabaseManager : NSObject

+ (id)sharedManager;

//沙盒存储路径
- (NSString *)resourcePath;

//copy需要的资料到沙盒
- (void)copyNeededResourceToResourcePath;

//将macAddress字符串转换成NSData类型Mac地址（开放给PLSaveAlarmInfo使用）
- (NSData *)changeMacAddressStringToMacAddress:(NSString *)macAddressStr;

//保存单个灯泡数据
- (void)saveLightInfo:(PLModel_Device *)light andscenename:(NSString *)currentSceneName1;

//保存多个灯泡数据,deleteOldData 为YES时先清空整个表数据再保存
- (void)saveLightsInfo:(NSArray *)lightsArr
         DeleteOldData:(BOOL)deleteOldData andscenename:(NSString *)currentSceneName1;

//查询灯泡信息(默认当前场景)
- (NSArray *)queryLightsStatus:(NSArray *)lightsArr;

//查询某一场景灯泡信息
- (NSArray *)queryLightsStatus:(NSArray *)lightsArr SceneName:(NSString *)sceneName;

//获取某一场景的所有灯
- (NSArray *)queryAllLightsWithSceneName:(NSString *)sceneName;

//添加场景
- (BOOL)addSceneWithSceneName:(NSString *)sceneName;

//删除场景
- (BOOL)deleteScene:(PLSceneModel *)scene;

//修改场景名字
- (BOOL)renameSceneWithSceneName:(NSString *)sceneName newSceneName:(NSString *)newSceneName;

//根据场景名称查询对应的场景
- (PLSceneModel *)querySceneWithSceneName:(NSString *)sceneName;

//查询所有的场景
- (NSArray *)queryAllScenes;

//修改场景icon、image
- (void)modifySceneWithScene:(PLSceneModel *)scene
                   SceneIcon:(UIImage *)sceneIcon
                  SceneImage:(UIImage *)sceneImage;




@end
