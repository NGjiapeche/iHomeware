//
//  PLColorPickerView.h
//  PilotLaboratories
//
//  Created by frontier on 14-4-1.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLCustomButton.h"

@class PLGradientView;


@protocol PLColorPickerViewDelegate <NSObject>

- (void)btnAddSecenPressed;

@end

@interface PLColorPickerView : UIView
{
    CGRect warmColorMatrixFrame;
    CGRect coolColorMatrixFrame;
    UIColor *currentColor;
    
    CGRect bigPicColorMatrixFrame;
}

@property (strong, nonatomic) NSArray *arrLights;

@property (readwrite) CGFloat currentBrightness;
@property (readwrite) CGFloat currentHue;
@property (readwrite) CGFloat currentSaturation;

@property (strong, nonatomic) IBOutlet UIImageView *warmHueSatImage;
@property (strong, nonatomic) IBOutlet UIImageView *coolHueSatImage;
@property (strong, nonatomic) PLCustomButton *currentLightClicked;
@property (assign, nonatomic) int dimLight;

@property (strong, nonatomic) NSMutableArray *mutArrAllLights;
@property (strong, nonatomic) NSMutableArray *mutArrAllBtns;
@property (assign, nonatomic) id<PLColorPickerViewDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIImageView *imageVBigTap; //余长涛新增
//二期编辑页面
@property (strong, nonatomic) IBOutlet UITableView *tableLights;
@property (strong, nonatomic) IBOutlet UIButton *btnPohoto;

@property (strong, nonatomic) NSMutableArray *mutArrSave;



@end
