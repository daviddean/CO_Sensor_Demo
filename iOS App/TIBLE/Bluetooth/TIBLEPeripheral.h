/*
 *  TIBLEPeripheral.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class TIBLEService;

@interface TIBLEPeripheral : NSObject

@property (nonatomic, strong) CBPeripheral * peripheral;
@property (nonatomic, strong) TIBLEService * service;

@property (nonatomic, assign) BOOL isConnecting;
@property (nonatomic, assign) BOOL isConnected; //this is whether we are showing
												//to the user if sensor is connected or not.
												//we only show to user one sensor connected.
												//internally, we may have muultiple sensors
												//connected.
@property (nonatomic, strong) NSString * uuidStr;
@property (nonatomic, strong) NSString * nameStr;

@property (nonatomic, assign) BOOL didConnectionTimeout;

@end
