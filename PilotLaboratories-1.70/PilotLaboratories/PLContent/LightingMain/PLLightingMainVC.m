//
//  PLLightingMainVC.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14/11/7.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLLightingMainVC.h"
#import "PLSceneView.h"
#import "PLLightingVC.h"

#define SceneViewWidth          106
#define SceneViewHeight         106

@interface PLLightingMainVC ()<UIAlertViewDelegate,PLSceneViewDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *scenesArray;
@property (strong, nonatomic) PLSceneModel *selectedScene;
@property (strong, nonatomic) NSTimer *syncSceneTimer;
@property(assign,nonatomic)BOOL Isadderror;
@property(strong,nonatomic)UIButton *imgbtn;
@end

@implementation PLLightingMainVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    yct_initNav(NO, YES, YES, NSLocalizedString(@"Lighting", nil), nil, nil, nil, @"OnOrOff.png",  @"笔1.png",nil);
    //加载场景
    [self loadScenes];
     [self setdefualt];
//    if ([[PLSceneManager sharedManager] shouldSyncScene])
//    {NSLog(@"111");
//        //同步本地场景给网关
//        [self syncLocalSceneToGateway];
//       
//    }
//    else
//    {NSLog(@"222");
//        //同步当前场景
//        [self syncCurrentSceneToGateWay];
//    }
    [self syncCurrentSceneToGateWay];
}
-(void)viewDidAppear:(BOOL)animated{
      [self syncCurrentSceneToGateWay];
    NSArray *subViews = self.scrollView.subviews;
    PLSceneView *sview = [subViews objectAtIndex:0];
    sview.iconBtn.selected = YES;
    [sview.iconBtn setImage:[UIImage imageNamed:@"light_OFF.png"] forState:UIControlStateNormal];
    [sview.iconBtn setImage:[UIImage imageNamed:@"light_ON.png"] forState:UIControlStateSelected];
}
-(void)setdefualt
{
//  PLSceneModel *currentScene = [[PLSceneManager sharedManager] currentScene];
   NSArray *larr =  [[PLNetworkManager sharedManager]lightsArr];
     NSArray *devicesArray = [[PLSceneManager sharedManager] queryLightsStatus:larr];
            for (PLModel_Device *light in devicesArray)
            {
                if ( light.colorR==0 && light.colorG == 0 && light.colorB == 0 & light.locationX==0 & light.locationY==0)
                {
                    DebugLog(@"设定默认值");
                    light.colorR = 255;
                    light.colorG = 240;
                    light.colorB = 195;
                    light.locationX= 44;
                    light.locationY= 126;
                    light.Dim = 15;
                    [[PLDatabaseManager sharedManager] saveLightInfo:light andscenename:@"Relax"];
                    
                    light.colorR = 160;
                    light.colorG = 220;
                    light.colorB = 255;
                    light.locationX= 181;
                    light.locationY= 108;
                    light.Dim = 15;
                    [[PLDatabaseManager sharedManager] saveLightInfo:light andscenename:@"Read"];
                    
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
                     [[PLDatabaseManager sharedManager] saveLightInfo:light andscenename:@"TreePimay"];
                    
                }
            }
}
- (void)viewWillAppear:(BOOL)animated
{
   
      NSArray *subViews = self.scrollView.subviews;
    PLSceneView *sview = [subViews objectAtIndex:0];
    sview.iconBtn.selected = NO;
    //cun默认场景
    
    if (self.shouldReloadScene)
    {
        self.shouldReloadScene = NO;
        //重新加载场景
        [self loadScenes];
    }
}

- (void)loadScenes
{
    NSArray *subViews = self.scrollView.subviews;
    for (UIView *view in subViews)
    {
        if ([view isKindOfClass:[PLSceneView class]] || [view isKindOfClass:[UIView class]])
        {
            
            [view removeFromSuperview];
        }
    }
    
    UIScreen *screen = [UIScreen mainScreen];
    float width = screen.bounds.size.width;
    float height = screen.bounds.size.height;
    self.scrollView.frame = CGRectMake(0, 67, width, height - 67 - 44);
    NSArray *allScenes = [[PLSceneManager sharedManager] allScenes];
    NSString *currentSceneName = [[PLSceneManager sharedManager] currentSceneName];
    int currentSceneIndex = 0;
    self.scenesArray = [NSMutableArray arrayWithArray:allScenes];
    for (int i = 0; i <= allScenes.count; i++)
    {
        if (i==1 || i== 2 || i== 5 || i== 6 || i== 8) {
            continue;
        }
        int j;//中间缺省的ui
        if (i==3 || i ==4) {
            j = 2;
        }else if(i == 7){
            j = 4;
        }else if(i > 8){
            j = 5;
        }else{
            j = 0;
        }
    
        if (i<allScenes.count) {
            PLSceneModel *scene = allScenes[i];
            if ([scene.strSecenName isEqualToString:currentSceneName])
            {
                currentSceneIndex = i;
                self.selectedScene = scene;
            }
            PLSceneView *sceneView = [[PLSceneView alloc] initWithScene:scene];
            float orginX = 320 * ((i-j) / 9) + ((i-j) % 3) * SceneViewWidth;
            float spaceY = (CGRectGetHeight(self.scrollView.frame) - SceneViewHeight * 3) / 4.0;
            float orginY = ((i-j) % 9) / 3 * SceneViewHeight + ((i-j)% 9 / 3 + 1) * spaceY;
            sceneView.frame = CGRectMake(orginX, orginY, SceneViewWidth, SceneViewHeight);
            sceneView.delegate = self;
            [self.scrollView addSubview:sceneView];
        }else{
           
            float orginX = 320 * ((i-j) / 9) + ((i-j) % 3) * SceneViewWidth;
            DebugLog(@"qidian:%f",orginX);
            float spaceY = (CGRectGetHeight(self.scrollView.frame) - SceneViewHeight * 3) / 4.0;
            float orginY = ((i-j) % 9) / 3 * SceneViewHeight + ((i-j)% 9 / 3 + 1) * spaceY;
             self.imgbtn= [[UIButton alloc]initWithFrame: CGRectMake(10, 5, SceneViewWidth-20, SceneViewHeight-20)];
            [self.imgbtn setImage:[UIImage imageNamed:@"APP界面 +"] forState:UIControlStateNormal];
            [self.imgbtn setImage:[UIImage imageNamed:@"PLus-button"] forState:UIControlStateSelected];
          self.imgbtn.layer.cornerRadius = CGRectGetWidth(self.imgbtn.frame) / 2.0;
             UIView *addimg =[[UIView alloc]initWithFrame: CGRectMake(orginX, orginY, SceneViewWidth, SceneViewHeight)];
            [self.imgbtn addTarget:self action:@selector(addscene:) forControlEvents:UIControlEventTouchUpInside];
            [addimg addSubview:self.imgbtn];
            [self.scrollView addSubview:addimg];
        }
        
    }
    int x =(int)allScenes.count-4;
    int pages = x % 9 == 0 ? (x / 9) : (x / 9 + 1);
    float contentWidth = CGRectGetWidth(self.scrollView.frame) * pages;
    self.scrollView.contentSize = CGSizeMake(contentWidth, CGRectGetHeight(self.scrollView.frame));
    
    float currentPage = ((currentSceneIndex-4) / 9);
    [self.scrollView setContentOffset:CGPointMake(width * currentPage, 0)];

}
-(void)addscene:(UIButton *)senderbtn{
    senderbtn.selected = YES;
    [self showAlertViewWithTag:101];
}
- (void)sceneView:(PLSceneView *)view iconButtonDidClicked:(UIButton *)button
{
    //开关控制
    if (view.scene.sceneIndex == 1)
    {
       
        BOOL on = button.selected;
        [[PLNetworkManager sharedManager] deviceSwitchWithDeviceType:LightType switchOn:on];
    }
    
    //场景控制
    if (view.scene.sceneIndex > 3)
    {
        UIView *view1 = (UIView*)self.btnRight;
        [UIView animateWithDuration:1.0 // 动画时长
                              delay:0.0 // 动画延迟
             usingSpringWithDamping:1.0 // 类似弹簧振动效果 0~1
              initialSpringVelocity:1.0 // 初始速度
                            options:UIViewAnimationOptionCurveLinear // 动画过渡效果
                         animations:^{
                             CGAffineTransform transform;
                             transform = CGAffineTransformScale(view1.transform, 1.2, 1.2);
                             view1.transform = transform;
                    } completion:^(BOOL finished) {
                        CGAffineTransform transform;
                        transform = CGAffineTransformScale(view1.transform, 5.00/6.00, 5.00/6.00);
                        view1.transform = transform;
                         }];
        if (self.selectedScene == view.scene)
        {
            return;
        }
        
        self.selectedScene = view.scene;
        ShowHUD;
        //设置当前场景
       
        [[PLSceneManager sharedManager] setCurrentSceneName:view.scene.strSecenName];
         int scenceindex;
        if ([view.scene.strSecenName isEqualToString:@"Relax"]) {
          scenceindex =1;
        }else if ([view.scene.strSecenName isEqualToString:@"Read"]){
            scenceindex =2;
        }else if ([view.scene.strSecenName isEqualToString:@"TreePimay"]){
               scenceindex =3;
        }else{
            scenceindex = view.scene.sceneIndex;
        }
        //发送场景控制命令
        NSArray *lightsArray = [[PLSceneManager sharedManager] queryAllLightsWithSceneName:view.scene.strSecenName];
        [[PLNetworkManager sharedManager] sceneControlWithType:RecallSceneType
                                                   SceneNumber:scenceindex
                                                       GroupID:0
                                                     LightsArr:lightsArray
                                                     SceneName:view.scene.strSecenName];
        HideHUD;
    }
}

- (void)sceneView:(PLSceneView *)view iconButtonDidLongPressed:(UIButton *)button
{
    if (view.scene.sceneIndex > 2)
    {
        self.selectedScene = view.scene;
    }
    
    if (view.scene.sceneIndex > 4)
    {
        [[PLSceneManager sharedManager] setCurrentSceneName:view.scene.strSecenName];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Scene Edit", nil)] delegate:self cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"Cancel", nil)] destructiveButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"Delete Scene", nil)] otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"Rename Scene", nil)],nil];
        float deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (deviceVersion < 8.0)
        {
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        }
        else
        {
            [actionSheet showInView:self.view];
        }
        
    }
   
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        BOOL success = [[PLSceneManager sharedManager] deleteScene:self.selectedScene];
        if (success)
        {
            //发送删除场景指令给网关
            [[PLNetworkManager sharedManager] sceneControlWithType:RemoveSceneType
                                                       SceneNumber:self.selectedScene.sceneIndex
                                                           GroupID:0
                                                         LightsArr:nil
                                                         SceneName:self.selectedScene.strSecenName];
            
            //刷新UI
            UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                                message:@"Delete Scene Success!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alterView show];
            [self loadScenes];
        }
        else
        {
            UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                                message:@"Delete Scene Error!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alterView show];
        }
    }
    else if (buttonIndex == 1)
    {
        [self showAlertViewWithTag:102];
    }
}

- (void)showAlertViewWithTag:(int)tag
{
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                        message:NSLocalizedString(@"Please input your Scene Name", nil)
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"YES", nil];
    alterView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textFieldEmail = [alterView textFieldAtIndex:0];
    textFieldEmail.placeholder = NSLocalizedString(@"Please input your Scene Name", nil);
    alterView.tag = tag;
    [alterView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.imgbtn.selected = NO;
    if (alertView.tag == 101)
    {
        //新增场景
        if (buttonIndex == 1)
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSString *newSceneName = textField.text;
            if (newSceneName.length > 0)
            {
                BOOL hasExist = [self sceneNameAlreadyExist:newSceneName];
                if (!hasExist)
                {
                    BOOL success = [[PLSceneManager sharedManager] addSceneWithSceneName:newSceneName];
                    if (success)
                    {
                        [[PLSceneManager sharedManager] setCurrentSceneName:newSceneName];
                        [self loadScenes];
                        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                                            message:@"Add Scene Success!"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                        [alterView show];
                    }
                    else
                    {
                        
                        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                                            message:@"Add Scene Error!"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                        [[PLSceneManager sharedManager] deleteScene: [[[PLSceneManager sharedManager] allScenes] lastObject]];
                        [alterView show];
                         [self loadScenes];
                    }
                }
                else
                {
                    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                                        message:@"Scene has already exist!"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alterView show];
                }
            }
        }
        else
        {
            
        }
    }
    else if (alertView.tag == 102)
    {
        //修改场景
        if (buttonIndex == 1)
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSString *newSceneName = textField.text;
            if (newSceneName.length > 0)
            {
                BOOL hasExist = [self sceneNameAlreadyExist:newSceneName];
                if (!hasExist)
                {
                    NSString *currentSceneName = [[PLSceneManager sharedManager] currentSceneName];
                    BOOL success = [[PLSceneManager sharedManager] renameSceneWithSceneName:currentSceneName newSceneName:newSceneName];
                    if (success)
                    {
                        [[PLSceneManager sharedManager] setCurrentSceneName:newSceneName];
                        [self loadScenes];
                        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                                            message:@"Rename Scene Success!"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                        [alterView show];

                    }
                    else
                    {
                        BOOL success = [[PLSceneManager sharedManager] renameSceneWithSceneName:newSceneName newSceneName:currentSceneName];
                        [[PLSceneManager sharedManager] setCurrentSceneName:currentSceneName];
                        [self loadScenes];
                        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                                            message:@"Rename Scene Error!"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                        [alterView show];
                    }
                }
                else
                {
                    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                                        message:@"Scene has already exist!"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alterView show];
                }
            }
        }
        else
        {
            
        }
    }else if (alertView.tag == 1){
        if (buttonIndex == 0){
            [[PLSceneManager sharedManager] setIsEditingScene:YES];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"PLLighting" bundle:[NSBundle mainBundle]];
            PLLightingVC *vc = [storyBoard instantiateViewControllerWithIdentifier:@"PLLightingVC"];
            vc.scene = self.selectedScene;
            [self.navigationController pushViewController:vc animated:YES];

        }else{
            
        }
    }
}

- (BOOL)sceneNameAlreadyExist:(NSString *)sceneName
{
    BOOL hasExist = NO;
    for (int i = 0; i < self.scenesArray.count; i++)
    {
        PLSceneModel *scene = self.scenesArray[i];
        if ([scene.strSecenName isEqualToString:sceneName])
        {
            hasExist = YES;
            break;
        }
    }
    
    return hasExist;
}

- (void)btnRightPressed
{

//    [self showAlertViewWithTag:101];
    NSString*title =  [NSString stringWithFormat:NSLocalizedString(@"Whether to modify the scene", nil)];
    NSString *cancel =[NSString stringWithFormat:NSLocalizedString(@"YES", nil)];
    NSString *okbnt =[NSString stringWithFormat:NSLocalizedString(@"NO", nil)];
    
    UIAlertView *aler = [[UIAlertView alloc]initWithTitle:WarmPrompt message:title delegate:self cancelButtonTitle:cancel otherButtonTitles:okbnt, nil];
    aler.tag = 1;
    [aler show];

}

- (void)btnMiddlePressedWithBtn:(UIButton *)btn
{
//    NSString*title =  [NSString stringWithFormat:NSLocalizedString(@"Whether to modify the scene", nil)];
//    NSString *cancel =[NSString stringWithFormat:NSLocalizedString(@"YES", nil)];
//     NSString *okbnt =[NSString stringWithFormat:NSLocalizedString(@"NO", nil)];
//
//    UIAlertView *aler = [[UIAlertView alloc]initWithTitle:WarmPrompt message:title delegate:self cancelButtonTitle:cancel otherButtonTitles:okbnt, nil];
//    aler.tag = 1;
//    [aler show];
}

- (void)syncLocalSceneToGateway
{
    ShowHUD;
    if (!self.scenesArray)
    {
        NSArray *allScenes = [[PLSceneManager sharedManager] allScenes];
        self.scenesArray = [NSMutableArray arrayWithArray:allScenes];
    }
    
    DebugLog(@"\n\n\n==============================Start SyncLocalSceneToGateway:\n\n");
    self.syncSceneTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sendSyncCommand) userInfo:nil repeats:YES];
}

- (void)sendSyncCommand
{
    static int sceneIndex = 3;
    if (self.scenesArray.count >= sceneIndex + 1)
    {
        PLSceneModel *scene = self.scenesArray[sceneIndex];
        NSArray *lightsArray = [[PLSceneManager sharedManager] queryAllLightsWithSceneName:scene.strSecenName];
        int scenceindex;
        if ([scene.strSecenName isEqualToString:@"Relax"]) {
            scenceindex =1;
        }else if ([scene.strSecenName isEqualToString:@"Read"]){
            scenceindex =2;
        }else if ([scene.strSecenName isEqualToString:@"TreePimay"]){
            scenceindex =3;
        }else{
            scenceindex = scene.sceneIndex;
        }
        [[PLNetworkManager sharedManager] sceneControlWithType:StoreSceneType
                                                   SceneNumber:scenceindex
                                                       GroupID:0
                                                     LightsArr:lightsArray
                                                     SceneName:scene.strSecenName];
        DebugLog(@"\n\n\n==============================Sync %@ to Gateway\n\n",scene.strSecenName);
        sceneIndex++;
    }
    else
    {
        [self.syncSceneTimer invalidate];
        [self setSyncSceneTimer:nil];
        DebugLog(@"\n\n\n==============================End SyncLocalSceneToGateway:\n\n");
        HideHUD;
        //同步当前场景给网关
        [self syncCurrentSceneToGateWay];
    }
}

- (void)syncCurrentSceneToGateWay
{
    //同步当前场景给网关
    DebugLog(@"\n\n\n==============================syncCurrentSceneToGateWay\n\n");
    PLSceneModel *currentScene = [[PLSceneManager sharedManager] currentScene];
    DebugLog(@"%@",currentScene.strSecenName);
    NSArray *lightsArray = [[PLSceneManager sharedManager] queryAllLightsWithSceneName:currentScene.strSecenName];
    int scenceindex;
    if ([currentScene.strSecenName isEqualToString:@"Relax"]) {
        scenceindex =1;
    }else if ([currentScene.strSecenName isEqualToString:@"Read"]){
        scenceindex =2;
    }else if ([currentScene.strSecenName isEqualToString:@"TreePimay"]){
        scenceindex =3;
    }else{
        scenceindex = currentScene.sceneIndex;
    }
    [[PLNetworkManager sharedManager] sceneControlWithType:RecallSceneType
                                               SceneNumber:scenceindex
                                                   GroupID:0
                                                 LightsArr:lightsArray
                                                 SceneName:currentScene.strSecenName];
}


@end