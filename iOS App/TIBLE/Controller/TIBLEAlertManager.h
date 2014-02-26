/*
 *  TIBLEAlertManager.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>


@interface TIBLEAlertManager : NSObject

+ (TIBLEAlertManager *) sharedTIBLEAlertManager;

- (void) showUserAlertToTurnOnBluetooth;
- (void) showUserAlertCanNotScanNeedToTurnOnBluetooth;
- (void) showUserAlertBluetoothLowEnergyNotAvailable;
- (void) showUserAlertBluetoothUnknownError;
- (void) showUserAlertBluetoothNotAuthorizedForThisApp;

- (void) showUserAlertConnectionToSensorTimeout;

- (void) showUserAlertFailedToWriteValueForCharacteristic;

@end
