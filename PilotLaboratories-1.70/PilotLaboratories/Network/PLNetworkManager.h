//
//  PLNetworkManager.h
//  PilotLaboratories
//
//  Created by 付亚明 on 3/27/14.
//  Copyright (c) 2014 yct. All rights reserved.
//



/*
 域名：cloud01.pilot-lab.com
 IP1：64.87.28.185
 IP2: 72.10.222.53
 IP3: 64.246.140.180
 IP4: 64.246.152.37
 port：9250
 */

#define UDPDiscoveryGetwayPort                  4156
#define GateWayPort                             1234
//"182.254.192.44"
//"119.29.37.38"
//"cloud02cn.pilot-lab.com.cn"
//"cloud01.pilot-lab.com"
#define DefaultChineseCloudServerAddress        @"cloud02cn.pilot-lab.com.cn"
#define DefaultEnglishCloudServerAddress        @"cloud01.pilot-lab.com"
#define CloudServerPort                         9250
#define CheckDeviceListTime                     8


#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "PLModel_Device.h"
#import "PLModel_Group.h"
#import "PLModel_CheckResult.h"
#import "PLModel_SecurityStateResult.h"
#import "PLUserInfoManager.h"

//IP Package format
#define PackageStart                                0xFE
#define RequestStart                                0x00
#define ResponseStart                               0x01
#define PackageEnd                                  0xFF

//CommondID
//Common
#define DeviceSwitchCommondID                       0x0000
#define DeviceDiscoveryCommondID                    0x0001
#define CheckDeviceStatusCommondID                  0x0002
#define JoinNetworkCommondID                        0x0003
#define LightsDimCommondID                          0x0004
#define LightsColorCommondID                        0x0005
#define LightsNormalCommondID                       0x0006
#define GetAlarmInfoCommondID                       0x0007
#define LightsRemoveCommondID                       0x0008
#define LightsIdentifyCommondID                     0x0009
#define GroupSetupCommondID                         0x000A
#define GroupConfigCommondID                        0x000B
#define GroupQueryCommondID                         0x000C
#define AlarmInformCommondID                        0x000D
#define GatewayCommondID                            0x000E
#define IPSetCommondID                              0x000F
#define SecurityStateSelectCommandID                0x0013
#define ResetOrRebootCommandID                      0x0015
#define SecurityStateRequestCommandID               0x0016
#define GateWayCurrentVersionCommandID              0x0019
#define SceneControlCommandID                       0x001A
#define EnableAlarmGWCommandID                      0x001D

//Gateway-Mobile
#define CredentialAskCommondID                      0x0010
#define CIDAskCommondID                             0x0011
#define UserCredentialGMCommandID                   0x0012
#define CheckUserCredentialCommandID                0x0014
#define MobileDeviceInfoCommandID                   0x0018


//CloudServer-Mobile
#define CredentialSendCommondID                     0x0201
#define GatewayChooseCommondID                      0x0202
#define SendUserCredentialToCloudServerCommandID    0x0203
#define DeviceTokenSendCommandID                    0x0204
#define LastestVersionCommandID                     0x0205
#define Deltokenbind                                0x0209
#define ConcatenatedPacketCommandID                 0xE000
#define StartUpDateCommandId                        0x001B

//DeviceSwitchStatus
#define DeviceSwitchOnStatua                        0x01
#define DeviceSwitchOffStatua                       0x00

//ServerType
typedef NS_ENUM (NSInteger,ServerType)
{
    NoneServerType = 0,
    CloudServerType,
    GatewayType,
};

//GroupConfigType
typedef NS_ENUM (NSInteger,GroupConfigType)
{
    ParaType = 0,
    AddMembersType,
    RemoveMembersType,
};

//SecurityStateType
typedef NS_ENUM (NSInteger,SecurityStateType)
{
    AwayArmType = 0x01,
    HomeArmType = 0x02,
    DisArmType = 0x03,
};

//ResetRebootType
typedef NS_ENUM (NSInteger,ResetRebootType)
{
    RebootGatewayType = 0x01,
    ResetGatewayType = 0x02,
    ResetDeviceType = 0x03,
};

//SceneControlType
typedef NS_ENUM (NSInteger, SceneControlType)
{
    StoreSceneType = 0x01,
    RecallSceneType = 0x02,
    TurnSceneDevicesOffType = 0x03,
    RemoveSceneType = 0x04,
    RemoveAllScenesType = 0x05
};


@interface PLNetworkManager : NSObject

//当前网络状态（联网方式）
@property (assign, nonatomic, readonly) NetworkStatus currentNetworkStatus;

//当前连接的服务器类型
@property (assign, nonatomic, readonly) ServerType currentServerType;

//CloudServer地址
@property (copy, nonatomic) NSString *cloudServerAddress;

//当前手机连接的Wifi Name
@property (copy, nonatomic, readonly) NSString *currentConnectWifiName;

//当前发现的所有网关
@property (strong, nonatomic, readonly) NSMutableArray *allGatewayArr;

//是否连接上网关
@property (assign, nonatomic, readonly) BOOL connectedWithGateway;

//当前连接网关IP
@property (strong, nonatomic, readonly) NSString *currentConnectedGatewayIP;

//当前连接网关的CID
@property (strong, nonatomic, readonly) NSData *currentConnectedGatewayCID;

//所有连接过的网关所在的Wifi（Name）
@property (strong, nonatomic, readonly) NSMutableArray *connectedWifiArr;

//所有连接过的网关信息
//Wifi Name为Key 网关IP地址列表(数组)为Value
@property (strong, nonatomic, readonly) NSMutableDictionary *gateWayInfoDict;

//所有连接过的网关的Credential
@property (strong, nonatomic, readonly) NSMutableArray *gatewayCredentialArr;
//当前的网关的Credential
@property (strong, nonatomic) NSData *gatewayCredential;

//All Devices Arr
@property (strong, nonatomic,readonly) NSMutableArray *allDeviceArr;

//Lights Arr
@property (strong, nonatomic, readonly) NSMutableArray *lightsArr;

//Sensor Arr
@property (strong, nonatomic, readonly) NSMutableArray *sensorArr;

//Switch Arr
@property (strong, nonatomic, readonly) NSMutableArray *switchArr;
@property(assign,nonatomic)BOOL isconnectcloundforupdate;
+ (id)sharedManager;



//开启测试模式,没连接网关情况下虚拟灯泡
- (void)startTestModel;

//
- (NSString *)cloudServerAddress;

//开始检测网络状态
- (void)startCheckNetWork;

//获取到网关列表
#define DidDiscoveryGateway             @"DidDiscoveryGateway"
//开始搜索网关
- (void)startDiscoveryGetway;

//停止搜索网关
- (void)stopDiscoveryGetway;

//连接到网关
#define DidConnectedToGateway           @"DidConnectedToGateway"
//连接网关
- (BOOL)connectToGetwayWithIPAddress:(NSString *)IPAddress;

//连接到CloudServer
#define DidConnectedToCloudServer       @"DidConnectedToCloudServer"
#define DidConnectedToCloudServerForUpDate       @"DidConnectedToCloudServerFOrUpDate"
//连接CloudServer
- (BOOL)connectToCloudServer;

//断开网关、CloudServer连接
- (void)disConnectToGetway;

//开始每隔CheckDeviceListTime秒查询一次设备列表
- (void)startCheckDeviceList;

//停止查询设备列表
- (void)stopCheckDeviceList;

//连接上网关时保存手机当前连接的wifi Name以及连接上的网关的IP地址
- (void)saveWifiNameAndGateWayIPAddress;

//保存device token
- (void)saveDeviceTocken:(NSData *)deviceToken;

//发送device token给cloudserver
- (void)sendDeviceTokenToCloudServer;



//1.
//改变灯泡开关失败
#define DeviceSwitchError                @"DeviceSwitchError"
//lightsSwitch打开或关闭某一个灯泡开关
- (void)lightSwitchWithLight:(PLModel_Device *)light switchOn:(BOOL)switchOn;
//lightsSwitch打开或关闭某一组灯泡开关
- (void)lightSwitchWithLightsList:(NSArray *)lightsArr switchOn:(BOOL)switchOn;
//打开或关闭所有的灯或者开关
- (void)deviceSwitchWithDeviceType:(DeviceType)deviceType switchOn:(BOOL)switchOn;


//2.
//从网关上获取到设备列表
#define DidDiscoveryDevice               @"DidDiscoveryDevice"
//DeviceDiscovery发现设备
- (void)deviceDiscovery;


//3.
//获取到设备状态
#define DidRefreshDeviceStatus           @"DidRefreshDeviceStatus"
//CheckDeviceStatus查询一台设备状态
- (void)checkDeviceStatuswithDoor;
- (void)checkDeviceStatuswithSwitch;
- (void)checkDeviceStatus:(PLModel_Device *)device;
//CheckDeviceStatus查询一组设备状态
- (void)checkDeviceStatusWithDeviceList:(NSArray *)deviceArr;


//4.
//获取到新入网设备
#define NewDeviceDiscovery               @"NewDeviceDiscovery"
//newDeviceDiscovery新设备入网
- (void)newDeviceDiscovery;


//5.
//改变灯泡亮度失败
#define LightsDimError                   @"LightsDimError"
//lightsDim调节单个灯泡亮度 level 1-16
- (void)changeLightsDimWithLight:(PLModel_Device *)light level:(int)level;
//lightsDim调节一组灯泡亮度 level 1-16
- (void)changeLightsDimWithLightsList:(NSArray *)lightsArr level:(int)level;


//6.
//改变灯泡颜色成功
#define LightsColorSucceed               @"LightsColorSucceed"
//改变灯泡颜色失败
#define LightsColorFailed                @"LightsColorFailed"
//lightsColor调节单个灯泡颜色
- (void)changeLightsColorWithLight:(PLModel_Device *)light
                            colorR:(int)colorR
                            colorG:(int)colorG
                            colorB:(int)colorB;
//lightsColor调节一组灯泡颜色
- (void)changeLightsColorWithLightsList:(NSArray *)lightsArr
                                 colorR:(int)colorR
                                 colorG:(int)colorG
                                 colorB:(int)colorB;


//7.
//恢复灯泡状态成功
#define LightsNormalSucceed              @"LightsNormalSucceed"
//恢复灯泡状态失败
#define LightsNormalFailed               @"LightsNormalFailed"
//lightsNormal调整单个灯泡到正常状态
- (void)moveLightsToNormalWithLight:(PLModel_Device *)light;
//lightsNormal调整一组灯泡到正常状态
- (void)moveLightsToNormalWithLightsList:(NSArray *)lightsArr;


//9.
//移除灯泡成功
#define LightsRemoveSucceed              @"LightsRemoveSucceed"
//移除灯泡失败
#define LightsRemoveFailed               @"LightsRemoveFailed"
//lightsRemove将单个灯泡从网络中移除
- (void)removeLightsWithLight:(PLModel_Device *)light;
//lightsRemove将一组灯泡从网络中移除
- (void)removeLightsWithLightsList:(NSArray *)lightsArr;


//10.
//LightsIdentify发送当前受控灯泡
- (void)lightsIdentifyWithLight:(PLModel_Device *)light;


//11.
//创建分组成功
#define GroupSetupSucceed                @"GroupSetupSucceed"
//创建分组失败
#define GroupSetupFailed                 @"GroupSetupFailed"
//GroupSetup创建分组
- (void)groupSetup:(PLModel_Group *)group;


//12.
//获取凭证组成功
#define DidGetCredential                 @"DidGetCredential"
#define DidGetCredentialWhenCloud        @"DidGetCredentialWhenCloud"
//credentialAsk从网关获取凭证
- (void)credentialAsk;
//保存获取到的网关凭证
- (void)saveGatewayCredential:(NSData *)credentialData;


//13.
//GroupConfig成功
#define GroupConfigSucceed              @"GroupConfigSucceed"
//GroupConfig失败
#define GroupConfigFailed               @"GroupConfigFailed"
//GroupConfig
- (void)groupConfigWithGroup:(PLModel_Group *)group
                  ConfigType:(GroupConfigType)configType
                  LightsList:(NSArray *)lightsArr;


//14.
//查询分组状态成功
#define GroupQuerySucceed               @"GroupQuerySucceed"
//查询分组状态失败
#define GroupQueryFailed                @"GroupQueryFailed"
//GroupQuery查询分组状态
- (void)groupQuery:(PLModel_Group *)group;


//15.
//AlarmInform
//收到报警信息
#define ReceiveAlarmInform              @"ReceiveAlarmInform"


//16.
//UDP Broadcast
//收到UDP Broadcast
#define ReceiveUDPBroadcast             @"ReceiveUDPBroadcast"


//17.
//IP地址设置成功
#define SetGetwayIPSucceed              @"SetGetwayIPSucceed"
//IP地址设置失败
#define SetGetwayIPFailed               @"SetGetwayIPFailed"
//设置网关IP
- (void)setGetwayIP:(NSString *)ipString;


//18.
//CredentialAsk 同12


//19.
//接收到CredentialSendResponse
#define ReceiveCredentialSendResponse   @"ReceiveCredentialSendResponse"
//CredentialSend
- (void)credentialSend;


//20.
//GatewayChoose选择网关
- (void)gatewayChooseWithGatewayID:(NSString *)gatewayID;


//21.
//获取CID成功
#define DidGetCID                       @"DidGetCID"
//获取CID
- (void)CIDAsk;


//22.
//接收到网关checkUserName反馈
//用户信息唯一
#define UserCredentialIsUnique          @"UserCredentialIsUnique"
//用户信息已存在
#define UserCredentialHasAlreadyExist   @"UserCredentialHasAlreadyExist"
//发送UserCredential给网关，检查是否已经存在
- (void)checkUserCredential;

//临时用户信息唯一
#define TempUserCredentialIsUnique          @"TempUserCredentialIsUnique"
//临时用户信息已存在
#define TempUserCredentialHasAlreadyExist   @"TempUserCredentialHasAlreadyExist"
//修改邮箱时临时验证使用此方法；
- (void)checkTempUserCredential;


//23.
//发送UserCredential成功
#define DidSendUserCredentialGM         @"DidSendUserCredentialGM"
//发送UserCredentialGM给网关，禁止前一台手机使用或者允许两台手机同时使用
- (void)userCredentialGM:(BOOL)continueToUseBothDevice;




//24.
//发送CellPhoneInfo成功
#define DidSendCellPhoneInfo            @"DidSendCellPhoneInfo"
//第一次连接网关时发送手机信息给网关
- (void)sendCellPhoneInfoToGateWay;


//25.
//选择报警类型成功
#define SecurityStateSelectSucceed      @"SecurityStateSelectSucceed"
//选择所有传感器报警类型
- (void)securityStateSelectWithType:(SecurityStateType)type;
//选择单个传感器报警类型
- (void)securityStateSelectWithType:(SecurityStateType)type Device:(PLModel_Device *)device;


//26.
//重置、重启网关或者设备成功
#define ResetRebootSucceed              @"ResetRebootSucceed"
//重置、重启网关或者设备
- (void)resetOrRebootWithType:(ResetRebootType)type Device:(PLModel_Device *)device;


//27.
//查询安全状态成功,参数object PLModel_SecurityStateResult
#define SecurityStateRequestSucceed     @"SecurityStateRequestSucceed"
//查询安全状态
- (void)securityStateRequest;


//28.
//查询网关当前版本成功，参数NSString 例如：1.1
#define DidGetGatewayCurrentVersion     @"DidGetGatewayCurrentVersion"
//查询网关当前版本
- (void)quaryGatewayCurrentVersion;
#define DidAccpetTotalpage                @"DidAccpetTotalpage"
//更新版本
-(void)startUpdataGwversion;
-(void)GetUpdataGwversionInfo;

//29.
//场景控制成功
#define SceneControlSucceed             @"SceneControlSucceed"
//场景控制失败
#define SceneControlFailed              @"SceneControlFailed"
//场景控制
- (void)sceneControlWithType:(SceneControlType)type
                 SceneNumber:(int)sceneNumber
                     GroupID:(int)groupID
                   LightsArr:(NSArray *)lightsArr
                   SceneName:(NSString *)sceneName;


//30.
//获取CloudServer上Gateway最新版本成功
#define DidGetLastestVersion            @"DidGetLastestVersion"
//获取CloudServer上Gateway最新版本
- (void)getFirmwareVervionStoredInCloud;

-(void)disConnectToClund;
-(BOOL)dismissconnect;



//以下方法仅限当前连接类型是GatewayType时新建socket连接cloudserver发送相关数据调用
- (void)writeDataToCloudServerFORUPDATEWithBurrer:(char *)pBuffer
                                      nBufferSize:(int)nBufferSize
                                         pOutSize:(int)pOutSize;//发给服务器需要再次封装
//创建与CloudServer的连接
- (void)creatSecondConnectToCloudServer;

//发送用户名密码给CloudServer
- (void)sendUserCredentialToCloudServerWhenSecondConnect;

//发送device tocken给CloudServer
- (void)sendDeviceTokenToCloudServerWhenSecondConnect;
#define CredentialSucceed         @"CredentialSucceed"

#define DidDeltokenbind         @"DidDeltokenbind"
//解除推送绑定
- (void)sendDidDeltokenbind;
//删除凭证
- (void)deleteGatewayCredential:(NSData *)credentialData;
//获取版本
- (void)GetLatesVersionWhenSecondConnect;


//31.
#define SwitchSoundSucceed              @"SwitchSoundSucceed"
//屏蔽网关声音开关指令
- (void)switchGatwaySoundwithflag:(BOOL)enabled;








@end
