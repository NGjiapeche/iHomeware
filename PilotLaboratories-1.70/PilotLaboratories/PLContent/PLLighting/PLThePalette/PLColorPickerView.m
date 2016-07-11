//
//  PLColorPickerView.m
//  PilotLaboratories
//
//  Created by frontier on 14-4-1.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLColorPickerView.h"
#import "UIColor-HSVAdditions.h"
#import "PLModel_Device.h"
#import "PLClickedBigButton.h"

#import "PLLightingCell.h"

#define distace 17.5

@interface PLColorPickerView()<UITableViewDataSource,UITableViewDelegate,PLLightingCellDelegate>

@property (strong, nonatomic) NSMutableArray *mutArrPosition;
@property (assign, nonatomic) int rememberSliderValue;
@property (assign, nonatomic) int iRememberPixel;

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) UILabel *colorLabel;

@end

@implementation PLColorPickerView

- (void)dealloc
{
    [self setMutArrPosition:nil];
    [self setMutArrAllBtns:nil];
    [self setMutArrSave:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    NSArray *tempArr = [[NSBundle mainBundle] loadNibNamed:@"PLColorPickerView"
                                                     owner:self
                                                   options:nil];
    self = tempArr[0];
    if (self)
    {
        self.frame = frame;
        self.tableLights.delegate = self;
        self.tableLights.dataSource = self;
        
        if (IS_IPHONE4)
        {
            self.tableLights.frame = CGRectMake(10, 229, 300, 130);
        }

        bigPicColorMatrixFrame = commonPicColorFrame;
        warmColorMatrixFrame = kWarmHueSatFrame;
        coolColorMatrixFrame = kCoolHueSatFrame;
        self.iRememberPixel = 0;
        _mutArrPosition = [[NSMutableArray alloc] initWithCapacity:0];
        _mutArrAllLights = [[NSMutableArray alloc] initWithCapacity:0];
        _mutArrAllBtns = [[NSMutableArray alloc] initWithCapacity:0];
        self.dimLight = 0;
        self.currentBrightness = kInitialBrightness;
        currentColor = [[UIColor alloc]init];
        
        _colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
        _colorLabel.backgroundColor = [UIColor clearColor];
        _colorLabel.font = [UIFont systemFontOfSize:12.0];
        _colorLabel.textColor = [UIColor blackColor];
        //[self addSubview:_colorLabel];
    }
    return self;
}

-(void)setArrLights:(NSArray *)arrLights
{
    [self.tableLights reloadData];
    @synchronized(self)
    {
        if (arrLights.count == 0)
        {
            DebugLog(@"111111111111");
            for(UIView *subView in self.subviews)
            {
                if ([subView isKindOfClass:[PLCustomButton class]])
                {
                    [subView removeFromSuperview];
                }
                else if ([subView isKindOfClass:[PLClickedBigButton class]])
                {
                    [subView removeFromSuperview];
                }
            }
            
            [self.mutArrAllBtns removeAllObjects];
            self.currentLightClicked = nil;
        }
        else
        {
            DebugLog(@"222222222222");
            for (int i = 0; i < arrLights.count; i++)
            {
                PLModel_Device *light = arrLights[i];
                BOOL isExsit = NO;
                for (int j = 0; j < _arrLights.count; j++)
                {
                    PLModel_Device *lightOld = _arrLights[j];
                    if ([light.macAddress isEqualToData:lightOld.macAddress])
                    {
                        isExsit = YES;
                        break;
                    }
                }
                
                if (!isExsit)
                {
                    int r = light.colorR;
                    int g = light.colorG;
                    int b = light.colorB;
                    char firstShortAddress = light.firstShortAddr;
                    char secondShortAddress = light.secondShortAddr;
                    NSString *strDeviceKey = [light deviceKey];
                    UIColor *lightColor = COLOR_RGB(r, g, b);
                    
                    PLCustomButton *btnLight = [PLCustomButton buttonWithType:UIButtonTypeCustom];
                    btnLight.frame = CGRectMake(0, 0, 35, 35);
                    if (!light.onOff)
                    {
                        btnLight.on = NO;
                        [btnLight setBackgroundImage:[UIImage imageNamed:@"lightOff"]
                                            forState:UIControlStateNormal];
                        [btnLight setBackgroundImage:[UIImage imageNamed:@"lightSelectOff"]
                                            forState:UIControlStateSelected];
                    }
                    else
                    {
                        btnLight.on = YES;
                        [btnLight setBackgroundImage:[UIImage imageNamed:@"lightOn"]
                                            forState:UIControlStateNormal];
                        [btnLight setBackgroundImage:[UIImage imageNamed:@"lightSelect"]
                                            forState:UIControlStateSelected];
                    }
                    NSString *strTitle = [NSString stringWithFormat:@"%d",light.index];
                    [btnLight setTitle:strTitle forState:UIControlStateNormal];
                    btnLight.titleLabel.font = fontCustom(12);
                    [btnLight setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                    btnLight.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                    btnLight.deviceKey = strDeviceKey;
                    btnLight.firstShortAddress = firstShortAddress;
                    btnLight.secondShortAddress = secondShortAddress;
                    btnLight.light = light;
                    [btnLight addTarget:self
                                 action:@selector(lightButtonClicked:)
                       forControlEvents:UIControlEventTouchUpInside];
                    
                    UIPanGestureRecognizer *gestureRecognizer
                    = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(handlePanGesture:)];
                    [btnLight addGestureRecognizer:gestureRecognizer];
                    if (self.imageVBigTap.hidden)
                    {
                        [self setColor:lightColor andLight:btnLight];
                    }
                    else
                    {
                        if (light.locationX < 10 && light.locationY < 10)
                        {
                            light.locationX = 10;
                            light.locationY = 35 + 190 - 17.5;
                        }
                        btnLight.center = CGPointMake(light.locationX, light.locationY);
                    }
                    [self addSubview:btnLight];
                    
                    
                    [self.mutArrAllBtns addObject:btnLight];
                    
                    //保存到数据库
                    [[PLDatabaseManager sharedManager] saveLightInfo:light andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                }
                else
                {
                    int r = light.colorR;
                    int g = light.colorG;
                    int b = light.colorB;
                    UIColor *lightColor = COLOR_RGB(r, g, b);
                    
                    for (PLCustomButton *btn in self.mutArrAllBtns)
                    {
                        if ([btn.light.macAddress isEqualToData:light.macAddress])
                        {
                            btn.light = light;
                            if ((int)btn.light.colorG == (int)light.colorG && (int)btn.light.colorR == (int)light.colorR && (int)btn.light.colorB == (int)light.colorB)
                            {
                                
                            }
                            else
                            {
                                [self setColor:lightColor andLight:btn];
                                //保存到数据库
                                [[PLDatabaseManager sharedManager] saveLightInfo:light andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                            }
                        }
                    }
                }
                
            }
            
            for (int j = 0; j < self.mutArrAllBtns.count; j++)
            {
                PLCustomButton *lightBtn = self.mutArrAllBtns[j];
                if ([lightBtn isKindOfClass:[PLClickedBigButton class]])
                {
                    //大灯
                    PLClickedBigButton *bigLight = (PLClickedBigButton *)lightBtn;
                    NSMutableArray *mutArrClickedLights = bigLight.mutArrClickedLights;
                    for (int k = 0; k < mutArrClickedLights.count; k++)
                    {
                        PLModel_Device *existLight = mutArrClickedLights[k];
                        BOOL stillExist = NO;
                        for (int l = 0; l < arrLights.count; l++)
                        {
                            PLModel_Device *light = arrLights[l];
                            if ([light.macAddress isEqualToData:existLight.macAddress])
                            {
                                stillExist = YES;
                                [mutArrClickedLights replaceObjectAtIndex:k withObject:light];
                                break;
                            }
                        }
                        if (!stillExist)
                        {
                            [mutArrClickedLights removeObject:existLight];
                            k--;
                        }
                    }
                    
                    if (mutArrClickedLights.count > 0)
                    {
                        bigLight.mutArrClickedLights = mutArrClickedLights;
                    }
                    else
                    {
                        [bigLight removeFromSuperview];
                        [self.mutArrAllBtns removeObject:bigLight];
                        j--;
                    }
                }
                else
                {
                    //小灯
                    BOOL stillExist = NO;
                    for (int l = 0; l < arrLights.count; l++)
                    {
                        PLModel_Device *light = arrLights[l];
                        if ([light.macAddress isEqualToData:lightBtn.light.macAddress])
                        {
                            stillExist = YES;
                            lightBtn.light = light;
                            break;
                        }
                    }
                    if (!stillExist)
                    {
                        [lightBtn removeFromSuperview];
                        [self.mutArrAllBtns removeObject:lightBtn];
                    }
                }
            }
        }
        
        NSArray *tempAllLightsArr = [NSArray arrayWithArray:arrLights];
        _arrLights = tempAllLightsArr;
    }
}

#pragma mark - 灯泡点击时候触发的事件 -

- (void)lightButtonClicked:(id)sender
{
    if (self.currentLightClicked)
    {
        self.currentLightClicked.selected = NO;
    }
    
    PLCustomButton *lightBtn = (PLCustomButton *)sender;
    self.currentLightClicked = lightBtn;
    self.currentLightClicked.selected = YES;
}

#pragma mark - 灯泡上加的手势 -

- (void)handlePanGesture:(UIPanGestureRecognizer *)recongnizer
{
    self.iRememberPixel ++;
    DebugLog(@"self.iRememberPixel===========  %d",self.iRememberPixel);
    PLCustomButton *lightBtn = (PLCustomButton *)recongnizer.view;
    if (!lightBtn.on)
    {
        return;
    }
    
    int buttonHeight = (int)self.currentLightClicked.frame.size.height;
    if (self.currentLightClicked == lightBtn)
    {
        //当前拖动的是大灯
        if ([lightBtn isKindOfClass:[PLClickedBigButton class]])
        {
            CGPoint point = [recongnizer locationInView:self];
            DebugLog(@"point *********************==== %f == %f",point.x, point.y);
            if (!self.imageVBigTap.hidden)
            {
                if (CGRectContainsPoint(bigPicColorMatrixFrame,point))
                {
                    CGPoint center = CGPointMake(point.x, point.y - buttonHeight / 2);
                    lightBtn.center = center;
                    NSMutableArray *mutArrRGB = [[NSMutableArray alloc] initWithCapacity:0];
                    UIColor *color = [self getPixelColorAtLocation:point];
                    mutArrRGB = [self changeUIColorToRGB:color];
                    
                    NSString *strRed = [NSString stringWithFormat:@"%@",mutArrRGB[0]];
                    NSString *strGreen = [NSString stringWithFormat:@"%@",mutArrRGB[1]];
                    NSString *strBlut = [NSString stringWithFormat:@"%@",mutArrRGB[2]];
                    
                    int colorR = (int)[strRed integerValue];
                    int colorG = (int)[strGreen integerValue];
                    int colorB = (int)[strBlut integerValue];
                    DebugLog(@"r == %d,g == %d,b == %d ",colorR,colorG,colorB);
                    _colorLabel.text = [NSString stringWithFormat:@"R:%d G:%d B:%d",colorR,colorG,colorB];
                    _colorLabel.backgroundColor = color;
                    
                    PLClickedBigButton *bigButton = (PLClickedBigButton *)lightBtn;
                    for (PLModel_Device *device in bigButton.mutArrClickedLights)
                    {
                        //记住灯的颜色值、位置
                        device.colorR = colorR;
                        device.colorG = colorG;
                        device.colorB = colorB;
                        device.locationX = center.x;
                        device.locationY = center.y;
                    }
                    
                    NSArray *lightsArr = bigButton.mutArrClickedLights;
                    if (recongnizer.state == UIGestureRecognizerStateEnded)
                    {
                        [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:lightsArr
                                                                                   colorR:colorR
                                                                                   colorG:colorG
                                                                                   colorB:colorB];
                        //保存到数据库
                        [[PLDatabaseManager sharedManager] saveLightsInfo:lightsArr
                                                            DeleteOldData:NO andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                    }
                    else
                    {
                        if (self.iRememberPixel%20)
                        {
                            return;
                        }
                        else
                        {
                            [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:lightsArr
                                                                                       colorR:colorR
                                                                                       colorG:colorG
                                                                                       colorB:colorB];
                            //保存到数据库
                            [[PLDatabaseManager sharedManager] saveLightsInfo:lightsArr
                                                                DeleteOldData:NO andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                        }
                    }
                }
            }
            else
            {
                if (CGRectContainsPoint(warmColorMatrixFrame,point))
                {
                    CGPoint center = CGPointMake(point.x, point.y - buttonHeight / 2);
                    lightBtn.center = center;
                    
                    NSMutableArray *mutArrRGB = [[NSMutableArray alloc] initWithCapacity:0];
                    UIColor *color = [self getPixelColorAtLocation:point];
                    mutArrRGB = [self changeUIColorToRGB:color];
                    
                    NSString *strRed = [NSString stringWithFormat:@"%@",mutArrRGB[0]];
                    NSString *strGreen = [NSString stringWithFormat:@"%@",mutArrRGB[1]];
                    NSString *strBlut = [NSString stringWithFormat:@"%@",mutArrRGB[2]];
                    
                    int colorR = (int)[strRed integerValue];
                    int colorG = (int)[strGreen integerValue];
                    int colorB = (int)[strBlut integerValue];
                    DebugLog(@"r == %d,g == %d,b == %d ",colorR,colorG,colorB);
                    _colorLabel.text = [NSString stringWithFormat:@"R:%d G:%d B:%d",colorR,colorG,colorB];
                    _colorLabel.backgroundColor = color;
                    
                    PLClickedBigButton *bigButton = (PLClickedBigButton *)lightBtn;
                    for (PLModel_Device *device in bigButton.mutArrClickedLights)
                    {
                        //记住调过灯的颜色值、位置
                        device.colorR = colorR;
                        device.colorG = colorG;
                        device.colorB = colorB;
                        device.locationX = center.x;
                        device.locationY = center.y;
                    }
                    
                    NSArray *lightsArr = bigButton.mutArrClickedLights;
                    if (recongnizer.state == UIGestureRecognizerStateEnded)
                    {
                        [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:lightsArr
                                                                                   colorR:colorR
                                                                                   colorG:colorG
                                                                                   colorB:colorB];
                        //保存到数据库
                        [[PLDatabaseManager sharedManager] saveLightsInfo:lightsArr
                                                            DeleteOldData:NO andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                    }
                    else
                    {
                        if (self.iRememberPixel%20)
                        {
                            return;
                        }
                        else
                        {
                            [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:lightsArr
                                                                                       colorR:colorR
                                                                                       colorG:colorG
                                                                                       colorB:colorB];
                            //保存到数据库
                            [[PLDatabaseManager sharedManager] saveLightsInfo:lightsArr
                                                                DeleteOldData:NO andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                        }
                        
                    }
                }
                else if (CGRectContainsPoint(coolColorMatrixFrame, point))
                {
                    CGPoint center = CGPointMake(point.x, point.y - buttonHeight / 2);
                    lightBtn.center = center;
                    
                    NSMutableArray *mutArrRGB = [[NSMutableArray alloc] initWithCapacity:0];
                    UIColor *color = [self getPixelColorAtLocation:point];
                    mutArrRGB = [self changeUIColorToRGB:color];
                    
                    NSString *strRed = [NSString stringWithFormat:@"%@",mutArrRGB[0]];
                    NSString *strGreen = [NSString stringWithFormat:@"%@",mutArrRGB[1]];
                    NSString *strBlut = [NSString stringWithFormat:@"%@",mutArrRGB[2]];
                    
                    int colorR = (int)[strRed integerValue];
                    int colorG = (int)[strGreen integerValue];
                    int colorB = (int)[strBlut integerValue];
                    DebugLog(@"r == %d,g == %d,b == %d ",colorR,colorG,colorB);
                    _colorLabel.text = [NSString stringWithFormat:@"R:%d G:%d B:%d",colorR,colorG,colorB];
                    _colorLabel.backgroundColor = color;
                    
                    PLClickedBigButton *bigButton = (PLClickedBigButton *)lightBtn;
                    for (PLModel_Device *device in bigButton.mutArrClickedLights)
                    {
                        //记住调过灯的颜色值
                        device.colorR = colorR;
                        device.colorG = colorG;
                        device.colorB = colorB;
                        device.locationX = center.x;
                        device.locationY = center.y;
                    }

                    NSArray *lightsArr = bigButton.mutArrClickedLights;
                    if (recongnizer.state == UIGestureRecognizerStateEnded)
                    {
                        [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:lightsArr
                                                                                   colorR:colorR
                                                                                   colorG:colorG
                                                                                   colorB:colorB];
                        //保存到数据库
                        [[PLDatabaseManager sharedManager] saveLightsInfo:lightsArr
                                                            DeleteOldData:NO andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                    }
                    else
                    {
                        if (self.iRememberPixel%20)
                        {
                            return;
                        }
                        else
                        {
                            [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:lightsArr
                                                                                       colorR:colorR
                                                                                       colorG:colorG
                                                                                       colorB:colorB];
                            //保存到数据库
                            [[PLDatabaseManager sharedManager] saveLightsInfo:lightsArr
                                                                DeleteOldData:NO andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                        }
                    }
                }
            }
        }
        else
        {
            //当前拖动的是小灯
            for (PLCustomButton *btnLights in self.mutArrAllBtns)
            {
                //两个灯相碰，需合并
                if (lightBtn != btnLights && CGRectContainsPoint(btnLights.frame, lightBtn.center))
                {
                    //小灯碰到大灯
                    if ([btnLights isKindOfClass:[PLClickedBigButton class]])
                    {
                        CGPoint point = [recongnizer locationInView:self];
                        CGPoint center = CGPointMake(point.x, point.y - buttonHeight / 2);
                        
                        NSMutableArray *mutArrRGB = [[NSMutableArray alloc] initWithCapacity:0];
                        UIColor *color = [self getPixelColorAtLocation:point];
                        mutArrRGB = [self changeUIColorToRGB:color];
                        
                        NSString *strRed = [NSString stringWithFormat:@"%@",mutArrRGB[0]];
                        NSString *strGreen = [NSString stringWithFormat:@"%@",mutArrRGB[1]];
                        NSString *strBlut = [NSString stringWithFormat:@"%@",mutArrRGB[2]];
                        
                        int colorR = (int)[strRed integerValue];
                        int colorG = (int)[strGreen integerValue];
                        int colorB = (int)[strBlut integerValue];
                        _colorLabel.text = [NSString stringWithFormat:@"R:%d G:%d B:%d",colorR,colorG,colorB];
                        _colorLabel.backgroundColor = color;
                        
                        lightBtn.light.colorR = colorR;
                        lightBtn.light.colorG = colorG;
                        lightBtn.light.colorB = colorB;
                        lightBtn.light.locationX = center.x;
                        lightBtn.light.locationY = center.y;
                        [[PLNetworkManager sharedManager] changeLightsColorWithLight:lightBtn.light
                                                                              colorR:colorR
                                                                              colorG:colorG
                                                                              colorB:colorB];
                        //保存到数据库
                        [[PLDatabaseManager sharedManager] saveLightInfo:lightBtn.light andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                        
                        //拖动小灯碰到大灯，小灯加入到大灯中
                        PLClickedBigButton *bigLight = (PLClickedBigButton *)btnLights;
                        NSMutableArray *mutArrClickedLights = bigLight.mutArrClickedLights;
                        [mutArrClickedLights addObject:lightBtn.light];
                        bigLight.mutArrClickedLights = mutArrClickedLights;
                        bigLight.selected = YES;
                        bigLight.on = YES;
                        //取消当前选中灯的高亮
                        self.currentLightClicked.selected = NO;
                        //设置新的高亮灯泡
                        self.currentLightClicked = bigLight;
                        [lightBtn removeFromSuperview];
                        [self.mutArrAllBtns removeObject:lightBtn];
                        return;
                    }
                    else//小灯碰到小灯
                    {
                        //拖动小灯碰到小灯，加入新的大灯
                        PLClickedBigButton *bigLight = [PLClickedBigButton buttonWithType:UIButtonTypeCustom];
                        bigLight.on = YES;
                        [bigLight setBackgroundImage:[UIImage imageNamed:@"lightOn"]
                                            forState:UIControlStateNormal];
                        [bigLight setBackgroundImage:[UIImage imageNamed:@"lightSelect"]
                                            forState:UIControlStateSelected];
                        bigLight.frame = CGRectMake(0, 0, 50, 50);
                        NSMutableArray *lightsArr = [NSMutableArray new];
                        [lightsArr addObject:lightBtn.light];
                        [lightsArr addObject:btnLights.light];
                        bigLight.mutArrClickedLights = lightsArr;
                        [bigLight addTarget:self
                                     action:@selector(lightButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
                        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                                            action:@selector(handlePanGesture:)];
                        [bigLight addGestureRecognizer:gestureRecognizer];
                        
                        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                                       action:@selector(handleLongPressGesture:)];
                        longPressGesture.minimumPressDuration = 0.5;
                        [bigLight addGestureRecognizer:longPressGesture];
                        [self addSubview:bigLight];
                        
                        lightBtn.center = btnLights.center;
                        bigLight.center = btnLights.center;
                        bigLight.selected = YES;
                        bigLight.on = YES;
                        //取消当前选中灯的高亮
                        self.currentLightClicked.selected = NO;
                        //设置新的高亮灯泡
                        self.currentLightClicked = bigLight;
                        [lightBtn removeFromSuperview];
                        [btnLights removeFromSuperview];
                        [self.mutArrAllBtns removeObject:lightBtn];
                        [self.mutArrAllBtns removeObject:btnLights];
                        [self.mutArrAllBtns addObject:bigLight];
                        return;
                    }
                }
            }
            
            //正常拖动
            CGPoint point = [recongnizer locationInView:self];
            DebugLog(@"point *********************==== %f == %f",point.x, point.y);
            if (!self.imageVBigTap.hidden)
            {
                if(CGRectContainsPoint(bigPicColorMatrixFrame, point))
                {
                    CGPoint center = CGPointMake(point.x, point.y - buttonHeight / 2);
                    lightBtn.center = center;
                    
                    NSMutableArray *mutArrRGB = [[NSMutableArray alloc] initWithCapacity:0];
                    UIColor *color = [self getPixelColorAtLocation:point];
                    mutArrRGB = [self changeUIColorToRGB:color];
                    
                    NSString *strRed = [NSString stringWithFormat:@"%@",mutArrRGB[0]];
                    NSString *strGreen = [NSString stringWithFormat:@"%@",mutArrRGB[1]];
                    NSString *strBlut = [NSString stringWithFormat:@"%@",mutArrRGB[2]];
                    int colorR = (int)[strRed integerValue];
                    int colorG = (int)[strGreen integerValue];
                    int colorB = (int)[strBlut integerValue];
                    DebugLog(@"r == %d,g == %d,b == %d ",colorR,colorG,colorB);
                    _colorLabel.text = [NSString stringWithFormat:@"R:%d G:%d B:%d",colorR,colorG,colorB];
                    _colorLabel.backgroundColor = color;
                    
                    //记住灯的颜色、位置
                    lightBtn.light.colorR = colorR;
                    lightBtn.light.colorG = colorG;
                    lightBtn.light.colorB = colorB;
                    lightBtn.light.locationX = center.x;
                    lightBtn.light.locationY = center.y;
                    
                    if (recongnizer.state == UIGestureRecognizerStateEnded)
                    {
                        [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:@[lightBtn.light]
                                                                                   colorR:colorR
                                                                                   colorG:colorG
                                                                                   colorB:colorB];
                        //保存到数据库
                        [[PLDatabaseManager sharedManager] saveLightInfo:lightBtn.light andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                    }
                    else
                    {
                        if (self.iRememberPixel%20)
                        {
                            return;
                        }
                        else
                        {
                            [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:@[lightBtn.light]
                                                                                       colorR:colorR
                                                                                       colorG:colorG
                                                                                       colorB:colorB];
                            //保存到数据库
                            [[PLDatabaseManager sharedManager] saveLightInfo:lightBtn.light andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                        }
                    }
                }
            }
            else
            {
                if (CGRectContainsPoint(warmColorMatrixFrame,point))
                {
                    CGPoint center = CGPointMake(point.x, point.y - buttonHeight / 2);
                    lightBtn.center = center;
                    
                    NSMutableArray *mutArrRGB = [[NSMutableArray alloc] initWithCapacity:0];
                    UIColor *color = [self getPixelColorAtLocation:point];
                    mutArrRGB = [self changeUIColorToRGB:color];
                    
                    NSString *strRed = [NSString stringWithFormat:@"%@",mutArrRGB[0]];
                    NSString *strGreen = [NSString stringWithFormat:@"%@",mutArrRGB[1]];
                    NSString *strBlut = [NSString stringWithFormat:@"%@",mutArrRGB[2]];
                    
                    int colorR = (int)[strRed integerValue];
                    int colorG = (int)[strGreen integerValue];
                    int colorB = (int)[strBlut integerValue];
                    DebugLog(@"r == %d,g == %d,b == %d ",colorR,colorG,colorB);
                    _colorLabel.text = [NSString stringWithFormat:@"R:%d G:%d B:%d",colorR,colorG,colorB];
                    _colorLabel.backgroundColor = color;
                    
                    //记住灯的颜色、位置
                    lightBtn.light.colorR = colorR;
                    lightBtn.light.colorG = colorG;
                    lightBtn.light.colorB = colorB;
                    lightBtn.light.locationX = center.x;
                    lightBtn.light.locationY = center.y;
                    
                    if (recongnizer.state == UIGestureRecognizerStateEnded)
                    {
                        [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:@[lightBtn.light]
                                                                                   colorR:colorR
                                                                                   colorG:colorG
                                                                                   colorB:colorB];
                        //保存到数据库
                        [[PLDatabaseManager sharedManager] saveLightInfo:lightBtn.light andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                    }
                    else
                    {
                        if (self.iRememberPixel%20)
                        {
                            return;
                        }
                        else
                        {
                            [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:@[lightBtn.light]
                                                                                       colorR:colorR
                                                                                       colorG:colorG
                                                                                       colorB:colorB];
                            //保存到数据库
                            [[PLDatabaseManager sharedManager] saveLightInfo:lightBtn.light andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                        }
                    }
                }
                else if (CGRectContainsPoint(coolColorMatrixFrame, point))
                {
                    CGPoint center = CGPointMake(point.x, point.y - buttonHeight / 2);
                    lightBtn.center = center;
                    
                    NSMutableArray *mutArrRGB = [[NSMutableArray alloc] initWithCapacity:0];
                    UIColor *color = [self getPixelColorAtLocation:point];
                    mutArrRGB = [self changeUIColorToRGB:color];
                    
                    NSString *strRed = [NSString stringWithFormat:@"%@",mutArrRGB[0]];
                    NSString *strGreen = [NSString stringWithFormat:@"%@",mutArrRGB[1]];
                    NSString *strBlut = [NSString stringWithFormat:@"%@",mutArrRGB[2]];
                    
                    int colorR = (int)[strRed integerValue];
                    int colorG = (int)[strGreen integerValue];
                    int colorB = (int)[strBlut integerValue];
                    DebugLog(@"r == %d,g == %d,b == %d ",colorR,colorG,colorB);
                    _colorLabel.text = [NSString stringWithFormat:@"R:%d G:%d B:%d",colorR,colorG,colorB];
                    _colorLabel.backgroundColor = color;
                    
                    //记住灯的颜色、位置
                    lightBtn.light.colorR = colorR;
                    lightBtn.light.colorG = colorG;
                    lightBtn.light.colorB = colorB;
                    lightBtn.light.locationX = center.x;
                    lightBtn.light.locationY = center.y;
                    
                    if (recongnizer.state == UIGestureRecognizerStateEnded)
                    {
                        [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:@[lightBtn.light]
                                                                                   colorR:colorR
                                                                                   colorG:colorG
                                                                                   colorB:colorB];
                        //保存到数据库
                        [[PLDatabaseManager sharedManager] saveLightInfo:lightBtn.light andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                    }
                    else
                    {
                        if (self.iRememberPixel%20)
                        {
                            return;
                        }
                        else
                        {
                            [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:@[lightBtn.light]
                                                                                       colorR:colorR
                                                                                       colorG:colorG
                                                                                       colorB:colorB];
                            //保存到数据库
                            [[PLDatabaseManager sharedManager] saveLightInfo:lightBtn.light andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
                        }
                    }
                }
            }
        }
    }
    else
    {
        return;
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recongnizer
{
    PLClickedBigButton *bigLight = (PLClickedBigButton *)recongnizer.view;
    [bigLight removeGestureRecognizer:recongnizer];
    for (int i = 0; i < bigLight.mutArrClickedLights.count; i++)
    {
        PLModel_Device *light = bigLight.mutArrClickedLights[i];
        char firstShortAddress = light.firstShortAddr;
        char secondShortAddress = light.secondShortAddr;
        NSString *strDeviceKey = [light deviceKey];
        PLCustomButton *btnLight = [PLCustomButton buttonWithType:UIButtonTypeCustom];
        btnLight.frame = CGRectMake(0, 0, 35, 35);
        
        btnLight.firstShortAddress = firstShortAddress;
        btnLight.secondShortAddress = secondShortAddress;
        btnLight.deviceKey = strDeviceKey;
        btnLight.light = light;
        btnLight.on = bigLight.on;
        btnLight.center = bigLight.center;
        NSString *strTitle = [NSString stringWithFormat:@"%d",light.index];
        
        [btnLight setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnLight.titleLabel.font = fontCustom(12);
        [btnLight setTitle:strTitle forState:UIControlStateNormal];
        [btnLight setTitle:strTitle forState:UIControlStateSelected];
        
        if (!bigLight.on)
        {
            [btnLight setBackgroundImage:[UIImage imageNamed:@"lightOff"]
                                forState:UIControlStateNormal];
            [btnLight setBackgroundImage:[UIImage imageNamed:@"lightSelectOff"] forState:UIControlStateSelected];
        }
        else
        {
            [btnLight setBackgroundImage:[UIImage imageNamed:@"lightOn"]
                                forState:UIControlStateNormal];
            [btnLight setBackgroundImage:[UIImage imageNamed:@"lightSelect"]
                                forState:UIControlStateSelected];
        }
        
        [btnLight addTarget:self
                     action:@selector(lightButtonClicked:)
           forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *gestureRecognizer
        = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handlePanGesture:)];
        [btnLight addGestureRecognizer:gestureRecognizer];
        [self addSubview:btnLight];
        [self.mutArrAllBtns addObject:btnLight];
    }
    
    if (self.currentLightClicked == bigLight)
    {
        self.currentLightClicked.selected = NO;
        self.currentLightClicked = nil;
    }
    [bigLight removeFromSuperview];
    [self.mutArrAllBtns removeObject:bigLight];
}

#pragma mark - 根据灯泡的颜色定位灯泡的位置 -

- (void)setColor:(UIColor *)color andLight:(UIButton *)light
{
    CGFloat hue = color.hue;
    CGFloat saturation = color.saturation;
    CGPoint hueSatPosition;
    hueSatPosition.x = (hue * kMatrixWidth) + kWarmXAxisOffset;
    hueSatPosition.y = (1.0 - saturation) * kMatrixHeight + kWarmYAxisOffset - 17.5;
    light.center = hueSatPosition;
}

#pragma mark - 获取拖动位置的color -

- (UIColor *)updateHueSatWithMovement:(CGPoint)position
{
    self.currentHue = (position.x-kWarmXAxisOffset)/kMatrixWidth;
    self.currentSaturation = 1.0 -  (position.y-kWarmYAxisOffset)/kMatrixHeight;
    DebugLog(@"******self.hue******** === %f",self.currentHue);
    currentColor  = [UIColor colorWithHue:self.currentHue
                               saturation:self.currentSaturation
                               brightness:self.currentBrightness
                                    alpha:1.0];
    return currentColor;
}

#pragma mark - 调节亮度后获取的亮度color -

- (void)updateValue:(UISlider *)sender
{
    if (self.currentLightClicked.selected)
    {
        if (self.rememberSliderValue != (int)sender.value)
        {
            self.rememberSliderValue = (int)sender.value;
            NSArray *lightsArr;
            if ([self.currentLightClicked isKindOfClass:[PLClickedBigButton class]])
            {
                PLClickedBigButton *currentLightClicked = (PLClickedBigButton *)self.currentLightClicked;
                lightsArr = [NSArray arrayWithArray:currentLightClicked.mutArrClickedLights];
            }
            else
            {
                lightsArr = @[self.currentLightClicked.light];
            }
            self.currentLightClicked.light.Dim = (int)sender.value;
            
            if ((int)sender.value == 0)
            {
                [self.currentLightClicked setBackgroundImage:[UIImage imageNamed:@"lightOff.png"] forState:UIControlStateNormal];
                [self.currentLightClicked setBackgroundImage:[UIImage imageNamed:@"lightSelectOff"] forState:UIControlStateSelected];
            }
            else
            {
                [self.currentLightClicked setBackgroundImage:[UIImage imageNamed:@"lightOn.png"] forState:UIControlStateNormal];
                [self.currentLightClicked setBackgroundImage:[UIImage imageNamed:@"lightSelect.png"] forState:UIControlStateSelected];
            }
            
            [[PLNetworkManager sharedManager] changeLightsDimWithLightsList:lightsArr
                                                                      level:(int)sender.value];
            //保存Dim到数据库
            for (PLModel_Device *light in lightsArr)
            {
                light.Dim = (int)sender.value;
                [[PLDatabaseManager sharedManager] saveLightInfo:light andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
            }
        }
        DebugLog(@"slider.value == %.1f",sender.value);
    }
    else
    {
        
    }
}

#pragma mark - touch 事件  -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint theEndPoint = [touch locationInView:self];
        [self calculateWithEndPoint:theEndPoint];
        //return;
    }
}

- (void)calculateWithEndPoint:(CGPoint)theEndPoint
{
    [self dispatchTouchEvent:theEndPoint];
}


-(void)dispatchTouchEvent:(CGPoint)point
{
    if (!self.currentLightClicked.selected)
    {
        if (CGRectContainsPoint(coolColorMatrixFrame, point) || CGRectContainsPoint(warmColorMatrixFrame, point))
        {
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                            message:NSLocalizedString(@"Please select a light and choose a color！", nil)
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alter show];
        }
        else
        {
            
        }
        
    }
    else
    {
        if (!self.currentLightClicked.on)
        {
            return;
        }
        
        DebugLog(@"point *********************==== %f == %f",point.x, point.y);
        int buttonHeight = (int)self.currentLightClicked.frame.size.height;
        if (!self.imageVBigTap.hidden)
        {
            if (CGRectContainsPoint(bigPicColorMatrixFrame,point))
            {
                [self animateView:self.currentLightClicked toPosition:point];
                CGPoint center = CGPointMake(point.x, point.y - buttonHeight / 2);
                
                NSMutableArray *mutArrRGB = [[NSMutableArray alloc] initWithCapacity:0];
                UIColor *color = [self getPixelColorAtLocation:point];
                mutArrRGB = [self changeUIColorToRGB:color];
                
                NSString *strRed = [NSString stringWithFormat:@"%@",mutArrRGB[0]];
                NSString *strGreen = [NSString stringWithFormat:@"%@",mutArrRGB[1]];
                NSString *strBlut = [NSString stringWithFormat:@"%@",mutArrRGB[2]];
                
                int colorR = (int)[strRed integerValue];
                int colorG = (int)[strGreen integerValue];
                int colorB = (int)[strBlut integerValue];
                DebugLog(@"r == %d,g == %d,b == %d ",colorR,colorG,colorB);
                _colorLabel.text = [NSString stringWithFormat:@"R:%d G:%d B:%d",colorR,colorG,colorB];
                _colorLabel.backgroundColor = color;
                
                //记住调过灯的颜色值
                self.currentLightClicked.light.colorR = colorR;
                self.currentLightClicked.light.colorG = colorG;
                self.currentLightClicked.light.colorB = colorB;
                self.currentLightClicked.light.locationX = center.x;
                self.currentLightClicked.light.locationY = center.y;
                NSArray *lightsArr;
                if ([self.currentLightClicked isKindOfClass:[PLClickedBigButton class]])
                {
                    PLClickedBigButton *bigButton = (PLClickedBigButton *)self.currentLightClicked;
                    for (PLModel_Device *light in bigButton.mutArrClickedLights)
                    {
                        light.colorR = colorR;
                        light.colorG = colorG;
                        light.colorB = colorB;
                        light.locationX = center.x;
                        light.locationY = center.y;
                    }
                    lightsArr = bigButton.mutArrClickedLights;
                }
                else
                {
                    lightsArr = @[self.currentLightClicked.light];
                }
                [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:lightsArr
                                                                           colorR:colorR
                                                                           colorG:colorG
                                                                           colorB:colorB];
                //保存到数据库
                [[PLDatabaseManager sharedManager] saveLightsInfo:lightsArr
                                                    DeleteOldData:NO andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
            }
        }
        else
        {
            if (CGRectContainsPoint(warmColorMatrixFrame,point))
            {
                [self animateView:self.currentLightClicked toPosition:point];
                CGPoint center = CGPointMake(point.x, point.y - buttonHeight / 2);
                
                NSMutableArray *mutArrRGB = [[NSMutableArray alloc] initWithCapacity:0];
                UIColor *color = [self getPixelColorAtLocation:point];
                mutArrRGB = [self changeUIColorToRGB:color];
                
                NSString *strRed = [NSString stringWithFormat:@"%@",mutArrRGB[0]];
                NSString *strGreen = [NSString stringWithFormat:@"%@",mutArrRGB[1]];
                NSString *strBlut = [NSString stringWithFormat:@"%@",mutArrRGB[2]];
                
                int colorR = (int)[strRed integerValue];
                int colorG = (int)[strGreen integerValue];
                int colorB = (int)[strBlut integerValue];
                DebugLog(@"r == %d,g == %d,b == %d ",colorR,colorG,colorB);
                _colorLabel.text = [NSString stringWithFormat:@"R:%d G:%d B:%d",colorR,colorG,colorB];
                _colorLabel.backgroundColor = color;
                
                //记住调过灯的颜色值
                self.currentLightClicked.light.colorR = colorR;
                self.currentLightClicked.light.colorG = colorG;
                self.currentLightClicked.light.colorB = colorB;
                self.currentLightClicked.light.locationX = center.x;
                self.currentLightClicked.light.locationY = center.y;
                NSArray *lightsArr;
                if ([self.currentLightClicked isKindOfClass:[PLClickedBigButton class]])
                {
                    PLClickedBigButton *bigButton = (PLClickedBigButton *)self.currentLightClicked;
                    for (PLModel_Device *light in bigButton.mutArrClickedLights)
                    {
                        light.colorR = colorR;
                        light.colorG = colorG;
                        light.colorB = colorB;
                        light.locationX = center.x;
                        light.locationY = center.y;
                    }
                    lightsArr = bigButton.mutArrClickedLights;
                }
                else
                {
                    lightsArr = @[self.currentLightClicked.light];
                }
                [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:lightsArr
                                                                           colorR:colorR
                                                                           colorG:colorG
                                                                           colorB:colorB];
                //保存到数据库
                [[PLDatabaseManager sharedManager] saveLightsInfo:lightsArr
                                                    DeleteOldData:NO andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
            }
            else if (CGRectContainsPoint(coolColorMatrixFrame, point))
            {
                [self animateView:self.currentLightClicked toPosition: point];
                CGPoint center = CGPointMake(point.x, point.y - buttonHeight / 2);
                
                NSMutableArray *mutArrRGB = [[NSMutableArray alloc] initWithCapacity:0];
                UIColor *color = [self getPixelColorAtLocation:point];
                mutArrRGB = [self changeUIColorToRGB:color];
                
                NSString *strRed = [NSString stringWithFormat:@"%@",mutArrRGB[0]];
                NSString *strGreen = [NSString stringWithFormat:@"%@",mutArrRGB[1]];
                NSString *strBlut = [NSString stringWithFormat:@"%@",mutArrRGB[2]];
                
                int colorR = (int)[strRed integerValue];
                int colorG = (int)[strGreen integerValue];
                int colorB = (int)[strBlut integerValue];
                DebugLog(@"r == %d,g == %d,b == %d ",colorR,colorG,colorB);
                _colorLabel.text = [NSString stringWithFormat:@"R:%d G:%d B:%d",colorR,colorG,colorB];
                _colorLabel.backgroundColor = color;
                
                //记住调过灯的颜色值
                self.currentLightClicked.light.colorR = colorR;
                self.currentLightClicked.light.colorG = colorG;
                self.currentLightClicked.light.colorB = colorB;
                self.currentLightClicked.light.locationX = center.x;
                self.currentLightClicked.light.locationY = center.y;
                NSArray *lightsArr;
                if ([self.currentLightClicked isKindOfClass:[PLClickedBigButton class]])
                {
                    PLClickedBigButton *bigButton = (PLClickedBigButton *)self.currentLightClicked;
                    for (PLModel_Device *light in bigButton.mutArrClickedLights)
                    {
                        light.colorR = colorR;
                        light.colorG = colorG;
                        light.colorB = colorB;
                        light.locationX = center.x;
                        light.locationY = center.y;
                    }
                    lightsArr = bigButton.mutArrClickedLights;
                }
                else
                {
                    lightsArr = @[self.currentLightClicked.light];
                }
                [[PLNetworkManager sharedManager] changeLightsColorWithLightsList:lightsArr
                                                                           colorR:colorR
                                                                           colorG:colorG
                                                                           colorB:colorB];
                //保存到数据库
                [[PLDatabaseManager sharedManager] saveLightsInfo:lightsArr
                                                    DeleteOldData:NO andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
            }
 
        }
        
    }
}

- (void)animateView:(UIView *)theView
         toPosition:(CGPoint) thePosition
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kAnimationDuration];
    theView.center = CGPointMake(thePosition.x, thePosition.y - self.currentLightClicked.frame.size.height/2);
    theView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

#pragma mark - 控制灯的开关  -

//单个
- (IBAction)handleSingleSwitch:(UISwitch *)sender
{
    if (!sender.on)
    {
        self.currentLightClicked.selected = NO;
        self.currentLightClicked.on = NO;
        [self.currentLightClicked setBackgroundImage:[UIImage imageNamed:@"lightOff.png"] forState:UIControlStateNormal];
        [self.currentLightClicked setBackgroundImage:[UIImage imageNamed:@"lightSelectOff.png"] forState:UIControlStateSelected];
        //灯组
        if ([self.currentLightClicked isKindOfClass:[PLClickedBigButton class]])
        {
            PLClickedBigButton *bigButton = (PLClickedBigButton *)self.currentLightClicked;
            [[PLNetworkManager sharedManager] lightSwitchWithLightsList:bigButton.mutArrClickedLights switchOn:NO];
        }
        else//单个灯
        {
            [[PLNetworkManager sharedManager] lightSwitchWithLight:self.currentLightClicked.light switchOn:NO];
        }
    }
    else
    {
        self.currentLightClicked.selected = YES;
        self.currentLightClicked.on = YES;
        [self.currentLightClicked setBackgroundImage:[UIImage imageNamed:@"lightOn.png"] forState:UIControlStateNormal];
        [self.currentLightClicked setBackgroundImage:[UIImage imageNamed:@"lightSelect.png"] forState:UIControlStateSelected];
        //灯组
        if ([self.currentLightClicked isKindOfClass:[PLClickedBigButton class]])
        {
            PLClickedBigButton *bigButton = (PLClickedBigButton *)self.currentLightClicked;
            [[PLNetworkManager sharedManager] lightSwitchWithLightsList:bigButton.mutArrClickedLights switchOn:YES];
        }
        else//单个灯
        {
            [[PLNetworkManager sharedManager] lightSwitchWithLight:self.currentLightClicked.light switchOn:YES];
        }
    }
}

//所有
- (IBAction)handleMasterSwitch:(UISwitch *)sender
{
    if (!sender.on)
    {
        self.currentLightClicked.selected = NO;
        [[PLNetworkManager sharedManager] deviceSwitchWithDeviceType:LightType switchOn:NO];
        for (PLCustomButton *btn in self.mutArrAllBtns)
        {
            btn.on = NO;
            [btn setBackgroundImage:[UIImage imageNamed:@"lightOff.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"lightSelectOff.png"] forState:UIControlStateSelected];
        }
    }
    else
    {
        self.currentLightClicked.selected = YES;
        [[PLNetworkManager sharedManager] deviceSwitchWithDeviceType:LightType switchOn:YES];
        for (PLCustomButton *btn in self.mutArrAllBtns)
        {
            btn.on = YES;
            [btn setBackgroundImage:[UIImage imageNamed:@"lightOn.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"lightSelect.png"] forState:UIControlStateSelected];
        }
    }
}

- (IBAction)btnControlONorOFFClicked:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"All Off"])
    {
        self.currentLightClicked.selected = NO;
        [[PLNetworkManager sharedManager] deviceSwitchWithDeviceType:LightType switchOn:NO];
        for (PLCustomButton *btn in self.mutArrAllBtns)
        {
            [btn setBackgroundImage:[UIImage imageNamed:@"lightOff.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"lightSelectOff.png"] forState:UIControlStateSelected];
        }
        [sender setTitle:@"All On" forState:UIControlStateNormal];
        
    }
    else
    {
        self.currentLightClicked.selected = YES;
        [[PLNetworkManager sharedManager] deviceSwitchWithDeviceType:LightType switchOn:YES];
        for (PLCustomButton *btn in self.mutArrAllBtns)
        {
            [btn setBackgroundImage:[UIImage imageNamed:@"lightOn.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"lightOn.png"] forState:UIControlStateSelected];
        }
        [sender setTitle:@"All Off" forState:UIControlStateNormal];
    }
}

#pragma mark - 普通图片取色 -
- (NSMutableArray *)changeUIColorToRGB:(UIColor *)color
{
    NSMutableArray *RGBStrValueArr = [[NSMutableArray alloc] init];
    NSString *RGBStr = nil;
    //获得RGB值描述
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    //将RGB值描述分隔成字符串
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    //获取红色值
    float r = [[RGBArr objectAtIndex:1] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%f",r];
    [RGBStrValueArr addObject:RGBStr];
    //获取绿色值
    float g = [[RGBArr objectAtIndex:2] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%f",g];
    [RGBStrValueArr addObject:RGBStr];
    //获取蓝色值
    float b = [[RGBArr objectAtIndex:3] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%f",b];
    [RGBStrValueArr addObject:RGBStr];
    //返回保存RGB值的数组
    return RGBStrValueArr;
    
}

- (UIColor *)getPixelColorAtLocation:(CGPoint)point
{
    float colorPointY;
    CGImageRef inImage;
    if (!self.imageVBigTap.hidden)
    {
        inImage = self.imageVBigTap.image.CGImage;
        colorPointY = fabsf(point.y - 35);
    }
    else if (CGRectContainsPoint(warmColorMatrixFrame,point))
    {
        UIImage *warmImage = [UIImage imageNamed:@"WarmColor.png"];
        inImage = warmImage.CGImage;
        colorPointY = fabsf(point.y - 35);
    }
    else if (CGRectContainsPoint(coolColorMatrixFrame, point))
    {
        UIImage *coolImage = [UIImage imageNamed:@"CoolColor.png"];
        inImage = coolImage.CGImage;
        colorPointY = fabsf(point.y - 185);
    }
    else
    {
        inImage = nil;
        return [UIColor whiteColor];
    }
    
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL)
    {
        return nil;
    }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0, 0}, {w, h}};
    
    CGContextDrawImage(cgctx, rect, inImage);
    float colorPointX = fabsf(point.x - 10);
    CGPoint colorPoint = CGPointMake(colorPointX, colorPointY);
    
    UIColor *color = nil;
    unsigned char *data = CGBitmapContextGetData(cgctx);
    if (data != NULL) {
        
        DebugLog(@"roun(point.y )==== %f *****************  round(point,x) ==%f",round(point.y),round(point.x));
        
        int offset = 4 * ((w * round(colorPoint.y)) + round(colorPoint.x));
        int alpha = data[offset];
        int red = data[offset + 1];
        int green = data[offset + 2];
        int blue = data[offset + 3];
        color = [UIColor colorWithRed:(red / 255.0f) green:(green / 255.0f) blue:(blue / 255.0f) alpha:(alpha / 255.0f)];
        DebugLog(@"red == %d******green == %d*******blue == %d",red,green,blue);
    }
    
    CGContextRelease(cgctx);
    
    if (data) { free(data); }
    
    return color;
}

- (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    bitmapBytesPerRow = (int)(pixelsWide * 4);
    bitmapByteCount = (int)(bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL) {
        fprintf(stderr, "Error allocating color space ");
        return NULL;
    }
    
    bitmapData = malloc(bitmapByteCount);
    if (bitmapData == NULL) {
        fprintf(stderr, "Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow,
                                    colorSpace, kCGImageAlphaPremultipliedFirst);
    if (context == NULL) {
        free(bitmapData);
        fprintf(stderr, "Context not created!");
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

#pragma mark - 二期东西处理 -
- (IBAction)btnChoosePicPressed:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(btnAddSecenPressed)])
    {
        [self.delegate btnAddSecenPressed];
    }
}


#pragma mark - tableview多选 -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return  self.arrLights.count;
    return [[PLNetworkManager sharedManager] lightsArr].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
#pragma tableView delegate methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//添加一项
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DebugLog(@"*****************1");
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//取消一项
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    DebugLog(@"*****************2");
}

//选择后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    DebugLog(@"*****************3");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    static NSString *CellIdentifier = @"PLLightingCell";
    //自定义cell类
    PLLightingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //通过xib的名称加载自定义的cell
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PLLightingCell" owner:self options:nil] lastObject];
    }
    cell.delegate = self;
    
    PLModel_Device *model = [[PLNetworkManager sharedManager] lightsArr][indexPath.row];
    cell.labelTitle.text = [NSString stringWithFormat:@"%d",model.index];
    cell.labelTitle.font = fontCustom(15);
    cell.slider.value = 15;
    for (PLModel_Device *light in self.arrLights)
    {
        if ([light.macAddress isEqualToData:model.macAddress])
        {
            cell.slider.value = light.Dim;
            break;
        }
    }
    
    
    
    BOOL isSelected = NO;
    for (PLModel_Device *device in self.mutArrSave)
    {
        if ([device.macAddress isEqualToData:model.macAddress])
        {
            isSelected = YES;
            break;
        }
    }
    cell.btnSelected.selected = isSelected;
    
    return cell;
}


- (void)btnSelectedPressedOnLightingCell:(PLLightingCell *)cell
                                  andBtn:(UIButton *)btnOnCell
{
    NSIndexPath *index = [self.tableLights indexPathForCell:cell];
    PLModel_Device *device = [[PLNetworkManager sharedManager] lightsArr][index.row];
    
    
    if (btnOnCell.selected)
    {
        btnOnCell.selected = YES;
        
        //判断mutArrSave中是否已存在被选中的灯泡
        BOOL isExist = NO;
        for (PLModel_Device *existDevice in self.mutArrSave)
        {
            if ([device.macAddress isEqualToData:existDevice.macAddress])
            {
                isExist = YES;
                break;
            }
        }
        
        //不存在则添加，已存在不需再添加
        if (!isExist)
        {
            [self.mutArrSave addObject:device];
        }
    }
    else
    {
        btnOnCell.selected = NO;
        //判断mutArrSave中是否已存在被取消的灯泡，存在则移除
        for (PLModel_Device *existDevice in self.mutArrSave)
        {
            if ([device.macAddress isEqualToData:existDevice.macAddress])
            {
                [self.mutArrSave removeObject:existDevice];
                break;
            }
        }
    }
}

- (void)sliderClickedOnLightingCell:(PLLightingCell *)cell andSlider:(UISlider *)slider
{
    
    NSIndexPath *index = [self.tableLights indexPathForCell:cell];
    PLModel_Device *light = [[PLNetworkManager sharedManager] lightsArr][index.row];
    //同步Dim
    [[PLNetworkManager sharedManager] changeLightsDimWithLight:light level:(int)slider.value];
    
    //保存到数据库
    //当前选中的是大灯
    if ([self.currentLightClicked isKindOfClass:[PLClickedBigButton class]])
    {
        PLClickedBigButton *bigButton = (PLClickedBigButton *)self.currentLightClicked;
        for (PLModel_Device *originalLight in bigButton.mutArrClickedLights)
        {
            if ([light.macAddress isEqual:originalLight.macAddress])
            {
                originalLight.Dim = (int)slider.value;
                light.firstShortAddr = originalLight.firstShortAddr;
                light.secondShortAddr = originalLight.secondShortAddr;
                light.colorR = originalLight.colorR;
                light.colorG = originalLight.colorG;
                light.colorB = originalLight.colorB;
                light.locationX = bigButton.center.x;
                light.locationY = bigButton.center.y;
                light.Dim = (int)slider.value;
                break;
            }
        }
        [[PLDatabaseManager sharedManager] saveLightInfo:light andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
    }
    //当前选中的是小灯
    else
    {
        for (PLCustomButton *lightBtn in self.mutArrAllBtns)
        {
            if ([light.macAddress isEqual:lightBtn.light.macAddress])
            {
                lightBtn.light.Dim = (int)slider.value;
                light.firstShortAddr = lightBtn.light.firstShortAddr;
                light.secondShortAddr = lightBtn.light.secondShortAddr;
                light.colorR = lightBtn.light.colorR;
                light.colorG = lightBtn.light.colorG;
                light.colorB = lightBtn.light.colorB;
                light.locationX = lightBtn.center.x;
                light.locationY = lightBtn.center.y;
                light.Dim = (int)slider.value;
                break;
            }
        }
        [[PLDatabaseManager sharedManager] saveLightInfo:light andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
    }
}


@end