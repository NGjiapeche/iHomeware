//
//  PLAlertsCell.m
//  PilotLaboratories
//
//  Created by yuchangtao on 14-5-7.
//  Copyright (c) 2014年 yct. All rights reserved.
//

#import "PLAlertsCell.h"

@implementation PLAlertsCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PLAlertsCell" owner:self options:nil];
    if (nib)
    {
        self = nib[0];
        return self;
    }
    return nil;
    
}
-(void)setcelldevicename:(PLModel_Device *)device withindex:(NSInteger)index{
     DebugLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~%d~~~~~~~~~~%@",device.deviceType,device.deviceName);
    switch (device.deviceType)
    {
        case Becon:
        {
            NSString *deviceName;
            if (device.deviceName.length == 0){
                deviceName = [NSString stringWithFormat:NSLocalizedString(@"Becon%d", nil),index+ 1];
                device.deviceName = deviceName;
                self.titleLabel.text = deviceName;
            }  else
            {
                self.titleLabel.text = [NSString stringWithFormat:@"%@",device.deviceName];
            };
        }
            break;
        case PanicSensorType:
        {
            NSString *deviceName;
            if (device.deviceName.length == 0){
                deviceName = [NSString stringWithFormat:NSLocalizedString(@"PanicSensor%d", nil),index+ 1];
                device.deviceName = deviceName;
                self.titleLabel.text = deviceName;
            }  else
            {
                self.titleLabel.text = [NSString stringWithFormat:@"%@",device.deviceName];
            }

        }
            break;
        case TemperatureSensorType:
        {

            NSString *deviceName;
            if (device.deviceName.length == 0){
                deviceName = [NSString stringWithFormat:NSLocalizedString(@"TemperatureSensor%d", nil),index+ 1];
                device.deviceName = deviceName;
                self.titleLabel.text = deviceName;
            }  else
            {
                self.titleLabel.text = [NSString stringWithFormat:@"%@",device.deviceName];
            }
        }
            break;
            
        case DoorSensorType:
        {

            NSString *deviceName;
            if (device.deviceName.length == 0){
                deviceName = [NSString stringWithFormat:NSLocalizedString(@"DoorSensor%d", nil),index+ 1];
                device.deviceName = deviceName;
                self.titleLabel.text = deviceName;
            }  else
            {
                self.titleLabel.text = [NSString stringWithFormat:@"%@",device.deviceName];
            }
        }
            break;
            
        case PirSensorType:
        {

            NSString *deviceName;
            if (device.deviceName.length == 0){
                deviceName = [NSString stringWithFormat:NSLocalizedString(@"PirSensor%d", nil),index+ 1];
                device.deviceName = deviceName;
                self.titleLabel.text = deviceName;
            }  else
            {
                self.titleLabel.text = [NSString stringWithFormat:@"%@",device.deviceName];
            }
        }
            break;
            
        case GravitySensorType:
        {
            NSString *deviceName;

            if (device.deviceName.length == 0){
                deviceName = [NSString stringWithFormat:NSLocalizedString(@"GravitySensor%d", nil),index+ 1];
                device.deviceName = deviceName;
                self.titleLabel.text = deviceName;
            }  else
            {
                self.titleLabel.text = [NSString stringWithFormat:@"%@",device.deviceName];
            }
        }
            break;
            
        case VibrationSensorType:
        {

            NSString *deviceName;
            if (device.deviceName.length == 0){
                deviceName = [NSString stringWithFormat:NSLocalizedString(@"CoinGuard%d", nil),index+ 1];
                device.deviceName = deviceName;
                self.titleLabel.text = deviceName;
            }  else
            {
                self.titleLabel.text = [NSString stringWithFormat:@"%@",device.deviceName];
            }
        }
            break;
        case SmokeSensorType:
        {

            NSString *deviceName;
            if (device.deviceName.length == 0){
                deviceName = [NSString stringWithFormat:NSLocalizedString(@"SmokeSensor%d", nil),index+ 1];
                device.deviceName = deviceName;
                self.titleLabel.text = deviceName;
            }  else
            {
                self.titleLabel.text = [NSString stringWithFormat:@"%@",device.deviceName];
            }
        }
            break;
        case CO2SenserType:
        {

            NSString *deviceName;
            if (device.deviceName.length == 0){
                deviceName = [NSString stringWithFormat:NSLocalizedString(@"CO2Senser%d", nil),index+ 1];
                device.deviceName = deviceName;
                self.titleLabel.text = deviceName;
            }  else
            {
                self.titleLabel.text = [NSString stringWithFormat:@"%@",device.deviceName];
            }
        }
            break;
        case COSenserType:
        {

            NSString *deviceName;
            if (device.deviceName.length == 0){
                deviceName = [NSString stringWithFormat:NSLocalizedString(@"COSenser%d", nil),index+ 1];
                device.deviceName = deviceName;
                self.titleLabel.text = deviceName;
            }  else
            {
                self.titleLabel.text = [NSString stringWithFormat:@"%@",device.deviceName];
            }
        }
            break;
        case WaterSensorType:
        {

            NSString *deviceName;
            if (device.deviceName.length == 0){
                deviceName = [NSString stringWithFormat:NSLocalizedString(@"WaterSensor%d", nil),index+ 1];
                device.deviceName = deviceName;
                self.titleLabel.text = deviceName;
            }  else
            {
                self.titleLabel.text = [NSString stringWithFormat:@"%@",device.deviceName];
            }
        }
            break;
        case WebcamTy:
        {

            NSString *deviceName;
            if (device.deviceName.length == 0){
                deviceName = [NSString stringWithFormat:NSLocalizedString(@"WebcamTy%d", nil),index+ 1];
                device.deviceName = deviceName;
                self.titleLabel.text = deviceName;
            }  else
            {
                self.titleLabel.text = [NSString stringWithFormat:@"%@",device.deviceName];
            }
        }
            break;
            
        default:
            break;
    }
    
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
