/*
 *  TIBLEDeviceListPickerManager.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEDeviceListPickerManager.h"
#import "TIBLEDeviceListPickerTableViewController.h"
#import "TIBLEUIConstants.h"
#import "TIBLEDevicesManager.h"
#import "TIBLEFeatures.h"


@interface TIBLEDeviceListPickerManager ()
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

@end

@implementation TIBLEDeviceListPickerManager

- (id) init {
	
	self = [super init];
	
	if(self != nil){
		
		[self registerForNotifications];
	}
	
	return self;
}

- (void) showProgressScanning{
	
	//give immediate feedback to user that scanning is in progress.
	if(self.activityIndicator != nil){
		
		self.activityIndicator.hidden = NO;
		[self.activityIndicator startAnimating];
	}
	
	if(self.refreshButton != nil){
		[self.refreshButton setHidden:YES];
	}
}

- (IBAction)refreshList:(id)sender {

	[[TIBLEDevicesManager sharedTIBLEDevicesManager] restartDiscovery];
}

- (void) registerForNotifications{
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateActivityIndicator:)
												 name:TIBLE_NOTIFICATION_BLE_SCANNING
											   object:nil];	
}

- (void) updateActivityIndicator: (NSNotification *) notif{
	
	BOOL scanning = [[TIBLEDevicesManager sharedTIBLEDevicesManager] isScanning];
	
	if(scanning == YES){
		
		if(self.activityIndicator != nil){
			self.activityIndicator.hidden = NO;
			[self.activityIndicator startAnimating];
		}
		
		if(self.refreshButton != nil){
			[self.refreshButton setHidden:YES];
		}
	}
	else{

		if(self.activityIndicator != nil){
			self.activityIndicator.hidden = YES;
			[self.activityIndicator stopAnimating];
		}
		
		if(self.refreshButton != nil){
			[self.refreshButton setHidden:NO];
		}
	}
}

- (BOOL) isDevicesListAlertShowing{
	
	BOOL retVal = NO;
	
	if(self.devicesListAlertWindow != nil){
		retVal = YES;
	}
	
	return retVal;
}

- (void) showDevicesListAlert{
	
	if(TIBLE_FEATURE_ENABLE_SENSOR_PICKER_DIALOG){
		
		if([self isDevicesListAlertShowing] == NO){
			
			UINib *nib = [UINib nibWithNibName:@"TIBLEDevicesListAlertWindow" bundle:nil];
			[nib instantiateWithOwner:self options:nil];
			
			self.devicesListAlertWindow.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
			self.devicesListAlertWindow.hidden = NO;
			self.devicesListAlertWindow.userInteractionEnabled = YES;
			//[devicesListAlertWindow makeKeyWindow];
			
			[self.devicesListAlertWindow setOrientationToCurrentDeviceOrientation];
			
			[self updateActivityIndicator:nil];
			
			[self.stretchableAlertBackgroundImageView setImageForName:@"alert_view_background.png"
															andInsets:UIEdgeInsetsMake(80, 35, 60, 35)];
			
			[self.stretchableAlertContentBackgroundImageView setImageForName:@"alert_view_content_background.png"
																   andInsets:UIEdgeInsetsMake(6, 4, 5, 6)];
			
			[self.tableContainerView addSubview:self.tableVC.view];
			self.tableVC.view.frame = self.tableContainerView.bounds;
			
			//start BLE discovery if scanning is not already happening.
			
			TIBLEDevicesManager * deviceManager = [TIBLEDevicesManager sharedTIBLEDevicesManager];
			
			//if app is already scanning, don't want to scan.
			//if app is connecting to a sensor, don't want to scan.
			//if app has no sensor connected, want to trigger a scan.
			if(deviceManager.isScanning == NO &&
			   deviceManager.isConnecting == NO &&
			   deviceManager.connectedSensor == nil){
				
				[self showProgressScanning];
				
				[[TIBLEDevicesManager sharedTIBLEDevicesManager] restartDiscovery];
			}
		
			//can show also for sensor just being discovered after user dimisses picker,
			//or for connected sensor change.
			
			[self.delegate devicePickerDidShow];
		}
	}
}

- (IBAction)dismissDevicesListAlert:(id)sender {
	
	[self.devicesListAlertWindow removeFromSuperview];
	self.devicesListAlertWindow = nil;
	
	self.tableVC = nil;
	
	[self.delegate devicePickerDidHide];
}

@end
