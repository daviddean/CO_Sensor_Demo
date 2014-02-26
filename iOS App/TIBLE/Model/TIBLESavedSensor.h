/*
 *  TIBLESavedSensor.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

/**
* Singleton class used to manage the device names
* given to sensors in the connect tab.
*/

#import <Foundation/Foundation.h>

@interface TIBLESavedSensor : NSObject {
    NSMutableDictionary *savedSensors;
}

+ (TIBLESavedSensor *) sharedTIBLESavedSensor;

/**
* @param uuid The uuid of the sensor.
* @returns Name assigned to sensor.
*/
- (NSString *)getNameWithUUID:(CFUUIDRef)uuid;


/**
* @param uuid The uuid of the sensor.
* @param name The name to assign to this uuid.
*/
- (void)setSensorWithUUID:(CFUUIDRef)uuid withName:(NSString *)name;

@end
