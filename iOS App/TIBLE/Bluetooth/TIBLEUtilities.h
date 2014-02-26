/*
 *  TIBLEUtilities.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TIBLERawDataModel.h"

@interface TIBLEUtilities : NSObject

+ (TIBLERawDataModel *) valueForMeasurementSample:(CBCharacteristic *) characteristic;

+ (NSString *) stringForCFUUID: (CFUUIDRef) uuid;
+ (NSString *) stringForUUID: (CBUUID *) uuid;
+ (UIColor *) colorFromIntARGB4444Value: (int32_t) colorIntValue;
+ (NSString *) dateAndTimeStampString;
+ (NSString *) dateAndTimeStampShortPathString;
+ (NSString *) formattedStringForValue: (float_t) value;

@end
