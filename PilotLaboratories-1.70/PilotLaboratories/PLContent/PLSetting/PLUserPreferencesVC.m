//
//  PLUserPreferencesVC.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-8.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLUserPreferencesVC.h"
#import <MessageUI/MessageUI.h>
#import "PLNotiAndAlerts.h"

#define BothConnect @"continue"
#define DisableOne @"disable"

@interface PLUserPreferencesVC ()<MFMailComposeViewControllerDelegate,PLNotiAndAlertsDelegate>

@property (strong, nonatomic) IBOutlet UILabel *labelEmail;
@property (strong, nonatomic) UIAlertView *alter;
//@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelEmaiMain;
@property (strong, nonatomic) IBOutlet UILabel *labelRecover;
@property (copy, nonatomic) NSString *toChangeEmail;
@property (copy, nonatomic) NSString *toChangePW;
@property (strong, nonatomic) NSData *dataPsw;
@property (copy, nonatomic) NSString *strRemberPsw;

@property (strong, nonatomic) IBOutlet UILabel *labelSmallTitle;
@end

@implementation PLUserPreferencesVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.labelSmallTitle.text = NSLocalizedString(@"User Email", nil);
    
    DebugLog(@"labelTitle ====== %@",self.labelSmallTitle.text);
    self.labelEmaiMain.text = NSLocalizedString(@"Email -", nil);
    self.labelRecover.text = NSLocalizedString(@"Recover Password", nil);
    
    if (IS_IPHONE5)
    {
        self.labelSmallTitle.font = fontCustom(15);
        self.labelEmail.font = fontCustom(15);
        self.labelEmaiMain.font = fontCustom(15);
        self.labelRecover.font = fontCustom(15);
    }
    else
    {
        self.labelSmallTitle.font = fontCustom(15);
        self.labelEmail.font = fontCustom(15);
        self.labelEmaiMain.font = fontCustom(15);
        self.labelRecover.font = fontCustom(15);
    }
    
    self.labelEmail.text = [NSString stringWithFormat:@"%@",[[PLUserInfoManager sharedManager] userCredentialStr]];
    
    
    //用户信息唯一
    [[NSNotificationCenter defaultCenter] addObserverForName:TempUserCredentialIsUnique
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      HideHUD;
                                                      [[PLUserInfoManager sharedManager] setTempUserCredentialStr:nil];
                                                      [[PLUserInfoManager sharedManager] setTempPasswordStr:nil];
                                                      [[PLUserInfoManager sharedManager] setUserCredentialStr:self.toChangeEmail];
                                                      [[PLUserInfoManager sharedManager] setPasswordStr:self.toChangePW];
                                                      self.labelEmail.text = self.toChangeEmail;
                                                  }];
    //用户信息已经存在
    [[NSNotificationCenter defaultCenter] addObserverForName:TempUserCredentialHasAlreadyExist
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      HideHUD;
                                                      PLModel_CheckResult *result = note.object;
                                                      NSData *dataPsw = result.password;
                                                      
                                                      self.dataPsw = dataPsw;
                                                      
                                                      NSString *strPsw = [[NSString alloc] initWithData:dataPsw encoding:NSUTF8StringEncoding];
                                                      self.strRemberPsw = strPsw;
                                                      
                                                      CGRect frame = [UIScreen mainScreen].bounds;
                                                      PLNotiAndAlerts *notiAndalert = [PLNotiAndAlerts new];
                                                      notiAndalert.frame = frame;
                                                      notiAndalert.arrGateways = @[BothConnect,DisableOne];
                                                      notiAndalert.delegate =self;
                                                      
                                                      [notiAndalert show];
                                                  }];
    
    //发送UserCredentialGM给网关成功
    [[NSNotificationCenter defaultCenter] addObserverForName:DidSendUserCredentialGM
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      HideHUD;
                                                      [[PLUserInfoManager sharedManager] setTempUserCredentialStr:nil];
                                                      [[PLUserInfoManager sharedManager] setTempPasswordStr:nil];
                                                  }];
}

#pragma mark - PLNotiAndAlerts delegate 用户信息已经存在 -
- (void)cellOnWifiDidSelected:(NSString *)notiFrom withView:(PLNotiAndAlerts *)alterView
{
    if ([notiFrom isEqualToString:BothConnect])
    {
        ShowHUD;
        //同意两台同时登陆
        [[PLUserInfoManager sharedManager] setPreviousPasswordData:self.dataPsw];
        [[PLNetworkManager sharedManager] userCredentialGM:YES];
    }
    else
    {
        ShowHUD;
        //只允许一台登陆
        [[PLUserInfoManager sharedManager] setPasswordStr:self.strRemberPsw];
        [[PLNetworkManager sharedManager] userCredentialGM:NO];
    }
    
    [[PLUserInfoManager sharedManager] setUserCredentialStr:self.toChangeEmail];
    self.labelEmail.text = self.toChangeEmail;
    alterView = nil;
}


#pragma mark - 点击修改邮箱 -

- (IBAction)btnEmailPressed:(UIButton *)sender
{
    // 点击修改邮箱
    ;
    _alter = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                        message:NSLocalizedString(@"Please input your Email", nil)
                                       delegate:self
                              cancelButtonTitle:@"NO"
                              otherButtonTitles:@"YES", nil];
    _alter.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textFieldEmail = [_alter textFieldAtIndex:0];
    textFieldEmail.placeholder = NSLocalizedString(@"Please input your Email", nil);
    [_alter show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.alter)
    {
        UITextField *textFieldEmail = [alertView textFieldAtIndex:0];
        if (buttonIndex)
        {
            BOOL isEmail = [self validateEmail:textFieldEmail.text];
            if (isEmail)
            {
                //self.labelEmail.text = textFieldEmail.text;
                if (![textFieldEmail.text isEqualToString:self.labelEmail.text])
                {
                    ShowHUD;
                    self.toChangeEmail = textFieldEmail.text;
                    [[PLUserInfoManager sharedManager] setTempUserCredentialStr:self.toChangeEmail];
                    self.toChangePW = [self randomPassword];
                    [[PLUserInfoManager sharedManager] setTempPasswordStr:self.toChangePW];
                    [[PLNetworkManager sharedManager] checkTempUserCredential];
                }
            }
            else
            {
                UIAlertView *alterSigle = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                                     message:NSLocalizedString(@"Please enter a valid email address", nil)
                                                                    delegate:self
                                                           cancelButtonTitle:@"NO"
                                                           otherButtonTitles:@"YES", nil];
                [alterSigle show];
            }
        }
    }
    else
    {
        if (buttonIndex == 1)
        {
            [self.alter show];
        }
    }
}

#pragma mark - 长生随机密码 -
-(NSString *)randomPassword{
    //自动生成6位随机密码
    NSTimeInterval random=[NSDate timeIntervalSinceReferenceDate];
    DebugLog(@"now:%.6f",random);
    NSString *randomString = [NSString stringWithFormat:@"%.6f",random];
    NSString *randompassword = [[randomString componentsSeparatedByString:@"."]objectAtIndex:1];
    DebugLog(@"randompassword:%@",randompassword);
    return randompassword;
}

#pragma mark - 判断是否为正确的邮箱 -

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

#pragma mark - 发送密码到邮箱里 -

- (IBAction)btnSendPSWToEmailPressed:(id)sender
{
//    [self alertWithMessage:@"This feature has not yet been developed"];
    
//    [self sendMailInApp];
}

//激活邮件功能
- (void)sendMailInApp
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        [self alertWithMessage:@"当前系统版本不支持应用内发送邮件功能，您可以使用mailto方法代替"];
        return;
    }
    if (![mailClass canSendMail]) {
        [self alertWithMessage:@"用户没有设置邮件账户"];
        return;
    }
    [self displayMailPicker];
}

//调出邮件发送窗口
- (void)displayMailPicker
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"eMail主题"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: @"240454168@qq.com"];
    [mailPicker setToRecipients: toRecipients];

//    //添加抄送
//    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
//    [mailPicker setCcRecipients:ccRecipients];
//    //添加密送
//    NSArray *bccRecipients = [NSArray arrayWithObjects:@"fourth@example.com", nil];
//    [mailPicker setBccRecipients:bccRecipients];
    
//    // 添加一张图片
//    UIImage *addPic = [UIImage imageNamed: @"Icon@2x.png"];
//    NSData *imageData = UIImagePNGRepresentation(addPic);            // png
//    //关于mimeType：http://www.iana.org/assignments/media-types/index.html
//    [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"Icon.png"];
    
    //添加一个pdf附件
//    NSString *file = [self fullBundlePathFromRelativePath:@"高质量C++编程指南.pdf"];
//    NSData *pdf = [NSData dataWithContentsOfFile:file];
//    [mailPicker addAttachmentData: pdf mimeType: @"" fileName: @"高质量C++编程指南.pdf"];
//    
    NSString *emailBody = @"<font color='red'>eMail</font> 正文";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    [self presentViewController:mailPicker animated:YES completion:nil];
}

#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"用户取消编辑邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"用户成功保存邮件";
            break;
        case MFMailComposeResultSent:
            msg = @"用户点击发送";
            break;
        case MFMailComposeResultFailed:
            msg = @"用户试图保存或者发送邮件失败";
            break;
        default:
            msg = @"";
            break;
    }
    [self alertWithMessage:msg];
}

- (void)alertWithMessage:(NSString *)string
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:WarmPrompt
                                                    message:string
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alter show];
    
}

- (IBAction)btnBackPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
