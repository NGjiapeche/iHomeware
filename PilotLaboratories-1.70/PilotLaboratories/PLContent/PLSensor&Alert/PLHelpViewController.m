//
//  PLHelpViewController.m
//  PilotLaboratories
//
//  Created by PilotLab on 15/7/29.
//  Copyright (c) 2015年 yct. All rights reserved.
//

#import "PLHelpViewController.h"

@interface PLHelpViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *backbut;
@property (weak, nonatomic) IBOutlet UILabel *titel;
@property (strong, nonatomic) IBOutlet UITableView *helptable;
@property(strong,nonatomic)NSArray *arr;
@property(assign   ,nonatomic)NSInteger didselect;
@property(assign,nonatomic)CGFloat didselectcellheight;

@end

@implementation PLHelpViewController
-(NSArray *)arr{
    if (_arr == nil) {
        NSArray *arLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        NSString *strLang = [arLanguages objectAtIndex:0];
        if ([strLang isEqualToString:@"en"]){
            NSString *path = [[NSBundle mainBundle] pathForResource:@"EnglishHelper" ofType:@"plist"];
            self.arr = [NSArray arrayWithContentsOfFile:path];
        }else{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Helper" ofType:@"plist"];
            self.arr = [NSArray arrayWithContentsOfFile:path];
        }
    }
    return _arr;
}
-(void)viewWillAppear:(BOOL)animated{
    [_helptable reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    _helptable.separatorColor = [UIColor redColor];
    _didselect = 1000;
    _didselectcellheight = 1000;
    [_titel setText:[NSString stringWithFormat:NSLocalizedString(@"Help", nil)]];
    if (IS_IPHONE5) {
     
    }else{
         _helptable.frame = CGRectMake(0, 55, 320, 350);
    }
}
//计算高度
 - (CGSize)sizeWithString:(NSString *)str font:(UIFont *)font
{
        NSDictionary *dict = @{NSFontAttributeName : font};
        // 如果将来计算的文字的范围超出了指定的范围,返回的就是指定的范围
        // 如果将来计算的文字的范围小于指定的范围, 返回的就是真实的范围
    CGSize maxsize = CGSizeMake(self.view.frame.size.width-30,1000);
        CGSize size =  [str boundingRectWithSize:maxsize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
        return size;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *arLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *strLang = [arLanguages objectAtIndex:0];
   
    if (indexPath.row == _didselect)
    {
        return  _didselectcellheight;
    }
   else if ([strLang isEqualToString:@"en"] && indexPath.row > 2){
        return 60;
        
    }else{
        return  40;
    }

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSArray *arr = cell.contentView.subviews;
    for (UIView *view in arr) {
        [view removeFromSuperview];
    }
    if ( cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
 
    }
    NSDictionary *dict = self.arr[indexPath.row];
    UILabel *labelQ = [[UILabel alloc]init];
    NSString *s1 = dict[@"Q"];
    NSArray *arLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *strLang = [arLanguages objectAtIndex:0];
    if ([strLang isEqualToString:@"en"] && indexPath.row > 2){
        labelQ.frame = CGRectMake(15,5, 290 , 50);
        
    }else{
       labelQ.frame = CGRectMake(15,5, 290 , 30);
    }
    
    [labelQ setText:s1];
    [labelQ setFont:[UIFont systemFontOfSize:14 ]];
    [cell.contentView addSubview:labelQ];
    labelQ.numberOfLines = 0;
    [labelQ setTextColor:[UIColor blackColor]];
    if (indexPath.row == _didselect) {
        [labelQ setTextColor:[UIColor colorWithRed:110/256.0 green:170/256.0 blue:212/256.0 alpha:1]];
          NSDictionary *dict = self.arr[indexPath.row];
        UILabel *labelA = [[UILabel alloc]init];
        NSString *s2 = dict[@"A"];
        s2 = [s2 stringByReplacingOccurrencesOfString:@"/n" withString:@"\n"];
        UIFont *font2 = [UIFont systemFontOfSize:12 ];
        CGSize size2 = [self sizeWithString:s2  font:font2];
         [labelA setFont:font2];
        [labelA setText:s2];
        labelA.numberOfLines = 0;
        if ([strLang isEqualToString:@"en"] && indexPath.row > 2){
           labelA.frame = CGRectMake(15,55, size2.width , size2.height);
             _didselectcellheight = 65+size2.height;
        }else{
          labelA.frame = CGRectMake(15,35, size2.width , size2.height);
             _didselectcellheight = 45+size2.height;
        }
        
        [cell.contentView addSubview:labelA];
       
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_didselect != indexPath.row) {
        _didselect = indexPath.row;
    
        [UIView animateWithDuration:0.25f animations:^{
            [_helptable reloadData];
    
    }];
    };
}
- (IBAction)popmyview:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
