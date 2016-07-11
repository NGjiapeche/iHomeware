//
//  FMMoveTableViewCell.m
//  TestMoveTableview
//
//  Created by yuchangtao on 14-5-12.
//  Copyright (c) 2014年 yuchangtao. All rights reserved.
//

#define kGreenColor [UIColor colorWithRed:144/255.0 green: 202/255.0 blue: 119/255.0 alpha: 1.0]

#import "FMMoveTableViewCell.h"

@implementation FMMoveTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FMMoveTableViewCell" owner:self options:nil];
    if (nib)
    {
        self = nib[0];
        if (IS_IPHONE5)
        {
           self.labelName.font = fontCustom(22.5);
        }
        else
        {
            self.labelName.font = fontCustom(18.5);
        }
        
//        [self.customSwithch setOnTintColor: kGreenColor];
//        [self.customSwithch setOn: YES
//                          animated: YES];
//        [self.customSwithch setDidChangeHandler:^(BOOL isOn) {
//            NSLog(@"Smallest switch changed to %d", isOn);
//        }];
        
//        UILongPressGestureRecognizer *longPressed = [[UILongPressGestureRecognizer alloc] init];
//        [longPressed addTarget:self action:@selector(cellLongPressed:)];
//        [longPressed setMinimumPressDuration:0.5f];
//        [self addGestureRecognizer:longPressed];
        return self;
    }
    
    return nil;
    
}

- (void)prepareForMove
{
//	[[self textLabel] setText:@""];
//	[[self detailTextLabel] setText:@""];
//	[[self imageView] setImage:nil];
    [self.labelName setText:@""];
    
}

- (IBAction)switchDevicePressed:(UISwitch *)sender {
    BOOL isbtnOn = [sender isOn];
    if ([self.delegate respondsToSelector:@selector(swichPressedOnCell:andSwichStatus:)])
    {
        [self.delegate swichPressedOnCell:self andSwichStatus:isbtnOn];
    }

}

//- (void)cellLongPressed:(FMMoveTableViewCell *)cell
//{
//    [self.delegate longPressCell:cell];
//}


@end
