/*
 *  TIBLEDevicesManager.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import "TIBLEDiscovery.h"
#import "TIBLESensorModel.h"
#import "TIBLESensorConstants.h"
#import "TIBLEPeripheral.h"

@interface TIBLEDevicesManager : NSObject <TIBLEServiceDelegate, TIBLEDiscoveryyDelegate>

+ (TIBLEDevicesManager *) sharedTIBLEDevicesManager;

- (void) startDiscovery;
- (void) restartDiscovery;
- (NSArray *) availablePeripherals; //including connected one(s).
- (void) connectToPeripheral:(TIBLEPeripheral *) peripheral;

@property (strong, nonatomic) TIBLESensorModel * connectedSensor;
@property(nonatomic, strong) TIBLEDiscovery * discoveryManager;

- (TIBLEService *) connectedService; //comes from connected sensor.

- (BOOL) isBluetoothEnabled;
- (void) checkIdleTimerEnabled;
- (BOOL) isScanning;
- (BOOL) isConnecting;
- (BOOL) isReadingCharacteristics;

@end
