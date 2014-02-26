/*
 *  TIBLECharacteristics.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLECharacteristics.h"
#import "TIBLESensorConstants.h"

@interface TIBLECharacteristics ()

@end

@implementation TIBLECharacteristics

- (id) init {
    
    self = [super init];
    
    if(self != nil){
        
        self.serviceUUID = [CBUUID UUIDWithString:TIBLE_SENSOR_SERVICE_UUID];
        
        self.characteristics = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void) addCharacteristic:(CBCharacteristic *)characteristic{
    
    NSString * uuidString = [[TIBLEUtilities stringForUUID:[characteristic UUID]] uppercaseString];
    
    [self.characteristics setObject:characteristic forKey:uuidString];
}

- (CBCharacteristic *) characteristicForUUID: (NSString *) uuidKeyString{
	
	return [self.characteristics objectForKey:[uuidKeyString uppercaseString]];
}

@end
