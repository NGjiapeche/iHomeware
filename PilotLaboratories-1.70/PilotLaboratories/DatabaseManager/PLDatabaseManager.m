//
//  PLDatabaseManager.m
//  PilotLaboratories
//
//  Created by 付亚明 on 9/18/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import "PLDatabaseManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "PLModel_Device.h"
#import "HuangConstants.h"
#import "PLSceneModel.h"

@interface PLDatabaseManager()

@property (strong, nonatomic) FMDatabase *dataBase;
@property (strong, nonatomic) FMDatabaseQueue *databaseQueue;

@end

static PLDatabaseManager *manager;

@implementation PLDatabaseManager

+ (id)sharedManager
{
    @synchronized(self)
    {
        if (!manager)
        {
            manager = [[PLDatabaseManager alloc] init];
        }
       
        return manager;
    }
}

- (NSString *)resourcePath
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/Resource/"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path isDirectory:NO])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return path;
}

#pragma mark - copy数据库到沙盒

- (void)copyNeededResourceToResourcePath
{
    NSString *resourcePath = [self resourcePath];
    NSString *dbPath = [resourcePath stringByAppendingPathComponent:@"Pilot.db"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dbPath])
    {
        DebugLog(@"\n\n==============================copy数据库到沙盒\n\n");
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Pilot" ofType:@"db"];
        if ([fileManager copyItemAtPath:bundlePath toPath:dbPath error:nil])
        {
            DebugLog(@"\n\n==============================copy数据库到沙盒成功\n\n");
            
            //copy场景图片到沙河路径
            DebugLog(@"\n\n==============================copy场景图片到沙河\n\n");
            NSArray *scenes = [self queryAllScenes];
            for (int i = 0; i < scenes.count; i++)
            {
                PLSceneModel *scene = scenes[i];
                //暖色照片只用copy一次
                if (i == 0)
                {
                    NSString *imageName = scene.strSecenBackImage;
                    NSString *imagePrefix = [imageName substringToIndex:imageName.length - 4];
                    NSString *imageResourcePath = [resourcePath stringByAppendingPathComponent:imageName];
                    NSString *imageBundlePath = [[NSBundle mainBundle] pathForResource:imagePrefix ofType:@"png"];
                    if ([fileManager copyItemAtPath:imageBundlePath toPath:imageResourcePath error:nil])
                    {
                        DebugLog(@"\n\n==============================copy %@ 到沙盒成功\n\n",imageName);
                    }
                    else
                    {
                        DebugLog(@"\n\n==============================copy %@ 到沙盒失败\n\n",imageName);
                    }
                }
                
                NSString *iconName = scene.strSecenIcon;
                NSString *iconPrefix = [iconName substringToIndex:iconName.length - 4];
                NSString *iconResourcePath = [resourcePath stringByAppendingPathComponent:iconName];
                NSString *iconBundlePath = [[NSBundle mainBundle] pathForResource:iconPrefix ofType:@"png"];
                if ([fileManager copyItemAtPath:iconBundlePath toPath:iconResourcePath error:nil])
                {
                    DebugLog(@"\n\n==============================copy %@ 到沙盒成功\n\n",iconName);
                }
                else
                {
                    DebugLog(@"\n\n==============================copy %@ 到沙盒失败\n\n",iconName);
                }
            }
        }
        else
        {
            DebugLog(@"\n\n==============================copy数据库到沙盒失败\n\n");
        }
    }
    else
    {
        DebugLog(@"\n\n==============================沙盒数据库已存在\n\n");
    }
}

- (void)deleteSceneResource:(PLSceneModel *)scene
{
    if (scene)
    {
        //删除icon
        [self deleteResourceWithResourcePath:scene.sceneIconPath ResourceName:scene.strSecenIcon];
        //删除image
        [self deleteResourceWithResourcePath:scene.sceneImagePath ResourceName:scene.strSecenBackImage];
    }
}

- (void)deleteResourceWithResourcePath:(NSString *)path ResourceName:(NSString *)name
{
    //默认图片不能删
    if ([name isEqualToString:@"WarmColor.png"])
    {
        DebugLog(@"\n\n==============================Do Not Delete %@\n\n",name);
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
    {
        BOOL success = [fileManager removeItemAtPath:path error:nil];
        if (success)
        {
            DebugLog(@"\n\n==============================Delete %@ success\n\n",name);
        }
        else
        {
            DebugLog(@"\n\n==============================Delete %@ failed\n\n",name);
        }
    }
    else
    {
        DebugLog(@"\n\n==============================%@ not exist\n\n",name);
    }
}

- (void)saveSceneResource:(PLSceneModel *)scene
                SceneIcon:(UIImage *)sceneIcon
               SceneImage:(UIImage *)sceneImage
{
    if (scene && sceneIcon)
    {
        NSData *iconData = UIImagePNGRepresentation(sceneIcon);
        BOOL success = [iconData writeToFile:scene.sceneIconPath atomically:YES];
        if (success)
        {
            DebugLog(@"\n\n==============================save %@ success\n\n",scene.strSecenIcon);
        }
        else
        {
            DebugLog(@"\n\n==============================save %@ failed\n\n",scene.strSecenIcon);
        }
    }
    
    if (scene && sceneImage)
    {
        NSData *iconData = UIImagePNGRepresentation(sceneImage);
        BOOL success = [iconData writeToFile:scene.sceneImagePath atomically:YES];
        if (success)
        {
            DebugLog(@"\n\n==============================save %@ success\n\n",scene.strSecenBackImage);
        }
        else
        {
            DebugLog(@"\n\n==============================save %@ failed\n\n",scene.strSecenBackImage);
        }
    }
}

#pragma mark - dataBase

- (FMDatabase *)dataBase
{
    @synchronized(self)
    {
        if (!_dataBase)
        {
            NSString *resourcePath = [self resourcePath];
            NSString *filePath = [resourcePath stringByAppendingPathComponent:@"Pilot.db"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:filePath])
            {
                _dataBase = [[FMDatabase alloc] initWithPath:filePath];
                [_dataBase open];
            }
        }
        
        return _dataBase;
    }
}

#pragma mark - databaseQueue

- (FMDatabaseQueue *)databaseQueue
{
    @synchronized(self)
    {
        if (!_databaseQueue)
        {
            NSString *resourcePath = [self resourcePath];
            NSString *filePath = [resourcePath stringByAppendingPathComponent:@"Pilot.db"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:filePath])
            {
                _databaseQueue = [[FMDatabaseQueue alloc] initWithPath:filePath];
            }
        }
        
        return _databaseQueue;
    }
}

#pragma mark - runUpdateCommands

- (void)runUpdateCommands:(NSArray *)commandsArr
{
    FMDatabaseQueue *databaseQueue = [self databaseQueue];
    [databaseQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (commandsArr.count)
        {
            for (NSString *command in commandsArr)
            {
                DebugLog(@"\n\n\n==============================SQLUpdateCommand:\n\n%@\n\n",command);
                [db executeUpdate:command];
            }
        }
        [db close];
    }];
}

#pragma mark - runQuaryCommand

- (NSArray *)runQuaryCommand:(NSString *)command withscenename:(NSString *)namestr
{
    __block NSMutableArray *resultsArray = [NSMutableArray new];
    FMDatabaseQueue *databaseQueue = [self databaseQueue];
    [databaseQueue inDatabase:^(FMDatabase *db) {
        [db open];
        FMResultSet *rs = [db executeQuery:command];
        DebugLog(@"\n\n\n==============================SQLQuaryCommand:\n\n%@\n\n",command);
        while ([rs next])
        {
            PLModel_Device *light = [PLModel_Device new];
            NSString *macAddressStr = [rs stringForColumn:@"MacAddress"];
            light.macAddress = [self changeMacAddressStringToMacAddress:macAddressStr];
            light.firstShortAddr = [rs intForColumn:@"FirstShortAddress"];
            light.secondShortAddr = [rs intForColumn:@"SecondShortAddress"];
            light.colorR = [rs intForColumn:@"ColorR"];
            light.colorG = [rs intForColumn:@"ColorG"];
            light.colorB = [rs intForColumn:@"ColorB"];
            light.locationX = [rs intForColumn:@"LocationX"];
            light.locationY = [rs intForColumn:@"LocationY"];
            light.onOff = YES;
            light.Dim = [rs intForColumn:@"Dim"];
            
         [resultsArray addObject:light];
             DebugLog(@"取出来的灯(MacAddress, FirstShortAddress, SecondShortAddress, ColorR, ColorG, ColorB, LocationX, LocationY, Dim) values (%@, %@, %d, %d, %d, %d, %d, %d, %d,%d)",namestr,light.macAddress,light.firstShortAddr,light.secondShortAddr,light.colorR, light.colorG, light.colorB,light.locationX,light.locationY,light.Dim);
        }
       
        [rs close];
        [db close];
    }];
    
    return resultsArray;
}

#pragma mark - 保存单个灯泡数据

- (void)saveLightInfo:(PLModel_Device *)light andscenename:(NSString *)currentSceneName1
{
    NSString *currentSceneName =currentSceneName1;
    NSString *tempStr = [NSString stringWithFormat:@"%@",light.macAddress];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"<" withString:@"\""];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@">" withString:@"\""];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *macAddress = [NSString stringWithFormat:@"%@",tempStr];
    int firstShortAddress = light.firstShortAddr;
    int secondShortAddr = light.secondShortAddr;
    int colorR = light.colorR;
    int colorG = light.colorG;
    int colorB = light.colorB;
    NSString *sqlStr = [NSString stringWithFormat:@"replace into %@ (MacAddress, FirstShortAddress, SecondShortAddress, ColorR, ColorG, ColorB, LocationX, LocationY, Dim) values (%@, %d, %d, %d, %d, %d, %d, %d, %d)",currentSceneName,macAddress,firstShortAddress,secondShortAddr,colorR,colorG,colorB,light.locationX,light.locationY,light.Dim];
    DebugLog(@"@@@@@@@@@@@@@@@@@@@@@@@@@%@",sqlStr);
    NSArray *commandsArr = @[sqlStr];
    [self runUpdateCommands:commandsArr];
}

#pragma mark - 保存多个灯泡数据

- (void)saveLightsInfo:(NSArray *)lightsArr
         DeleteOldData:(BOOL)deleteOldData andscenename:(NSString *)currentSceneName1
{
    NSString *currentSceneName = currentSceneName1;
    NSMutableArray *commandsArr = [NSMutableArray new];
    if (deleteOldData)
    {
        NSString *command = [NSString stringWithFormat:@"delete from %@",currentSceneName];
        [commandsArr addObject:command];
    }
    
    for (PLModel_Device *light in lightsArr)
    {
        NSString *tempStr = [NSString stringWithFormat:@"%@",light.macAddress];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"<" withString:@"\""];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@">" withString:@"\""];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *macAddress = [NSString stringWithFormat:@"%@",tempStr];
        int firstShortAddress = light.firstShortAddr;
        int secondShortAddr = light.secondShortAddr;
        int colorR = light.colorR;
        int colorG = light.colorG;
        int colorB = light.colorB;
        NSString *sqlStr = [NSString stringWithFormat:@"replace into %@ (MacAddress, FirstShortAddress, SecondShortAddress, ColorR, ColorG, ColorB, LocationX, LocationY, Dim) values (%@, %d, %d, %d, %d, %d, %d, %d, %d)",currentSceneName,macAddress,firstShortAddress,secondShortAddr,colorR,colorG,colorB,light.locationX,light.locationY,light.Dim];
        [commandsArr addObject:sqlStr];
    }
    [self runUpdateCommands:commandsArr];
}


#pragma mark - 查询灯泡信息(默认当前场景)

- (NSArray *)queryLightsStatus:(NSArray *)lightsArr
{
    NSString *currentSceneName = [[PLSceneManager sharedManager] currentSceneName];
    return [self queryLightsStatus:lightsArr SceneName:currentSceneName];
}

//查询某一场景灯泡信息
- (NSArray *)queryLightsStatus:(NSArray *)lightsArr SceneName:(NSString *)sceneName
{
    if (!sceneName || sceneName.length == 0)
    {
        sceneName = [[PLSceneManager sharedManager] currentSceneName];
    }
    
    NSString *macArrressStr = @"";
    for (int i = 0; i < lightsArr.count; i++)
    {
        PLModel_Device *light = lightsArr[i];
        NSString *tempStr = [NSString stringWithFormat:@"%@",light.macAddress];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"<" withString:@"\""];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@">" withString:@"\""];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *macAddress = [NSString stringWithFormat:@"%@",tempStr];
        if (i < lightsArr.count - 1)
        {
            NSString *tempStr = [NSString stringWithFormat:@"MacAddress = %@ or ",macAddress];
            macArrressStr = [macArrressStr stringByAppendingString:tempStr];
        }
        else
        {
            NSString *tempStr = [NSString stringWithFormat:@"MacAddress = %@",macAddress];
            macArrressStr = [macArrressStr stringByAppendingString:tempStr];
        }
    }
    
    NSString *command = [NSString stringWithFormat:@"Select * from %@ where (%@)",sceneName,macArrressStr];
    return [self runQuaryCommand:command withscenename:sceneName];

}

#pragma mark - 获取某一场景的所有灯

- (NSArray *)queryAllLightsWithSceneName:(NSString *)sceneName
{
    if(sceneName)
    {
        NSString *command = [NSString stringWithFormat:@"select * from %@",sceneName];
        return [self runQuaryCommand:command withscenename:sceneName];
    }
    return nil;
}

- (NSData *)changeMacAddressStringToMacAddress:(NSString *)macAddressStr
{
    char macAddress[8];
    NSString *macAddressStr0 = [macAddressStr substringToIndex:2];
    macAddress[0] = [self changeHexStrToInt:macAddressStr0];
    
    NSString *macAddressStr1 = [macAddressStr substringWithRange:NSMakeRange(2, 2)];
    macAddress[1] = [self changeHexStrToInt:macAddressStr1];
    
    NSString *macAddressStr2 = [macAddressStr substringWithRange:NSMakeRange(4, 2)];
    macAddress[2] = [self changeHexStrToInt:macAddressStr2];
    
    NSString *macAddressStr3 = [macAddressStr substringWithRange:NSMakeRange(6, 2)];
    macAddress[3] = [self changeHexStrToInt:macAddressStr3];
    
    NSString *macAddressStr4 = [macAddressStr substringWithRange:NSMakeRange(8, 2)];
    macAddress[4] = [self changeHexStrToInt:macAddressStr4];
    
    NSString *macAddressStr5 = [macAddressStr substringWithRange:NSMakeRange(10, 2)];
    macAddress[5] = [self changeHexStrToInt:macAddressStr5];
    
    NSString *macAddressStr6 = [macAddressStr substringWithRange:NSMakeRange(12, 2)];
    macAddress[6] = [self changeHexStrToInt:macAddressStr6];
    
    NSString *macAddressStr7 = [macAddressStr substringWithRange:NSMakeRange(14, 2)];
    macAddress[7] = [self changeHexStrToInt:macAddressStr7];
    
    NSData *data = [NSData dataWithBytes:macAddress length:8];
    return data;
}

- (int)changeHexStrToInt:(NSString *)hexStr
{
    NSString *heighStr = [hexStr substringToIndex:1];
    int heigh = [self changeLetterToNumber:heighStr];
    
    NSString *lowStr = [hexStr substringFromIndex:1];
    int low = [self changeLetterToNumber:lowStr];
    
    return heigh * 16 + low;
}

- (int)changeLetterToNumber:(NSString *)letter
{
    if ([letter isEqualToString:@"a"] || [letter isEqualToString:@"A"])
    {
        return 10;
    }
    else if ([letter isEqualToString:@"b"] || [letter isEqualToString:@"B"])
    {
        return 11;
    }
    else if ([letter isEqualToString:@"c"] || [letter isEqualToString:@"C"])
    {
        return 12;
    }
    else if ([letter isEqualToString:@"d"] || [letter isEqualToString:@"D"])
    {
        return 13;
    }
    else if ([letter isEqualToString:@"e"] || [letter isEqualToString:@"E"])
    {
        return 14;
    }
    else if ([letter isEqualToString:@"f"] || [letter isEqualToString:@"F"])
    {
        return 15;
    }
    else
    {
        return letter.intValue;
    }
}

#pragma mark - 添加场景

- (BOOL)addSceneWithSceneName:(NSString *)sceneName
{
    if (!sceneName)
    {
        return NO;
    }
    
    NSString *sceneIcon = [NSString stringWithFormat:@"%@_icon.png",sceneName];
    NSString *sceneImage = [NSString stringWithFormat:@"%@_image.png",sceneName];
    NSString *command1 = [NSString stringWithFormat:@"insert into SceneName (sceneName, sceneIcon, sceneImage) values (\"%@\", \"%@\", \"%@\")",sceneName, sceneIcon, sceneImage];
    NSString *command2 = [NSString stringWithFormat:@"create table if not exists %@ (MacAddress text primary key, FirstShortAddress integer, SecondShortAddress integer, ColorR integer, ColorG integer, ColorB integer, LocationX integer, LocationY integer, Dim integer)",sceneName];
    //添加场景图片
    PLSceneModel *scene = [PLSceneModel new];
    scene.strSecenName = sceneName;
    scene.strSecenIcon = sceneIcon;
    scene.strSecenBackImage = sceneImage;
    UIImage *image = [UIImage imageNamed:@"WarmColor.png"];
    [self saveSceneResource:scene SceneIcon:image SceneImage:image];
    
    //执行创建场景表命令
    return [self runAddSceneCommand:@[command1, command2]];
}

- (BOOL)runAddSceneCommand:(NSArray *)commandArr
{
    __block BOOL success = NO;
    if (commandArr.count >= 2)
    {
        NSString *command1 = commandArr[0];
        FMDatabaseQueue *databaseQueue = [self databaseQueue];
        [databaseQueue inDatabase:^(FMDatabase *db) {
            [db open];
            DebugLog(@"\n\n\n==============================SQLAddSceneCommand:\n\n%@\n\n",command1);
            if ([db executeUpdate:command1])
            {
                DebugLog(@"\n\n\n==============================SQLAddSceneCommand:Success\n\n");
                NSString *command2 = commandArr[1];
                DebugLog(@"\n\n\n==============================SQLAddSceneCommand:\n\n%@\n\n",command2);
                if([db executeUpdate:command2])
                {
                    success = YES;
                    DebugLog(@"\n\n\n==============================SQLAddSceneCommand:Success\n\n");
                }
                else
                {
                    success = NO;
                    DebugLog(@"\n\n\n==============================SQLAddSceneCommand:Failed\n\n");
                }
            }
            else
            {
                success = NO;
                DebugLog(@"\n\n\n==============================SQLAddSceneCommand:Failed\n\n");
            }
            [db close];
        }];
    }
    
    return success;
}

#pragma mark - 删除场景

- (BOOL)deleteScene:(PLSceneModel *)scene
{
    if (!scene)
    {
        return NO;
    }
    
    NSString *command1 = [NSString stringWithFormat:@"delete from SceneName where sceneName = \"%@\"",scene.strSecenName];
    NSString *command2 = [NSString stringWithFormat:@"drop table %@",scene.strSecenName];
    return [self runDeleteSceneCommand:@[command1, command2] Scene:scene];
}

- (BOOL)runDeleteSceneCommand:(NSArray *)commandArr Scene:(PLSceneModel *)scene
{
    __block BOOL success = NO;
    if (commandArr.count >= 2)
    {
        NSString *command1 = commandArr[0];
        FMDatabaseQueue *databaseQueue = [self databaseQueue];
        [databaseQueue inDatabase:^(FMDatabase *db) {
            [db open];
            DebugLog(@"\n\n\n==============================SQLDeleteSceneCommand:\n\n%@\n\n",command1);
            if ([db executeUpdate:command1])
            {
                DebugLog(@"\n\n\n==============================SQLDeleteSceneCommand:Success\n\n");
                NSString *command2 = commandArr[1];
                DebugLog(@"\n\n\n==============================SQLDeleteSceneCommand:\n\n%@\n\n",command2);
                if([db executeUpdate:command2])
                {
                    success = YES;
                    DebugLog(@"\n\n\n==============================SQLDeleteSceneCommand:Success\n\n");
                    
                    //删除场景图片
                    [self deleteSceneResource:scene];
                }
                else
                {
                    success = NO;
                    DebugLog(@"\n\n\n==============================SQLDeleteSceneCommand:Failed\n\n");
                }
            }
            else
            {
                success = NO;
                DebugLog(@"\n\n\n==============================SQLDeleteSceneCommand:Failed\n\n");
            }
            [db close];
        }];
    }
    
    return success;
}

#pragma mark - 修改场景名字

- (BOOL)renameSceneWithSceneName:(NSString *)sceneName newSceneName:(NSString *)newSceneName
{
    if (!sceneName || !newSceneName || [sceneName isEqualToString:newSceneName])
    {
        return NO;
    }
    
//    NSString *newSceneIcon = [NSString stringWithFormat:@"%@_icon.png",newSceneName];
//    NSString *newSceneImage = [NSString stringWithFormat:@"%@_image.png",newSceneName];
//    NSString *command1 = [NSString stringWithFormat:@"update SceneName set sceneName = \"%@\", sceneIcon = \"%@\", sceneImage = \"%@\" where sceneName = \"%@\"",newSceneName,newSceneIcon,newSceneImage,sceneName];

    NSString *command1 = [NSString stringWithFormat:@"update SceneName set sceneName = \"%@\" where sceneName = \"%@\"",newSceneName,sceneName];
    NSString *command2 = [NSString stringWithFormat:@"alter table %@ rename to %@",sceneName,newSceneName];
    return [self runRenameSceneCommand:@[command1, command2]];
}

- (BOOL)runRenameSceneCommand:(NSArray *)commandArr
{
    __block BOOL success = NO;
    if (commandArr.count >= 2)
    {
        NSString *command1 = commandArr[0];
        FMDatabaseQueue *databaseQueue = [self databaseQueue];
        [databaseQueue inDatabase:^(FMDatabase *db) {
            [db open];
            DebugLog(@"\n\n\n==============================SQLRenameSceneCommand:\n\n%@\n\n",command1);
            if ([db executeUpdate:command1])
            {
                DebugLog(@"\n\n\n==============================SQLRenameSceneCommand:Success\n\n");
                NSString *command2 = commandArr[1];
                DebugLog(@"\n\n\n==============================SQLRenameSceneCommand:\n\n%@\n\n",command2);
                if([db executeUpdate:command2])
                {
                    success = YES;
                    DebugLog(@"\n\n\n==============================SQLRenameSceneCommand:Success\n\n");
                }
                else
                {
                    success = NO;
                    DebugLog(@"\n\n\n==============================SQLRenameSceneCommand:Failed\n\n");
                }
            }
            else
            {
                success = NO;
                DebugLog(@"\n\n\n==============================SQLRenameSceneCommand:Failed\n\n");
            }
            [db close];
        }];
    }
    
    return success;
}

#pragma mark - 根据场景名称查询对应的场景

- (PLSceneModel *)querySceneWithSceneName:(NSString *)sceneName
{
    __block PLSceneModel *scene = nil;
    if(sceneName)
    {
        NSString *command = [NSString stringWithFormat:@"select * from SceneName where sceneName = \"%@\"",sceneName];
        DebugLog(@"\n\n\n==============================SQLQuarySceneWithSceneNameCommand:\n\n%@\n\n",command);
        FMDatabaseQueue *databaseQueue = [self databaseQueue];
        [databaseQueue inDatabase:^(FMDatabase *db) {
            [db open];
            FMResultSet *rs = [db executeQuery:command];
            while ([rs next])
            {
                NSString *sceneName = [rs stringForColumn:@"sceneName"];
                NSString *sceneIcon = [rs stringForColumn:@"sceneIcon"];
                NSString *sceneImage = [rs stringForColumn:@"sceneImage"];
                int sceneIndex = [rs intForColumn:@"serial"];
                
                scene = [PLSceneModel new];
                scene.strSecenName = sceneName;
                scene.strSecenIcon = sceneIcon;
                scene.strSecenBackImage = sceneImage;
                scene.sceneIndex = sceneIndex;
                
                DebugLog(@"\n\n\n==============================Scene %@\nSceneName:%@\nSceneIcon:%@\nSceneImage:%@\nSceneIndex:%d\n\n",sceneName,sceneName,sceneIcon,sceneImage,sceneIndex);
            }
            [rs close];
            [db close];
        }];
    }
    
    return scene;
}

#pragma mark - 查询所有的场景

- (NSArray *)queryAllScenes
{
    __block NSMutableArray *scenesArr = [NSMutableArray new];
    NSString *command = [NSString stringWithFormat:@"Select * from SceneName"];
    DebugLog(@"\n\n\n==============================SQLQueryAllScenesCommand:\n\n%@\n\n",command);
    if (command)
    {
        FMDatabaseQueue *databaseQueue = [self databaseQueue];
        [databaseQueue inDatabase:^(FMDatabase *db) {
            [db open];
            FMResultSet *rs = [db executeQuery:command];
            while ([rs next])
            {
                NSString *sceneName = [rs stringForColumn:@"sceneName"];
                NSString *sceneIcon = [rs stringForColumn:@"sceneIcon"];
                NSString *sceneImage = [rs stringForColumn:@"sceneImage"];
                int sceneIndex = [rs intForColumn:@"serial"];
                
                PLSceneModel *scene = [PLSceneModel new];
                scene.strSecenName = sceneName;
                scene.strSecenIcon = sceneIcon;
                scene.strSecenBackImage = sceneImage;
                scene.sceneIndex = sceneIndex;
                [scenesArr addObject:scene];
                DebugLog(@"\n\n\n==============================Scene %@\nSceneName:%@\nSceneIcon:%@\nSceneImage:%@\nSceneIndex:%d\n\n",sceneName,sceneName,sceneIcon,sceneImage,sceneIndex);
            }
            [rs close];
            [db close];
        }];
    }
    return scenesArr;
}


#pragma mark - 修改场景icon、image

- (void)modifySceneWithScene:(PLSceneModel *)scene
                   SceneIcon:(UIImage *)sceneIcon
                  SceneImage:(UIImage *)sceneImage
{
    //删除旧的图片
    [self deleteSceneResource:scene];
    //保存新的图片
    [self saveSceneResource:scene SceneIcon:sceneIcon SceneImage:sceneImage];
}





@end
