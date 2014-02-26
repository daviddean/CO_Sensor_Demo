/*
 *  CBUUID+StringExtraction.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBUUID (StringExtraction)

- (NSString *)representativeString;

@end
