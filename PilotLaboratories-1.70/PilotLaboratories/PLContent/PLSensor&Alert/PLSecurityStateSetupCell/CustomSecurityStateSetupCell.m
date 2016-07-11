//
//  CustomSecurityStateSetupCell.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-8.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "CustomSecurityStateSetupCell.h"

@implementation CustomSecurityStateSetupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomSecurityStateSetupCell" owner:self options:nil];
    if (nib)
    {
        self = nib[0];
        return self;
    }
    return nil;
    
}
-(void)setcellinfo:(PLModel_Device *)device withindex:(NSInteger)index{

    
        switch (device.deviceType)
        {
            case Becon:
            {
                NSString *deviceName;
                if (device.deviceName.length == 0){
                     deviceName = [NSString stringWithFormat:NSLocalizedString(@"Becon%d", nil),index+ 1];
                      device.deviceName = deviceName;
                     self.labelSensor.text = deviceName;
                }  else
                {
                    self.labelSensor.text = [NSString stringWithFormat:@"%@",device.deviceName];
                }
                self.switchOnOrOff.hidden = YES;
            }
                break;
            case PanicSensorType:
            {
                NSString *deviceName;
                if (device.deviceName.length == 0){
                    deviceName = [NSString stringWithFormat:NSLocalizedString(@"PanicSensor%d", nil),index+ 1];
                    device.deviceName = deviceName;
                    self.labelSensor.text = deviceName;
                }  else
                {
                    self.labelSensor.text = [NSString stringWithFormat:@"%@",device.deviceName];
                }
                self.switchOnOrOff.hidden = YES;
            }
                break;
            case TemperatureSensorType:
            {
                 self.switchOnOrOff.hidden = NO;
                NSString *deviceName;
                if (device.deviceName.length == 0){
                    deviceName = [NSString stringWithFormat:NSLocalizedString(@"TemperatureSensor%d", nil),index+ 1];
                    device.deviceName = deviceName;
                    self.labelSensor.text = deviceName;
                }  else
                {
                    self.labelSensor.text = [NSString stringWithFormat:@"%@",device.deviceName];
                }
            }
                break;
                
            case DoorSensorType:
            {
                 self.switchOnOrOff.hidden = NO;
                NSString *deviceName;
                if (device.deviceName.length == 0){
                    deviceName = [NSString stringWithFormat:NSLocalizedString(@"DoorSensor%d", nil),index+ 1];
                    self.labelSensor.text = deviceName;
                }  else
                {
                    self.labelSensor.text = [NSString stringWithFormat:@"%@",device.deviceName];
                }
            }
                break;
                
            case PirSensorType:
            {
                 self.switchOnOrOff.hidden = NO;
                NSString *deviceName;
                if (device.deviceName.length == 0){
                    deviceName = [NSString stringWithFormat:NSLocalizedString(@"PirSensor%d", nil),index+ 1];
                    device.deviceName = deviceName;
                    self.labelSensor.text = deviceName;
                }  else
                {
                    self.labelSensor.text = [NSString stringWithFormat:@"%@",device.deviceName];
                }
            }
                break;
                
            case GravitySensorType:
            {
                NSString *deviceName;
                self.switchOnOrOff.hidden = NO;
                if (device.deviceName.length == 0){
                    deviceName = [NSString stringWithFormat:NSLocalizedString(@"GravitySensor%d", nil),index+ 1];
                    device.deviceName = deviceName;
                    self.labelSensor.text = deviceName;
                }  else
                {
                    self.labelSensor.text = [NSString stringWithFormat:@"%@",device.deviceName];
                }
            }
                break;
                
            case VibrationSensorType:
            {
                 self.switchOnOrOff.hidden = NO;
                NSString *deviceName;
                if (device.deviceName.length == 0){
                    deviceName = [NSString stringWithFormat:NSLocalizedString(@"CoinGuard%d", nil),index+ 1];
                    device.deviceName = deviceName;
                    self.labelSensor.text = deviceName;
                }  else
                {
                    self.labelSensor.text = [NSString stringWithFormat:@"%@",device.deviceName];
                }
            }
                break;
            case SmokeSensorType:
            {
                self.switchOnOrOff.hidden = YES;
                NSString *deviceName;
                if (device.deviceName.length == 0){
                    deviceName = [NSString stringWithFormat:NSLocalizedString(@"SmokeSensor%d", nil),index+ 1];
                    device.deviceName = deviceName;
                    self.labelSensor.text = deviceName;
                }  else
                {
                    self.labelSensor.text = [NSString stringWithFormat:@"%@",device.deviceName];
                }
            }
                break;
            case CO2SenserType:
            {
                self.switchOnOrOff.hidden = YES;
                NSString *deviceName;
                if (device.deviceName.length == 0){
                    deviceName = [NSString stringWithFormat:NSLocalizedString(@"CO2Senser%d", nil),index+ 1];
                    device.deviceName = deviceName;
                    self.labelSensor.text = deviceName;
                }  else
                {
                    self.labelSensor.text = [NSString stringWithFormat:@"%@",device.deviceName];
                }
            }
                break;
            case COSenserType:
            {
                self.switchOnOrOff.hidden = YES;
                NSString *deviceName;
                if (device.deviceName.length == 0){
                    deviceName = [NSString stringWithFormat:NSLocalizedString(@"COSenser%d", nil),index+ 1];
                    device.deviceName = deviceName;
                    self.labelSensor.text = deviceName;
                }  else
                {
                    self.labelSensor.text = [NSString stringWithFormat:@"%@",device.deviceName];
                }
            }
                break;
            case WaterSensorType:
            {
                self.switchOnOrOff.hidden = YES;
                NSString *deviceName;
                if (device.deviceName.length == 0){
                    deviceName = [NSString stringWithFormat:NSLocalizedString(@"WaterSensor%d", nil),index+ 1];
                    device.deviceName = deviceName;
                    self.labelSensor.text = deviceName;
                }  else
                {
                    self.labelSensor.text = [NSString stringWithFormat:@"%@",device.deviceName];
                }
            }
                break;
            case WebcamTy:
            {
                self.switchOnOrOff.hidden = NO;
                NSString *deviceName;
                if (device.deviceName.length == 0){
                    deviceName = [NSString stringWithFormat:NSLocalizedString(@"WebcamTy%d", nil),index+ 1];
                    device.deviceName = deviceName;
                    self.labelSensor.text = deviceName;
                }  else
                {
                    self.labelSensor.text = [NSString stringWithFormat:@"%@",device.deviceName];
                }
            }
                break;
                
            default:
                break;
        }

  
    DebugLog(@"~~~~~~~~~~~~~~~~~~~~~%d~~~~~~~~%@~~~~~~~~~~%@ ！！！%d!!!%d",device.onOff,device.macAddress,device.deviceName,device.firstShortAddr,device.secondShortAddr);
    if (device.onOff)
    {
        self.switchOnOrOff.on = YES;
    }
    else
    {
        self.switchOnOrOff.on = NO;
    }
    if (device.issi > 0 && device.issi <= 168) {
        dispatch_async(dispatch_get_main_queue(), ^{
                    self.issiimg.image = [UIImage imageNamed:@"rssi_leve1"];
        });
    }else if (device.issi > 168 && device.issi <= 185) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.issiimg.image = [UIImage imageNamed:@"rssi_leve2"];
        });
    }else if (device.issi > 185 && device.issi <= 202) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.issiimg.image = [UIImage imageNamed:@"rssi_leve3"];
            });
    }
    else if (device.issi > 202 ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.issiimg.image = [UIImage imageNamed:@"rssi_leve4"];
        });
    }else if(device.issi == 0){
         dispatch_async(dispatch_get_main_queue(), ^{
            self.labelSensor.frame  = CGRectMake(10, self.labelSensor.frame.origin.y, self.labelSensor.frame.size.width, self.labelSensor.frame.size.height);
         });

    }
}
- (IBAction)swichOnOrOffPressed:(UISwitch *)sender
{
    BOOL isbtnOn = [sender isOn];
    if ([self.delegate respondsToSelector:@selector(swichPressedOnCell:andSwichStatus:)])
    {
        [self.delegate swichPressedOnCell:self andSwichStatus:isbtnOn];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
