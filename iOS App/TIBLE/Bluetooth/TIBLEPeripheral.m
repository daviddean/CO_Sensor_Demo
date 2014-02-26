/*
 *  TIBLEPeripheral.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEPeripheral.h"
#import "TIBLEUtilities.h"
#import "TIBLEUIConstants.h"
#import "TIBLEDevicesManager.h"

@interface TIBLEPeripheral ()

@end

@implementation TIBLEPeripheral


- (id) init {
	
	self = [super init];
	
	if(self != nil){
		self.peripheral = nil;
		self.uuidStr = nil;
		self.nameStr = nil;
		self.isConnecting = NO;
		self.isConnected = NO;
		self.didConnectionTimeout = NO;
		self.service = nil;
	}
	
	return self;
}

- (void) sendNotificationConnectingToSensor{
	
	[TIBLELogger info:@"TIBLEPeripheral - Sending Notification: NOTIFICATION_BLE_CONNECTING.\n"];
	
	NSNotification * notif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_BLE_CONNECTING
														   object:nil
														 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:notif];
	
}

- (void) setIsConnecting:(BOOL)isConnecting{
	
	if(isConnecting != _isConnecting){
		
		_isConnecting = isConnecting;
		
		[self sendNotificationConnectingToSensor];
		
		[[TIBLEDevicesManager sharedTIBLEDevicesManager] checkIdleTimerEnabled];
	}
}

- (void) setPeripheral:(CBPeripheral *)peripheral{
	
	//take the default peripheral name if it exists
	if(peripheral.name != nil){
		self.nameStr = peripheral.name;
	}
	else{
		self.nameStr = NSLocalizedString(@"ConnectScreen.SensorName.Default", nil);
	}
	
	if(peripheral.UUID != nil){
		self.uuidStr = [TIBLEUtilities stringForCFUUID:peripheral.UUID];
	}
	
	_peripheral = peripheral;
}

- (void) setNameStr:(NSString *)nameStr{
	
	_nameStr = nameStr;
}

- (NSString *) uuidStr{

	if(_peripheral.UUID != nil){
		_uuidStr = [TIBLEUtilities stringForCFUUID:_peripheral.UUID];
	}

	return _uuidStr;
}

- (void) dealloc{
	
	[self.service cleanup];
	self.service = nil;
}

@end
