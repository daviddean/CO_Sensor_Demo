/*
 *  TIBLEService.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEDiscovery.h"
#import "TIBLEService.h"
#import "TIBLECharacteristics.h"
#import "TIBLEUtilities.h"
#import "TIBLESensorConstants.h"
#import "TIBLECharacteristicsSingleton.h"
#import "TIBLEUIConstants.h"
#import "TIBLEAlertManager.h"
#import "TIBLEFeatures.h"

@interface TIBLEService() <CBPeripheralDelegate>


@end

@implementation TIBLEService

- (id) initWithPeripheral:(TIBLEPeripheral *)peripheral controller:(id<TIBLEServiceDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        
        self.characteristics = [[TIBLECharacteristics alloc] init];
        self.peripheral = peripheral;
        self.peripheral.peripheral.delegate = self; //I am the delegate for CBPeripheralDelegate
        self.delegate = delegate; //I have a delegate TIBLEServiceDelegate
		
		//assume first thing will do is read chars, then after that is done it enables
		//receiving samples.
		self.isReceivingDataEnabled = NO;
		self.isReadingCharacteristics = YES;
		
		[self registerForNotifications];
	}
    
    return self;
}

- (void) reset
{
	if (self.peripheral.peripheral != nil) {
		
		self.peripheral.peripheral = nil;
	}
}

- (void) dealloc{
	
	[self cleanup];
	
	self.peripheral.peripheral.delegate = nil;
	self.peripheral = nil;
	
}
- (void) cleanup{
	
	[self unregisterForNotifications];
}

/* Enable if want app to not work with BLE sensor while in the background.
 Need to accomodate for fact that this is not the only service that may be connected. */
//Not used for app right now.

- (void)enteredBackground
{
	if(TIBLE_FEATURE_ENABLE_APP_RUNNNING_IN_BACKGROUND == NO){
		
		// Find the fishtank service
		if(self.isReceivingDataEnabled){
			[self unregisterForSensorNotifications];
		}
	}
}

- (void)enteredForeground
{
	if(TIBLE_FEATURE_ENABLE_APP_RUNNNING_IN_BACKGROUND == NO){

		// Find the fishtank service
		if(self.isReceivingDataEnabled){
			[self registerSensorForNotifications];
		}
	}
}

/* Not used since the app does not allow the user to explicitely
 disconnect from a sensor. This means when we get a disconnect, 
 an error occurred and we can not establish a connection to the peripheral. */

- (void) unregisterForSensorNotifications{
	
	//does not work at this point. service is already nil in peripheral, why?
	if(TIBLE_SENSOR_REGISTER_FOR_SENSOR_COMMAND_NOTIFICATIONS){

		NSString * key = [[TIBLECharacteristicsSingleton sharedTIBLECharacteristicsSingleton]
						  characteristicKeyStringFromDescriptionName:kSensorCommandCharacteristicKey];
		
		CBCharacteristic * commandCharacteristic = [self.characteristics characteristicForUUID:key];
		
		if(commandCharacteristic != nil){
			
			if(self.isReceivingDataEnabled == YES){
				
				[TIBLELogger detail:@"\t Unregistering for Command Notify Characteristic Notification.\n"];
				
				[self.peripheral.peripheral setNotifyValue:NO forCharacteristic:commandCharacteristic];
				
				self.isReceivingDataEnabled = NO;
			}
		}
	}
}

- (void) allCharacteristicsAreRead: (NSNotification *) notification{
	
	self.isReadingCharacteristics = NO;
	
	[self registerSensorForNotifications];
}

- (void) registerForNotifications{
	
	[self unregisterForNotifications];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(allCharacteristicsAreRead:)
												 name:TIBLE_NOTIFICATION_BLE_CHARACTERISTICS_READING_ENDED
											   object:nil];
	
}

- (void) unregisterForNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) registerSensorForNotifications{
	
	if(TIBLE_SENSOR_REGISTER_FOR_SENSOR_COMMAND_NOTIFICATIONS){
		
		NSString * key = [[TIBLECharacteristicsSingleton sharedTIBLECharacteristicsSingleton]
						  characteristicKeyStringFromDescriptionName:kSensorCommandCharacteristicKey];
		
		CBCharacteristic * commandCharacteristic = [self.characteristics characteristicForUUID:key];
		
		CBCharacteristicProperties charPropertyNotify = commandCharacteristic.properties &
		CBCharacteristicPropertyNotify;
		
		if(charPropertyNotify == CBCharacteristicPropertyNotify){
			
			if(self.isReceivingDataEnabled == NO){
			
				[TIBLELogger detail:@"\t Registering for Command Notify Characteristic Notification.\n"];
				
				[self.peripheral.peripheral setNotifyValue:YES forCharacteristic:commandCharacteristic];
			
				self.isReceivingDataEnabled = YES;
			}
		}
	}
}

- (void) requestToReadChar: (CBCharacteristic *) characteristic{
	
	CBCharacteristicProperties charPropertyRead = characteristic.properties &
	CBCharacteristicPropertyRead;
	
	if(charPropertyRead == CBCharacteristicPropertyRead){
	
		[TIBLELogger detail:@"\t Requesting to Read Value for Characteristic.\n"];
		
		self.isReadingCharacteristics = YES;
		
		[self.peripheral.peripheral readValueForCharacteristic:characteristic];
	}

}

- (void) startDiscoveringServices
{
	[TIBLELogger detail:@"TIBLEService - *** Start Discovering Services.\n"];
    NSArray * servicesUUIDsArray = [NSArray arrayWithObjects:[CBUUID UUIDWithString:TIBLE_SENSOR_SERVICE_UUID], nil];
    [self.peripheral.peripheral discoverServices:servicesUUIDsArray];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
 
	[TIBLELogger detail:@"TIBLEService - *** Did Discover Services called.\n"];
	
	NSArray * services	= nil;
    
	if (peripheral != self.peripheral.peripheral) {
		[TIBLELogger error:@"\t Error - Did Discover Services does not match peripherhal.\n"];
		return ;
	}

	if ([error code] != 0) {
		[TIBLELogger error:@"\t Error: %@\n", error];
		return ;
	}
    
	services = [peripheral services];
    
	if (!services || ![services count]) {
		[TIBLELogger error:@"\t Error: No services in array.\n"];
		return;
	}

    self.service = nil;
    
	for (CBService *service in services) {

		[TIBLELogger detail:@"\t Found Service: %@\n", [service description]];
     
        if([[service UUID] isEqual:[CBUUID UUIDWithString:TIBLE_SENSOR_SERVICE_UUID]]){
        
            self.service = service;
            break;
        }
    }
    
    if(self.service != nil){
        
        NSArray * characteristicsArray = [[TIBLECharacteristicsSingleton sharedTIBLECharacteristicsSingleton]
										  generateCharacteristicsUUIDsArray];
        
        [self.peripheral.peripheral discoverCharacteristics:characteristicsArray
                                      forService:self.service];
        
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
	NSArray		*characteristics	= [service characteristics];
	CBCharacteristic *characteristic;
    
	[TIBLELogger detail:@"TIBLEService - *** Did Discover Characteristics For Service called.\n"];
	
	if (peripheral != self.peripheral.peripheral) {
		[TIBLELogger error:@"\t Error - Did Discover Characteristics does not match peripherhal.\n"];
		return ;
	}
	
	if (service != self.service) {
		[TIBLELogger error:@"\t Error - Service does not match.\n"];
		return ;
	}
    
	if ([error code] != 0) {
		[TIBLELogger error:@"\t Error - %@\n", error];
		return ;
	}
    
	for (characteristic in characteristics) {
		
		NSString * description = [[TIBLECharacteristicsSingleton sharedTIBLECharacteristicsSingleton]
								  characteristicDescriptionNameFromUUID:[characteristic UUID]];
		
		NSString * uuidCharacteristicString = [TIBLEUtilities stringForUUID:[characteristic UUID]];
		
		[TIBLELogger detail:@"\t ptr: %p\n", characteristic];
		[TIBLELogger detail:@"\t description: %@\n", description];
		[TIBLELogger detail:@"\t uuid: %@\n", uuidCharacteristicString];
		
		
        [self.characteristics addCharacteristic:characteristic];

		[self logCharacteristicProperties:characteristic.properties];
		
		//request to read value for char
		[self requestToReadChar:characteristic];
    }
}

//failed to register for notification
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
	
	NSString * description = [[TIBLECharacteristicsSingleton sharedTIBLECharacteristicsSingleton]
							  characteristicDescriptionNameFromUUID:[characteristic UUID]];
	
	[TIBLELogger detail:@"TIBLEService - Did Update Notification State for characteristic called.\n"];
	[TIBLELogger detail:@"\t characteristic: %@", description];
	
	if ([error code] != 0) {
		[TIBLELogger error:@"\t Error - Could NOT upate notification state for characteristic. Error code: %@\n",
		 [error localizedDescription]];
	}
}


- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	[TIBLELogger detail:@"TIBLEService - Did Update Value For Characteristic called.\n"];
    
	if (peripheral != self.peripheral.peripheral) {
		[TIBLELogger error:@"\t Error - Could not update characteristic. Wrong peripheral.\n"];
		return ;
	}

    if ([error code] != 0) {
		[TIBLELogger error:@"\t Error - Could not update characteristic. Error code: %@\n", error];
		return ;
	}
    
	//make sure characteristic is one that we found already.
	NSString * uuidString = [TIBLEUtilities stringForUUID:[characteristic UUID]];

	NSString * description = [[TIBLECharacteristicsSingleton sharedTIBLECharacteristicsSingleton]
							  characteristicDescriptionNameFromUUID:[characteristic UUID]];
	
	[TIBLELogger detail:@"\t characteristic: %@", description];
	
	if([self.characteristics.characteristics valueForKey:uuidString] != nil){
	
		//tell delegate the value for the characteristic is updated
		[self.delegate updatedCharacteristic:characteristic];
	}
}

//comes back with error if it could not write value for characteristic. what error is sucess??
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
	
	[TIBLELogger detail:@"TIBLEService - Did Write Value For Characteristic called.\n"];
	
	NSString * description = [[TIBLECharacteristicsSingleton sharedTIBLECharacteristicsSingleton]
							  characteristicDescriptionNameFromUUID:[characteristic UUID]];
	
	[TIBLELogger detail:@"\t characteristic: %@", description];
	
	if ([error code] != 0) {
		[TIBLELogger error:@"\t Error - Could not write value for characteristic. Error code: %@\n", error];
		[[TIBLEAlertManager sharedTIBLEAlertManager] showUserAlertFailedToWriteValueForCharacteristic];
	}
	
	/* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
    [peripheral readValueForCharacteristic:characteristic];
}

#pragma mark - Flow of Sensor Data

- (void) sendSensorCommandToStartSendingData: (CBCharacteristic *) characteristic{
	
    NSData  *data	= nil;
    int8_t value	= 1;
	
	if (!self.peripheral) {
        [TIBLELogger warn:@"TIBLEService - Warning - Could NOT send command to start sending data. Not connected to a peripheral.\n"];
		return ;
    }
    
	if (!characteristic) {
        [TIBLELogger warn:@"TIBLEService - Warning - Could NOT send command to start sending data. No valid command characteristic."];
        return;
    }
		
    data = [NSData dataWithBytes:&value length:sizeof (value)];

	[self.peripheral.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

#pragma mark - Internal Helpers

- (void) setIsReadingCharacteristics:(BOOL)isReadingCharacteristics{
	
	if(_isReadingCharacteristics != isReadingCharacteristics){
		
		_isReadingCharacteristics = isReadingCharacteristics;
		
		if(isReadingCharacteristics){
			[self sendNotificationCharacterisicsReadingIsStarting];
		}
	}
}

- (void) sendNotificationCharacterisicsReadingIsStarting{
	
	[TIBLELogger info:@"TIBLESensorProfile - Sending Notification NOTIFICATION_BLE_CHARACTERISTICS_READING_STARTED.\n"];
	
	NSNotification * notif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_BLE_CHARACTERISTICS_READING_STARTED
														   object:nil
														 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:notif];
}

- (void) logCharacteristicProperties: (CBCharacteristicProperties) properties{
	
	NSString * propertiesString = @"";
	
	//broadcast
	if((properties &  CBCharacteristicPropertyBroadcast) == CBCharacteristicPropertyBroadcast){
		
		[propertiesString stringByAppendingString:@" Broadcast,"];
	}
	
	//readable
	if((properties &  CBCharacteristicPropertyRead) == CBCharacteristicPropertyRead){
		[propertiesString stringByAppendingString:@" Read,"];
	}
	
	//writable with no response
	if((properties &  CBCharacteristicPropertyWriteWithoutResponse) == CBCharacteristicPropertyWriteWithoutResponse){
		
		[propertiesString stringByAppendingString:@" Write Without Response, "];
	}
	
	//writable
	if((properties &  CBCharacteristicPropertyWrite) == CBCharacteristicPropertyWrite){
		
		[propertiesString stringByAppendingString:@" Write, "];
	}
	
	if((properties &  CBCharacteristicPropertyNotify) == CBCharacteristicPropertyNotify){
		
		[propertiesString stringByAppendingString:@" Notify, "];
	}
	
	//indicate
	if((properties &  CBCharacteristicPropertyIndicate) == CBCharacteristicPropertyIndicate){
		
		[propertiesString stringByAppendingString:@" Indicate, "];
	}
	
	//authenticated signed writes
	if((properties &  CBCharacteristicPropertyAuthenticatedSignedWrites) == CBCharacteristicPropertyAuthenticatedSignedWrites){
		
		[propertiesString stringByAppendingString:@" Authenticated Signed Writes, "];
	}
	
	//extended properties
	if((properties &  CBCharacteristicPropertyExtendedProperties) == CBCharacteristicPropertyExtendedProperties){
		
		[propertiesString stringByAppendingString:@" Extended Properties, "];
	}
	
	//notify encryption required
	if((properties &  CBCharacteristicPropertyNotifyEncryptionRequired) == CBCharacteristicPropertyNotifyEncryptionRequired){
		
		[propertiesString stringByAppendingString:@" Encryption Required, "];
	}
	
	//indicate encryption required
	if((properties &  CBCharacteristicPropertyIndicateEncryptionRequired) == CBCharacteristicPropertyIndicateEncryptionRequired){
		
		[propertiesString stringByAppendingString:@" Indicate Encryption Required, "];
	}
	
	[TIBLELogger detail:@"\t properties: %@\n,", propertiesString];
}

@end
