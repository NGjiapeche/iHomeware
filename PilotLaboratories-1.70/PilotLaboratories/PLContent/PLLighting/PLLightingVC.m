//
//  PLLightingVC.m
//  PilotLaboratories
//
//  Created by frontier on 14-3-20.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLLightingVC.h"
#import "PLColorPickerView.h"
#import "PLModel_Device.h"
#import "MLImageCrop.h"
#import "PLLightingMainVC.h"

@interface PLLightingVC ()<PLColorPickerViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MLImageCropDelegate>

@property (strong, nonatomic) UIImagePickerController *imgPickerVC;
@property (strong, nonatomic) UIImage *selectedImg;

@property (assign, nonatomic) BOOL isSelePic;

@end

@implementation PLLightingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.logo1 removeFromSuperview];
    self.isSelePic = NO;
    
    if ([[PLSceneManager sharedManager] isEditingScene])
    {
        yct_initNav(YES, YES, NO, NSLocalizedString(@"Lighting", nil), nil, NSLocalizedString(@"Save", nil), nil, @"backBlue.png", nil, nil);
        _tempColorView.btnPohoto.hidden = NO;
        _tempColorView.tableLights.hidden = NO;
    }
    else
    {
        yct_initNav(YES, NO, NO, NSLocalizedString(@"Lighting", nil), nil, nil, nil, @"backBlue.png", nil, nil);
        _tempColorView.btnPohoto.hidden = YES;
        _tempColorView.tableLights.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidDiscoveryDevice:)
                                                 name:DidDiscoveryDevice
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleDidRefreshDeviceStatus:)
//                                                 name:DidRefreshDeviceStatus
//                                               object:nil];

    _tempColorView = [[PLColorPickerView alloc] initWithFrame:CGRectMake(0, 67, 320, 456)];
    
    if (self.scene.sceneIndex <= 9)
    {
        _tempColorView.btnPohoto.hidden = YES;
    }
    
    UIImage *warmColorImage = [UIImage imageNamed:@"WarmColor.png"];
    UIImage *sceneImage = [UIImage imageWithContentsOfFile:self.scene.sceneImagePath];
    if ([UIImagePNGRepresentation(warmColorImage) isEqualToData:UIImagePNGRepresentation(sceneImage)])
    {
        _tempColorView.imageVBigTap.hidden = YES;
        _tempColorView.warmHueSatImage.hidden = NO;
        _tempColorView.coolHueSatImage.hidden = NO;
    }
    else
    {
        _tempColorView.imageVBigTap.hidden = NO;
        _tempColorView.warmHueSatImage.hidden = YES;
        _tempColorView.coolHueSatImage.hidden = YES;
        
        UIImage *image = [UIImage imageWithContentsOfFile:self.scene.sceneImagePath];
        _tempColorView.imageVBigTap.image = image;
    }
    
    _tempColorView.delegate = self;
    [self.view addSubview:_tempColorView];
    
    //查询当前场景的在线灯
    NSMutableArray *lightsArr = [[PLNetworkManager sharedManager] lightsArr];
    NSArray *devicesArray = [[PLSceneManager sharedManager] queryLightsStatus:lightsArr];
    NSString *namestr = [[PLSceneManager sharedManager]currentSceneName];
    for (PLModel_Device *light in devicesArray) {
        DebugLog(@"数据库里有灯");
            if ([namestr isEqualToString:@"Relax"]) {
                if (light.colorR==0 && light.colorG == 0 && light.colorB == 0 & light.locationX==0 & light.locationY==0 )
                {
                    light.colorR = 255;
                    light.colorG = 240;
                    light.colorB = 195;
                    light.locationX= 44;
                    light.locationY= 126;
                    light.Dim = 15;
                }
            }
            else if ([namestr isEqualToString:@"Read"]) {
                if (light.colorR==0 && light.colorG == 0 && light.colorB == 0 & light.locationX==0 & light.locationY==0 ){
                    light.colorR = 160;
                    light.colorG = 220;
                    light.colorB = 155;
                    light.locationX= 181;
                    light.locationY= 108;
                    light.Dim = 15;
                }
            }
            else if ([namestr isEqualToString:@"TreePimay"]) {
                if (light.colorR==0 && light.colorG == 0 && light.colorB == 0 & light.locationX==0 & light.locationY==0 ){
                    if (light.secondShortAddr <0X55) {
                        light.colorR = 255;
                        light.colorG = 10;
                        light.colorB = 10;
                        light.locationX= 10;
                        light.locationY= 19;
                    }else  if (light.secondShortAddr < 0xAA) {
                        light.colorR = 10;
                        light.colorG = 255;
                        light.colorB = 10;
                        light.locationX= 110;
                        light.locationY= 26;
                    }else{
                        light.colorR = 10;
                        light.colorG = 10;
                        light.colorB = 255;
                        light.locationX= 210;
                        light.locationY= 29;
                    }
                    
                    light.Dim = 15;
                }
      
            }else
            {
                
                
            }
    }

    if (devicesArray.count)
    {
        [_tempColorView setArrLights:devicesArray];
        
        //设置_tempColorView mutArrSave
        _tempColorView.mutArrSave = [NSMutableArray arrayWithArray:devicesArray];
    }
    else
    {
        //若查不到在线的灯，则查询当前场景所有的灯
        devicesArray = [[PLSceneManager sharedManager] queryAllLightsWithSceneName:self.scene.strSecenName];
        //若当前场景无灯，则添加所有搜索到的灯泡
        if (!devicesArray || devicesArray.count == 0)
        {
             DebugLog(@"当前场景无灯，则添加所有搜索到的灯泡");
            NSMutableArray *mutArrAllTemp = lightsArr;
            if ([[PLSceneManager sharedManager] isEditingScene])
            {
                for (PLModel_Device *light in mutArrAllTemp)
                {
                    DebugLog(@"添加");
                    light.onOff = YES;
//                    if (light.colorR==0 && light.colorG == 0 && light.colorB == 0 & light.locationX==0 & light.locationY==0 )
//                    {
                        if ([namestr isEqualToString:@"Relax"]) {
                            light.colorR = 255;
                            light.colorG = 240;
                            light.colorB = 195;
                            light.locationX= 44;
                            light.locationY= 126;
                            light.Dim = 15;
                        }
                        else if ([namestr isEqualToString:@"Read"]) {
                            light.colorR = 160;
                            light.colorG = 220;
                            light.colorB = 255;
                            light.locationX= 181;
                            light.locationY= 108;
                            light.Dim = 15;
                        }
                        else if ([namestr isEqualToString:@"TreePimay"])
                        {
                            if (light.secondShortAddr <0X55) {
                                light.colorR = 255;
                                light.colorG = 10;
                                light.colorB = 10;
                                light.locationX= 21;
                                light.locationY= 15;
                            }else  if (light.secondShortAddr < 0xAA) {
                                light.colorR = 10;
                                light.colorG = 255;
                                light.colorB = 10;
                                light.locationX= 110;
                                light.locationY= 26;
                            }else{
                                light.colorR = 10;
                                light.colorG = 10;
                                light.colorB = 255;
                                light.locationX= 210;
                                light.locationY= 29;
                            }
                            
                            light.Dim = 15;
                        }else
                        {
                            
                            
                        }
                        
//                    }

                }
                [_tempColorView setArrLights:mutArrAllTemp];
            }
            
            _tempColorView.mutArrSave = [NSMutableArray arrayWithArray:mutArrAllTemp];
        }
        else
        { DebugLog(@"当前场景有灯但是没有灯在线");
            //当前场景有灯但是没有灯在线
            [_tempColorView setArrLights:nil];
            _tempColorView.mutArrSave = [NSMutableArray arrayWithArray:devicesArray];
        }
    }
    
    [_tempColorView.tableLights reloadData];
}

- (void)handleDidDiscoveryDevice:(NSNotification *)notification
{
    NSArray *lightsArr = [[PLNetworkManager sharedManager] lightsArr];
    if (lightsArr.count)
    {
        //从数据库中查询状态，返回数据会走QueryLightsStatusSuccess通知
        NSArray *dbLightsArray = [[PLDatabaseManager sharedManager] queryLightsStatus:lightsArr];
//        //App启动发送存储的灯泡信息到网关
//        if ([[PLSceneManager sharedManager] appLaunch])
//        {
//            [[PLSceneManager sharedManager] setAppLaunch:NO];
//            //发送存储的灯泡信息到网关
//            
//            for (PLModel_Device *light in lightsArr)
//            {
//                [[PLNetworkManager sharedManager] changeLightsColorWithLight:light
//                                                                      colorR:light.colorR
//                                                                      colorG:light.colorG
//                                                                      colorB:light.colorB];
//            }
//        }
        
        [self.tempColorView setArrLights:dbLightsArray];
    }
    else
    {
        [self.tempColorView setArrLights:nil];
    }
}

- (void)handleDidRefreshDeviceStatus:(NSNotification *)notification
{
    NSArray *lightsArr = [[PLNetworkManager sharedManager] lightsArr];
    [self.tempColorView setArrLights:lightsArr];
}

- (void)btnAddSecenPressed
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancell", nil) destructiveButtonTitle:NSLocalizedString(@"Camera", nil) otherButtonTitles:NSLocalizedString(@"Photo album", nil), nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if (!self.imgPickerVC)
        {
            _imgPickerVC = [[UIImagePickerController alloc] init];
            _imgPickerVC.delegate = self;
        }
        _imgPickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:_imgPickerVC animated:YES completion:nil];
    }
    else if (buttonIndex == 1)
    {
        if (!self.imgPickerVC)
        {
            _imgPickerVC = [[UIImagePickerController alloc] init];
            _imgPickerVC.delegate = self;
        }
        _imgPickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:_imgPickerVC animated:YES completion:nil];
    } 
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.selectedImg = info[@"UIImagePickerControllerOriginalImage"];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    MLImageCrop *imageCrop = [[MLImageCrop alloc]init];
    imageCrop.delegate = self;
    imageCrop.ratioOfWidthAndHeight = 300.0f/190.0f;
    imageCrop.image = self.selectedImg;
    [imageCrop showWithAnimation:YES];
}

- (void)cropImage:(UIImage*)cropImage forOriginalImage:(UIImage*)originalImage
{
    self.isSelePic = YES;
    self.selectedImg = cropImage;
    
    _tempColorView.imageVBigTap.hidden = NO;
    _tempColorView.warmHueSatImage.hidden = YES;
    _tempColorView.coolHueSatImage.hidden = YES;
    [_tempColorView setNeedsDisplay];
    
    CGRect imageRect = CGRectMake(0, 0, 300, 190);
    UIImage *sceneImage = [self reRectImage:self.selectedImg toRect:imageRect];
    _tempColorView.imageVBigTap.image = sceneImage;
}

- (UIImage *)reRectImage:(UIImage *)image toRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
    [image drawInRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)btnRightPressed
{
    if (self.scene.sceneIndex > 9)
    {
        if (self.isSelePic)
        {
            DebugLog(@"yes");
            //保存图片
            CGRect imageRect = CGRectMake(0, 0, 300, 190);
            UIImage *sceneImage = [self reRectImage:self.selectedImg toRect:imageRect];
            _tempColorView.imageVBigTap.image = sceneImage;
            
            CGImageRef cgRef = sceneImage.CGImage;
            CGImageRef imageRef = CGImageCreateWithImageInRect(cgRef, CGRectMake(70, 15, 160, 160));
            UIImage *sceneIcon = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            
            [[PLDatabaseManager sharedManager] modifySceneWithScene:self.scene SceneIcon:sceneIcon SceneImage:sceneImage];
        }

    }
    
    NSMutableArray *toSaveLightsArr = [NSMutableArray arrayWithArray:_tempColorView.mutArrSave];
    //获取坐标
    for (PLModel_Device *light in toSaveLightsArr)
    {
        for (PLCustomButton *lightBtn in _tempColorView.mutArrAllBtns)
        {
            if ([light.macAddress isEqual:lightBtn.light.macAddress])
            {
                light.firstShortAddr = lightBtn.light.firstShortAddr;
                light.secondShortAddr = lightBtn.light.secondShortAddr;
                light.colorR = lightBtn.light.colorR;
                light.colorG = lightBtn.light.colorG;
                light.colorB = lightBtn.light.colorB;
                light.locationX = lightBtn.center.x;
                light.locationY = lightBtn.center.y;
                light.Dim = lightBtn.light.Dim;
                DebugLog(@"light.firstShortAddr %d,light.secondShortAddr%d,light.colorR%d,light.colorG%d,light.colorB%d",light.firstShortAddr ,light.secondShortAddr,light.colorR,light.colorG,light.colorB);
                break;
            }
        }
    }
    
    //保存坐标
    [[PLDatabaseManager sharedManager] saveLightsInfo:toSaveLightsArr
                                        DeleteOldData:YES andscenename:[[[PLSceneManager sharedManager] currentScene] strSecenName]];
    
    //发送控制命令
    int scenceindex;
    if ([self.scene.strSecenName isEqualToString:@"Relax"]) {
        scenceindex =1;
    }else if ([self.scene.strSecenName isEqualToString:@"Read"]){
        scenceindex =2;
    }else if ([self.scene.strSecenName isEqualToString:@"TreePimay"]){
        scenceindex =3;
    }else{
        scenceindex = self.scene.sceneIndex;
    }
    [[PLNetworkManager sharedManager] sceneControlWithType:StoreSceneType
                                               SceneNumber:scenceindex
                                                   GroupID:0
                                                 LightsArr:toSaveLightsArr
                                                 SceneName:self.scene.strSecenName];
    
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:WarmPrompt message:NSLocalizedString(@"Save",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil)otherButtonTitles:nil, nil];
    alter.tag = 1002;
    [alter show];
}


- (void)btnBackPressed
{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"logostatue" object:[NSNumber numberWithInt:1]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1002)
    {
        if (self.isSelePic)
        {
            NSArray *vcs = self.navigationController.viewControllers;
            if (vcs.count >= 2)
            {
                PLLightingMainVC *vc = vcs[vcs.count - 2];
                vc.shouldReloadScene = YES;
            }
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}



@end
