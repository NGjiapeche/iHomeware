//
//  PLMutipleGatewaysView.h
//  PilotLaboratories
//
//  Created by yuchangtao on 14-4-25.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PLMutipleGatewaysViewDelegate <NSObject>

- (void)getGateWay:(NSInteger )strGateway;

@end


@interface PLMutipleGatewaysView : UIView<UITableViewDataSource,UITableViewDelegate,PLMutipleGatewaysViewDelegate>

@property (unsafe_unretained, nonatomic) id<PLMutipleGatewaysViewDelegate>delegate;
@property (strong, nonatomic) NSMutableArray *mutArrGateway;
@property (strong, nonatomic) IBOutlet UITableView *tableVIew;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

-(void)reloaddata;
@end
