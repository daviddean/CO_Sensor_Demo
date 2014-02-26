/*
 *  TIBLECharacteristics.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TIBLEUtilities.h"

@interface TIBLECharacteristics : NSObject

@property (nonatomic, strong) CBUUID * serviceUUID;
@property (nonatomic, strong) NSMutableDictionary * characteristics; //found

- (void) addCharacteristic:(CBCharacteristic *)characteristic;
- (CBCharacteristic *) characteristicForUUID: (NSString *) uuidKeyString;

@end
