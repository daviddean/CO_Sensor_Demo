/*
 *  TIBLEDiscovery.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEDiscovery.h"
#import "TIBLECharacteristics.h"
#import "TIBLEService.h"
#import "TIBLESensorConstants.h"
#import "TIBLEUIConstants.h"
#import "TIBLEPeripheral.h"
#import "TIBLESavedSensor.h"
#import "TIBLEAlertManager.h"
#import "TIBLEFeatures.h"
#import "TIBLESensorConstants.h"

@interface TIBLEDiscovery () <CBCentralManagerDelegate> {
	CBCentralManager    *centralManager;
    BOOL				pendingInit;
}

@property (nonatomic, strong) NSTimer * connectionTimer;
@property (nonatomic, strong) NSTimer * scanningTimer;

@property (nonatomic, assign) BOOL isScanning;


@end

@implementation TIBLEDiscovery

@synthesize discoveryDelegate;
@synthesize serviceDelegate;

#pragma mark -
#pragma mark Init

- (id) init
{
    self = [super init];
    if (self) {
		
		if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH)
			[TIBLELogger info:@"TIBLEDiscovery - Init called.\n"];
		
        self.discoveredPeripherals = [[NSMutableArray alloc] init];
		centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
		_isScanning = NO;
	}
    return self;
}

#pragma mark -
#pragma Keeping State

/*
 *  CBCentralManagerState Possible States.
 *
 *  Represents the current state of a CBCentralManager.
 *
 *  CBCentralManagerStateUnknown       State unknown, update imminent.
 *  CBCentralManagerStateResetting     The connection with the system service was momentarily lost, update imminent.
 *  CBCentralManagerStateUnsupported   The platform doesn't support the Bluetooth Low Energy Central/Client role.
 *  CBCentralManagerStateUnauthorized  The application is not authorized to use the Bluetooth Low Energy Central/Client role.
 *  CBCentralManagerStatePoweredOff    Bluetooth is currently powered off.
 *  CBCentralManagerStatePoweredOn     Bluetooth is currently powered on and available to use.
 */

- (BOOL) isBluetoothEnabled{

	BOOL enabled = YES;
	
	if((centralManager.state == CBCentralManagerStatePoweredOff) ||
	   (centralManager.state == CBCentralManagerStateUnauthorized) ||
	   (centralManager.state == CBCentralManagerStateUnsupported) ||
	   (centralManager.state == CBCentralManagerStateUnknown)){
		
		enabled = NO;
	}
	
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH)
		[TIBLELogger info:@"TIBLEDiscovery - Bluetooth Enabled: %@\n", enabled?@"YES":@"NO"];
	
	return enabled;
}

- (BOOL) isConnecting{
	
	BOOL isConnectingValue = NO; //by default
	
	//return YES if it has any peripheral in isConnecting state.
	
	for(TIBLEPeripheral * ti_peripheral in self.discoveredPeripherals){
		
		if(ti_peripheral.isConnecting){
			
			//found at least one peripheral in the process of connecting.
			isConnectingValue = YES;
			break;
		}
	}
	
	return isConnectingValue;
}

- (void) setScanning:(BOOL)scanning{
	
	if(_isScanning != scanning){
		
		_isScanning = scanning;
		
		if(_isScanning == NO){
			
			[self invalidateScanningTimer];
			[self.discoveryDelegate discoveryStoppedScanning];
		}
		else{
			[self.discoveryDelegate discoveryStartedScanning];
		}
	}

	//keep it outside, used to reset indicators which may be in animating
	//prior to actual scanning state being set.
	[self sendNotificationScanningSensors];
}

#pragma mark -
#pragma mark - Keeping Peripherals

- (TIBLEPeripheral *) getTIPeripheralForCBPeripheral: (CBPeripheral *) peripheral {
	
	TIBLEPeripheral * ti_peripheral = nil;
	
	if(peripheral == nil)
		return ti_peripheral;
	
	for(TIBLEPeripheral * temp_peripheral in self.discoveredPeripherals){
		
		if(temp_peripheral.peripheral == peripheral){
			
			ti_peripheral = temp_peripheral;
			break;
		}
	}
	
	return ti_peripheral;
}

#pragma mark -
#pragma mark - Connection Timer

- (void) handleConnectionTimout{
	
	//get peripheral that is connecting.
	//since we only allow one to be connecting,
	//this is the one that timeout.
	TIBLEPeripheral * ti_peripheral = nil;
	
	for(TIBLEPeripheral * ti_peripheral_tmp in self.discoveredPeripherals){
		
		if(ti_peripheral_tmp.isConnecting == YES){
					
			ti_peripheral = ti_peripheral_tmp;
			break;
		}
	}
	
	if(ti_peripheral != nil){
		
		[TIBLELogger info:@"TIBLEDiscovery - Handling Connction Timeout by requesting to cancel periperhal connection, time: %f\n",
		 [[NSDate date] timeIntervalSinceReferenceDate]];
	
		ti_peripheral.didConnectionTimeout = YES;
	
		[centralManager cancelPeripheralConnection:ti_peripheral.peripheral];
	}
}

- (void) checkConnectionTimeout: (NSTimer *) timer{
	
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger info:@"TIBLEDiscovery - Connection Timer Expired: time: %f\n",
		 [[NSDate date] timeIntervalSinceReferenceDate]];
	}
	
	[self invalidateConnectionTimer];

	[self handleConnectionTimout];
	
	[[TIBLEAlertManager sharedTIBLEAlertManager] showUserAlertConnectionToSensorTimeout];
}

- (void) invalidateConnectionTimer{
	
	if(self.connectionTimer != nil){

		if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
			[TIBLELogger info:@"\t Invaliding Connection Timer."];
		}
		
		[self.connectionTimer invalidate];
		self.connectionTimer = nil;
	}
}

- (void) startConnectionTimer{
	
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger info:@"TIBLEDiscovery - Starting Connection Timer: time: %f\n",
		 [[NSDate date] timeIntervalSinceReferenceDate]];
	}
	
	[self invalidateConnectionTimer];
	
	self.connectionTimer = [NSTimer timerWithTimeInterval:TIBLE_CONNECTION_TIMEOUT
												   target:self
												 selector:@selector(checkConnectionTimeout:)
												 userInfo:nil
												  repeats:NO];
	
	[[NSRunLoop mainRunLoop] addTimer:self.connectionTimer forMode:NSDefaultRunLoopMode];
}

- (void) stopConnectionTimer{
	
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger info:@"TIBLEDiscovery - Stop Connection Timer called.\n"];
	}
	
	[self invalidateConnectionTimer];
}

#pragma mark -
#pragma Scanning Timer

- (void) checkScanningTimeout: (NSTimer *) timer{
	
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger info:@"TIBLEDiscovery - Scanning Timer Expired: time: %f\n",
		 [[NSDate date] timeIntervalSinceReferenceDate]];
	}
	
	[self invalidateScanningTimer];
	
	[self stopScanning];
}

- (void) invalidateScanningTimer{
	
	if(self.scanningTimer != nil){
		
		if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
			[TIBLELogger info:@"\t Invaliding Scanning Timer."];
		}
		
		[self.scanningTimer invalidate];
		self.scanningTimer = nil;
	}
}

- (void) startScanningTimer{
	
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger info:@"TIBLEDiscovery - Starting Scanning Timer: time: %f\n",
		 [[NSDate date] timeIntervalSinceReferenceDate]];
	}
	
	[self invalidateScanningTimer];
	
	self.scanningTimer = [NSTimer timerWithTimeInterval:TIBLE_SCANNING_TIMEOUT
												 target:self
												 selector:@selector(checkScanningTimeout:)
											   userInfo:nil
												repeats:NO];
	
	[[NSRunLoop mainRunLoop] addTimer:self.scanningTimer forMode:NSDefaultRunLoopMode];
}

#pragma mark - Scanning Routines

- (void) restartDiscovery{
	
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger info:@"TIBLEDiscovery - *** Restarting Discovery.\n"];
	}
	
	[self stopScanning];
	
	//do not clear list of available peripherals since a sensor that is connected
	//will remain connected and this app does not cancel connections.
	//also this is called after app launch, and the list of available sensor may
	//already contain sensors that have been retrieved.
	
	//give 3 sec window for connected sensors to disconnect before starting discovery.
	[self startScanning];
	
	//when stop scanning timer expires, the list is refresh in case there were no
	//peripherals discovered but that remain in the list.
}

- (void) startScanning
{
	if(self.isScanning == NO){
				
		if([self isBluetoothEnabled] == YES){

			if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
				[TIBLELogger info:@"TIBLEDiscovery - *** START Scanning.\n"];
			}
			
			self.scanning = YES;
			
			NSArray * servicesUUIDsArray = [NSArray arrayWithObjects:[CBUUID UUIDWithString:TIBLE_SENSOR_SERVICE_UUID],
											nil];
			
			NSDictionary * options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
																 forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
			
			[self startScanningTimer];
			
			[centralManager scanForPeripheralsWithServices:servicesUUIDsArray options:options];
		}
		else{
			
			//show user alert.
			
			if(centralManager.state == CBCentralManagerStatePoweredOff){
				
				[[TIBLEAlertManager sharedTIBLEAlertManager] showUserAlertCanNotScanNeedToTurnOnBluetooth];
			}
			else if(centralManager.state == CBCentralManagerStateUnauthorized){
				
				[[TIBLEAlertManager sharedTIBLEAlertManager] showUserAlertBluetoothNotAuthorizedForThisApp];
			}
			else if(centralManager.state == CBCentralManagerStateUnsupported){
				
				[[TIBLEAlertManager sharedTIBLEAlertManager] showUserAlertBluetoothLowEnergyNotAvailable];
			}
			else if(centralManager.state == CBCentralManagerStateUnknown){
				
				//do nothing, update is imminent.
			}
		}
	}
}

- (void) stopScanning
{	
	if(self.isScanning == YES){
	
		if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
			[TIBLELogger info:@"TIBLEDiscovery - *** STOP Scanning.\n"];
		}
		
		self.scanning = NO;
		[centralManager stopScan];
		
		//send notification in case there were no devices discovered,
		//but that were already in the list.
		[discoveryDelegate discoveryDidRefresh];
	}
}

- (void) clearListOfDiscoveredDevices {
	
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH)
		[TIBLELogger info:@"TIBLEDiscovery - *** Clearing list of discovered peripherals.\n"];
	
	[self.discoveredPeripherals removeAllObjects];
	
	[discoveryDelegate discoveryClearList];
}

#pragma mark - Scanning Callbacks

- (TIBLEPeripheral *) addPeripheralToDiscoveredList: (CBPeripheral *) peripheral{
	
	TIBLEPeripheral * ti_peripheral = [self getTIPeripheralForCBPeripheral:peripheral];
	
	if(ti_peripheral != nil){
		
		//found one with equal uuid but obj not the same
		
		if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
			[TIBLELogger info:@"\t Found ti_peripheral that matches uuid. Re-assigning cbperipheral (ptr:%@)\n",
			 peripheral];
		}
	}
	else{
		
		//if nil, then create it.
		if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
			[TIBLELogger info:@"\t Creating ti_peripheral. Assigning cbperipheral ...\n" ];
			[TIBLELogger info:@"\t\t (ptr:%@)\n", peripheral];
		}
		
		
		ti_peripheral = [[TIBLEPeripheral alloc] init];
		
		[TIBLELogger info:@"\t Adding to list of discovered peripherals.\n"];
		[self.discoveredPeripherals addObject:ti_peripheral];
		
	}
	
	ti_peripheral.peripheral = peripheral;
	
	if(peripheral != nil && [peripheral UUID] != nil){
		
		NSString *name = [[TIBLESavedSensor sharedTIBLESavedSensor] getNameWithUUID:[peripheral UUID]];
		
		if(name != nil)
			[ti_peripheral setNameStr:name];
	}
	
	return ti_peripheral;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
	 advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger info:@"TIBLEDiscovery - *** Discovered Peripheral: %@\n",
		 [TIBLEUtilities stringForCFUUID:[peripheral UUID]]];
    }
        
	TIBLEPeripheral * ti_peripheral = [self addPeripheralToDiscoveredList:peripheral];
			
	[self.discoveryDelegate discoveryFoundPeripheral:ti_peripheral];
}

#pragma mark - Connect / Disconnect Routines

- (void) connectPeripheral:(TIBLEPeripheral*)ti_peripheral
{
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger info:@"TIBLEDiscovery - *** Connect to Peripheral called (ptr: %p)\n",
		 ti_peripheral.peripheral];
	}
	
	if(self.isConnecting == YES){

		[TIBLELogger info:@"\t Not processing connect request, alrady in connecting state."];
		return;
	}
	
	if ([ti_peripheral.peripheral isConnected] == NO) {
		
		if(ti_peripheral.isConnecting == YES){
			//already trying to connect.
			[TIBLELogger info:@"\t Peripheral is already trying to connect."];
			return;
		}
	
		if(ti_peripheral.service != nil){
		
			[ti_peripheral.service cleanup];
			ti_peripheral.service = nil;
		}
		
		BOOL wasScanning = self.isScanning;
		
		//do not scan while connecting
		//trigger notification to make sure indicators stop.
		[self stopScanning];
		
		if(wasScanning == YES){
			//in 2 seconds.
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
				[self connectPeripheral:ti_peripheral];
			});
			
			return;
		}
		
		ti_peripheral.isConnected = NO;
		ti_peripheral.isConnecting = YES;
		
		[self startConnectionTimer];
		
		if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH)
			[TIBLELogger info:@"\t Requesting To Connect."];
		
		[centralManager connectPeripheral:ti_peripheral.peripheral options:nil];
		
		//save device for later retrieval.
		[self addSavedDevice:[TIBLEUtilities stringForCFUUID:[ti_peripheral.peripheral UUID]]];
		
		[self.discoveryDelegate discoveryDidRefresh];
	}
	else{ //already connected to the system.
		
		ti_peripheral.isConnected = YES;
		ti_peripheral.isConnecting = NO;
		
		[self stopScanning]; //do not scan while connecting
		
		[self showOtherPeripheralsAsDisconnected:ti_peripheral];
		
		[discoveryDelegate  discoveryDidConnectToPeripheral:ti_peripheral];
	}
}

- (void) showOtherPeripheralsAsDisconnected: (TIBLEPeripheral *) connectedPeripheral{
	
	for(TIBLEPeripheral * tiPeripheralTmp in self.discoveredPeripherals){
		
		if(tiPeripheralTmp != connectedPeripheral){
			
			[self disconnectPeripheral:tiPeripheralTmp];
		}
	}
}

- (void) disconnectPeripheral:(TIBLEPeripheral*)ti_peripheral
{
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger info:@"TIBLEDiscovery - *** Disconnect to Peripheral called: (ptr: %p)\n",
		 ti_peripheral.peripheral];
	}

	ti_peripheral.isConnecting = NO;
	ti_peripheral.isConnected = NO;
	
	// do not call cancelPeripheralConnection.
	
	//remove service.
	if(ti_peripheral.service != nil){
		
		[ti_peripheral.service cleanup];
		
		[ti_peripheral.service unregisterForNotifications];
		[ti_peripheral.service unregisterForSensorNotifications];
		
		ti_peripheral.service = nil;
	}
}

#pragma mark - Connection Callbacks

- (TIBLEService *) startServiceForPeripheral:(TIBLEPeripheral *) ti_peripheral{
	
	/* Create a service instance. */
	TIBLEService * service = [[TIBLEService alloc] initWithPeripheral:ti_peripheral controller:serviceDelegate];
	[service startDiscoveringServices];

	return service;
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger info:@"TIBLEDiscovery - *** Did Connect to Peripheral called (ptr: %p)\n",
		 peripheral];
	}
	
	//at this point the UUID should not be nil because it has connected.
	
	TIBLEPeripheral * ti_peripheral = [self getTIPeripheralForCBPeripheral:peripheral];
	
	ti_peripheral.isConnected = YES;
	ti_peripheral.isConnecting = NO;
	ti_peripheral.didConnectionTimeout = NO;
	
	[self showOtherPeripheralsAsDisconnected:ti_peripheral];
    
    [discoveryDelegate  discoveryDidConnectToPeripheral:ti_peripheral];

	[self stopConnectionTimer];
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral
				  error:(NSError *)error
{
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger error:@"TIBLEDiscovery - *** Error - Did Fail to Connect to Peripheral (ptr: %p)", peripheral];
		[TIBLELogger error:@"\t Error: %@\n", [error localizedDescription]];
	}
	
	TIBLEPeripheral * ti_peripheral = [self getTIPeripheralForCBPeripheral:peripheral];
	
	ti_peripheral.didConnectionTimeout = YES;
	
	ti_peripheral.isConnected = NO;
	ti_peripheral.isConnecting = NO;
	
	[discoveryDelegate discoveryDidFailToConnectToPeripheral:ti_peripheral error:error];

	//remove it from the list, so user doesn't see it, and hits refresh.
	[ti_peripheral.service cleanup];
	ti_peripheral.service = nil;
	[self.discoveredPeripherals removeObject:ti_peripheral];
	
	[self stopConnectionTimer];
	
	[discoveryDelegate discoveryDidRefresh];
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral
				  error:(NSError *)error
{
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH && error != nil){
		[TIBLELogger warn:@"TIBLEDiscovery - *** Warning - Did Disconnect from Peripheral (ptr: %p)", peripheral];
		[TIBLELogger warn:@"\t Error: %@\n", [error localizedDescription]];
	}
	
	TIBLEPeripheral * ti_peripheral = [self getTIPeripheralForCBPeripheral:peripheral];
	BOOL removeFromList = YES;
	
	if(ti_peripheral.didConnectionTimeout == YES){
		//we stopped the connection because it is taking too long, error will be nil.
		
		removeFromList = YES;
	}
	else if([error code] == CBErrorConnectionTimeout){ //user turned off, or a real timeout.
		
		//retry once.
		if(ti_peripheral.isConnected == YES){
		
			[TIBLELogger warn:@"\t Retrying to connnect, since user did not disconnect explicitely."];
			
			//user had not cancel it, try to connect again.
			[self connectPeripheral:ti_peripheral];
			return;
		}
		
		removeFromList = YES; //user turned off.
	}
	else if(error == nil){
		//error can be nil, we show as disconnected but we don't get rid of peripheral object
		//since user can connect to it again.
		[TIBLELogger warn:@"\t Not removing from list."];
		
		removeFromList = NO;
	}
	
	ti_peripheral.isConnected = NO;
	ti_peripheral.isConnecting = NO;
	ti_peripheral.didConnectionTimeout = NO;
	
	[discoveryDelegate discoveryDidDisconnectFromPeripheral:ti_peripheral error:error];

	[ti_peripheral.service cleanup];
	ti_peripheral.service = nil;
	
	if(removeFromList){
		[self.discoveredPeripherals removeObject:ti_peripheral];
	}
	
	[self stopConnectionTimer];
	
	[discoveryDelegate discoveryDidRefresh];
}

#pragma mark - Notification Helpers

- (void) sendNotificationScanningSensors{
	
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH)
		[TIBLELogger info:@"TIBLEDevicesManager - Sending Notification: NOTIFICATION_BLE_SCANNING.\n"];
	
	NSNotification * notif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_BLE_SCANNING
														   object:nil
														 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:notif];
	
}

#pragma mark - Central Manager Delegate Methods

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    static CBCentralManagerState previousState = -1;
    
    int currentState = [centralManager state];
    
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger info:@"TIBLEDiscovery - Central Manager Update State called ...\n"];
	}
	
	switch (currentState) {
            
		case CBCentralManagerStatePoweredOff:
		{

			if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH)
				[TIBLELogger info:@"\t Central Manager POWERED OFF"];
			
			[self clearListOfDiscoveredDevices];
            
			/* Tell user to power ON BT for functionality, but not on first run - 
			 the Framework will alert in that instance. */
            if (previousState != -1) {
                [discoveryDelegate discoveryStatePoweredOff];
            }
            
			break;
		}
            
		case CBCentralManagerStateUnauthorized:
		{
			/* Tell user the app is not allowed. */
			if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH)
				[TIBLELogger info:@"\t Central Manager State UNAUTHORIZED"];

            [discoveryDelegate discoveryStateAppNotAuthorized];
            
			break;
		}
            
		case CBCentralManagerStateUnknown:
		{
			/* Bad news, let's wait for another event. */
			
			if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH)
				[TIBLELogger info:@"\t Central Manager State UNKNOWN"];
			
			break;
		}
            
		case CBCentralManagerStatePoweredOn:
		{
			if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH)
				[TIBLELogger info:@"\t Central Manager State POWERED ON"];
			
			pendingInit = NO;
			
			[self loadSavedDevices];
			[centralManager retrieveConnectedPeripherals];
			
			[discoveryDelegate discoveryDidRefresh];
			
            break;
		}
            
		case CBCentralManagerStateResetting:
		{
			if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH)
				[TIBLELogger info:@"\t Central Manager State RESETTING"];
			
			[self clearListOfDiscoveredDevices];
            [discoveryDelegate discoveryDidRefresh];
            
			pendingInit = YES;
            
            break;
		}

        case CBCentralManagerStateUnsupported:
        {
            [[TIBLEAlertManager sharedTIBLEAlertManager] showUserAlertBluetoothLowEnergyNotAvailable];
            
            break;
        }

	}

    previousState = [centralManager state];
}

#pragma mark - Restoring Peripherals Routines - FOR REFERENCE, NOT USED.

/* Reload from file. */
- (void) loadSavedDevices
{
	NSArray * storedPeripheralsArray = [[NSUserDefaults standardUserDefaults] arrayForKey:kStoredDevicesKey];
	
	if(storedPeripheralsArray == nil){

		if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH)
			[TIBLELogger info:@"TIBLEDiscovery - No stored peripherals to load."];
        
		return;
	}
	
	for (NSString * deviceUUIDString in storedPeripheralsArray) {
        
		CBUUID * uuid = [CBUUID UUIDWithString:deviceUUIDString];

        if (uuid == nil)
            continue;
        
		if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
			[TIBLELogger info:@"TIBLEDiscovery - Requesting to Retrieve Peripheral with UUID:%@\n",
			 deviceUUIDString];
		}
		
        [centralManager retrievePeripherals:[NSArray arrayWithObject:uuid]];
    }
}

- (void) addSavedDevice:(NSString *) uuidStr
{
	NSArray * storedPeripheralsArray = [[NSUserDefaults standardUserDefaults] arrayForKey:kStoredDevicesKey];
	NSMutableArray * newStoredPeripheralsArray = nil;
	
	if(storedPeripheralsArray != nil){
		
		newStoredPeripheralsArray = [NSMutableArray arrayWithArray:storedPeripheralsArray];
		
		BOOL found =  NO;
		
		for(NSString * tmpStr in storedPeripheralsArray){
			
			if([tmpStr isEqualToString:uuidStr]){
				
				//this peripheral is already saved.
				found = YES;
				break;
			}
		}
		
		//didn't find it, add it to the array.
		if(found == NO){
			[newStoredPeripheralsArray addObject:uuidStr];
		}
	}
	else{
		//stored array is empty, create one and add it.
		newStoredPeripheralsArray = [NSMutableArray arrayWithCapacity:5];
		
		[newStoredPeripheralsArray addObject:uuidStr];
	}
	
	/* Store */
    [[NSUserDefaults standardUserDefaults] setObject:newStoredPeripheralsArray forKey:kStoredDevicesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) removeSavedDevice:(NSString *) uuidStr
{
	NSArray * storedPeripheralsArray = [[NSUserDefaults standardUserDefaults] arrayForKey:kStoredDevicesKey];
	NSMutableArray * newStoredPeripheralsArray = nil;
	
	if(storedPeripheralsArray != nil){
		
		newStoredPeripheralsArray = [NSMutableArray arrayWithArray:storedPeripheralsArray];
		
		for(NSString * tmpStr in storedPeripheralsArray){
			
			if([tmpStr isEqualToString:uuidStr]){

				//remove it.
				[newStoredPeripheralsArray removeObject:tmpStr];
			}
			else{
				//not there.
			}
		}
	}
	else{
		//array is empty.
	}
	
	/* Store */
	[[NSUserDefaults standardUserDefaults] setObject:newStoredPeripheralsArray forKey:kStoredDevicesKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals{

	//we just add them to the list, even though connected internally, the user has too choose to connect to it in this app.
	CBPeripheral * peripheral;
	
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger info:@"TIBLEDiscovery - *** Did Retrieve Peripherals called."];
	}
	
	/* Add to list. */
	for (peripheral in peripherals) {
		
		TIBLEPeripheral * ti_peripheral = [self addPeripheralToDiscoveredList:peripheral];
		
		[self.discoveryDelegate discoveryFoundPeripheral:ti_peripheral];
	}
	
	[discoveryDelegate discoveryDidRefresh];
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals{
	
	CBPeripheral * peripheral;
	
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger info:@"TIBLEDiscovery - *** Did Retrieve Peripherals called."];
	}
	
	/* Add to list. */
	for (peripheral in peripherals) {
			
		TIBLEPeripheral * ti_peripheral = [self addPeripheralToDiscoveredList:peripheral];
		
		[self.discoveryDelegate discoveryFoundPeripheral:ti_peripheral];
	}
	
	[discoveryDelegate discoveryDidRefresh];
}

- (void) centralManager:(CBCentralManager *)central didFailToRetrievePeripheralForUUID:(CFUUIDRef)UUID error:(NSError *)error
{
	/* Nuke from plist. */
	
	if(TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH){
		[TIBLELogger error:@"TIBLEDiscovery - Did Fail To Retrieve Connected peripheral"];
		[TIBLELogger error:@"\t Error - %@\n", [error localizedDescription]];
	}
	
	[self removeSavedDevice:[TIBLEUtilities stringForCFUUID:UUID]];
}

@end
