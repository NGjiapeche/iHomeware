//
//  PLClickedBigButton.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-6-30.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLCustomButton.h"

@interface PLClickedBigButton : PLCustomButton

@property (strong, nonatomic) NSMutableArray *mutArrClickedLights;
@property (assign, nonatomic) unsigned char colorR;
//颜色G 1Byte
@property (assign, nonatomic) unsigned char colorG;
//颜色B 1Byte
@property (assign, nonatomic) unsigned char colorB;

@end
