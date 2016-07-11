//
//  PLCustomAlterView.h
//  PilotLaboratories
//
//  Created by frontier on 14-3-21.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLCustomAlterView;

@protocol PLCustomAlterViewDelegate <NSObject>

@optional
- (void)customSelectView:(PLCustomAlterView *)view didSelectRowAtIndex:(NSInteger) indexRow;
- (void)baseSelectViewBackGroundDidClicked:(PLCustomAlterView *)view;

@end

@interface PLCustomAlterView : UIView

@property (unsafe_unretained, nonatomic) id<PLCustomAlterViewDelegate>delegate;
@property (strong, nonatomic) NSArray *dataSourceArr;
@property (strong, nonatomic) NSString *title;

- (void)show;

@end
