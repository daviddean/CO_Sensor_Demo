/*
 *  TIBLEService.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TIBLECharacteristics.h"
#import "TIBLEPeripheral.h"

@protocol TIBLEServiceDelegate<NSObject>

-(void) updatedCharacteristic:(CBCharacteristic *) characteristic;

@end

@interface TIBLEService : NSObject

- (void) registerSensorForNotifications;
- (void) unregisterForSensorNotifications;

- (void) registerForNotifications;
- (void) unregisterForNotifications;

- (id) initWithPeripheral:(TIBLEPeripheral *)peripheral controller:(id<TIBLEServiceDelegate>)controller;
- (void) startDiscoveringServices;

- (void) reset;
- (void) cleanup;

- (void)enteredForeground;
- (void)enteredBackground;

@property (nonatomic, weak) TIBLEPeripheral * peripheral;
@property (nonatomic, strong) CBService * service; //found
@property (nonatomic, assign) BOOL isReceivingDataEnabled;
@property (nonatomic, strong) TIBLECharacteristics * characteristics;
@property (nonatomic, weak) id<TIBLEServiceDelegate> delegate;

@property (nonatomic, assign) BOOL isReadingCharacteristics;

@end
