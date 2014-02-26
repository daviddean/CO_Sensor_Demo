/*
 *  TIBLEDiscovery.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TIBLEService.h"
#import "TIBLEPeripheral.h"

@protocol TIBLEDiscoveryyDelegate <NSObject>

- (void) discoveryFoundPeripheral:(TIBLEPeripheral *) ti_peripheral;
- (void) discoveryDidConnectToPeripheral:(TIBLEPeripheral *) ti_peripheral;
- (void) discoveryDidFailToConnectToPeripheral:(TIBLEPeripheral *) ti_peripheral error:(NSError *) error;
- (void) discoveryDidDisconnectFromPeripheral:(TIBLEPeripheral *) ti_peripheral error:(NSError *) error;
- (void) discoveryClearList;
- (void) discoveryDidRefresh;
- (void) discoveryStatePoweredOff;
- (void) discoveryStateAppNotAuthorized;
- (void) discoveryStartedScanning;
- (void) discoveryStoppedScanning;

@end

@interface TIBLEDiscovery : NSObject

- (TIBLEPeripheral *) getTIPeripheralForCBPeripheral: (CBPeripheral *) peripheral;

- (BOOL) isBluetoothEnabled;
- (void) startScanning;
- (void) stopScanning;
- (void) restartDiscovery;

- (BOOL) isConnecting;
- (BOOL) isScanning;

- (void) connectPeripheral:(TIBLEPeripheral*)peripheral;
- (void) disconnectPeripheral:(TIBLEPeripheral*)peripheral;
- (TIBLEService *) startServiceForPeripheral:(TIBLEPeripheral *) ti_peripheral;

@property (strong, nonatomic) NSMutableArray * discoveredPeripherals;
@property (nonatomic, weak) id<TIBLEDiscoveryyDelegate> discoveryDelegate;
@property (nonatomic, weak) id<TIBLEServiceDelegate> serviceDelegate;

@end
