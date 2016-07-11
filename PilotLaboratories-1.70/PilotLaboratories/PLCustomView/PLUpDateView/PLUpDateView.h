//
//  PLUpDateView.h
//  PilotLaboratories
//
//  Created by PilotLab on 15/7/3.
//  Copyright (c) 2015年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PLUpDateView;
@protocol PLUpDateViewDelegate <NSObject>

-(void)IFbntPressedwithselect:(BOOL)yesorno;
-(void)UpbntPressed;
-(void)CancelPressed;
@end


@interface PLUpDateView : UIView

@property(weak,nonatomic)id<PLUpDateViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *titel;
@property (weak, nonatomic) IBOutlet UILabel *NewVerNumb;
@property (weak, nonatomic) IBOutlet UILabel *OldVerNumb;
@property (weak, nonatomic) IBOutlet UIButton *IFbnt;
@property (weak, nonatomic) IBOutlet UIButton *Upbnt;
@property (weak, nonatomic) IBOutlet UIButton *Cancelbnt;
@property (weak, nonatomic) IBOutlet UILabel *newlabel;
@property (weak, nonatomic) IBOutlet UILabel *oldlabel;
@property (weak, nonatomic) IBOutlet UILabel *cancellabel;

-(void)setoldversion:(NSString*)oldnum newvwesion:(NSString*)newnum;
@end
