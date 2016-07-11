//
//  PLLightingVC.h
//  PilotLaboratories
//
//  Created by frontier on 14-3-20.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLRootVC.h"
#import "PLSceneModel.h"
#import "PLColorPickerView.h"

@interface PLLightingVC : PLRootVC

@property (strong, nonatomic) PLSceneModel *scene;
@property (strong, nonatomic) PLColorPickerView *tempColorView;

@end
