//
//  PLMutipleGatewaysView.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-4-25.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLMutipleGatewaysView.h"
#import "PLGatewayCell.h"

@implementation PLMutipleGatewaysView

- (id)initWithFrame:(CGRect)frame
{
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"PLMutipleGatewaysView"
                                                     owner:self
                                                   options:nil];
    
    self = tempArr[0];
    self.frame = frame;
    if (IS_IPHONE5)
    {
        self.labelTitle.font = fontCustom(15);
    }
    else
    {
        self.labelTitle.font = fontCustom(15);
    }
    return self;
}

- (void)setMutArrGateway:(NSMutableArray *)mutArrGateway
{
    _mutArrGateway = mutArrGateway;
    [self.tableVIew reloadData];
}

-(void)reloaddata{
 [self.tableVIew reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mutArrGateway.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PLGatewayCell *cell;
    static NSString *identifier = @"PLGatewayCell";
    cell = (PLGatewayCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PLGatewayCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if (IS_IPHONE5)
    {
        cell.labelGateway.font = fontCustom(15);
    }
    else
    {
        cell.labelGateway.font = fontCustom(15);
    }
    if ([self.mutArrGateway[indexPath.row] isEqualToString:@"-----------------------------------"]) {
        cell.labelGateway.text = @"";
    }else{
      cell.labelGateway.text = self.mutArrGateway[indexPath.row];  
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults *mydefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr =[NSMutableArray arrayWithArray: [mydefault objectForKey:@"gatwangname"]];
    NSString *gatwayname = [NSString stringWithFormat:@"%@",arr[indexPath.row]];
    if ([gatwayname isEqualToString:@"-----------------------------------"]) {
        return 0;
    }else{
        return 44;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strGateway = self.mutArrGateway[indexPath.row];
    NSInteger index1 = indexPath.row;
    [self.delegate getGateWay:index1];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self.tableVIew reloadData];
}


@end
