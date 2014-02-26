/*
 *  TIBLESensorModel.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import "TIBLESensorProfile.h"
#import "TIBLERawDataModel.h"
#import "TIBLESampleQueue.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TIBLEPeripheral.h"

//model for sensor that has been connected at least once (assume connected).

@interface TIBLESensorModel : NSObject <NSCopying>

@property (nonatomic, assign) BOOL isCalibrated;

//these properties are nil if the sensor is not connected.
@property (nonatomic, strong) TIBLESensorProfile * sensorProfile;
@property (nonatomic, strong) TIBLESampleQueue * sensorSamples;
@property (nonatomic, strong) TIBLEPeripheral * peripheral;
@property (nonatomic, assign) float_t adc_cal;

- (id) initWithPeripheral: (TIBLEPeripheral *) ti_peripheral;

- (void) updateSensorData:(NSString *) characteristic value:(TIBLERawDataModel *) valueModel;

- (UIColor *) colorForLatestSample;

- (void) calibrate;
- (float) voutValue: (float) adc_val;
- (float) formulaValue: (float) adc_val;
- (float) value: (float) adc_val;
- (TIBLESampleModel *) latestSample;
- (float) latestValue;
- (float) maxValue;
- (float) minValue;
- (BOOL) isCalibrating;

@end
