//
//  PLSceneManager.h
//  PilotLaboratories
//
//  Created by 付亚明 on 9/18/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLSceneManager : NSObject

//App刚启动
@property (assign, nonatomic) BOOL appLaunch;
//是否需要同步场景，连接上一个新的网关时需要同步本地场景给网关
@property (assign, nonatomic) BOOL shouldSyncScene;
//当前场景名
@property (copy, nonatomic) NSString *currentSceneName;
//当前场景
@property (strong, nonatomic) PLSceneModel *currentScene;
//正在编辑场景
@property (assign, nonatomic) BOOL isEditingScene;

+ (id)sharedManager;

//所有的场景
- (NSArray *)allScenes;

//添加场景
- (BOOL)addSceneWithSceneName:(NSString *)sceneName;

//删除场景
- (BOOL)deleteScene:(PLSceneModel *)scene;

//修改场景名字
- (BOOL)renameSceneWithSceneName:(NSString *)sceneName newSceneName:(NSString *)newSceneName;

//根据场景名称查询对应的场景
- (PLSceneModel *)querySceneWithSceneName:(NSString *)sceneName;

//获取某一场景的所有灯
- (NSArray *)queryAllLightsWithSceneName:(NSString *)sceneName;

//查询灯泡信息(默认当前场景)
- (NSArray *)queryLightsStatus:(NSArray *)lightsArr;

//查询某一场景灯泡信息
- (NSArray *)queryLightsStatus:(NSArray *)lightsArr SceneName:(NSString *)sceneName;

@end
