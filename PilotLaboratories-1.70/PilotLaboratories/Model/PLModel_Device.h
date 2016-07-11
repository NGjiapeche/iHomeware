//
//  PLModel_Device.h
//  PilotLaboratories
//
//  Created by 付亚明 on 4/1/14.
//  Copyright (c) 2014 yct. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(char, DeviceType)
{
    LightType = 0x01,
    TemperatureSensorType = 0x07,
    DoorSensorType = 0x03,
    PirSensorType = 0x04,
    GravitySensorType = 0x05,
//    TempSensorType  = 0x07,
    VibrationSensorType = 0x08,
    WaterSensorType = 0x09,
    PanicSensorType = 0x0A,
    SmokeSensorType = 0x0B,
    CO2SenserType = 0x0C,
    COSenserType = 0X0D,
    Becon = 0x0F,
    SwitchType = 0x10,
    WebcamTy = 0x20,
    
};

typedef NS_ENUM (char, AlertType)
{
    SecuritySystemWarningType = 0x01,
    SecuritySystemInformationType = 0x02,
    SecuritySystemErrorType = 0x03,
    HomeAutomationAlertType = 0x04,
    GeneralAlertType = 0x05,
    UpdateAvailableType = 0x06,
};

@interface PLModel_Device : NSObject
//信号
@property (assign, nonatomic)unsigned char issi;
//短地址 2Byte
@property (assign, nonatomic) unsigned char firstShortAddr;
@property (assign, nonatomic) unsigned char secondShortAddr;
//设备类型 1Byte
@property (assign, nonatomic) DeviceType deviceType;
//和网关的连接状态 1Byte
@property (assign, nonatomic) char comFlag;
//传感器状态 2Byte
@property (assign, nonatomic) unsigned char firstSensorStatus;
@property (assign, nonatomic) unsigned char secondSensorStatus;
//报警类型 1Byte
@property (assign, nonatomic) AlertType alertType;
//颜色R 1Byte
@property (assign, nonatomic) unsigned char colorR;
//颜色G 1Byte
@property (assign, nonatomic) unsigned char colorG;
//颜色B 1Byte
@property (assign, nonatomic) unsigned char colorB;
//Dim 1Byte
@property (assign, nonatomic) char Dim;
//开关状态 1Byte
@property (assign, nonatomic) BOOL onOff;
//设备名称
@property (copy, nonatomic) NSString *deviceName;
//设备最近一次报警时间
@property (copy, nonatomic) NSString *deviceAlertTime;
//设备报警时间记录
@property (copy, nonatomic) NSArray *alertTimeList;
//设备报警状态是否打开
@property (assign, nonatomic) BOOL alertStatus;
//设备正在报警
@property (assign, nonatomic) BOOL isAlerting;
//设备序号(使用在灯泡上)
@property (assign, nonatomic) int index;
//X坐标(使用在灯泡上)
@property (assign, nonatomic) int locationX;
//Y坐标(使用在灯泡上)
@property (assign, nonatomic) int locationY;
//Mac地址
@property (strong, nonatomic) NSData *macAddress;
@property (assign, nonatomic) BOOL isSelected;

//场景图标
@property (strong, nonatomic) NSString *strIcon;
//场景调色背景图
@property (strong, nonatomic) NSString *strBackImage;

//纪录设备名称判断
@property (copy, nonatomic) NSString *deviame;
- (NSString *)deviceKey;

@end
