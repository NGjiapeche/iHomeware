//
//  PLRootVC.m
//  PilotLaboratories
//
//  Created by frontier on 14-3-24.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLRootVC.h"

@interface PLRootVC ()
@property (strong, nonatomic) UIImageView *imageVHeaderBg;
@property (strong, nonatomic) UIButton *btnLeft;

@property (strong, nonatomic) UIButton *btnMiddle;
@property (strong, nonatomic) UILabel *labelTitle;
@property (strong, nonatomic) UIImageView *imageViewMainBg;

@end

@implementation PLRootVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *color = [UIColor colorWithRed:69/255.0f green:144/255.0f blue:255/255.0f alpha:1.0];
    
    CGRect frame = [UIScreen mainScreen].bounds;

    self.viewBackground = [[UIView alloc] initWithFrame:frame];
    self.viewBackground.backgroundColor = COLOR_RGB(224, 224, 224);
    [self.view addSubview:self.viewBackground];
    
    CGRect navFrame = CGRectMake(0, 0, 320, 64);
    UIImageView *imageViewNav = [[UIImageView alloc] initWithFrame:navFrame];
    imageViewNav.backgroundColor = COLOR_RGB(255, 255, 255);
    [self.viewBackground addSubview:imageViewNav];
    [self.view sendSubviewToBack:self.viewBackground];
    
    
//    UIImageView *imageViewLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 48, 48)];
//    imageViewLogo.image = [UIImage imageNamed:@"logo.png"];
//    [viewBackground addSubview:imageViewLogo];
//    [self.view sendSubviewToBack:viewBackground];
//    
//    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 256, 64)];
//    labelTitle.text = @"Pilot Laboratories";
//    labelTitle.textColor = COLOR_RGB(134, 134, 134);
//    labelTitle.font = fontCustom(12);
//    [viewBackground addSubview:labelTitle];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    UIImageView *imageViewLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
    imageViewLogo.backgroundColor = [UIColor colorWithRed:245/255 green:245/255 blue:245/255 alpha:0.1];
    _logo1 =[[UIImageView alloc] initWithFrame:CGRectMake(20, 2, 100, 40)];
    _logo1.image = [UIImage imageNamed:@"LOGO1.png"];
    [imageViewLogo addSubview:_logo1];
    [self.viewBackground addSubview:imageViewLogo];
    
    CGRect lineFrame = CGRectMake(0, 64, 320, 3);
    UIImageView *imageViewLine = [[UIImageView alloc] initWithFrame:lineFrame];
    imageViewLine.image = [UIImage imageNamed:@"topLine.png"];

    [self.viewBackground addSubview:imageViewLine];
    
    
    self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(98, 31, 125, 21)];
    self.labelTitle.textAlignment = NSTextAlignmentCenter;
    self.labelTitle.font = fontCustom(15);
    [self.view addSubview:self.labelTitle];
    
    self.btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnLeft.frame = CGRectMake(10, 29, 48, 26);
    self.btnLeft.titleLabel.textColor = [UIColor colorWithRed:70/255 green:155/255 blue:255/255 alpha:1.0];
    [self.btnLeft addTarget:self action:@selector(btnBackPressed) forControlEvents:UIControlEventTouchUpInside];
    self.btnLeft.titleLabel.font = fontCustom(15);
    [self.btnLeft setTitleColor:color forState:UIControlStateNormal];
    self.btnLeft.imageEdgeInsets = UIEdgeInsetsMake(1.5 , 5, 1.5, 17);
    [self.view addSubview:self.btnLeft];
    
    self.btnMiddle = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnMiddle.frame = CGRectMake(214, 29, 48, 26);
    [self.btnMiddle addTarget:self action:@selector(btnMiddlePressedWithBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.btnMiddle.titleLabel.font = fontCustom(15);
    [self.btnMiddle setTitleColor:color forState:UIControlStateNormal];
//    [self.btnMiddle setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 18)];
    self.btnMiddle.imageEdgeInsets = UIEdgeInsetsMake(1.5 , 10, 1.5, 12);
    [self.view addSubview:self.btnMiddle];
    
    self.btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnRight.frame = CGRectMake(268, 29, 48, 26);
    [self.btnRight addTarget:self action:@selector(btnRightPressed) forControlEvents:UIControlEventTouchUpInside];
    self.btnRight.titleLabel.font = fontCustom(15);
    [self.btnRight setTitleColor:color forState:UIControlStateNormal];
    self.btnRight.imageEdgeInsets = UIEdgeInsetsMake(1.5 , 5, 1.5, 17);
    [self.view addSubview:self.btnRight];

    self.isLeft = YES;
    self.isRight = YES;
    self.isMiddle = YES;
    
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideorshowlogo:) name:@"logostatue" object:nil];
}
-(void)hideorshowlogo:(NSNotification *)noti{
    int i = [noti.object intValue];
    if (i == 1) {
       
     
    }else{
     
    }
}
-(void)setIsLeft:(BOOL)isLeft
{
    if (isLeft)
    {
        self.btnLeft.hidden = YES;
    }
    else
    {
        self.btnLeft.hidden = NO;
    }
}

-(void)setIsRight:(BOOL)isRight
{
    if (isRight)
    {
        self.btnRight.hidden = YES;
    }
    else
    {
        self.btnRight.hidden = NO;
    }
    
}

- (void)setIsMiddle:(BOOL)isMiddle
{
    if (isMiddle)
    {
        self.btnMiddle.hidden = YES;
    }
    else
    {
        self.btnMiddle.hidden = NO;
    }
}

- (void)setStrRightTitle:(NSString *)strRightTitle
{
//    self.btnRight.frame = CGRectMake(278, 29, 44, 26);
    [self.btnRight setTitle:strRightTitle forState:UIControlStateNormal];
}

- (void)setStrLeftTitle:(NSString *)strLeftTitle
{
//    self.btnLeft.frame = CGRectMake(10, 29, 44, 26);

    [self.btnLeft setTitle:strLeftTitle forState:UIControlStateNormal];
}

- (void)setStrMiddleTitle:(NSString *)strMiddleTitle
{
//    self.btnMiddle.frame = CGRectMake(234, 29, 44, 26);
    [self.btnMiddle setTitle:strMiddleTitle forState:UIControlStateNormal];
}

- (void)setStrMiddleImage:(NSString *)strMiddleImage
{
    [self.btnMiddle setImage:[UIImage imageNamed:strMiddleImage] forState:UIControlStateNormal];
}

- (void)setStrLeftImage:(NSString *)strLeftImage
{
    [self.btnLeft setImage:[UIImage imageNamed:strLeftImage] forState:UIControlStateNormal];
}

- (void)setStrRightImage:(NSString *)strRightImage
{
    [self.btnRight setImage:[UIImage imageNamed:strRightImage] forState:UIControlStateNormal];
}

-(void)setStrTitle:(NSString *)strTitle
{
    self.labelTitle.text = strTitle;
}


- (void)btnRightPressed
{
    
}

- (void)btnBackPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnMiddlePressedWithBtn:(UIButton *)btn
{
    
}


@end
