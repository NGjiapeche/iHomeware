//
//  PLCustomLongPressCellAlter.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-6-23.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PLCustomLongPressCellAlterDelegate <NSObject>

- (void)btnOKPressedWithName:(NSString *)strChangeName;

@end

@interface PLCustomLongPressCellAlter : UIView

@property (assign, nonatomic) id<PLCustomLongPressCellAlterDelegate>delegate;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;


- (void)show;

@end
