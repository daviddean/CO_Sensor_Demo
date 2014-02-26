/*
 *  TIBLENoSensorAvailableViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLENoSensorAvailableViewController.h"
#import "TIBLEUIConstants.h"
#import "TIBLEDevicesManager.h"
#import "TIBLEURLConstants.h"
#import "TIBLEInfoViewController.h"
#import "TIBLEUIConstants.h"

@interface TIBLENoSensorAvailableViewController ()
@property (strong, nonatomic) IBOutlet UILabel *notConnectedlabel;
@property (strong, nonatomic) IBOutlet UILabel *turnOnSensorLabel;
@property (strong, nonatomic) IBOutlet UILabel *BLELabel;
@property (strong, nonatomic) IBOutlet UIButton *purchaseButton; /*!< Takes the user to the info tab to view purchase a sensor. */
@property (strong, nonatomic) IBOutlet UIButton *connectButton;/*!< Allows the user to search for sensors that are in range. */

@end

@implementation TIBLENoSensorAvailableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		self.accessibilityLabel = TIBLE_UI_COMPONENT_NO_SENSOR_VC_IDENTIFIER;
		self.navigationController.accessibilityLabel = TIBLE_UI_COMPONENT_NO_SENSOR_VC_IDENTIFIER;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
    [self.notConnectedlabel setText:NSLocalizedString(@"NoSensorAvailableScreen.NotConnected.Header", @"Not connected label")];
    [self.turnOnSensorLabel setText:NSLocalizedString(@"NoSensorAvailableScreen.message.two", @"Inform user to turn on sensor")];
    [self.BLELabel setText:NSLocalizedString(@"NoSensorAvailableScreen.message.one", @"Info user that app only works with a connected sensor")];
    [self.purchaseButton setTitle:NSLocalizedString(@"NoSensorAvailableScreen.PurchaseSensor.message", @"Allows the user to purchase sensor") forState:UIControlStateNormal];
    [self.purchaseButton setTitle:NSLocalizedString(@"NoSensorAvailableScreen.PurchaseSensor.message", @"Allows the user to purchase sensor") forState:UIControlStateSelected];
    [self.connectButton setTitle:NSLocalizedString(@"NoSensorAvailableScreen.ConnectNearby.message",
												   @"Connect to sensor when there isn't one connected") forState:UIControlStateNormal];
    [self.connectButton setTitle:NSLocalizedString(@"NoSensorAvailableScreen.ConnectNearby.message",
												   @"Connect to sensor when there isn't one connected") forState:UIControlStateSelected];
}

- (IBAction)purchaseSensorButtonTapped:(id)sender {
    
	//take user to Safari.
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: kTIURLSensorCombo]];
}

- (IBAction)connectToSensorButtonTapped:(id)sender {

	//send notification so picker launches if necessary.
	NSNotification * notif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_UPDATE_DEVICE_LIST
														   object:nil
														 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:notif];
}

-(void) dealloc{
	
	self.notConnectedlabel = nil;
	self.turnOnSensorLabel = nil;
	self.BLELabel = nil;
	self.purchaseButton = nil;
	self.connectButton = nil;
}

@end
