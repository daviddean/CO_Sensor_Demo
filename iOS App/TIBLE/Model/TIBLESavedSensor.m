/*
 *  TIBLESavedSensor.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLESavedSensor.h"
#import "TIBLESensorConstants.h"

@implementation TIBLESavedSensor

+ (TIBLESavedSensor *)sharedTIBLESavedSensor {
    static TIBLESavedSensor *sharedTIBLESavedSensor = nil;
    
    if (!sharedTIBLESavedSensor) {
        sharedTIBLESavedSensor = [[super allocWithZone:nil] init];
    }
    
    return sharedTIBLESavedSensor;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedTIBLESavedSensor];
}

- (id)init {
    self = [super init];
    
    if (self) {
        if (!savedSensors) {
            
            savedSensors = [[[NSUserDefaults standardUserDefaults]
                             dictionaryForKey:kSavedSensorNamesKey] mutableCopy];
        }
    }
    
    return self;
}

- (NSString *)getNameWithUUID:(CFUUIDRef)uuid {
    
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    NSString *name = nil;
    
    if ([savedSensors objectForKey:uuidString] != nil) {
        name = [savedSensors objectForKey:uuidString];
    }
    
    return  name;
}

- (void)setSensorWithUUID:(CFUUIDRef)uuid withName:(NSString *)name {
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    
    if (!savedSensors)
        savedSensors = [[NSMutableDictionary alloc] init];
    
    [savedSensors setObject:name forKey:uuidString];
    
    [[NSUserDefaults standardUserDefaults] setObject:savedSensors forKey:kSavedSensorNamesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
