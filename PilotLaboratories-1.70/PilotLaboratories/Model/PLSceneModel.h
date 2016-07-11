//
//  PLSceneModel.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14/12/4.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLSceneModel : NSObject

@property (copy, nonatomic) NSString *strSecenIcon;
@property (copy, nonatomic) NSString *strSecenBackImage;
@property (copy, nonatomic) NSString *strSecenName;
@property (assign, nonatomic) int sceneIndex;
@property (copy, nonatomic) NSString *strTableName;

//icon沙盒路径
- (NSString *)sceneIconPath;
//image沙盒路径
- (NSString *)sceneImagePath;

@end
