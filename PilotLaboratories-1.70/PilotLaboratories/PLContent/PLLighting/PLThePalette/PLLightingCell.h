//
//  PLLightingCell.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14/12/2.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PLLightingCell;

@protocol PLLightingCellDelegate <NSObject>

- (void)btnSelectedPressedOnLightingCell:(PLLightingCell *)cell andBtn:(UIButton *)btnOnCell;
- (void)sliderClickedOnLightingCell:(PLLightingCell *)cell andSlider:(UISlider *)slider;
- (void)updateValue:(UISlider *)sender;


@end

@interface PLLightingCell : UITableViewCell

@property (weak, nonatomic) id <PLLightingCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *btnSelected;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UISlider *slider;

@end
