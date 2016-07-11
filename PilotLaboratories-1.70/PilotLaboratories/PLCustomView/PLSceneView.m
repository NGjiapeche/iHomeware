//
//  PLSceneView.m
//  PilotLaboratories
//
//  Created by 付亚明 on 2/8/15.
//  Copyright (c) 2015 yct. All rights reserved.
//

#import "PLSceneView.h"

#define SceneDidSelected    @"SceneDidSelected"

@interface PLSceneView ()


@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation PLSceneView

- (void)dealloc
{
    [self setIconBtn:nil];
    [self setNameLabel:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithScene:(PLSceneModel *)scene
{
    NSArray *tempArray = [[NSBundle mainBundle] loadNibNamed:@"PLSceneView" owner:nil options:nil];
    if (tempArray && tempArray.count > 0)
    {
        self = tempArray[0];
        self.scene = scene;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSceneDidSelected:) name:SceneDidSelected object:nil];
        [self loadUI];
        return self;
    }
    
    return nil;
}

- (void)loadUI
{
    self.nameLabel.text = NSLocalizedString(self.scene.strSecenName, nil);
    self.iconBtn.layer.cornerRadius = CGRectGetWidth(self.iconBtn.frame) / 2.0;
    self.iconBtn.layer.masksToBounds = YES;
    self.iconBtn.layer.borderWidth = 3.0;
    self.iconBtn.showsTouchWhenHighlighted = NO;
    [self.iconBtn addTarget:self action:@selector(iconButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(iconButtonLongPressed:)];
    gesture.minimumPressDuration = 1.0;
    [self.iconBtn addGestureRecognizer:gesture];
    
    [self.iconBtn setImage:[UIImage imageWithContentsOfFile:self.scene.sceneIconPath] forState:UIControlStateNormal];
    
    NSString *currentSceneName = [[PLSceneManager sharedManager] currentSceneName];
    if ([currentSceneName isEqualToString:self.scene.strSecenName])
    {
        self.iconBtn.layer.borderColor = [UIColor redColor].CGColor;
    }
    else
    {
        self.iconBtn.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    if (self.scene.sceneIndex == 1)
    {
        self.iconBtn.selected = YES;
        [self.iconBtn setImage:[UIImage imageNamed:@"light_OFF.png"] forState:UIControlStateNormal];
        [self.iconBtn setImage:[UIImage imageNamed:@"light_ON.png"] forState:UIControlStateSelected];
    }
}

- (void)iconButtonClicked:(UIButton *)sender
{
    if (self.scene.sceneIndex == 1)
    {
        self.iconBtn.selected = !self.iconBtn.selected;
    }
    
    if (self.scene.sceneIndex > 3)
    {
        self.iconBtn.layer.borderColor = [UIColor redColor].CGColor;
        [[NSNotificationCenter defaultCenter] postNotificationName:SceneDidSelected object:self.scene.strSecenName];
    }
    
    if ([self.delegate respondsToSelector:@selector(sceneView:iconButtonDidClicked:)])
    {
        [self.delegate sceneView:self iconButtonDidClicked:sender];
    }
}

- (void)iconButtonLongPressed:(UILongPressGestureRecognizer *)gesture
{
    
    if (self.scene.sceneIndex > 9)
    {
        self.iconBtn.layer.borderColor = [UIColor redColor].CGColor;
        [[NSNotificationCenter defaultCenter] postNotificationName:SceneDidSelected object:self.scene.strSecenName];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if ([self.delegate respondsToSelector:@selector(sceneView:iconButtonDidLongPressed:)])
        {
            [self.delegate sceneView:self iconButtonDidLongPressed:self.iconBtn];
        }
    }
}

- (void)handleSceneDidSelected:(NSNotification *)notification
{
    NSString *selectedScene = notification.object;
    if (selectedScene && [self.scene.strSecenName isEqualToString:selectedScene] && self.scene.sceneIndex > 3)
    {
        self.iconBtn.layer.borderColor = [UIColor redColor].CGColor;
    }
    else
    {
        self.iconBtn.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
