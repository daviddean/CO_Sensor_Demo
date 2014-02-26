/*
 *  TIBLEAlertManager.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEAlertManager.h"
#import "TIBLECommonMacros.h"
#import "TIBLEDevicesManager.h"

#define TIBLE_ALERT_MANAGER_TIME_INTERVAL_SECS 3600.0f //1 hr

@interface TIBLEAlertManager ()

@property (nonatomic, strong) NSDate * timestampOne;
@property (nonatomic, strong) UIAlertView * alertOne;

@property (nonatomic, strong) NSDate * timestampTwo;
@property (nonatomic, strong) UIAlertView * alertTwo;

@end

@implementation TIBLEAlertManager

SINGLETON_FOR_CLASS(TIBLEAlertManager)

#pragma mark - External Bluetooth Related

- (void) showUserAlertToTurnOnBluetooth{
	
	NSString * message = NSLocalizedString(@"Alert.BT.TurnedOff",
										   @"Alert to user when Bluetooth is turned off.");
	[self showUserAlertBluetooth:message];
}

- (void) showUserAlertCanNotScanNeedToTurnOnBluetooth{
	
	NSString * message = NSLocalizedString(@"Alert.BT.CanNotScan",
										   @"Alert to user app can not scan since bluetooth is turned off.");
	[self showUserAlertBluetooth:message];
}

- (void) showUserAlertBluetoothLowEnergyNotAvailable{
	
	NSString * message = NSLocalizedString(@"Alert.BT.NotAvailable",
										   @"Alert user BLE not available.");
	[self showUserAlertBluetooth:message];
}

- (void) showUserAlertBluetoothNotAuthorizedForThisApp{
	
	NSString * message = NSLocalizedString(@"Alert.BT.AppNotAuthorized",
										   @"Alert user BLE not authorized.");
	[self showUserAlertBluetooth:message];
}

- (void) showUserAlertBluetoothUnknownError{
	
	NSString * message = NSLocalizedString(@"Alert.BT.UnknownError",
										   @"Alert user Bluetooth Uknown Error.");
	[self showUserAlertBluetooth:message];
}

#pragma mark - External Connection Related

- (void) showUserAlertConnectionToSensorTimeout{
	
	NSString * message = NSLocalizedString(@"Alert.BT.ConnectionTimeout",
										   @"Alert user sensor connection timeout.");
	[self showUserAlertBluetooth:message];
}

#pragma mark - External Write Characteristic Error

- (void) showUserAlertFailedToWriteValueForCharacteristic{

	NSString * message = NSLocalizedString(@"Alert.BT.CanNotWriteValue",
										   @"Alert user could not write value for characteristic.");
	[self showUserAlertBluetooth:message];
}

#pragma mark - Helper

- (void) showUserAlertBluetooth: (NSString *) message{
	
    if([[TIBLEDevicesManager sharedTIBLEDevicesManager] isBluetoothEnabled] == NO){
        
        if(self.timestampTwo == nil ||
           [self.timestampTwo timeIntervalSinceNow] > TIBLE_ALERT_MANAGER_TIME_INTERVAL_SECS){
            
            self.timestampTwo = [NSDate date];
            
			[TIBLELogger info:@"TIBLEAlertManager - Showing user Alert - %@.\n", message];
			
			NSString * OKButton = NSLocalizedString(@"Alert.OK", nil);
			
			self.alertTwo = [[UIAlertView alloc] initWithTitle:nil
													   message:message
													  delegate:self
											 cancelButtonTitle:OKButton
											 otherButtonTitles:nil];
			[self.alertTwo show];
		}
	}
}

@end
