/*
 *  TIBLEConnectViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEConnectViewController.h"
#import "TIBLESelectableSensorCell.h"
#import "TIBLEUIConstants.h"
#import "TIBLEDevicesManager.h"
#import "TIBLEDeviceListPickerTableViewController.h"
#import "TIBLESavedSensor.h"

@interface TIBLEConnectViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *stretchBGImageView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton; /*!< Starts scanning for available sensors. */
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator; /*!< Is shown while App scans for sensors. */
@property (strong, nonatomic) UIAlertView *alertMessage;

@end

@implementation TIBLEConnectViewController


#pragma mark - Init

- (IBAction)refreshList:(id)sender {
	
	//give immediate feedback to user that refresh is in progress.
	if(self.activityIndicator != nil){
		
		self.activityIndicator.hidden = NO;
		[self.activityIndicator startAnimating];
	}
	
	if(self.refreshButton != nil)
		[self.refreshButton setHidden:YES];
	
	[[TIBLEDevicesManager sharedTIBLEDevicesManager] restartDiscovery];
}

- (void) updateActivityIndicator: (NSNotification *) notif{
	
	BOOL scanning = [[TIBLEDevicesManager sharedTIBLEDevicesManager] isScanning];
	
	if(scanning == YES){
		
		if(self.activityIndicator != nil){
			self.activityIndicator.hidden = NO;
			[self.activityIndicator startAnimating];
		}
		
		if(self.refreshButton != nil)
			[self.refreshButton setHidden:YES];
	}
	else{
		
		if(self.activityIndicator != nil){
			self.activityIndicator.hidden = YES;
			[self.activityIndicator stopAnimating];
		}
			
		if(self.refreshButton != nil)
			[self.refreshButton setHidden:NO];
	}
}

- (void) configure{
	
	self.title = NSLocalizedString(@"Connect.title", @"Connect tab title");
    self.navigationController.title = NSLocalizedString(@"Connect.title", @"Connect title");
	
	self.accessibilityLabel = TIBLE_UI_COMPONENT_CONNECT_VC_IDENTIFIER;
	self.navigationController.accessibilityLabel = TIBLE_UI_COMPONENT_CONNECT_VC_IDENTIFIER;
	
	[self registerForNotifications];
	
	self.alertMessage = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ConnectScreen.SensorName.Alert.Title",nil)
												   message:NSLocalizedString(@"ConnectScreen.SensorName.Alert.Body", nil)
												  delegate:nil
										 cancelButtonTitle:NSLocalizedString(@"Button.Cancel", nil)
										 otherButtonTitles:NSLocalizedString(@"Button.Save", nil), nil];
	self.alertMessage.delegate = self;
	self.alertMessage.alertViewStyle = UIAlertViewStylePlainTextInput;
	[self.alertMessage textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (id)init
{
    self = [super init];
	
    if (self) {
		
		[self configure];
	}
	
	return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	
    if (self) {
		
		[self configure];
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.headerConnectedToSensor setTitleString:NSLocalizedString(@"ConnectScreen.ConnectedSensor.Header", @"Connect header")];
	[self.headerDiscoveredSensors setTitleString:NSLocalizedString(@"ConnectScreen.DiscoveredSensors.Header", @"Discovered header")];
    
    
    [self.labelNoSensorConnected setText:NSLocalizedString(@"SensorInfo.NoSensorConnected.Label", @"No sensor connected label")];
    [self.addressLabel setText:NSLocalizedString(@"SensorInfo.SensorAddress.Label", @"Address of sensor")];
    [self.typeLabel setText:NSLocalizedString(@"SensorInfo.SensorType.Label", @"Type of sensor")];
    [self.nameLabel setText:NSLocalizedString(@"SensorInfo.SensorName.Label", @"Name of sensor")];

	[self.tableContainerView addSubview:self.tableVC.view];
	self.tableVC.view.frame = self.tableContainerView.bounds;
	[self addChildViewController:self.tableVC];
	
	[self updateConnectedSensorInfoView:nil];
	
	[self registerForNotifications];
	
	[self.stretchableSensorInfoBackgroundImageView setImageForName:@"gradient_bg_stretch.png"
												  withLeftCapWidth:25 andTopCapHeight:25];
	
	 [self updateActivityIndicator:nil];
}

- (void) viewDidUnload{
	
	[self unregisterForNotifications];
	
    [self setLabelNoSensorConnected:nil];
	[self setAddressLabel:nil];
	[self setAddressValueLabel:nil];
	[self setTypeLabel:nil];
	[self setTypeValueLabel:nil];
	[self setNameLabel:nil];
	[self setNameValueLabel:nil];
    [self setStretchBGImageView:nil];
	[self setTableContainerView:nil];
	[self setTableVC:nil];
    [self setStretchableSensorInfoBackgroundImageView:nil];
	[super viewDidUnload];
}

- (void) registerForNotifications{

	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(characteristicValueUpdated:)
												 name:TIBLE_NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateConnectedSensorInfoView:)
												 name:TIBLE_NOTIFICATION_UPDATE_CONNECTED_SENSOR_CHANGED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateActivityIndicator:)
												 name:TIBLE_NOTIFICATION_BLE_SCANNING
											   object:nil];
}

- (void) unregisterForNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateConnectedSensorInfoView: (NSNotification *) notif{
	
	[self updateConnectedSensorInfoViewLabels];
}

- (void) updateConnectedSensorInfoViewLabels{

	TIBLESensorModel * connectedSensor = [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
	
	if(connectedSensor == nil){
		
		//make label visible if no sensor is connected.
		self.labelNoSensorConnected.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
		
		self.addressLabel.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
		self.addressValueLabel.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
		self.typeValueLabel.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
		self.typeLabel.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
		self.nameLabel.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
		self.nameValueLabel.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
        self.editSensorName.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
        self.editSensorName.enabled = NO;
	}
	else{
		
		self.labelNoSensorConnected.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
		
		self.addressLabel.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
		self.addressValueLabel.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
		self.typeValueLabel.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
		self.typeLabel.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
		self.nameLabel.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
		self.nameValueLabel.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
        self.editSensorName.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
        self.editSensorName.enabled = YES;
		
		self.addressValueLabel.text	= [connectedSensor.peripheral uuidStr];
		self.typeValueLabel.text = connectedSensor.sensorProfile.sensorTypeDescription;

        self.nameValueLabel.text = [connectedSensor.peripheral nameStr];
	}
	
	[self.view setNeedsDisplay];
}

- (void) characteristicValueUpdated: (NSNotification *) notif{
	
	[self updateConnectedSensorInfoViewLabels];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - set/edit sensor name

- (IBAction)editName:(id)sender {
	
	TIBLESensorModel * connectedSensor = [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
	
	NSString * defaultName = [connectedSensor.peripheral nameStr];
	
	if(defaultName == nil){
		defaultName = NSLocalizedString(@"ConnectScreen.SensorName.Placeholder", nil);
	}
	
	[[self.alertMessage textFieldAtIndex:0] setText:defaultName];
    
    [self.alertMessage show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) { // if we are saving
        
        TIBLEPeripheral *peripheral = [[[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedService] peripheral];
		
        NSString *uuidString = [peripheral uuidStr];
        CFUUIDRef uuid = CFUUIDCreateFromString(NULL, (CFStringRef)uuidString);
        
        NSString *name = [self.alertMessage textFieldAtIndex:0].text;
        [[TIBLESavedSensor sharedTIBLESavedSensor] setSensorWithUUID:uuid withName:name];
        
        [peripheral setNameStr:name];
        
        [self.tableVC refreshList];
        [self updateConnectedSensorInfoViewLabels];
        CFRelease(uuid);
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    UITextField *textField = [alertView textFieldAtIndex:0];
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    
    if ([[textField.text stringByTrimmingCharactersInSet: set] length] == 0) {
        return NO;
    }
    return YES;
}

@end
