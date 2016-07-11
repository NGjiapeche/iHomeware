//
//  PLNetworkManager.m
//  PilotLaboratories
//
//  Created by 付亚明 on 3/27/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#define BufferSize 2048
#import "PLAppDelegate.h"
#import "PLNetworkManager.h"
#import "AsyncSocket.h"
#import "AsyncUdpSocket.h"
#import <systemconfiguration/captivenetwork.h>
#import <AVFoundation/AVFoundation.h>

static PLNetworkManager *manager;

@interface PLNetworkManager ()<AsyncUdpSocketDelegate,AsyncSocketDelegate>

@property (strong, nonatomic) Reachability *reachability;
@property (strong, nonatomic) AsyncUdpSocket *udpSocket;
@property (strong, nonatomic) NSTimer *udpTimer;
@property (strong, nonatomic) AsyncSocket *tcpSocket;
@property (strong, nonatomic) NSTimer *tcpTimer;
@property (strong, nonatomic) NSTimer *tcpTimer1;
@property (strong, nonatomic) NSTimer *checkDeviceTimer;
@property (strong, nonatomic) NSTimer *checkDeviceTimer1;

@property (assign, nonatomic) BOOL isSwitchCheck;

@property (assign, nonatomic, readwrite) BOOL connectedWithGateway;
//当前网络状态（联网方式）
@property (assign, nonatomic, readwrite) NetworkStatus currentNetworkStatus;
//当前连接的服务器类型
@property (assign, nonatomic, readwrite) ServerType currentServerType;
//当前发现的所有网关
@property (strong, nonatomic, readwrite) NSMutableArray *allGatewayArr;
//网关IP
@property (strong, nonatomic, readwrite) NSString *currentConnectedGatewayIP;
//当前连接网关的CID
@property (strong, nonatomic, readwrite) NSData *currentConnectedGatewayCID;
//All Devices Arr
@property (strong, nonatomic, readwrite) NSMutableArray *allDeviceArr;
//Lights Arr
@property (strong, nonatomic, readwrite) NSMutableArray *lightsArr;
//Sensor Arr
@property (strong, nonatomic, readwrite) NSMutableArray *sensorArr;
//Switch Arr
@property (strong, nonatomic, readwrite) NSMutableArray *switchArr;
//所有连接过的网关所在的Wifi（Name）
@property (strong, nonatomic, readwrite) NSMutableArray *connectedWifiArr;
//所有连接过的网关信息
//Wifi Name为Key 网关IP地址列表为Value
@property (strong, nonatomic, readwrite) NSMutableDictionary *gateWayInfoDict;
//所有连接过的网关的Credential
@property (strong, nonatomic, readwrite) NSMutableArray *gatewayCredentialArr;
//连接CloudServer时使用，选择的网关的index
@property (assign, nonatomic) int selectedGateWayIndex;
//仅限于当前连接是GatewayType类型时调用
@property (strong, nonatomic) AsyncSocket *secondSocket;
@property(assign,nonatomic)BOOL isdissmissconnect;

@end

@implementation PLNetworkManager

+ (id)sharedManager
{
    @synchronized(self)
    {
        if (!manager)
        {
            manager = [[PLNetworkManager alloc] init];
        }
        
        return manager;
    }
}

//开启测试模式,没连接网关情况下虚拟灯泡
- (void)startTestModel
{
    NSMutableArray *deviceArr = [NSMutableArray new];
    PLModel_Device *light1 = [PLModel_Device new];
    light1.firstShortAddr = 10;
    light1.secondShortAddr = 11;
    light1.deviceType = 0x01;
    light1.colorR = 100;
    light1.colorG = 150;
    light1.colorB = 200;
    light1.Dim = 220;
    light1.onOff = YES;
    light1.macAddress = [[PLDatabaseManager sharedManager] changeMacAddressStringToMacAddress:@"1111111111111111"];
    light1.Dim = 0x0F;
    
    PLModel_Device *light2 = [PLModel_Device new];
    light2.firstShortAddr = 10;
    light2.secondShortAddr = 11;
    light2.deviceType = 0x01;
    light2.colorR = 100;
    light2.colorG = 150;
    light2.colorB = 200;
    light2.Dim = 220;
    light2.onOff = YES;
    light2.macAddress = [[PLDatabaseManager sharedManager] changeMacAddressStringToMacAddress:@"2222222222222222"];
    light2.Dim = 0x0F;
    
    PLModel_Device *light3 = [PLModel_Device new];
    light3.firstShortAddr = 10;
    light3.secondShortAddr = 11;
    light3.deviceType = 0x01;
    light3.colorR = 100;
    light3.colorG = 150;
    light3.colorB = 200;
    light3.Dim = 220;
    light3.onOff = YES;
    light3.macAddress = [[PLDatabaseManager sharedManager] changeMacAddressStringToMacAddress:@"3333333333333333"];
    light3.Dim = 0x0F;
    
    [deviceArr addObject:light1];
    [deviceArr addObject:light2];
    [deviceArr addObject:light3];
    self.lightsArr = deviceArr;
}

- (NSString *)cloudServerAddress
{
    NSString *cloudServerAddr = [[NSUserDefaults standardUserDefaults] objectForKey:@"CloudServerAddress"];
    if (!cloudServerAddr)
    {
        NSArray *arLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        NSString *strLang = [arLanguages objectAtIndex:0];
        float aversion =  [[[UIDevice currentDevice] systemVersion] floatValue];
        if (aversion >= 9.0) {
            if ([strLang isEqualToString:@"en"])
            {
                return DefaultEnglishCloudServerAddress;
            }
            else if ([strLang containsString:@"zh-Hans"] || [strLang containsString:@"zh-Hant"] || [strLang isEqualToString:@"zh-HK"] || [strLang isEqualToString:@"zh-TW"])
            {
                return DefaultChineseCloudServerAddress;
            }
            else
            {
              
                return DefaultEnglishCloudServerAddress;
            }
        }else{
            if ([strLang isEqualToString:@"en"])
            {
               
                return DefaultEnglishCloudServerAddress;
             
            }
            else if ([strLang isEqualToString:@"zh-Hans"] || [strLang isEqualToString:@"zh-Hant"] || [strLang isEqualToString:@"zh-HK"])
            {
            
                return DefaultChineseCloudServerAddress;
            }
            else
            {
                return DefaultEnglishCloudServerAddress;
            }
            
        }
        
    }
    
    return cloudServerAddr;
}

- (void)setCloudServerAddress:(NSString *)cloudServerAddress
{
    if (cloudServerAddress)
    {
        [[NSUserDefaults standardUserDefaults] setObject:cloudServerAddress forKey:@"CloudServerAddress"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//开始检测网络状态
- (void)startCheckNetWork
{
    //self.reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    self.reachability = [Reachability reachabilityForLocalWiFi];
    [self.reachability startNotifier];
}

- (NetworkStatus)currentNetworkStatus
{
    return self.reachability.currentReachabilityStatus;
}

- (void)setAllDeviceArr:(NSMutableArray *)allDeviceArr
{
    _allDeviceArr = allDeviceArr;
    
    if (!self.lightsArr)
    {
        _lightsArr = [NSMutableArray new];
    }
    
    if (!self.sensorArr)
    {
        _sensorArr = [NSMutableArray new];
    }
    
    if (!self.switchArr)
    {
        _switchArr = [NSMutableArray new];
    }
    
    [self.lightsArr removeAllObjects];
    [self.sensorArr removeAllObjects];
    [self.switchArr removeAllObjects];
    
    for (PLModel_Device *device in allDeviceArr)
    {
           if (device.deviceType == LightType)
        {
            //device.onOff = 0x00;
            [self.lightsArr addObject:device];
        }
        else if (device.deviceType == TemperatureSensorType || device.deviceType == DoorSensorType || device.deviceType == PirSensorType || device.deviceType == GravitySensorType || device.deviceType == VibrationSensorType || device.deviceType == WaterSensorType || device.deviceType == PanicSensorType || device.deviceType == SmokeSensorType || device.deviceType == CO2SenserType || device.deviceType == COSenserType || device.deviceType == Becon || device.deviceType == WebcamTy)
        {
            [self.sensorArr addObject:device];
        }
        else if (device.deviceType == SwitchType)
        {
            [self.switchArr addObject:device];
        }
    }
}

#pragma mark - startDiscoveryGetway 开始搜索网关

- (void)startDiscoveryGetway
{
    DebugLog(@"startDiscoveryGateway");
    _udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    if ([self.udpSocket bindToPort:UDPDiscoveryGetwayPort error:nil])
    {
        [self.udpSocket receiveWithTimeout:-1 tag:0];
        self.udpTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(checkUDPResponse)
                                                       userInfo:nil
                                                        repeats:YES];
    }
    else
    {
        DebugLog(@"DiscoveryGatewayError");
    }
}

#pragma mark - stopDiscoveryGetway 停止搜索网关

- (void)stopDiscoveryGetway
{
    DebugLog(@"stopDiscoveryGateway");
    [self.udpSocket setDelegate:nil];
    [self.udpSocket close];
    [self.udpTimer invalidate];
    [self setUdpTimer:nil];
}

#pragma mark - connectToGetway 连接网关

- (BOOL)connectToGetwayWithIPAddress:(NSString *)IPAddress
{
    if (IPAddress)
    {
        [self disConnectToGetway];
        DebugLog(@"ConnectToGateway:%@",IPAddress);
        _tcpSocket = [[AsyncSocket alloc] initWithDelegate:self];
        if ([self.tcpSocket connectToHost:IPAddress onPort:GateWayPort error:nil])
        {
            self.currentConnectedGatewayIP = IPAddress;
            self.currentServerType = GatewayType;
            self.tcpTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkTCPResponse) userInfo:nil repeats:YES];
            return YES;
        }
        else
        {
            self.currentConnectedGatewayIP = nil;
            self.currentServerType = NoneServerType;
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

#pragma mark - connectToCloudServer 连接CloudServer

- (BOOL)connectToCloudServer
{
    [self disConnectToGetway];
    _tcpSocket = [[AsyncSocket alloc] initWithDelegate:self];
    NSString *clouldServerAddress;
    if (self.cloudServerAddress)
    {
        clouldServerAddress = self.cloudServerAddress;
    }
    else
    {
        clouldServerAddress = [[PLNetworkManager sharedManager] cloudServerAddress];
    }
    
    DebugLog(@"ConnectToCloudServer:%@",clouldServerAddress);
    
    if ([self.tcpSocket connectToHost:clouldServerAddress onPort:CloudServerPort error:nil])
    {
        self.currentConnectedGatewayIP = clouldServerAddress;
        self.currentServerType = CloudServerType;
        self.tcpTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkTCPResponse) userInfo:nil repeats:YES];
        return YES;
    }
    else
    {
        self.currentConnectedGatewayIP = nil;
        self.currentServerType = NoneServerType;
        return NO;
    }
}

#pragma mark - disConnectToGetway 断开网关连接

- (void)disConnectToGetway
{
    if (self.tcpSocket)
    {
        DebugLog(@"DisConnectToGateway:%@",self.currentConnectedGatewayIP);
        [self stopCheckDeviceList];
        [self.tcpSocket disconnect];
        self.tcpSocket            = nil;
        [self.tcpTimer invalidate];
        [self setTcpTimer:nil];
        self.connectedWithGateway = NO;
        //        self.currentConnectedGatewayIP = nil;
        //        self.currentServerType = NoneServerType;
    }
}
#pragma mark - disConnectToGetway 检测版本更新后断开服务器连接
-(void)disConnectToClund{
    if (self.secondSocket) {
        DebugLog(@"DisConnectWIthCloundForUpdata");
        [self.secondSocket disconnect];
        self.secondSocket = nil;
        [self.tcpTimer1 invalidate];
        self.tcpTimer1 = nil;
        _isdissmissconnect = YES;
    }
}
-(BOOL)dismissconnect
{
    return _isdissmissconnect;
}
#pragma mark - startCheckDeviceList

- (void)startCheckDeviceList
{
    self.checkDeviceTimer = [NSTimer scheduledTimerWithTimeInterval:CheckDeviceListTime target:self selector:@selector(deviceDiscovery) userInfo:nil repeats:YES];
    [self.checkDeviceTimer fire];
   
   
}
#pragma mark - stopCheckDeviceList

- (void)stopCheckDeviceList
{
    if (self.checkDeviceTimer)
    {
        [self.checkDeviceTimer invalidate];
        [self setCheckDeviceTimer:nil];
    }
}


#pragma mark - writeDataToGateway 发送数据到网关

- (void)writeDataToGatewayWithBurrer:(char *)pBuffer
                         nBufferSize:(int)nBufferSize
                            pOutSize:(int)pOutSize
{
    NSData *toWriteData = [NSData dataWithBytes:pBuffer length:pOutSize];
    DebugLog(@"\n\nwriteDataToGateway:\n\n%@\n\n",toWriteData);
    [self.tcpSocket writeData:toWriteData withTimeout:-1 tag:0];
}


#pragma mark - writeDataToCloudServer 发送数据到CloudServer

- (void)writeDataToCloudServerWithBurrer:(char *)pBuffer
                             nBufferSize:(int)nBufferSize
                                pOutSize:(int)pOutSize
{
    //70 bytes userCredential + 12 bytes gatewayCredential + length of command packet payload
    char buffer[BufferSize];
    int bufferSize = BufferSize;
    int outSize = 0;
    char data[70 + 12 + pOutSize];
    char *pWrite = data;
    
    //userCredential
    NSData *userCredentialData = [[PLUserInfoManager sharedManager] userCredentialData];
    char *userCredential = (char *)[userCredentialData bytes];
    memcpy(pWrite, userCredential, userCredentialData.length);
    pWrite = pWrite + userCredentialData.length;
    
    NSData *passwordData = [[PLUserInfoManager sharedManager] passwordData];
    char *password = (char *)[passwordData bytes];
    memcpy(pWrite, password, passwordData.length);
    pWrite = pWrite + passwordData.length;
    
    //gatewayCredential
    if (self.gatewayCredentialArr.count > self.selectedGateWayIndex)
    {
        NSData *gatewayCredentialData = self.gatewayCredentialArr[self.selectedGateWayIndex];
        char *gatewayCredential = (char *)[gatewayCredentialData bytes];
        memcpy(pWrite, gatewayCredential, gatewayCredentialData.length);
        pWrite = pWrite + gatewayCredentialData.length;
    }
    
    //packet payload
    memcpy(pWrite, pBuffer, pOutSize);
    pWrite = pWrite + pOutSize;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:bufferSize
                               pOutSize:&outSize
                              CommandID:ConcatenatedPacketCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    [self writeDataToGatewayWithBurrer:buffer nBufferSize:bufferSize pOutSize:outSize];
}
- (void)writeDataToCloudServerFORUPDATEWithBurrer:(char *)pBuffer
                             nBufferSize:(int)nBufferSize
                                         pOutSize:(int)pOutSize{
    //70 bytes userCredential + 12 bytes gatewayCredential + length of command packet payload
    char buffer[BufferSize];
    int bufferSize = BufferSize;
    int outSize = 0;
    char data[70 + 12 + pOutSize];
    char *pWrite = data;
    
    //userCredential
    NSData *userCredentialData = [[PLUserInfoManager sharedManager] userCredentialData];
    char *userCredential = (char *)[userCredentialData bytes];
    memcpy(pWrite, userCredential, userCredentialData.length);
    pWrite = pWrite + userCredentialData.length;
    
    NSData *passwordData = [[PLUserInfoManager sharedManager] passwordData];
    char *password = (char *)[passwordData bytes];
    memcpy(pWrite, password, passwordData.length);
    pWrite = pWrite + passwordData.length;
    
    //gatewayCredential
    if (self.gatewayCredentialArr.count > self.selectedGateWayIndex)
    {
        NSData *gatewayCredentialData = self.gatewayCredentialArr[self.selectedGateWayIndex];
        DebugLog(@"gatewayCredential =========== %@",gatewayCredentialData);
        char *gatewayCredential = (char *)[gatewayCredentialData bytes];
        memcpy(pWrite, gatewayCredential, gatewayCredentialData.length);
        pWrite = pWrite + gatewayCredentialData.length;
    }
    
    //packet payload
    memcpy(pWrite, pBuffer, pOutSize);
    pWrite = pWrite + pOutSize;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:bufferSize
                               pOutSize:&outSize
                              CommandID:ConcatenatedPacketCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    NSData *toWriteData = [NSData dataWithBytes:buffer length:pOutSize];
    [self.secondSocket writeData:toWriteData withTimeout:-1 tag:0];
    DebugLog(@"\n\nUPDateVersionCloudServer:\n\n%@\n\n",toWriteData);
}

#pragma mark - Send Command to Getway
//  数据解析发给网关
- (void)getCommandToGatewayWithBurrer:(char *)pBuffer
                          nBufferSize:(int)nBufferSize
                             pOutSize:(int *)pOutSize
                            CommandID:(int)commandID
                               Length:(int)length
                           ListLength:(char)listLength
                                pData:(char *)pData
{
    int nWriteBytes = 0;
    char *pWrite = pBuffer;
    
    //PackageStart 0xFE 1Byte
    char packageStart = PackageStart;
    memcpy(pWrite,&packageStart, 1);
    pWrite++;
    nWriteBytes++;
    
    //RequestStart 0x00 1Byte
    char requestStart = RequestStart;
    memcpy(pWrite, &requestStart, 1);
    pWrite++;
    nWriteBytes++;
    
    //CommondID 2Byte
    char firstCommondID = (char)(commandID / 256);
    memcpy(pWrite, &firstCommondID, 1);
    pWrite++;
    nWriteBytes++;
    char secondCommondID = (char)(commandID % 256);
    memcpy(pWrite, &secondCommondID, 1);
    pWrite++;
    nWriteBytes++;
    
    //Length 2Byte
    memset(pWrite, (length / 256), 1);
    pWrite++;
    nWriteBytes++;
    memset(pWrite, (length % 256), 1);
    pWrite++;
    nWriteBytes++;
    
    //ListLength 2Byte
    memset(pWrite, 0, 1);
    pWrite++;
    nWriteBytes++;
    memcpy(pWrite, &listLength, 1);
    pWrite++;
    nWriteBytes++;
    
    //Data And FCS
    //FCS 1Byte
    char FCS = *(pBuffer + 2) ^ *(pBuffer + 3);
    for (int i = 4; i < nWriteBytes; i++)
    {
        FCS = FCS ^ *(pBuffer + i);
    }
    
    if (pData)
    {
        memcpy(pWrite, pData, length);
        pWrite += length;
        nWriteBytes += length;
        
        for (int i = 0; i < length; i++)
        {
            FCS = FCS ^ *pData;
            memcpy(pWrite, &pData, 1);
            pData++;
        }
    }
    
    memcpy(pWrite, &FCS, 1);
    pWrite++;
    nWriteBytes++;
    
    //END 2Byte
    char packageEnd = PackageEnd;
    memset(pWrite, 0, 1);
    pWrite++;
    nWriteBytes++;
    memcpy(pWrite, &packageEnd, 1);
    pWrite++;
    nWriteBytes++;
    
    if (pOutSize)
    {
        *pOutSize = nWriteBytes;
    }
}

#pragma mark - parserGetwayIPAddress 解析网关ip地址列表

- (NSArray *)parserGetwayIPAddressWithData:(NSData *)data
{
    NSUInteger nLen = [data length];
    char *pData = (char *)[data bytes];
    
    if(nLen > 0 && pData)
    {
        UInt8 packageStart = *pData++;
        UInt8 responseStart = *pData++;
        if (packageStart == PackageStart && responseStart == ResponseStart)
        {
            //CommandID
            char subCommandID1 = *pData++;
            char subCommandID2 = *pData++;
            char commandID = subCommandID1 * 16 + subCommandID2;
            //Length
            char subLength1 = *pData++;
            char subLength2 = *pData++;
            char length = subLength1 * 16 + subLength2;
            //ListLength
            char subListLength1 = *pData++;
            char subListLength2 = *pData++;
            char listLength = subListLength1 * 16 + subListLength2;
            
            if (commandID == GatewayCommondID)
            {
                if (!self.allGatewayArr)
                {
                    _allGatewayArr = [NSMutableArray new];
                }
                if (listLength == 0x00)
                {
                    unsigned char firstIP = *pData++;
                    unsigned char secondIP = *pData++;
                    unsigned char thirdIP = *pData++;
                    unsigned char forthIP = *pData++;
                    NSString *gatewayIP = [NSString stringWithFormat:@"%d.%d.%d.%d",firstIP,secondIP,thirdIP,forthIP];
                    DebugLog(@"DidDiscoveryGateway:%@",gatewayIP);
                    if (![self.allGatewayArr containsObject:gatewayIP])
                    {
                        [self.allGatewayArr addObject:gatewayIP];
                    }
                }
                else
                {
                    for (int i = 0; i < listLength; i++)
                    {
                        unsigned char firstIP = *pData++;
                        unsigned char secondIP = *pData++;
                        unsigned char thirdIP = *pData++;
                        unsigned char forthIP = *pData++;
                        pData++;
                        NSString *gatewayIP = [NSString stringWithFormat:@"%d.%d.%d.%d",firstIP,secondIP,thirdIP,forthIP];
                        DebugLog(@"DidDiscoveryGateway:%@",gatewayIP);
                        if (![self.allGatewayArr containsObject:gatewayIP])
                        {
                            [self.allGatewayArr addObject:gatewayIP];
                        }
                    }
                }
            }
            
            if (self.allGatewayArr.count)
            {
                DebugLog(@"DidDiscoveryGatewayEnd");
                [[NSNotificationCenter defaultCenter] postNotificationName:DidDiscoveryGateway object:self.allGatewayArr];
                return self.allGatewayArr;
            }
        }
    }
    
    return nil;
}

#pragma mark - lightSwitchWithLight 打开或关闭某一个灯泡开关

- (void)lightSwitchWithLight:(PLModel_Device *)light switchOn:(BOOL)switchOn
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    char data[4];
    char *pWrite = data;
    
    //Flag
    char flag;
    if (switchOn)
    {
        flag = DeviceSwitchOnStatua;
    }
    else
    {
        flag = DeviceSwitchOffStatua;
    }
    memcpy(pWrite, &flag, 1);
    pWrite++;
    
    //Short addr
    char firstShortAddr = light.firstShortAddr;
    memcpy(pWrite, &firstShortAddr, 1);
    pWrite++;
    char secondShortAddr = light.secondShortAddr;
    memcpy(pWrite, &secondShortAddr, 1);
    pWrite++;
    
    //DeviceType
    char deviceType = 0;
    if (light.deviceType != LightType)
    {
        deviceType = 1;
    }
    memcpy(pWrite, &deviceType, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x01;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:DeviceSwitchCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - lightSwitchWithLightsList 打开或关闭某一组灯泡开关

- (void)lightSwitchWithLightsList:(NSArray *)lightsArr switchOn:(BOOL)switchOn
{
    //    for (PLModel_Device *light in lightsArr)
    //    {
    //        [self lightSwitchWithLight:light switchOn:switchOn];
    //    }
    
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[1 + 2 * lightsArr.count + 1];
    char *pWrite = data;
    
    //Flag
    char flag;
    if (switchOn)
    {
        flag = DeviceSwitchOnStatua;
    }
    else
    {
        flag = DeviceSwitchOffStatua;
    }
    memcpy(pWrite, &flag, 1);
    pWrite++;
    
    //Short addr
    char deviceType = 0;
    for (PLModel_Device *light in lightsArr)
    {
        char firstShortAddr = light.firstShortAddr;
        memcpy(pWrite, &firstShortAddr, 1);
        pWrite++;
        char secondShortAddr = light.secondShortAddr;
        memcpy(pWrite, &secondShortAddr, 1);
        pWrite++;
        if (light.deviceType != LightType)
        {
            deviceType = 1;
        }
    }
    
    //DeviceType
    memcpy(pWrite, &deviceType, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = lightsArr.count;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:DeviceSwitchCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserLightsSwitch

- (NSArray *)parserLightsSwitchWithLength:(int)length
                               ListLength:(int)listLength
                                     Data:(char *)pData
{
    if (length && listLength)
    {
        NSMutableArray *deviceArr = [NSMutableArray new];
        for (int i = 0; i < listLength; i++)
        {
            PLModel_Device *device = [PLModel_Device new];
            //短地址
            device.firstShortAddr = *pData++;
            device.secondShortAddr = *pData++;
            
            [deviceArr addObject:device];
        }
        
        if (deviceArr.count)
        {
            return deviceArr;
        }
    }
    
    return nil;
}

#pragma mark - deviceSwitch 打开或关闭所有的灯或者开关

- (void)deviceSwitchWithDeviceType:(DeviceType)deviceType switchOn:(BOOL)switchOn
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[4];
    char *pWrite = data;
    
    //Flag
    char flag;
    if (switchOn)
    {
        flag = DeviceSwitchOnStatua;
    }
    else
    {
        flag = DeviceSwitchOffStatua;
    }
    memcpy(pWrite, &flag, 1);
    pWrite++;
    
    //Short addr
    char firstShortAddr = 0xFF;
    memcpy(pWrite, &firstShortAddr, 1);
    pWrite++;
    char secondShortAddr = 0xFF;
    memcpy(pWrite, &secondShortAddr, 1);
    pWrite++;
    
    //DeviceType
    char type;
    if (deviceType == LightType)
    {
        type = 0x00;
    }
    else if (deviceType == SwitchType)
    {
        type = 0x01;
    }
    memcpy(pWrite, &type, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:DeviceSwitchCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserDeviceSwitch

- (NSArray *)parserDeviceSwitchWithLength:(int)length
                               ListLength:(int)listLength
                                     Data:(char *)pData
{

    if (length && listLength)
    {
        NSMutableArray *deviceArr = [NSMutableArray new];
        for (int i = 0; i < listLength; i++)
        {
            PLModel_Device *device = [PLModel_Device new];
            //短地址
            device.firstShortAddr = *pData++;
            device.secondShortAddr = *pData++;
            
            [deviceArr addObject:device];
        }
        
        if (deviceArr.count)
        {
            return deviceArr;
        }
    }
    
    return nil;
}

#pragma mark - deviceDiscovery 发现设备

- (void)deviceDiscovery
{
    NSString *strlight =[NSString stringWithFormat:@"%lu",(unsigned long)self.lightsArr.count];
    NSString *strsensor = [NSString stringWithFormat:@"%lu",(unsigned long)self.sensorArr.count];
    NSString *strswitch = [NSString stringWithFormat:@"%lu",(unsigned long)self.switchArr.count];
    NSArray *arr = @[strlight,strsensor,strswitch];

    [[NSNotificationCenter defaultCenter]postNotificationName:@"Thebadgevalue" object:arr];
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Length
    char length = 0x00;
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:DeviceDiscoveryCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:nil];
    
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        NSLog(@"Check Device on");
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    
    //#ifndef __OPTIMIZE__
    //    DebugLog(@"\n\n=====================================测试传感器报警\n\n\n");
    //    //测试传感器报警使用
    //    PLModel_Device *device = [PLModel_Device new];
    //    device.deviceType = DoorSensorType;
    //    char macAddress[] = {18,52,3,0,1,-86,-85,-84,-83,-82,-81,-70,-69};
    //    device.macAddress = [NSData dataWithBytes:macAddress length:8];
    //    device.isAlerting = YES;
    //    [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveAlarmInform object:device];
    //#endif
}

#pragma mark - parserDeviceDiscovery获取的设备信息

- (NSArray *)parserDeviceDiscoveryWithLength:(int)length
                                  ListLength:(int)listLength
                                        Data:(char *)pData
{
  
    
    if (length && listLength)
    {
        NSMutableArray *deviceArr = [NSMutableArray new];
        for (int i = 0; i < listLength; i++)
        {
            PLModel_Device *device = [PLModel_Device new];
            //短地址
            device.firstShortAddr = *pData++;
            device.secondShortAddr = *pData++;
            
            //设备类型
            device.deviceType = *pData++;
            
            //设备Mac地址
            device.macAddress = [NSData dataWithBytes:pData length:8];
            pData = pData + 8;
            
            //信号
            if (length / listLength == 12) {
                device.issi = *pData++;
            }
     
            [deviceArr addObject:device];
        }
        
        if (deviceArr.count)
        {
            return deviceArr;
        }
    }
    
    return nil;
}
#pragma mark - SwicthSound 网关声音开关
- (void)switchGatwaySoundwithflag:(BOOL)enabled{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    char data[5];
    char *pWrite = data;
    char flag;
    if (enabled) {
        flag = 0x00;
    }else{
         flag = 0x01;
    }
    memcpy(pWrite, &flag, 1);
    pWrite++;
    
 
    pWrite++;

    pWrite++;
    pWrite++;
    
    pWrite++;
    //Length
    char length = sizeof(data);
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:EnableAlarmGWCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - CheckDeviceStatus 查询设备状态
- (void)checkDeviceStatuswithDoor{
    NSMutableArray *arr = [NSMutableArray array];
    for (PLModel_Device *device  in self.sensorArr) {
        if (device.deviceType == DoorSensorType) {
            [arr addObject:device];
       
        }
    }
            [self checkDeviceStatusWithDeviceList:arr];
}
- (void)checkDeviceStatuswithSwitch{
    NSMutableArray *arr = [NSMutableArray array];
    for (PLModel_Device *device  in self.switchArr) {
        if (device.deviceType == SwitchType) {
            [arr addObject:device];
            
        }
    }
    [self checkDeviceStatusWithDeviceList:arr];
    
}

- (void)checkDeviceStatus:(PLModel_Device *)device
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    char data[3];
    char *pWrite = data;
    //DeviceType
    char deviceType;
    
    if (device.deviceType == LightType)
    {
        deviceType = 0x01;
    }
    else if (device.deviceType == DoorSensorType)
    {
        deviceType = 0x03;
    }else {
       deviceType = 0x02;
    }
    memcpy(pWrite, &deviceType, 1);
    pWrite++;
    
    //Short addr
    char firstShortAddr = device.firstShortAddr;
    memcpy(pWrite, &firstShortAddr, 1);
    pWrite++;
    char secondShortAddr = device.secondShortAddr;
    memcpy(pWrite, &secondShortAddr, 1);
    pWrite++;
    DebugLog(@"~~%d~~~%d",firstShortAddr,secondShortAddr);
    //Length
    char length = sizeof(data);
    
    //ListLength
    char listLength = 0x01;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:CheckDeviceStatusCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
  
    NSLog(@"%s",buffer);
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
      
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - checkDeviceStatusWithDeviceList 查询一组设备状态

- (void)checkDeviceStatusWithDeviceList:(NSArray *)deviceArr
{
    //    for (PLModel_Device *device in deviceArr)
    //    {
    //        [self checkDeviceStatus:device];
    //    }
    
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[3 * deviceArr.count];
    char *pWrite = data;
    for (PLModel_Device *device in deviceArr)
    {
        //DeviceType
        char deviceType;
        if (device.deviceType == LightType)
        {
            deviceType = 0x01;
        }
        else if (device.deviceType == DoorSensorType)
        {
            deviceType = 0x03;
        }
        else if (device.deviceType == SwitchType)
        {
            deviceType = 0x10;
        }else{
          deviceType = 0x02;
        }
        memcpy(pWrite, &deviceType, 1);
        
        pWrite++;
        
        //Short addr
        char firstShortAddr = device.firstShortAddr;
     
        memcpy(pWrite, &firstShortAddr, 1);
        pWrite++;
        char secondShortAddr = device.secondShortAddr;
        memcpy(pWrite, &secondShortAddr, 1);
        pWrite++;
    }
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = deviceArr.count;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:CheckDeviceStatusCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
//     NSLog(@"查询一组设备状态%s",buffer);
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserCheckDeviceStatus

- (NSArray *)parserCheckDeviceStatusWithLength:(int)length
                                    ListLength:(int)listLength
                                          Data:(char *)pData
{
          PLAppDelegate *myapp =  [[UIApplication sharedApplication]delegate];
    _isSwitchCheck = NO;
    if (length)
    {
        NSMutableArray *deviceArr = [NSMutableArray new];
        for (int i = 0; i < listLength; i++)
        {
            PLModel_Device *device = [PLModel_Device new];
            //短地址
            device.firstShortAddr = *pData++;
            device.secondShortAddr = *pData++;
            
            //comFlag
            device.comFlag = *pData++;
            
            //设备类型
            device.deviceType = *pData++;
            
            //传感器状态
            device.firstSensorStatus = *pData++;
            device.secondSensorStatus = *pData++;
            
            //灯颜色及状态
            device.colorR = *pData++;
            device.colorG = *pData++;
            device.colorB = *pData++;
            device.Dim = *pData++;
            device.onOff = (*pData++ == 0x01 ? YES : NO);
            
            //Mac Address
            NSData *macAddress = [NSData dataWithBytes:pData length:8];
            device.macAddress = macAddress;
            pData = pData + 8;
            
            if (device.Dim <= 0x00 || device.Dim > 0x0F)
            {
                device.Dim = 0x0F;
            }
      
            [deviceArr addObject:device];
            DebugLog(@"type%d,first%d,second%d,mac%@,statu1%d,statu2%d,onoroff :%d",device.deviceType,device.firstShortAddr,device.secondShortAddr,device.macAddress,device.firstSensorStatus,device.secondSensorStatus,device.onOff);
            if (device.deviceType == 0x03 && device.firstSensorStatus == 0x01) {
                [myapp.DoorArray addObject:device];
               
            }
            if (device.deviceType == 0x10 ) {
                if (myapp.SwitchArray < self.switchArr) {
                     [myapp.SwitchArray addObject:device];
                        _isSwitchCheck = YES;
                }
            }
        }
        if (self.isSwitchCheck) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   [[NSNotificationCenter defaultCenter]postNotificationName:@"SwitchRefresh" object:nil];
            });
        }
        if (deviceArr.count)
        {
            
            return deviceArr;
        }
    }
    return nil;
}

#pragma mark - newDeviceDiscovery 新设备入网

- (void)newDeviceDiscovery
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Length
    char length = 0x00;
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:JoinNetworkCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:nil];
    
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserNewDeviceDiscovery

- (NSArray *)parserNewDeviceDiscoveryWithLength:(int)length
                                     ListLength:(int)listLength
                                           Data:(char *)pData
{
    if (length && listLength)
    {
        NSMutableArray *deviceArr = [NSMutableArray new];
        for (int i = 0; i < listLength; i++)
        {
            PLModel_Device *device = [PLModel_Device new];
            //短地址
            device.firstShortAddr = *pData++;
            device.secondShortAddr = *pData++;
            
            //comFlag
            device.comFlag = *pData++;
            
            //设备类型
            device.deviceType = *pData++;
            
            //传感器状态
            device.firstSensorStatus = *pData++;
            device.secondSensorStatus = *pData++;
            
            //灯颜色及状态
            device.colorR = *pData++;
            device.colorG = *pData++;
            device.colorB = *pData++;
            device.Dim = *pData++;
            device.onOff = (*pData++ == 0x01 ? YES : NO);
            
            [deviceArr addObject:device];
        }
        
        if (deviceArr.count)
        {
            return deviceArr;
        }
    }
    
    return nil;
}

#pragma mark - lightsDim调节单个灯泡亮度

- (void)changeLightsDimWithLight:(PLModel_Device *)light level:(int)level
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[4];
    char *pWrite = data;
    
    //level
    memcpy(pWrite, &level, 1);
    pWrite++;
    
    //Short addr
    char firstShortAddr = light.firstShortAddr;
    memcpy(pWrite, &firstShortAddr, 1);
    pWrite++;
    char secondShortAddr = light.secondShortAddr;
    memcpy(pWrite, &secondShortAddr, 1);
    pWrite++;
    
    //nAddr
    char nAddr = 0x01;
    memcpy(pWrite, &nAddr, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x01;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:LightsDimCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - lightsDim 调节一组灯泡亮度

- (void)changeLightsDimWithLightsList:(NSArray *)lightsArr level:(int)level
{
    //    for (PLModel_Device *light in lightsArr)
    //    {
    //        [self changeLightsDimWithLight:light level:level];
    //    }
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[1 + 2 * lightsArr.count];
    char *pWrite = data;
    
    //level
    memcpy(pWrite, &level, 1);
    pWrite++;
    
    //Short addr
    for (PLModel_Device *light in lightsArr)
    {
        char firstShortAddr = light.firstShortAddr;
        memcpy(pWrite, &firstShortAddr, 1);
        pWrite++;
        char secondShortAddr = light.secondShortAddr;
        memcpy(pWrite, &secondShortAddr, 1);
        pWrite++;
    }
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = lightsArr.count;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:LightsDimCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserLightsDim

- (NSArray *)parserLightsDimWithLength:(int)length
                            ListLength:(int)listLength
                                  Data:(char *)pData
{
    if (length && listLength)
    {
        NSMutableArray *deviceArr = [NSMutableArray new];
        for (int i = 0; i < listLength; i++)
        {
            PLModel_Device *device = [PLModel_Device new];
            //短地址
            device.firstShortAddr = *pData++;
            device.secondShortAddr = *pData++;
            
            [deviceArr addObject:device];
        }
        
        if (deviceArr.count)
        {
            return deviceArr;
        }
    }
    
    return nil;
}

#pragma mark - lightsColor 调节单个灯泡颜色

- (void)changeLightsColorWithLight:(PLModel_Device *)light
                            colorR:(int)colorR
                            colorG:(int)colorG
                            colorB:(int)colorB
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[6];
    char *pWrite = data;
    
    //colorR
    memcpy(pWrite, &colorR, 1);
    pWrite++;
    
    //colorG
    memcpy(pWrite, &colorG, 1);
    pWrite++;
    
    //colorB
    memcpy(pWrite, &colorB, 1);
    pWrite++;
    
    //Short addr
    char firstShortAddr = light.firstShortAddr;
    memcpy(pWrite, &firstShortAddr, 1);
    pWrite++;
    char secondShortAddr = light.secondShortAddr;
    memcpy(pWrite, &secondShortAddr, 1);
    pWrite++;
    
    //nAddr
    char nAddr = 0x01;
    memcpy(pWrite, &nAddr, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x01;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:LightsColorCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - lightsColor 调节一组灯泡颜色

- (void)changeLightsColorWithLightsList:(NSArray *)lightsArr
                                 colorR:(int)colorR
                                 colorG:(int)colorG
                                 colorB:(int)colorB
{
    //    for (PLModel_Device *light in lightsArr)
    //    {
    //        [self changeLightsColorWithLight:light colorR:colorR colorG:colorG colorB:colorB];
    //    }
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[3 + 2 * lightsArr.count + 1];
    char *pWrite = data;
    
    //colorR
    memcpy(pWrite, &colorR, 1);
    pWrite++;
    
    //colorG
    memcpy(pWrite, &colorG, 1);
    pWrite++;
    
    //colorB
    memcpy(pWrite, &colorB, 1);
    pWrite++;
    
    //Short addr
    for (PLModel_Device *light in lightsArr)
    {
        char firstShortAddr = light.firstShortAddr;
        memcpy(pWrite, &firstShortAddr, 1);
        pWrite++;
        char secondShortAddr = light.secondShortAddr;
        memcpy(pWrite, &secondShortAddr, 1);
        pWrite++;
    }
    
    //nAddr
    char nAddr = lightsArr.count;
    memcpy(pWrite, &nAddr, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = lightsArr.count;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:LightsColorCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserLightsColor

- (BOOL)parserLightsColorWithLength:(int)length
                         ListLength:(int)listLength
                               Data:(char *)pData
{
    char flag = *pData++;
    
    if (flag == 0x01)
    {
        return YES;
    }
    else if (flag == 0x00)
    {
        return NO;
    }
    
    return NO;
}

#pragma mark - lightsNormal 调整单个灯泡到正常状态

- (void)moveLightsToNormalWithLight:(PLModel_Device *)light
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[3];
    char *pWrite = data;
    
    //Short addr
    char firstShortAddr = light.firstShortAddr;
    memcpy(pWrite, &firstShortAddr, 1);
    pWrite++;
    char secondShortAddr = light.secondShortAddr;
    memcpy(pWrite, &secondShortAddr, 1);
    pWrite++;
    
    //nAddr
    char nAddr = 0x01;
    memcpy(pWrite, &nAddr, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x01;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:LightsNormalCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - lightsNormal 调整灯泡到正常状态

- (void)moveLightsToNormalWithLightsList:(NSArray *)lightsArr
{
    //    for (PLModel_Device *light in lightsArr)
    //    {
    //        [self moveLightsToNormalWithLight:light];
    //    }
    
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[2 * lightsArr.count + 1];
    char *pWrite = data;
    
    //Short addr
    for (PLModel_Device *light in lightsArr)
    {
        char firstShortAddr = light.firstShortAddr;
        memcpy(pWrite, &firstShortAddr, 1);
        pWrite++;
        char secondShortAddr = light.secondShortAddr;
        memcpy(pWrite, &secondShortAddr, 1);
        pWrite++;
    }
    
    //nAddr
    char nAddr = lightsArr.count;
    memcpy(pWrite, &nAddr, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = lightsArr.count;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:LightsNormalCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserLightsNormal

- (BOOL)parserLightsNormalWithLength:(int)length
                          ListLength:(int)listLength
                                Data:(char *)pData
{
    if (length)
    {
        char flag = *pData++;
        
        if (flag == 0x01)
        {
            return YES;
        }
        else if (flag == 0x00)
        {
            return NO;
        }
    }
    
    return NO;
}

#pragma mark - lightsRemove 将单个灯泡从网络中移除

- (void)removeLightsWithLight:(PLModel_Device *)light
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[3];
    char *pWrite = data;
    
    //Short addr
    char firstShortAddr = light.firstShortAddr;
    memcpy(pWrite, &firstShortAddr, 1);
    pWrite++;
    char secondShortAddr = light.secondShortAddr;
    memcpy(pWrite, &secondShortAddr, 1);
    pWrite++;
    
    //nAddr
    char nAddr = 0x01;
    memcpy(pWrite, &nAddr, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x01;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:LightsRemoveCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    
}

#pragma mark - lightsRemove 将灯泡从网络中移除

- (void)removeLightsWithLightsList:(NSArray *)lightsArr
{
    //    for (PLModel_Device *light in lightsArr)
    //    {
    //        [self removeLightsWithLight:light];
    //    }
    
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[2 * lightsArr.count + 1];
    char *pWrite = data;
    
    //Short addr
    for (PLModel_Device *light in lightsArr)
    {
        char firstShortAddr = light.firstShortAddr;
        memcpy(pWrite, &firstShortAddr, 1);
        pWrite++;
        char secondShortAddr = light.secondShortAddr;
        memcpy(pWrite, &secondShortAddr, 1);
        pWrite++;
    }
    
    //nAddr
    char nAddr = lightsArr.count;
    memcpy(pWrite, &nAddr, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = lightsArr.count;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:LightsRemoveCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserLightsRemove

- (BOOL)parserLightsRemoveWithLength:(int)length
                          ListLength:(int)listLength
                                Data:(char *)pData
{
    if (length)
    {
        char flag = *pData++;
        
        if (flag == 0x01)
        {
            return YES;
        }
        else if (flag == 0x00)
        {
            return NO;
        }
    }
    
    return NO;
}

#pragma mark - LightsIdentify 当前受控灯泡

- (void)lightsIdentifyWithLight:(PLModel_Device *)light
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[2];
    char *pWrite = data;
    
    //Short addr
    char firstShortAddr = light.firstShortAddr;
    memcpy(pWrite, &firstShortAddr, 1);
    pWrite++;
    char secondShortAddr = light.secondShortAddr;
    memcpy(pWrite, &secondShortAddr, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:LightsIdentifyCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserLightsIdentify

- (void)parserLightsIdentifyWithLength:(int)length
                            ListLength:(int)listLength
                                  Data:(char *)pData
{
    if (length)
    {
        
    }
}

#pragma mark - GroupSetup 创建分组

- (void)groupSetup:(PLModel_Group *)group
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[3];
    char *pWrite = data;
    
    //GroupID
    char groupID = group.groupID;
    memcpy(pWrite, &groupID, 1);
    pWrite++;
    
    //MaxMember
    char maxMember = group.maxMember;
    memcpy(pWrite, &maxMember, 1);
    pWrite++;
    
    //MemNum
    char memNum = group.memNum;
    memcpy(pWrite, &memNum, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:GroupSetupCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserGroupSetup

- (BOOL)parserGroupSetupWithLength:(int)length
                        ListLength:(int)listLength
                              Data:(char *)pData
{
    if (length)
    {
        char flag = *pData++;
        
        if (flag == 0x01)
        {
            return YES;
        }
        else if (flag == 0x00)
        {
            return NO;
        }
    }
    
    return NO;
}

#pragma mark - credentialAsk从网关获取凭证

- (void)credentialAsk
{
    DebugLog(@"\n\n=====================================credentialAsk\n\n");
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Length
    char length = 0x00;
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:CredentialAskCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:nil];
    [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
}

#pragma mark - parserCredentialAsk

- (NSData *)parserCredentialAskWithLength:(int)length
                               ListLength:(int)listLength
                                     Data:(char *)pData
{
    if (length)
    {
        NSData *credentialData = [NSData dataWithBytes:pData length:12];
        pData = pData + 12;
        
        return credentialData;
    }
    
    return nil;
}

#pragma mark - GroupConfig

- (void)groupConfigWithGroup:(PLModel_Group *)group
                  ConfigType:(GroupConfigType)configType
                  LightsList:(NSArray *)lightsArr
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    int dataLength = (int)(1 + 1 + 2 * lightsArr.count + 1 + 3);
    char data[dataLength];
    char *pWrite = data;
    
    //GroupID
    char groupID = group.groupID;
    memcpy(pWrite, &groupID, 1);
    pWrite++;
    
    //Flag
    char flag = configType;
    memcpy(pWrite, &flag, 1);
    pWrite++;
    
    //Short addr list
    for (int i = 0; i < lightsArr.count; i++)
    {
        PLModel_Device *light = lightsArr[i];
        char firstShortAddr = light.firstShortAddr;
        memcpy(pWrite, &firstShortAddr, 1);
        pWrite++;
        char secondShortAddr = light.secondShortAddr;
        memcpy(pWrite, &secondShortAddr, 1);
        pWrite++;
    }
    
    //Group_Type
    memcpy(pWrite, &groupID, 1);
    pWrite++;
    char maxMember = group.maxMember;
    memcpy(pWrite, &maxMember, 1);
    pWrite++;
    char memNum = group.memNum;
    memcpy(pWrite, &memNum, 1);
    pWrite++;
    
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = lightsArr.count;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:GroupConfigCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserGroupConfig

- (BOOL)parserGroupConfigWithLength:(int)length
                         ListLength:(int)listLength
                               Data:(char *)pData
{
    if (length)
    {
        char status = *pData++;
        
        return status;
    }
    
    return NO;
}

#pragma mark - GroupQuery

- (void)groupQuery:(PLModel_Group *)group
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    int dataLength = 1;
    char data[dataLength];
    char *pWrite = data;
    
    //GroupID
    char groupID = group.groupID;
    memcpy(pWrite, &groupID, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:GroupQueryCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserGroupQuery

- (PLModel_Group *)parserGroupQueryWithLength:(int)length
                                   ListLength:(int)listLength
                                         Data:(char *)pData
{
    if (length)
    {
        PLModel_Group *group = [PLModel_Group new];
        group.groupID = *pData++;
        group.maxMember = *pData++;
        group.memNum = *pData++;
        
        return group;
    }
    
    return nil;
}

#pragma mark - parserAlarmInform

- (PLModel_Device *)parserAlarmInformWithLength:(int)length
                                     ListLength:(int)listLength
                                           Data:(char *)pData
{
    if (length)
    {
        PLModel_Device *device = [PLModel_Device new];
        device.firstShortAddr = *pData++;
        device.secondShortAddr = *pData++;
        device.deviceType = *pData++;
        device.firstSensorStatus = *pData++;
        device.secondSensorStatus = *pData++;
        device.alertType = *pData++;
        device.macAddress = [NSData dataWithBytes:pData length:8];
        pData = pData + 8;
        device.isAlerting = YES;
        
        return device;
    }
    
    return nil;
}

#pragma mark - parserUDPBroadcast

- (NSArray *)parserUDPBroadcastWithLength:(int)length
                               ListLength:(int)listLength
                                     Data:(char *)pData
{
    if (length)
    {
        unsigned char firstIP = *pData++;
        unsigned char secondIP = *pData++;
        unsigned char thirdIP = *pData++;
        unsigned char forthIP = *pData++;
        int flag = *pData++;
        NSString *getwayIP = [NSString stringWithFormat:@"%d.%d.%d.%d",firstIP,secondIP,thirdIP,forthIP];
        NSString *flagStr = [NSString stringWithFormat:@"%d",flag];
        
        return @[getwayIP,flagStr];
    }
    
    return nil;
}

#pragma mark - SetGetwayIP

- (void)setGetwayIP:(NSString *)ipString
{
    NSArray *ipAddrArr = [ipString componentsSeparatedByString:@"."];
    if (ipAddrArr.count >= 4)
    {
        char buffer[BufferSize];
        int nBufferSize = BufferSize;
        int nOutSize = 0;
        
        //Data
        int dataLength = 4;
        char data[dataLength];
        char *pWrite = data;
        
        //IP Address
        unsigned char firstIP = [ipAddrArr[0] intValue];
        memcpy(pWrite, &firstIP, 1);
        pWrite++;
        
        unsigned char secondIP = [ipAddrArr[1] intValue];
        memcpy(pWrite, &secondIP, 1);
        pWrite++;
        
        unsigned char thirdIP = [ipAddrArr[2] intValue];
        memcpy(pWrite, &thirdIP, 1);
        pWrite++;
        
        unsigned char fourthIP = [ipAddrArr[3] intValue];
        memcpy(pWrite, &fourthIP, 1);
        pWrite++;
        
        //Length
        int length = (int)sizeof(data);
        
        //ListLength
        char listLength = 0x00;
        
        [self getCommandToGatewayWithBurrer:buffer
                                nBufferSize:nBufferSize
                                   pOutSize:&nOutSize
                                  CommandID:IPSetCommondID
                                     Length:length
                                 ListLength:listLength
                                      pData:data];
        
        if (self.currentServerType == GatewayType)
        {
            //连接的是网关则直接发送
            [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
        }
        else if (self.currentServerType == CloudServerType)
        {
            //连接的是CloudServer则再次封装后再发送
            [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
        }
    }
}

#pragma mark - parserSetGetwayIP

- (BOOL)parserSetGetwayIPWithLength:(int)length
                         ListLength:(int)listLength
                               Data:(char *)pData
{
    if (length)
    {
        char status = *pData++;
        
        return status;
    }
    
    return NO;
}

#pragma mark - CredentialSend

- (void)credentialSend
{
    if (self.gatewayCredentialArr.count)
    {
        char buffer[BufferSize];
        int nBufferSize = BufferSize;
        int nOutSize = 0;
        
        //Data
        int dataLength = (int)(1 + self.gatewayCredentialArr.count * 12);
        char data[dataLength];
        char *pWrite = data;
        
        //num
        unsigned char num = self.gatewayCredentialArr.count;
        memcpy(pWrite, &num, 1);
        pWrite++;
        
        //Credential list
        for (int i = 0; i < self.gatewayCredentialArr.count; i++)
        {
            NSData *credentialData = self.gatewayCredentialArr[i];
            char *credential = (char *)[credentialData bytes];
            memcpy(pWrite, credential, 12);
            pWrite = pWrite + 12;
        }
        
        //Length
        int length = (int)sizeof(data);
        
        //ListLength
        char listLength = 0x00;
        
        [self getCommandToGatewayWithBurrer:buffer
                                nBufferSize:nBufferSize
                                   pOutSize:&nOutSize
                                  CommandID:CredentialSendCommondID
                                     Length:length
                                 ListLength:listLength
                                      pData:data];
        
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserCredentialSend

- (int)parserCredentialSendWithLength:(int)length
                           ListLength:(int)listLength
                                 Data:(char *)pData
{
    if (length)
    {
        int gatewayNum = *pData++;
        
        return gatewayNum;
    }
    
    return 0;
}

#pragma mark - GatewayChoose

- (void)gatewayChooseWithGatewayID:(NSString *)gatewayID
{
    //    if (gatewayID)
    //    {
    //        char buffer[BufferSize];
    //        int nBufferSize = BufferSize;
    //        int nOutSize = 0;
    //
    //        //Data
    //        int dataLength = (int)(1 + self.credentialArr.count * 12);
    //        char data[dataLength];
    //        char *pWrite = data;
    //
    //        //sNum
    //        unsigned char sNum = gatewayID.intValue;
    //        memcpy(pWrite, &sNum, 1);
    //        pWrite++;
    //
    //        //Length
    //        int length = (int)sizeof(data);
    //
    //        //ListLength
    //        char listLength = 0x00;
    //
    //        [self getCommandToGatewayWithBurrer:buffer
    //                               nBufferSize:nBufferSize
    //                                  pOutSize:&nOutSize
    //                                 CommandID:CredentialSendCommondID
    //                                    Length:length
    //                                ListLength:listLength
    //                                     pData:data];
    //        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    //    }
    
    self.selectedGateWayIndex = gatewayID.intValue;
    DebugLog(@"self.selectedGateWayIndex ============== %d",self.selectedGateWayIndex);
}

#pragma mark - parserGatewayChoose

- (void)parserGatewayChooseWithLength:(int)length
                           ListLength:(int)listLength
                                 Data:(char *)pData
{
    if (length)
    {
        
    }
}

#pragma mark - CIDAsk

- (void)CIDAsk
{
    DebugLog(@"\n\n=====================================CIDAsk\n\n");
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Length
    char length = 0x00;
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:CIDAskCommondID
                                 Length:length
                             ListLength:listLength
                                  pData:nil];
    [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
}

#pragma mark - parserCIDAsk

- (NSData *)parserCIDAskWithLength:(int)length
                        ListLength:(int)listLength
                              Data:(char *)pData
{
    if (length)
    {
        NSData *cidData = [NSData dataWithBytes:pData length:8];
        pData = pData + 8;
        
        return cidData;
    }
    
    return nil;
}

#pragma mark - checkUserCredential

- (void)checkUserCredential
{
    DebugLog(@"\n\n=====================================checkUserCredential\n\n");
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    
    //Data
    int dataLength = 70;
    if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        dataLength = 82;
    }
    char data[dataLength];
    char *pWrite = data;
    
    //userCredential
    NSData *userCredentialData = [[PLUserInfoManager sharedManager] userCredentialData];
    char *userCredential = (char *)[userCredentialData bytes];
    memcpy(pWrite, userCredential, userCredentialData.length);
    pWrite = pWrite + userCredentialData.length;
    
    NSData *passwordData = [[PLUserInfoManager sharedManager] passwordData];
    char *password = (char *)[passwordData bytes];
    memcpy(pWrite, password, passwordData.length);
    pWrite = pWrite + passwordData.length;
    
    //Length
    char length = dataLength;
    
    //ListLength
    char listLength = 0x00;
    
    //CommandID
    int commandID;
    
    if (self.currentServerType == CloudServerType) {
        if (self.gatewayCredentialArr.count > self.selectedGateWayIndex)
        {
            DebugLog(@"gatewayCredentialArr - %@\n",self.gatewayCredentialArr);
            NSData *gatewayCredentialData = self.gatewayCredentialArr[self.selectedGateWayIndex];
            DebugLog(@"gatewayCredentialData ========= %@",gatewayCredentialData);
            char *gatewayCredential = (char *)[gatewayCredentialData bytes];
            memcpy(pWrite, gatewayCredential, gatewayCredentialData.length);
            pWrite = pWrite + gatewayCredentialData.length;
              commandID = SendUserCredentialToCloudServerCommandID;
            NSLog(@"NONONONOOO");
        }
    }else if (self.currentServerType == GatewayType){
//        NSData *gatewayCredentialData =[NSData dataWithData:self.gatewayCredential];
//        DebugLog(@"gatewayCredentialData ========= %@",self.gatewayCredential);
//        PLAppDelegate *aapp =[[UIApplication sharedApplication] delegate];
//        DebugLog(@"APPgatewayCredentialData ========= %@",aapp.gatwaycretail);
//        char *gatewayCredential = (char *)[self.gatewayCredential bytes];
//        memcpy(pWrite, gatewayCredential, gatewayCredentialData.length);
//        pWrite = pWrite + gatewayCredentialData.length;
         commandID = CheckUserCredentialCommandID;
//        NSLog(@"BUGBUGBUGBUG");
    }

    
//    if (self.currentServerType == GatewayType)
//    {
//        commandID = CheckUserCredentialCommandID;
//    }
//    else if (self.currentServerType == CloudServerType)
//    {
//        //gatewayCredential
//        if (self.gatewayCredentialArr.count > self.selectedGateWayIndex)
//        {
//            NSData *gatewayCredentialData = self.gatewayCredentialArr[self.selectedGateWayIndex];
//            char *gatewayCredential = (char *)[gatewayCredentialData bytes];
//            memcpy(pWrite, gatewayCredential, gatewayCredentialData.length);
//            pWrite = pWrite + gatewayCredentialData.length;
//        }
//        
//        commandID = SendUserCredentialToCloudServerCommandID;
//    }
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:commandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
}

#pragma mark - checkTempUserCredential 修改邮箱时临时验证使用此方法

- (void)checkTempUserCredential
{
    DebugLog(@"\n\n=====================================checkTempUserCredential\n\n");
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    int dataLength = 70;
    char data[dataLength];
    char *pWrite = data;
    
    //userCredential
    NSData *userCredentialData = [[PLUserInfoManager sharedManager] tempUserCredentialData];
    char *userCredential = (char *)[userCredentialData bytes];
    memcpy(pWrite, userCredential, userCredentialData.length);
    pWrite = pWrite + userCredentialData.length;
    
    NSData *passwordData = [[PLUserInfoManager sharedManager] tempPasswordData];
    char *password = (char *)[passwordData bytes];
    memcpy(pWrite, password, passwordData.length);
    pWrite = pWrite + passwordData.length;
    
    //Length
    char length = dataLength;
    
    //ListLength
    char listLength = 0x00;
    
    //CommandID
    int commandID;
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        commandID = CheckUserCredentialCommandID;
    }
    else {
        //连接的是CloudServer则再次封装后再发送
        commandID = SendUserCredentialToCloudServerCommandID;
    }
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:commandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
}

#pragma mark - parserCheckUserCredential

- (PLModel_CheckResult *)parserCheckUserCredentialWithLength:(int)length
                                                  ListLength:(int)listLength
                                                        Data:(char *)pData
{
    if (length)
    {
        char flag = *pData++;
        PLModel_CheckResult *checkResult = [PLModel_CheckResult new];
        checkResult.hasAlreadyExist = flag;
        
        if (flag == 0x01)
        {
            NSData *passwordData = [NSData dataWithBytes:pData length:6];
            checkResult.password = passwordData;
        }
        
        return checkResult;
    }
    
    return nil;
}

#pragma mark - userCredentialGM

- (void)userCredentialGM:(BOOL)continueToUseBothDevice
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    int dataLength = 1 + 70;
    char data[dataLength];
    char *pWrite = data;
    
    //Flag
    char flag = 0x00;
    if (continueToUseBothDevice)
    {
        flag = 0x01;
    }
    memcpy(pWrite, &flag, 1);
    pWrite++;
    
    //userCredential
    NSData *userCredentialData = [[PLUserInfoManager sharedManager] userCredentialData];
    char *userCredential = (char *)[userCredentialData bytes];
    memcpy(pWrite, userCredential, userCredentialData.length);
    pWrite = pWrite + userCredentialData.length;
    
    NSData *passwordData = [[PLUserInfoManager sharedManager] passwordData];
    if (continueToUseBothDevice)
    {
        passwordData = [[PLUserInfoManager sharedManager] previousPasswordData];
    }
    char *password = (char *)[passwordData bytes];
    memcpy(pWrite, password, passwordData.length);
    pWrite = pWrite + passwordData.length;
    
    //Length
    char length = dataLength;
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:UserCredentialGMCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
}

#pragma mark - parserUserCredentialGM

- (void)parserUserCredentialGMWithLength:(int)length
                              ListLength:(int)listLength
                                    Data:(char *)pData
{
    if (length)
    {
        
    }
}

#pragma mark - sendCellPhoneInfoToGateWay

- (void)sendCellPhoneInfoToGateWay
{
    DebugLog(@"\n\n=====================================sendCellPhoneInfoToGateWay\n\n");
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    int dataLength = 4;
    char data[dataLength];
    char *pWrite = data;
    
    //OS Type
    //ios 0x01  android 0x02    windowsPhone 0x03   blackberry 0x04
    char osType = 0x01;
    memcpy(pWrite, &osType, 1);
    pWrite++;
    
    //OS Version
    NSString *osVersionStr = [[UIDevice currentDevice] systemVersion];
    NSArray *tempArr = [osVersionStr componentsSeparatedByString:@"."];
    unsigned char osVersion;
    if (tempArr.count >= 2)
    {
        int bigVersion = [tempArr[0] intValue];
        int smallVersion = [tempArr[1] intValue];
        osVersion = bigVersion * 16 + smallVersion;
    }
    memcpy(pWrite, &osVersion, 1);
    pWrite++;
    
    //language
    //English 0x01  Chinese 0x02
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [userDefaults objectForKey:@"AppleLanguages"];
    NSString *osLanguageStr = [languages objectAtIndex:0];
    //en:英文  zh-Hans:简体中文   zh-Hant:繁体中文    ja:日本  ......
    char osLanguage;
    if ([osLanguageStr isEqualToString:@"en"])
    {
        osLanguage = 0x01;
    }
    else if ([osLanguageStr isEqualToString:@"zh-Hans"] || [osLanguageStr isEqualToString:@"zh-Hant"] || [osLanguageStr isEqualToString:@"zh-HK"] || [osLanguageStr isEqualToString:@"zh-TW"])
    {
        osLanguage = 0x02;
    }
    else
    {
        osLanguage = 0x03;
    }
    memcpy(pWrite, &osLanguage, 1);
    pWrite++;
    
    //rsrvd
    char rsrvd = 0x00;
    memcpy(pWrite, &rsrvd, 1);
    pWrite++;
    
    //Length
    char length = dataLength;
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:MobileDeviceInfoCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
}

#pragma mark - parserSendCellPhoneInfoToGateWay

- (void)parserSendCellPhoneInfoToGateWayWithLength:(int)length
                                        ListLength:(int)listLength
                                              Data:(char *)pData
{
    if (length)
    {
        
    }
}

#pragma mark - 选择单个传感器报警类型

- (void)securityStateSelectWithType:(SecurityStateType)type Device:(PLModel_Device *)device
{
  
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    int dataLength = 5;
    char data[dataLength];
    char *pWrite = data;
    
    //State
    char state = type;
    memcpy(pWrite, &state, 1);
    pWrite++;
    
    //SDNum
    char SDNum = 0x01;
    memcpy(pWrite, &SDNum, 1);
    pWrite++;
    
    //nAddr
    unsigned char firstShortAddr = device.firstShortAddr;
    unsigned char secondShortAddr = device.secondShortAddr;
    memcpy(pWrite, &firstShortAddr, 1);
    pWrite++;
    memcpy(pWrite, &secondShortAddr, 1);
    pWrite++;
    
    //on/off
    char onOff = device.onOff ? 0x01 : 0x00;
    memcpy(pWrite, &onOff, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x01;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:SecurityStateSelectCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - securityStateSelect 选择所有传感器报警类型

- (void)securityStateSelectWithType:(SecurityStateType)type
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    int dataLength = 2;
    char data[dataLength];
    char *pWrite = data;
    
    //State
    char state = type;
    memcpy(pWrite, &state, 1);
    pWrite++;
    
    //SDNum
    char SDNum = 0x00;
    memcpy(pWrite, &SDNum, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:SecurityStateSelectCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parseSecurityStateSelect

- (void)parseSecurityStateSelectWithLength:(int)length
                                ListLength:(int)listLength
                                      Data:(char *)pData
{
    if (length)
    {
        
    }
}

#pragma mark - resetOrReboot 重置、重启网关或者设备

- (void)resetOrRebootWithType:(ResetRebootType)type Device:(PLModel_Device *)device
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    int dataLength = 3;
    char data[dataLength];
    char *pWrite = data;
    
    //OP
    char op = type;
    memcpy(pWrite, &op, 1);
    pWrite++;
    
    //Short Address
    unsigned char firstShortAddr = 0x00;
    unsigned char secondShortAddr = 0x00;
    if (type == ResetDeviceType && device)
    {
        firstShortAddr = device.firstShortAddr;
        secondShortAddr = device.secondShortAddr;
    }
    memcpy(pWrite, &firstShortAddr, 1);
    pWrite++;
    memcpy(pWrite, &secondShortAddr, 1);
    pWrite++;
    
    //Length
    int length = (int)sizeof(data);
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:ResetOrRebootCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parseResetOrReboot

- (void)parseResetOrRebootWithLength:(int)length
                          ListLength:(int)listLength
                                Data:(char *)pData
{
    if (length)
    {
        
    }
}

#pragma mark - securityStateRequest 查询报警状态(当前报警模式)

- (void)securityStateRequest
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Length
    char length = 0x00;
    
    //ListLength
    char listLength = self.sensorArr.count;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:SecurityStateRequestCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:nil];
    
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserSecurityStateRequest

- (PLModel_SecurityStateResult *)parserSecurityStateRequestWithLength:(int)length
                                                           ListLength:(int)listLength
                                                                 Data:(char *)pData
{
    if (length && listLength)
    {
        PLModel_SecurityStateResult *result = [PLModel_SecurityStateResult new];
        result.type = *pData++;
        
        NSMutableArray *deviceArr = [NSMutableArray new];
        for (int i = 0; i < listLength; i++)
        {
            PLModel_Device *device = [PLModel_Device new];
            //短地址
            device.firstShortAddr = *pData++;
            device.secondShortAddr = *pData++;
            
            //设备状态
            device.onOff = (*pData++ == 0x01 ? YES : NO);
            
            //Mac地址
            NSData *macAddress = [NSData dataWithBytes:pData length:8];
            device.macAddress = macAddress;
            pData = pData + 8;
            
            [deviceArr addObject:device];
        }
        
        result.sensorsArr = deviceArr;
        return result;
    }
    
    return nil;
}

#pragma mark - 查询网关当前版本

- (void)quaryGatewayCurrentVersion
{
    DebugLog(@"=====================================sendoldversioninfo");
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    char data[] = {0x00,0x00};
    
    //Length
    char length = 0x02;
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:GateWayCurrentVersionCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserGatewayCurrentVersion

- (NSString *)parserGatewayCurrentVersionWithLength:(int)length
                                         ListLength:(int)listLength
                                               Data:(char *)pData
{
    int firstVersion = *pData++;
    int secondVersion = *pData++;
    PLAppDelegate *appdelegate =  [[UIApplication sharedApplication] delegate];
    NSString *gatewayVersion = [NSString stringWithFormat:@"%d.%d",firstVersion,secondVersion];
    appdelegate.VersionGWNumber = [NSString stringWithString:gatewayVersion];
    return gatewayVersion;
 
}

#pragma mark - 场景控制

- (void)sceneControlWithType:(SceneControlType)type
                 SceneNumber:(int)sceneNumber
                     GroupID:(int)groupID
                   LightsArr:(NSArray *)lightsArr
                   SceneName:(NSString *)sceneName
{
    DebugLog(@"选中的是%d",sceneNumber);
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    int dataLength = 1 + 1 + 2 + 2 * (int)lightsArr.count + 32;
    char data[dataLength];
    char *pWrite = data;
    
    //OP
    char op = type;
    memcpy(pWrite, &op, 1);
    pWrite++;
    
    //SceneNum
    memcpy(pWrite, &sceneNumber, 1);
    pWrite++;
    
    //groupID
    int firstGroupID = groupID / 256;
    memcpy(pWrite, &firstGroupID, 1);
    pWrite++;
    int secondGroupID = groupID % 256;
    memcpy(pWrite, &secondGroupID, 1);
    pWrite++;
    
    //sAddr
    if (lightsArr.count)
    {
        for (int i = 0; i < lightsArr.count; i++)
        {
            PLModel_Device *light = lightsArr[i];
            //Short addr
            char firstShortAddr = light.firstShortAddr;
            memcpy(pWrite, &firstShortAddr, 1);
            pWrite++;
            char secondShortAddr = light.secondShortAddr;
            memcpy(pWrite, &secondShortAddr, 1);
            pWrite++;
        }
    }
    
    //reserver
    memset(pWrite, 0xFF, 32);
    
    //Length
    char length = sizeof(data);
    
    //ListLength
    char listLength = lightsArr.count;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:SceneControlCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    
    if (self.currentServerType == GatewayType)
    {
        //连接的是网关则直接发送
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
    else if (self.currentServerType == CloudServerType)
    {
        //连接的是CloudServer则再次封装后再发送
        [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}

#pragma mark - parserSceneControl

- (BOOL)parserSceneControlWithLength:(int)length
                          ListLength:(int)listLength
                                Data:(char *)pData
{
    pData++;
    return *pData;
}

#pragma mark - 获取CloudServer上Gateway最新版本

- (void)getFirmwareVervionStoredInCloud
{
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    int dataLength = 8 + 2;
    char data[dataLength];
    char *pWrite = data;
    
    //CID
    if (self.currentConnectedGatewayCID)
    {
        char *cid = (char *)[self.currentConnectedGatewayCID bytes];
        memcpy(pWrite, cid, 8);
    }
    else
    {
        memset(pWrite, 0x00, 8);
        pWrite = pWrite + 8;
    }
    
    //reserve
    memset(pWrite, 0x00, 2);
    
    //Length
    char length = sizeof(data);
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:LastestVersionCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    
    
    //连接的是CloudServer,再次封装后再发送
    [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];

}

#pragma mark - parserFirmwareVervionStoredInCloud

- (NSString *)parserFirmwareVervionStoredInCloudWithLength:(int)length
                                                ListLength:(int)listLength
                                                      Data:(char *)pData
{
    int firstVersion = *pData++;
    int secondVersion = *pData++;
    unsigned char firstpage = *pData++;
    unsigned char secondpage = *pData++;
    unsigned char threepage = *pData++;
    unsigned char fourpage = *pData++;
    PLAppDelegate *app = [[UIApplication sharedApplication]delegate];
    NSString *gatewayVersion = [NSString stringWithFormat:@"%d.%d",firstVersion,secondVersion];
    app.VersionClundNumber = [NSString stringWithString:gatewayVersion];
    app.PageNumb  = 256*threepage + fourpage + 65536*secondpage + 16777216*firstpage;
    DebugLog(@"totalpage;%f",app.PageNumb);
    return gatewayVersion;
}



#pragma mark - saveDeviceTocken 保存device token

- (void)saveDeviceTocken:(NSData *)deviceToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:deviceToken forKey:@"DeviceTocken"];
    [userDefaults synchronize];
}

#pragma mark - sendDeviceTokenToCloudServer 发送device token给cloudserver

- (void)sendDeviceTokenToCloudServer
{
    DebugLog(@"\n\n=====================================1SendDeviceTokenToCloudServer\n\n");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *tockenData = [userDefaults objectForKey:@"DeviceTocken"];
    if (tockenData)
    {
        char buffer[BufferSize];
        int nBufferSize = BufferSize;
        int nOutSize = 0;
        
        //Data
        int dataLength = 32 + 8;
        char data[dataLength];
        char *pWrite = data;
        
        //DeviceToken 32Bytes
        char *deviceToken = (char *)[tockenData bytes];
        memcpy(pWrite, deviceToken, tockenData.length);
        pWrite = pWrite + tockenData.length;
        
        //reservedField 8Bytes
        memset(pWrite, 0xFF, 8);
        pWrite += 8;
        
        //Length
        char length = dataLength;
        
        //ListLength
        char listLength = 0x00;
        
        [self getCommandToGatewayWithBurrer:buffer
                                nBufferSize:nBufferSize
                                   pOutSize:&nOutSize
                                  CommandID:DeviceTokenSendCommandID
                                     Length:length
                                 ListLength:listLength
                                      pData:data];
        [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
    }
}
- ( void)parserGetCurrentPageInCloudWithLength:(int)length
                                                ListLength:(int)listLength
                                                      Data:(char *)pData{
    
  unsigned char firstpage = *pData++;
    unsigned char  secondpage = *pData++;
    unsigned char  threepage = *pData++;
    unsigned char  fourpage = *pData++;
       PLAppDelegate *app = [[UIApplication sharedApplication]delegate];
     app.TotalPageNumb  = 256*threepage + fourpage + 65536*secondpage + 16777216*firstpage;
    DebugLog(@"curruntpage:$%f",app.TotalPageNumb);
}














#pragma mark - creatSecondConnectToCloudServer 此方法仅限于当前连接是GatewayType类型时调用

- (void)creatSecondConnectToCloudServer
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    if (reachability.currentReachabilityStatus != NotReachable)
    {
        [self performSelectorOnMainThread:@selector(initSecondSocket) withObject:nil waitUntilDone:YES];
    }
}

- (void)initSecondSocket
{
    _secondSocket = [[AsyncSocket alloc] initWithDelegate:self];
    DebugLog(@"creatSecondConnectToCloudServer:%@",[self cloudServerAddress]);
    [self.secondSocket connectToHost:[self cloudServerAddress] onPort:CloudServerPort error:nil];
}

- (void)sendUserCredentialToCloudServerWhenSecondConnect
{
    DebugLog(@"\n\n=====================================sendUserCredentialToCloudServerWhenSecondConnect\n\n");
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    int dataLength = 82;
    char data[dataLength];
    char *pWrite = data;
    
    //userCredential
    NSData *userCredentialData = [[PLUserInfoManager sharedManager] userCredentialData];
    char *userCredential = (char *)[userCredentialData bytes];
    memcpy(pWrite, userCredential, userCredentialData.length);
    pWrite = pWrite + userCredentialData.length;
    
    NSData *passwordData = [[PLUserInfoManager sharedManager] passwordData];
    char *password = (char *)[passwordData bytes];
    memcpy(pWrite, password, passwordData.length);
    pWrite = pWrite + passwordData.length;
    
//    //gatewayCredential
    DebugLog(@"self.currentServerType ========= %d",self.currentServerType);
    if (self.currentServerType == CloudServerType) {
            if (self.gatewayCredentialArr.count > self.selectedGateWayIndex)
            {
                NSData *gatewayCredentialData = self.gatewayCredentialArr[self.selectedGateWayIndex];
                DebugLog(@"gatewayCredentialData ========= %@",gatewayCredentialData);
                char *gatewayCredential = (char *)[gatewayCredentialData bytes];
                memcpy(pWrite, gatewayCredential, gatewayCredentialData.length);
                pWrite = pWrite + gatewayCredentialData.length;
            }
    }else if (self.currentServerType == GatewayType){
        NSData *gatewayCredentialData =[NSData dataWithData:self.gatewayCredential];
        DebugLog(@"gatewayCredentialData ========= %@",self.gatewayCredential);
        PLAppDelegate *aapp =[[UIApplication sharedApplication] delegate];
          DebugLog(@"APPgatewayCredentialData ========= %@",aapp.gatwaycretail);
        char *gatewayCredential = (char *)[self.gatewayCredential bytes];
        memcpy(pWrite, gatewayCredential, gatewayCredentialData.length);
        pWrite = pWrite + gatewayCredentialData.length;
    }
    //Length
    char length = dataLength;
    
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:SendUserCredentialToCloudServerCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:data];
    NSData *toWriteData = [NSData dataWithBytes:buffer length:nOutSize];
    [self.secondSocket writeData:toWriteData withTimeout:-1 tag:0];
    DebugLog(@"\n\nUserCredentialToCloudServer:\n\n%@\n\n",toWriteData);
}
-(void)sendDidDeltokenbind{
    DebugLog(@"\n\n=====================================sendDidDeltokenbind\n\n");
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Length
    char length = 0;
    char data1[0] ;
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:Deltokenbind
                                 Length:length
                             ListLength:listLength
                                  pData:data1];
    
    NSData *toWriteData = [NSData dataWithBytes:buffer length:nOutSize];
    [self.secondSocket writeData:toWriteData withTimeout:-1 tag:0];
    DebugLog(@"\n\nsendDidDeltokenbind:\n\n%@\n\n",toWriteData);
}
- (void)sendDeviceTokenToCloudServerWhenSecondConnect
{
    DebugLog(@"\n\n=====================================2sendDeviceTokenToCloudServerWhenSecondConnect\n\n");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *tockenData = [userDefaults objectForKey:@"DeviceTocken"];
    if (tockenData)
    {
        char buffer[BufferSize];
        int nBufferSize = BufferSize;
        int nOutSize = 0;
        
        //Data
        int dataLength = 32 + 8;
        char data[dataLength];
        char *pWrite = data;
        
        //DeviceToken 32Bytes
        char *deviceToken = (char *)[tockenData bytes];
        memcpy(pWrite, deviceToken, tockenData.length);
        pWrite = pWrite + tockenData.length;
        
        //reservedField 8Bytes
        memset(pWrite, 0xFF, 8);
        pWrite += 8;
        
        //Length
        char length = dataLength;
        
        //ListLength
        char listLength = 0x00;
        
        [self getCommandToGatewayWithBurrer:buffer
                                nBufferSize:nBufferSize
                                   pOutSize:&nOutSize
                                  CommandID:DeviceTokenSendCommandID
                                     Length:length
                                 ListLength:listLength
                                      pData:data];
        NSData *toWriteData = [NSData dataWithBytes:buffer length:nOutSize];
        [self.secondSocket writeData:toWriteData withTimeout:-1 tag:0];
        DebugLog(@"\n\nwriteTockenToCloudServer:\n\n%@\n\n",toWriteData);
    }
    
}

- (void)GetLatesVersionWhenSecondConnect
{
    DebugLog(@"\n\n=====================================GetversionfromClound\n\n");
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    
    //Data
    int dataLength = 8 + 2;
    char data[dataLength];
    char *pWrite = data;
    
    //CID
    if (self.currentConnectedGatewayCID)
    {
        char *cid = (char *)[self.currentConnectedGatewayCID bytes];
        memcpy(pWrite, cid, 8);
    }
    else
    {
        memset(pWrite, 0x00, 8);
        pWrite = pWrite + 8;
    }
    
    //reserve
    memset(pWrite, 0x00, 2);
   pWrite += 2;
    //Length
    char length = dataLength;
   char data1[] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:LastestVersionCommandID
                                 Length:length
                             ListLength:listLength
                                  pData:data1];
    
        NSData *toWriteData = [NSData dataWithBytes:buffer length:nOutSize];
        [self.secondSocket writeData:toWriteData withTimeout:-1 tag:0];
        DebugLog(@"\n\nwriteGetLatesVersionCloudServer:\n\n%@\n\n",toWriteData);

//     [self writeDataToCloudServerWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
}
-(void)startUpdataGwversion{
    DebugLog(@"\n\n=====================================StartUpDateGayVersion\n\n");
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    //Length
    char length = 0x01;
    char data1[] = {0x00};
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:StartUpDateCommandId
                                 Length:length
                             ListLength:listLength
                                  pData:data1];
       [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
  
}

-(void)GetUpdataGwversionInfo{
    DebugLog(@"\n\n=====================================GetUpDateGayVersion\n\n");
    char buffer[BufferSize];
    int nBufferSize = BufferSize;
    int nOutSize = 0;
    //Length
    char length = 0x01;
    char data1[] = {0x01};
    //ListLength
    char listLength = 0x00;
    
    [self getCommandToGatewayWithBurrer:buffer
                            nBufferSize:nBufferSize
                               pOutSize:&nOutSize
                              CommandID:StartUpDateCommandId
                                 Length:length
                             ListLength:listLength
                                  pData:data1];
    
  [self writeDataToGatewayWithBurrer:buffer nBufferSize:nBufferSize pOutSize:nOutSize];
 
}


















#pragma mark - checkUDPResponse

- (void)checkUDPResponse
{
    [self.udpSocket receiveWithTimeout:-1 tag:0];
}

#pragma mark - checkTCPResponse

- (void)checkTCPResponse
{
    [self.tcpSocket readDataWithTimeout:-1 tag:0];
}
-(void)checkTCPResponseForUpData{
   [self.secondSocket readDataWithTimeout:-1 tag:0];
}

#pragma mark - AsyncUdpSocketDelegate

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    DebugLog(@"onUdpSocket didSendDataWithTag");
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    DebugLog(@"onUdpSocket didNotSendDataWithTag");
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    DebugLog(@"onUdpSocket didReceiveData:%@",data);
    //解析网关ip地址
    [self parserGetwayIPAddressWithData:data];
    
    return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    DebugLog(@"onUdpSocket didNotReceiveDataWithTag:%@",error);
}

#pragma mark - AsyncSocketDelegate

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    if (sock == self.tcpSocket)
    {
        if (self.currentServerType == GatewayType)
        {
            DebugLog(@"=====================DidConnectedToGateway");
            self.connectedWithGateway = YES;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DidConnectedToGateway object:nil];
        }
        else if (self.currentServerType == CloudServerType)
        {
            DebugLog(@"=====================DidConnectedToCloudServer");
            [[NSNotificationCenter defaultCenter] postNotificationName:DidConnectedToCloudServer object:nil];
        }
    }
    if (sock == self.secondSocket) {
        self.tcpTimer1 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkTCPResponseForUpData) userInfo:nil repeats:YES];
        DebugLog(@"已经连接服务器检查更新,发送token和认证信息");
        _isconnectcloundforupdate = YES;
           [[NSNotificationCenter defaultCenter] postNotificationName:DidConnectedToCloudServerForUpDate object:nil];
    }
}
-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
   DebugLog(@"!!!!!!!!!!!!!!!!errorfor:%@",err);
    
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock{
    DebugLog(@"已经断开连接%@",sock);
    
}
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //解析接收到得数据
    if (sock == self.secondSocket){
        DebugLog(@"服务器信息onSocket didReadData:\n\n%@\n\n",data);
        char *pData = (char *)[data bytes];
        [self parserReceivedData:pData];
    }
   else  if (sock == self.tcpSocket)
    {
        DebugLog(@"网关信息或者服务器转发onSocket didReadData:\n\n%@\n\n",data);
        char *pData = (char *)[data bytes];
        [self parserReceivedData:pData];
    }
  
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    
}

#pragma mark - parserReceivedData   //解析tcp接受的的数据

- (void)parserReceivedData:(char *)pData
{
    
  
    UInt8 packageStart = *pData++;
    UInt8 responseStart = *pData++;
    if (packageStart == PackageStart && responseStart == ResponseStart)
    {
        //CommandID
        int subCommandID1 = *pData++;
        int subCommandID2 = *pData++;
        int commandID = subCommandID1 * 256 + subCommandID2;
        //Length
        int subLength1 = *pData++;
        int subLength2 = *pData++;
        int length = subLength1 * 256 + subLength2;
        //ListLength
        int subListLength1 = *pData++;
        int subListLength2 = *pData++;
        int listLength = subListLength1 * 256 + subListLength2;
        DebugLog(@"commandID:%d",commandID);
        switch (commandID)
        {
            case DeviceSwitchCommondID:
            {
                DebugLog(@"Receive DeviceSwitchCommondID");
                NSArray *errorLightsArr = [self parserDeviceSwitchWithLength:length
                                                                  ListLength:listLength
                                                                        Data:pData];
                if (errorLightsArr)
                {
                    DebugLog(@"DeviceSwitchError");
                    [[NSNotificationCenter defaultCenter] postNotificationName:DeviceSwitchError object:errorLightsArr];
                }
            }
                break;
                
            case DeviceDiscoveryCommondID:
            {
                DebugLog(@"Receive DeviceDiscoveryCommondID");
                NSArray *devicesArr = [self parserDeviceDiscoveryWithLength:length
                                                                 ListLength:listLength
                                                                       Data:pData];
                if (devicesArr)
                {
                    self.allDeviceArr = [NSMutableArray arrayWithArray:devicesArr];
                    DebugLog(@"DidDiscoveryDevice");
                }
                else
                {
                    self.allDeviceArr = nil;
                }
            
                [[NSNotificationCenter defaultCenter] postNotificationName:DidDiscoveryDevice object:devicesArr];
            }
                break;
                
            case CheckDeviceStatusCommondID:
            {
                DebugLog(@"Receive CheckDeviceStatusCommondID");
                NSArray *devicesArr = [self parserCheckDeviceStatusWithLength:length
                                                                   ListLength:listLength
                                                                         Data:pData];
                if (devicesArr)
                {
                    NSMutableArray *allDeviceArr = self.allDeviceArr;
                    if (allDeviceArr.count)
                    {
                        for (PLModel_Device *device in devicesArr)
                        {
                            for (PLModel_Device *oldDevice in allDeviceArr)
                            {
                                //对比Mac Address，相同则替换
                                if ([device.macAddress isEqualToData:oldDevice.macAddress])
                                {
                                    int index = (int)[allDeviceArr indexOfObject:oldDevice];
                                    [allDeviceArr replaceObjectAtIndex:index withObject:device];
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        allDeviceArr = [NSMutableArray arrayWithArray:devicesArr];
                    }
                    
                    self.allDeviceArr = allDeviceArr;
                    DebugLog(@"DidRefreshDeviceStatus");
                  [[NSNotificationCenter defaultCenter] postNotificationName:DidRefreshDeviceStatus object:devicesArr];
                }
            }
                break;
                
            case JoinNetworkCommondID:
            {
                DebugLog(@"Receive JoinNetworkCommondID");
                NSArray *newDevicesArr = [self parserNewDeviceDiscoveryWithLength:length
                                                                       ListLength:listLength
                                                                             Data:pData];
                if (newDevicesArr)
                {
                    NSMutableArray *allDevicesArr = self.allDeviceArr;
                    [allDevicesArr addObjectsFromArray:newDevicesArr];
                    self.allDeviceArr = allDevicesArr;
                    DebugLog(@"NewDeviceDiscovery");
                    [[NSNotificationCenter defaultCenter] postNotificationName:NewDeviceDiscovery object:newDevicesArr];
                }
            }
                break;
                
            case LightsDimCommondID:
            {
                DebugLog(@"Receive LightsDimCommondID");
                NSArray *errorLightsArr = [self parserLightsDimWithLength:length
                                                               ListLength:listLength
                                                                     Data:pData];
                if (errorLightsArr)
                {
                    DebugLog(@"LightsDimError");
                    [[NSNotificationCenter defaultCenter] postNotificationName:LightsDimError object:errorLightsArr];
                }
            }
                break;
                
            case LightsColorCommondID:
            {
                DebugLog(@"Receive LightsColorCommondID");
                BOOL succeed = [self parserLightsColorWithLength:length
                                                      ListLength:listLength
                                                            Data:pData];
                if (succeed)
                {
                    DebugLog(@"LightsColorSucceed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:LightsColorSucceed object:nil];
                }
                else
                {
                    DebugLog(@"LightsColorFailed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:LightsColorFailed object:nil];
                }
            }
                break;
                
            case LightsNormalCommondID:
            {
                DebugLog(@"Receive LightsNormalCommondID");
                BOOL succeed = [self parserLightsNormalWithLength:length
                                                       ListLength:listLength
                                                             Data:pData];
                if (succeed)
                {
                    DebugLog(@"LightsNormalSucceed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:LightsNormalSucceed object:nil];
                }
                else
                {
                    DebugLog(@"LightsNormalFailed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:LightsNormalFailed object:nil];
                }
            }
                break;
                
            case GetAlarmInfoCommondID:
            {
                
            }
                break;
                
            case LightsRemoveCommondID:
            {
                DebugLog(@"Receive LightsRemoveCommondID");
                BOOL succeed = [self parserLightsRemoveWithLength:length
                                                       ListLength:listLength
                                                             Data:pData];
                if (succeed)
                {
                    DebugLog(@"LightsRemoveSucceed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:LightsRemoveSucceed object:nil];
                }
                else
                {
                    DebugLog(@"LightsRemoveFailed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:LightsRemoveFailed object:nil];
                }
            }
                break;
                
            case LightsIdentifyCommondID:
            {
                
            }
                break;
                
            case GroupSetupCommondID:
            {
                DebugLog(@"Receive GroupSetupCommondID");
                BOOL succeed = [self parserGroupSetupWithLength:length
                                                     ListLength:listLength
                                                           Data:pData];
                if (succeed)
                {
                    DebugLog(@"GroupSetupSucceed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:GroupSetupSucceed object:nil];
                }
                else
                {
                    DebugLog(@"GroupSetupFailed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:GroupSetupFailed object:nil];
                }
            }
                break;
                
            case GroupConfigCommondID:
            {
                DebugLog(@"Receive GroupConfigCommondID");
                BOOL succeed = [self parserGroupConfigWithLength:length
                                                      ListLength:listLength
                                                            Data:pData];
                if (succeed)
                {
                    DebugLog(@"GroupConfigSucceed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:GroupConfigSucceed object:nil];
                }
                else
                {
                    DebugLog(@"GroupConfigFailed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:GroupConfigFailed object:nil];
                }
            }
                break;
                
            case GroupQueryCommondID:
            {
                DebugLog(@"Receive GroupQueryCommondID");
                PLModel_Group *group = [self parserGroupQueryWithLength:length
                                                             ListLength:listLength
                                                                   Data:pData];
                if (group)
                {
                    DebugLog(@"GroupQuerySucceed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:GroupQuerySucceed object:group];
                }
                else
                {
                    DebugLog(@"GroupQueryFailed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:GroupQueryFailed object:nil];
                }
            }
                break;
                
            case AlarmInformCommondID:
            {
                DebugLog(@"Receive AlarmInformCommondID");
                PLModel_Device *device = [self parserAlarmInformWithLength:length
                                                                ListLength:listLength
                                                                      Data:pData];
                if (device)
                {
                    DebugLog(@"ReceiveAlarmInform");
                    [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveAlarmInform object:device];
                }
            }
                break;
                
            case IPSetCommondID:
            {
                DebugLog(@"Receive IPSetCommondID");
                BOOL succeed = [self parserSetGetwayIPWithLength:length
                                                      ListLength:listLength
                                                            Data:pData];
                if (succeed)
                {
                    DebugLog(@"SetGatewayIPSucceed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:SetGetwayIPSucceed object:nil];
                }
                else
                {
                    DebugLog(@"SetGatewayIPFailed");
                    [[NSNotificationCenter defaultCenter] postNotificationName:SetGetwayIPFailed object:nil];
                }
            }
                break;
                
            case SecurityStateRequestCommandID:
            {
                DebugLog(@"Receive SecurityStateRequestCommandID");
                PLModel_SecurityStateResult *result = [self parserSecurityStateRequestWithLength:length
                                                                                      ListLength:listLength
                                                                                            Data:pData];
                if (self.sensorArr.count)
                {
                    for (PLModel_Device *device in result.sensorsArr)
                    {
                        for (PLModel_Device *oldDevice in self.sensorArr)
                        {
                            if ([device.macAddress isEqualToData:oldDevice.macAddress])
                            {
                                oldDevice.onOff = device.onOff;
                                break;
                            }
                        }
                    }
                    
                    result.sensorsArr = self.sensorArr;
                }
                else
                {
                    self.sensorArr = [NSMutableArray arrayWithArray:result.sensorsArr];
                }
                
                DebugLog(@"SecurityStateRequestSucceed");
                [[NSNotificationCenter defaultCenter] postNotificationName:SecurityStateRequestSucceed object:result];
            }
                break;
                
            case CredentialAskCommondID:
            {
                DebugLog(@"Receive CredentialAskCommondID");
                NSData *credentialData = [self parserCredentialAskWithLength:length
                                                                  ListLength:listLength
                                                                        Data:pData];
                if (credentialData)
                {
                    DebugLog(@"DidGetCredentialAsk");
                    if (self.currentServerType == CloudServerType) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:DidGetCredentialWhenCloud object:credentialData];
                    }else if (self.currentServerType ==GatewayType){
                        [[NSNotificationCenter defaultCenter] postNotificationName:DidGetCredential object:credentialData];
                    }
                }
            }
                break;
                
            case CredentialSendCommondID:
            {
                DebugLog(@"Receive CredentialSendCommondID");
                int gatewayNum = [self parserCredentialSendWithLength:length
                                                           ListLength:listLength
                                                                 Data:pData];
                if (gatewayNum)
                {
                    DebugLog(@"ReceiveCredentialSendResponse");
                    NSNumber *num = [NSNumber numberWithInt:gatewayNum];
                    [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveCredentialSendResponse object:num];
                }
            }
                break;
                
            case GatewayChooseCommondID:
            {
                DebugLog(@"Receive GatewayChooseCommondID");
                
            }
                break;
                
            case CIDAskCommondID:
            {
                DebugLog(@"Receive CIDAskCommondID");
                NSData *cidData = [self parserCIDAskWithLength:length
                                                    ListLength:listLength
                                                          Data:pData];
                if (cidData)
                {
                    DebugLog(@"DidGetCID");
                    self.currentConnectedGatewayCID = cidData;
                    [[NSNotificationCenter defaultCenter] postNotificationName:DidGetCID object:cidData];
                }
            }
                break;
                
            case CheckUserCredentialCommandID:
            {
                DebugLog(@"Receive CheckUserCredentialCommandID");
                PLModel_CheckResult *checkResult = [self parserCheckUserCredentialWithLength:length
                                                                                  ListLength:listLength
                                                                                        Data:pData];
                if (checkResult)
                {
                    if ([[PLUserInfoManager sharedManager] tempUserCredentialStr])
                    {
                        if (!checkResult.hasAlreadyExist)
                        {
                            DebugLog(@"UserCredentialIsUnique");
                            [[NSNotificationCenter defaultCenter] postNotificationName:TempUserCredentialIsUnique object:checkResult];
                        }
                        else
                        {
                            DebugLog(@"UserCredentialHasAlreadyExist");
                            [[NSNotificationCenter defaultCenter] postNotificationName:TempUserCredentialHasAlreadyExist object:checkResult];
                        }
                    }
                    else
                    {
                        if (!checkResult.hasAlreadyExist)
                        {
                            DebugLog(@"UserCredentialIsUnique");
                            [[NSNotificationCenter defaultCenter] postNotificationName:UserCredentialIsUnique object:checkResult];
                        }
                        else
                        {
                            DebugLog(@"UserCredentialHasAlreadyExist");
                            [[NSNotificationCenter defaultCenter] postNotificationName:UserCredentialHasAlreadyExist object:checkResult];
                        }
                    }
                }
            }
                break;
                
            case UserCredentialGMCommandID:
            {
                DebugLog(@"Receive UserCredentialGMCommandID");
                [[NSNotificationCenter defaultCenter] postNotificationName:DidSendUserCredentialGM object:nil];
            }
                break;
                
            case MobileDeviceInfoCommandID:
            {
                DebugLog(@"Receive MobileDeviceInfoCommandID");
                [[NSNotificationCenter defaultCenter] postNotificationName:DidSendCellPhoneInfo object:nil];
            }
                break;
                
            case GateWayCurrentVersionCommandID:
            {
                DebugLog(@"Receive GateWayCurrentVersionCommandID");
                NSString *currentVersion = [self parserGatewayCurrentVersionWithLength:length
                                                                            ListLength:listLength
                                                                                  Data:pData];
                [[NSNotificationCenter defaultCenter] postNotificationName:DidGetGatewayCurrentVersion
                                                                    object:currentVersion];
            }
                break;
                
            case SceneControlCommandID:
            {
                DebugLog(@"Receive SceneControlCommandID");
                BOOL succeed = [self parserSceneControlWithLength:length
                                                       ListLength:listLength
                                                             Data:pData];
                if (succeed)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SceneControlSucceed
                                                                        object:nil];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SceneControlFailed
                                                                        object:nil];
                }
            }
                break;
                
            case SecurityStateSelectCommandID:
            {
                DebugLog(@"Receive SecurityStateSelectCommandID");
                [[NSNotificationCenter defaultCenter] postNotificationName:SecurityStateSelectSucceed object:nil];
            }
                break;
                
            case ResetOrRebootCommandID:
            {
                DebugLog(@"Receive ResetOrRebootCommandID");
                [[NSNotificationCenter defaultCenter] postNotificationName:ResetRebootSucceed object:nil];
            }
                break;
                
            case LastestVersionCommandID:
            {
                DebugLog(@"Receive LastestVersionCommandID");
                NSString *lastestVersion = [self parserFirmwareVervionStoredInCloudWithLength:length
                                                                                   ListLength:listLength
                                                                                         Data:pData];
                [[NSNotificationCenter defaultCenter] postNotificationName:DidGetLastestVersion
                                                                    object:lastestVersion];
            }
                break;
            case StartUpDateCommandId:
            {
                DebugLog(@"Receive StartUpDateCommandId AND Accept CurrentPage");
                [self parserGetCurrentPageInCloudWithLength:length ListLength:listLength Data:pData];
                [[NSNotificationCenter defaultCenter] postNotificationName:DidAccpetTotalpage
                                                                    object:nil];
            }
                break;
                
            case EnableAlarmGWCommandID:
            {
                DebugLog(@"Receive EnableAlarmGWCommandID");
                [[NSNotificationCenter defaultCenter] postNotificationName:SwitchSoundSucceed object:nil];
            }
                break;
            case SendUserCredentialToCloudServerCommandID:
            {
                DebugLog(@"Receive SendUserCredentialToCloudServerCommandID");
                [[NSNotificationCenter defaultCenter] postNotificationName:CredentialSucceed object:nil];
            }
                break;
            case Deltokenbind:
            {
                DebugLog(@"Receive DeltokenbindCommandID");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"Deltokenbind" object:nil];
            }
                break;
            default:
                break;
        }
        
        if (pData)
        {
            //指针向后移length byte跳过Data
            pData = pData + length;
            //指针向后移1byte跳过FCS
            pData++;
            //指针向后移2byte跳过END,粘包情况下便于继续解析
            pData = pData + 2;
            [self parserReceivedData:pData];
        }
    }
}

#pragma mark - saveWifiNameAndGateWayIPAddress

- (void)saveWifiNameAndGateWayIPAddress
{
    if (self.currentServerType == GatewayType)
    {
        NSString *currentWifiName = [self currentConnectWifiName];
        if (currentWifiName)
        {
            //保存wifi Name
            NSMutableArray *connectedWifiArr = self.connectedWifiArr;
            if (![connectedWifiArr containsObject:currentWifiName])
            {
                   DebugLog(@"wifi§数组保存");
                [connectedWifiArr addObject:currentWifiName];
                self.connectedWifiArr = connectedWifiArr;
             
            }
              DebugLog(@"wifi:%@",connectedWifiArr);
            
            //保存网关的IP地址到对应的Wifi Name下
            NSMutableDictionary *tempDict = self.gateWayInfoDict;
            if (!tempDict)
            {
                tempDict = [NSMutableDictionary new];
            }
            NSMutableArray *gateWayIPArr =[NSMutableArray arrayWithArray:(NSArray*)tempDict[currentWifiName]];
            for (NSDictionary *wifi in connectedWifiArr) {
                DebugLog(@"wifi and  Ip :%@",tempDict[wifi]);
            }
            if (!gateWayIPArr)
            {
                     DebugLog(@"111wifi§数组保存§下保存ip");
                gateWayIPArr = [NSMutableArray new];
                [gateWayIPArr addObject:self.currentConnectedGatewayIP];
            }
            else
            {
                DebugLog(@"IP:%@",gateWayIPArr);
                   DebugLog(@"222wifi§数组保存§下保存ip");
                if (![gateWayIPArr containsObject:self.currentConnectedGatewayIP])//判断是否存在
                {
                    DebugLog(@"cunzai%@",self.currentConnectedGatewayIP);
                    [gateWayIPArr addObject:self.currentConnectedGatewayIP];
               
                }
            }
            [tempDict setValue:gateWayIPArr forKey:currentWifiName];
            self.gateWayInfoDict = tempDict;
        }
    }
}

#pragma mark - currentConnectWifiName
//连上的wifi
- (NSString *)currentConnectWifiName
{
//    NSString *currentWifiName;
//    CFArrayRef wifiArray = CNCopySupportedInterfaces();
//    if (wifiArray)
//    {
//        CFDictionaryRef tempDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(wifiArray, 0));
//        if (tempDict)
//        {
//            NSDictionary *currentWifiDict = (NSDictionary*)CFBridgingRelease(tempDict);
//            currentWifiName = [currentWifiDict valueForKey:@"SSID"];
//        }
//    }
//    DebugLog(@"\n\nCurrentConnectWifiName:%@\n\n",currentWifiName);
//    return currentWifiName;
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
     DebugLog(@"\n\nCurrentConnectWifiName:%@\n\n",wifiName);
    return wifiName;

}

#pragma mark - connectedWifiArr

- (NSMutableArray *)connectedWifiArr
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *tempArr = [userDefault objectForKey:@"connectedWifiArr"];
    if (tempArr)
    {
        return [NSMutableArray arrayWithArray:tempArr];
    }
    
    return [NSMutableArray new];
}

- (void)setConnectedWifiArr:(NSMutableArray *)connectedWifiArr
{
    if (connectedWifiArr.count)
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:connectedWifiArr forKey:@"connectedWifiArr"];
        [userDefault synchronize];
    }
}

#pragma mark - gatewayCredentialArr

- (void)saveGatewayCredential:(NSData *)credentialData
{
    NSMutableArray *gatewayCredentialArr = self.gatewayCredentialArr;
    if (!gatewayCredentialArr)
    {
        gatewayCredentialArr = [NSMutableArray new];
    }
    
    if (![gatewayCredentialArr containsObject:credentialData])
    {
        DebugLog(@"存新的凭证");
        [gatewayCredentialArr insertObject:credentialData atIndex:gatewayCredentialArr.count];
    }
    self.gatewayCredentialArr = gatewayCredentialArr;
}
- (void)deleteGatewayCredential:(NSData *)credentialData
{
    NSMutableArray *gatewayCredentialArr = self.gatewayCredentialArr;
    DebugLog(@"删除前：%@",self.gatewayCredentialArr);
    if (!gatewayCredentialArr)
    {
        DebugLog(@"还没有存凭证");
    }
    
    if (![gatewayCredentialArr containsObject:credentialData])
    {
         DebugLog(@"还没有存凭证");
    }
    if ([gatewayCredentialArr containsObject:credentialData])
    {
        NSInteger indexx = [gatewayCredentialArr indexOfObject:credentialData];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSArray *tempArr = [userDefault objectForKey:@"gatewayCredentialArr"];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:tempArr];
//        [arr removeObject:credentialData];
        [arr replaceObjectAtIndex:indexx withObject:@"-----------------------------------"];
        [userDefault setObject:arr forKey:@"gatewayCredentialArr"];
        [userDefault synchronize];
        DebugLog(@"删除凭证成功");
    }
//    self.gatewayCredentialArr = gatewayCredentialArr;
        DebugLog(@"删除后：%@",self.gatewayCredentialArr);
}

- (NSMutableArray *)gatewayCredentialArr
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *tempArr = [userDefault objectForKey:@"gatewayCredentialArr"];
    if (tempArr)
    {
        return [NSMutableArray arrayWithArray:tempArr];
    }
    
    return nil;
}

- (void)setGatewayCredentialArr:(NSMutableArray *)gatewayCredentialArr
{
    if (gatewayCredentialArr.count)
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:gatewayCredentialArr forKey:@"gatewayCredentialArr"];
        [userDefault synchronize];
    }
}

#pragma mark - gateWayInfoDict

- (NSMutableDictionary *)gateWayInfoDict
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *tempDict = [userDefault objectForKey:@"gateWayInfoDict"];
    if (tempDict)
    {
        return [NSMutableDictionary dictionaryWithDictionary:tempDict];
    }
    
    return nil;
}

- (void)setGateWayInfoDict:(NSDictionary *)gateWayInfoDict
{
    if (gateWayInfoDict)
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:gateWayInfoDict forKey:@"gateWayInfoDict"];
        [userDefault synchronize];
    }
}


@end
