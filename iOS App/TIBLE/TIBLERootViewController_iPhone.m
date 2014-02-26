/*
 *  TIBLERootViewController_iPhone.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLERootViewController_iPhone.h"
#import "TIBLESensorInfoViewController.h"
#import "TIBLEGraphViewController.h"
#import "TIBLEConnectViewController.h"
#import "TIBLESettingsViewController.h"
#import "TIBLEInfoViewController.h"
#import "TIBLEDevicesManager.h"
#import "TIBLENoSensorAvailableViewController.h"
#import "TIBLEUIConstants.h"
#import "QuartzCore/CALayer.h"
#import "TIBLEDeviceListPickerManager.h"
#import "TIBLEResourceConstants.h"

@interface TIBLERootViewController_iPhone ()

@property (nonatomic, strong) TIBLEDeviceListPickerManager * devicePickerManager;
@property (nonatomic, strong) TIBLESettingsViewController *settingsVC;

@end

@implementation TIBLERootViewController_iPhone

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	
    if (self) {
		
		self.devicePickerManager = [[TIBLEDeviceListPickerManager alloc] init];
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self registerForNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showSettings{
	
	NSMutableArray *tabbarViewControllers = [NSMutableArray arrayWithArray:
											 [self viewControllers]];
	
	bool found = NO;
	
	for(UIViewController * tmpController in tabbarViewControllers){
		
		if([[tmpController accessibilityLabel] isEqualToString:TIBLE_UI_COMPONENT_SETTINGS_VC_IDENTIFIER]){

			//keep it
			found = YES;
			break;
		}
	}
	
	if(found == NO){
		
		//insert item at index 3.
		
		[tabbarViewControllers insertObject:self.settingsVC atIndex:3];
		
		self.viewControllers = tabbarViewControllers;
		
	}
}

- (void) hideSettings{
	
	NSMutableArray *tabbarViewControllers = [NSMutableArray arrayWithArray:
											 [self viewControllers]];
	
	bool found = NO;
	
	for(UIViewController * tmpController in tabbarViewControllers){
		
		if([[tmpController accessibilityLabel] isEqualToString:TIBLE_UI_COMPONENT_SETTINGS_VC_IDENTIFIER]){
			
			//remove it
			found = YES;
			[tabbarViewControllers removeObject:tmpController];
            self.settingsVC = (TIBLESettingsViewController *)tmpController;
			
			break;
		}
	}
	
	if(found == YES){
		
		self.viewControllers = tabbarViewControllers;
	}
	
}

- (void) registerForNotifications{
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateDeviceListAlert:)
												 name:TIBLE_NOTIFICATION_UPDATE_DEVICE_LIST
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateDeviceListAlert:)
												 name:TIBLE_NOTIFICATION_UPDATE_CONNECTED_SENSOR_CHANGED
											   object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showListAfterForeground:)
                                                 name:kAppEnteredForegroundNotification
                                               object:nil];
}

- (void) unregisterForNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (BOOL) isConnectViewControllerShowing{
	
	UIViewController * selectedVC = self.selectedViewController;
	
	if([selectedVC.accessibilityLabel isEqualToString:TIBLE_UI_COMPONENT_CONNECT_VC_IDENTIFIER] == YES){
		
		return YES;
	}
	
	return NO;
}

- (void) updateDeviceListAlert: (NSNotification *) notif{
	
	if([[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor] == nil &&
			[self isConnectViewControllerShowing] == NO){
		[self.devicePickerManager showDevicesListAlert];
	}
}

- (void) showListAfterForeground: (NSNotification *) notif{
    
    //only show list if there is no sensor connected
    if (![[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor]) {
        [self updateDeviceListAlert:nil];
    }
}

@end
