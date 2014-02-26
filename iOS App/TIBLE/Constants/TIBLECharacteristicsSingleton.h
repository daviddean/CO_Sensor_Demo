/*
 *  TIBLECharacteristicsSingleton.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface TIBLECharacteristicsSingleton : NSObject

+ (TIBLECharacteristicsSingleton *) sharedTIBLECharacteristicsSingleton;

@property (nonatomic, strong) NSDictionary * dictionaryUUIDStrings; //i.e., key = "2DA8" value = "Sensor_Denom_0_Characteristic"

- (NSArray *) generateCharacteristicsUUIDsArray;
- (NSString *) characteristicDescriptionNameFromUUID:(CBUUID *) uuid;
- (NSString *) characteristicKeyStringFromDescriptionName:(NSString *) descriptionName;

@end
