/*
 *  TIBLEDevicesManager.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEDevicesManager.h"
#import "TIBLEUtilities.h"
#import "TIBLECharacteristicsSingleton.h"
#import "TIBLEUIConstants.h"
#import "TIBLERawDataModel.h"
#import "TIBLEPeripheral.h"
#import "TIBLEAlertManager.h"
#import "TIBLEFeatures.h"

@interface TIBLEDevicesManager ()

@end


@implementation TIBLEDevicesManager

SINGLETON_FOR_CLASS(TIBLEDevicesManager)

#pragma mark - Init

- (id) init
{
    self = [super init];
    
    if(self != nil){
		
		[TIBLELogger detail:@"TIBLEDevicesManager - Init called.\n"];
		
        self.discoveryManager = [[TIBLEDiscovery alloc] init];
        self.connectedSensor =  nil;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:kAppEnteredBackgroundNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForegroundNotification:) name:kAppEnteredForegroundNotification object:nil];
		
		[self.discoveryManager setDiscoveryDelegate:self];
		[self.discoveryManager setServiceDelegate:self];
    }
    
    return self;
}

- (BOOL) isReadingCharacteristics{

	BOOL isReadingChars = NO;
	
	if(self.connectedService != nil){
			
		isReadingChars = [self.connectedService isReadingCharacteristics];
	}
	
	return isReadingChars;
}

- (BOOL) isBluetoothEnabled{

	return [self.discoveryManager isBluetoothEnabled];
}

- (void) discoveryStartedScanning{
	
	[self checkIdleTimerEnabled];
}

- (void) discoveryStoppedScanning{
	
	[self checkIdleTimerEnabled];
}

- (void) startDiscovery{
    
	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER)
		[TIBLELogger info:@"TIBLEDevicesManager - Start Discovery called.\n"];
	
    [self.discoveryManager startScanning];
}

- (void) restartDiscovery{

	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER)
		[TIBLELogger info:@"TIBLEDevicesManager - Restart Discovery called.\n"];
	
	[self.discoveryManager restartDiscovery];
}

- (void) sendNotificationForDeviceListRefresh{
	
	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER)
		[TIBLELogger info:@"TIBLEDevicesManager - Sending NOTIFICATION_UPDATE_DEVICE_LIST.\n"];
	
	NSNotification * updateUINotif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_UPDATE_DEVICE_LIST
																   object:nil
																 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:updateUINotif];
}

- (void) connectToPeripheral:(TIBLEPeripheral *) peripheral{
	
	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER)
		[TIBLELogger info:@"TIBLEDevicesManager - Connect to Peripheral called, %p \n", peripheral.peripheral];
	
	if([self.discoveryManager isConnecting] == YES){
		[TIBLELogger warn:@"\t Warning - Already in connecting state. Not accepting connect requests.\n"];
		return;
	}
	
	[self.discoveryManager connectPeripheral:peripheral];
}

#pragma mark - TIBLEServiceDelegateProtocol

-(void) updatedCharacteristic:(CBCharacteristic *) characteristic{

	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER){
		[TIBLELogger detail:@"****\n"];
		[TIBLELogger detail:@"TIBLEDevicesManager - Updating Characteristic: ...\n"];
    }
	
	NSString * uuidCharacteristicString = [TIBLEUtilities stringForUUID:[characteristic UUID]];
	
	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER){
		
		NSString * description = [[TIBLECharacteristicsSingleton sharedTIBLECharacteristicsSingleton] characteristicDescriptionNameFromUUID:[characteristic UUID]];

		[TIBLELogger detail:@"\t Description: %@\n", description];
		[TIBLELogger detail:@"\t UUID: %@\n", uuidCharacteristicString];
	}
	
	//make sure sensor is connected.
	if(self.connectedSensor == nil){
		
		[TIBLELogger warn:@"\t Can't update characteristic: %@ because connected sensor is nil.\n",
		 [characteristic description]];
		return;
	}
	
    //make sure service matches that of the connected service.
	if([self isCharateristicServiceUpdateFromConnectedSensor:characteristic] == YES){
	
		TIBLERawDataModel * valueModel = [TIBLEUtilities valueForMeasurementSample:characteristic];
		
			
		[TIBLELogger detail:@"TIBLEDevicesManager - Updating characteristic for connected sensor: %@\n",
		 self.connectedSensor.peripheral.uuidStr];
		
			
		[TIBLELogger detail:@"\t Characteristic peripheral is: %@\n",
			 [TIBLEUtilities stringForCFUUID:characteristic.service.peripheral.UUID]];
		
		[self.connectedSensor updateSensorData:uuidCharacteristicString value:valueModel];
	}
}

- (TIBLEService *) connectedService{
	
	TIBLEService * service = nil;
	
	if(self.connectedSensor != nil){
		
		service = self.connectedSensor.peripheral.service;
	}
	
	return service;
}

- (BOOL) isCharateristicServiceUpdateFromConnectedSensor: (CBCharacteristic *) characteristic{

	BOOL retVal = NO;
	
	if(characteristic == nil){
		return retVal;
	}
	
	TIBLEService * service = self.connectedService;
	
	//coming from the right sensor, sensor uuid need to match.
	if(self.connectedSensor.peripheral.peripheral == characteristic.service.peripheral){
		retVal = YES;
	}
	
	//the right characteristic
	if(service != nil &&
	   [service.service.UUID isEqual:characteristic.service.UUID] &&
	   [service.service.UUID isEqual:[CBUUID UUIDWithString:TIBLE_SENSOR_SERVICE_UUID]] &&
	   retVal == YES){
		
		retVal = YES;
	}
	else{
		retVal = NO;
	}
		
	return retVal;
}

#pragma mark - TIBLEDiscoveryDelegate

//UUID is only known after the connection has been established.
//After the first connection, the UUID is remembered/cached by the device.
//If the same peripheral is discovered later, the UUID will be available before connection.
//You can ask for all remembered peripherals by calling "retrievePeripherals".

- (void) discoveryDidConnectToPeripheral:(TIBLEPeripheral *) ti_peripheral
{
	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER)
		[TIBLELogger info:@"TIBLEDevicesManager - Did Connect to Peripheral called: %@\n",
		 [ti_peripheral uuidStr]];
	
	//this may be called multiple times for an already connected sensor.

	if(self.connectedSensor != nil &&
	   self.connectedSensor.peripheral == ti_peripheral){
		
		//connected to same peripheral, do nothing.
		
		return;
	}
	else{
		//if connected sensor is nil or is not a match for peripheral,
		//need to make a new model instance.
		
		//remove service.
		if(ti_peripheral.service != nil){
			
			[ti_peripheral.service cleanup];
			
			[ti_peripheral.service unregisterForNotifications];
			[ti_peripheral.service unregisterForSensorNotifications];
			
			ti_peripheral.service = nil;
		}
		
		//create new service.
		ti_peripheral.service = [self.discoveryManager startServiceForPeripheral:ti_peripheral];
		
		//create new model. everytime we create a new model, we need a new service,
		//so the characteristics are read into the model profile.
		self.connectedSensor = [[TIBLESensorModel alloc] initWithPeripheral:ti_peripheral];
	}
	
	[self checkIdleTimerEnabled];
	
	[self discoveryDidRefresh];
}

- (void) discoveryDidFailToConnectToPeripheral:(TIBLEPeripheral *) ti_peripheral error:(NSError *) error{

	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER)
		[TIBLELogger info:@"TIBLEDevicesManager - Did Fail to Connect to Peripheral called: %@\n",
		 [ti_peripheral uuidStr]];
	
	if(self.connectedSensor != nil &&
	   self.connectedSensor.peripheral == ti_peripheral){

		
		self.connectedSensor = nil;
	}
	else{
		//don't care.
	}

	[self checkIdleTimerEnabled];
	[self discoveryDidRefresh];
}

- (void) discoveryDidDisconnectFromPeripheral:(TIBLEPeripheral *) ti_peripheral error:(NSError *) error{

	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER){
		[TIBLELogger info:@"TIBLEDevicesManager - Did Disconnect from Peripheral called: %@\n",
		 [ti_peripheral uuidStr]];
	}

	if(self.connectedSensor != nil &&
	   self.connectedSensor.peripheral == ti_peripheral){
		
		self.connectedSensor = nil;
	}
	else{
		//don't care.
	}

	[self checkIdleTimerEnabled];
	[self discoveryDidRefresh];
}

- (void) setConnectedSensor:(TIBLESensorModel *)sensor{

	if(_connectedSensor != sensor){
		
		if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER){
			[TIBLELogger info:@"TIBLEDevicesManager - Setting Connected Sensor To: %@\n",
			 [sensor.peripheral uuidStr]];
		}
		
		_connectedSensor = sensor;
		
		[self checkIdleTimerEnabled];
        
        [self.connectedSensor setIsCalibrated:NO];
		
		[self sendNotificationConnectedSensorChanged];
	}
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    [TIBLELogger info:@"TIBLEDevicesManager - Entered background notification called."];
	
	[self.connectedService enteredBackground];
	
	[self checkIdleTimerEnabled];
}

- (void)didEnterForegroundNotification:(NSNotification*)notification
{
	[TIBLELogger info:@"TIBLEDevicesManager - Entered foreground notification called."];
	
	[self.connectedService enteredForeground];
	
	[self checkIdleTimerEnabled];
}

#pragma mark -
#pragma mark - Keep Screen On/Off

- (void) checkIdleTimerEnabled{
	
	BOOL idleTimerDisabled = NO; //by default let the screen go to sleep.
	
	BOOL condition1And = ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive);
	BOOL condition2Or = ((self.connectedSensor != nil) && (self.connectedSensor.peripheral.peripheral.isConnected == YES));
	BOOL condition3Or = [self.discoveryManager isConnecting];
	BOOL condition4Or = [self.discoveryManager isScanning];
	
	if(condition1And && (condition2Or || condition3Or || condition4Or)){
		idleTimerDisabled = YES;
	}

	[UIApplication sharedApplication].idleTimerDisabled = idleTimerDisabled;
}


#pragma mark -
#pragma mark - Notification Methods

- (BOOL) isConnecting{
	
	return [self.discoveryManager isConnecting];
}

- (BOOL) isScanning{
	
	return [self.discoveryManager isScanning];
}

- (void) sendNotificationConnectedSensorChanged{

	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER){
		
		[TIBLELogger info:@"TIBLEDevicesManager - Sending Notification: NOTIFICATION_UPDATE_CONNECTED_SENSOR_CHANGED - current sensor is: %@\n",
		 [self.connectedSensor.peripheral uuidStr]];
		
		[TIBLELogger detail:@"\t Current sensor is: %@\n",
		 [self.connectedSensor.peripheral uuidStr]];
	}
	
	NSNotification * notif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_UPDATE_CONNECTED_SENSOR_CHANGED
																   object:nil
																 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:notif];
	
}

- (void) discoveryFoundPeripheral:(TIBLEPeripheral *) ti_peripheral{
	
	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER){
		[TIBLELogger info:@"TIBLEDevicesManager - Discovery Found Peripheral called: %@\n",
		 [ti_peripheral uuidStr]];
	}
	
	[self discoveryDidRefresh];
}

- (void) discoveryClearList{
	
	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER){
		[TIBLELogger info:@"TIBLEDevicesManager - Setting Connected Service and Connected Sensor to (null)."];
	}

    self.connectedSensor = nil;
	
	[self discoveryDidRefresh];
}

- (void) discoveryDidRefresh{
    
	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER){
		[TIBLELogger info:@"TIBLEDevicesManager - Discovery Did Refresh called."];
	}
    
    //list of found peripherals has changed.
    [self printAvailablePeripherals];
	
	[self sendNotificationForDeviceListRefresh];
}

- (void) discoveryStatePoweredOff{
    
	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER){
		[TIBLELogger info:@"TIBLEDevicesManager - Discovery State Powered Off called."];
	}
    
	[[TIBLEAlertManager sharedTIBLEAlertManager] showUserAlertToTurnOnBluetooth];
}

- (void) discoveryStateAppNotAuthorized{
    
	if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER)
		[TIBLELogger info:@"TIBLEDevicesManager - Discovery App NOT Authorized called."];
}

#pragma mark - External Getters

- (NSArray *) availablePeripherals{
    
    return [self.discoveryManager discoveredPeripherals];
}

#pragma mark - Internal Helpers

- (void) printAvailablePeripherals{
    
    //[TIBLELogger info:@"\t Printing List of Peripherals:\n"];
    for(TIBLEPeripheral * peripheral in self.discoveryManager.discoveredPeripherals){
    
		if(TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER &&
		   TIBLE_DEBUG_PRINT_DISCOVERED_PERIPHERALS_ON_REFRESH){
			
			[TIBLELogger detail:@"\t\t ti_peripheral (%p),  cbperipheral: (%p)\n", peripheral, peripheral.peripheral];
			[TIBLELogger detail:@"\t\t name: %@\n", [peripheral nameStr]];
			[TIBLELogger detail:@"\t\t uuid: %@\n", [peripheral uuidStr]];
			[TIBLELogger detail:@"\t\t connected: %@\n", [peripheral.peripheral isConnected]?@"YES":@"NO"];
		}
    }
}

@end
