//
//  PLSceneView.h
//  PilotLaboratories
//
//  Created by 付亚明 on 2/8/15.
//  Copyright (c) 2015 yct. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLSceneModel.h"

@class PLSceneView;

@protocol PLSceneViewDelegate  <NSObject>

- (void)sceneView:(PLSceneView *)view iconButtonDidClicked:(UIButton *)button;
- (void)sceneView:(PLSceneView *)view iconButtonDidLongPressed:(UIButton *)button;

@end

@interface PLSceneView : UIView

@property (strong, nonatomic) PLSceneModel *scene;
@property (assign, nonatomic) id<PLSceneViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *iconBtn;
- (id)initWithScene:(PLSceneModel *)scene;

@end
