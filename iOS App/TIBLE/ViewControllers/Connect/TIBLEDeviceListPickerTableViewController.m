/*
 *  TIBLEDeviceListPickerTableViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEDeviceListPickerTableViewController.h"
#import "TIBLESelectableSensorCell.h"
#import "TIBLEUIConstants.h"
#import "TIBLEDevicesManager.h"
#import "TIBLEPeripheral.h"

#define SENSOR_INFO_CELL_HEIGHT 60.0f

@interface TIBLEDeviceListPickerTableViewController ()

@property (nonatomic,readwrite)int selectedCell;

@property (nonatomic, copy) NSArray * availablePeripherals;

@property (weak, nonatomic) IBOutlet UIView *tableContainerView;

@property (nonatomic, strong) UITableViewCell * emptyMessageCell;
@property (nonatomic, assign) BOOL isTableEmpty;

@end

@implementation TIBLEDeviceListPickerTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.isTableEmpty = YES;
	self.emptyMessageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TIBLEEmptyCell"];
	self.emptyMessageCell.textLabel.text = NSLocalizedString(@"ConnectScreen.NoSensorAvailable.Message", nil);
	self.emptyMessageCell.textLabel.font = [UIFont fontWithName:TIBLE_APP_FONT_NAME size:TIBLE_APP_FONT_H3_HEADER_SIZE];
	self.emptyMessageCell.userInteractionEnabled = NO;
	self.emptyMessageCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.emptyMessageCell.textLabel.textAlignment = NSTextAlignmentCenter;
	
	[self.tableView registerNib:[UINib nibWithNibName:@"TIBLESelectableSensorCell" bundle:nil]
		 forCellReuseIdentifier:@"TIBLESelectableSensorCell"];
	
	[self registerForNotifications];
	[self refreshList];
}

- (void) viewDidUnload{
	
	[self unregisterForNotifications];

	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateConnectedSensorInfoView: (NSNotification *) notif{
	
	[self refreshList];
}

- (void) updateDeviceList: (NSNotification *) notif{
	
	[self refreshList];
}

- (void) registerForNotifications{
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateDeviceList:)
												 name:TIBLE_NOTIFICATION_UPDATE_DEVICE_LIST
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateConnectedSensorInfoView:)
												 name:TIBLE_NOTIFICATION_UPDATE_CONNECTED_SENSOR_CHANGED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateDeviceList:)
												 name:TIBLE_NOTIFICATION_BLE_CONNECTING
											   object:nil];
	
}

- (void) unregisterForNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) internalRefresh{
	
	NSArray * devicesList = [[TIBLEDevicesManager sharedTIBLEDevicesManager] availablePeripherals];
	
	self.availablePeripherals = devicesList;
	
	if([self.availablePeripherals count] > 0){
		
		self.isTableEmpty = NO;
	}
	else{
		self.isTableEmpty = YES;
	}
	
	[self.tableView reloadData];
}

- (void) refreshList{
	
	[self internalRefresh];
}

#pragma UITableViewDataSource

- (TIBLESensorModel *) connectedSensor{
	
	return [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	int listCount = 1; //defaults to empty cell with message if there are no sensors available.
	
	if(self.isTableEmpty == NO){
		
		listCount = [self.availablePeripherals count];
	}

	return listCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
	UITableViewCell * retCell;
	
	if(self.isTableEmpty == NO){
		
		TIBLESelectableSensorCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TIBLESelectableSensorCell"];
		
		TIBLEPeripheral * peripheral = [self.availablePeripherals objectAtIndex:indexPath.row];
		
		cell.cellNameLabel.text = [peripheral nameStr];
		cell.cellNameLabel.font = [UIFont fontWithName:TIBLE_APP_FONT_NAME size:TIBLE_APP_FONT_NORMAL_SIZE];
		cell.cellAddressLabel.text = [peripheral uuidStr];
		cell.cellAddressLabel.font = [UIFont fontWithName:TIBLE_APP_FONT_NAME size:TIBLE_APP_FONT_NORMAL_SIZE];
		
		
		if(peripheral.isConnected == YES){
			
			cell.checkmark.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
			[cell.connectingIndicator stopAnimating];
		}
		else{ //not connected
			
			cell.checkmark.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
			
			if(peripheral.isConnecting){
				[cell.connectingIndicator startAnimating];
			}
			else{
				[cell.connectingIndicator stopAnimating];
			}
		}
		
		retCell = cell;
	}
	else{
		retCell = self.emptyMessageCell;
	}
    
    return retCell;
}

#pragma UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //if selected cell is same as currently selected, leave selected.
    self.selectedCell = indexPath.row;
    
	//make sure the peripheral is connected for selected index
	TIBLEPeripheral * peripheral = [self.availablePeripherals objectAtIndex:indexPath.row];
	TIBLESelectableSensorCell * cell = (TIBLESelectableSensorCell *) [self.tableView cellForRowAtIndexPath:indexPath];
	
	//to give user immediate feedback.
	if(peripheral.isConnected == NO &&
	   [[TIBLEDevicesManager sharedTIBLEDevicesManager] isConnecting] == NO){
		
		cell.checkmark.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
		[cell.connectingIndicator startAnimating];
	}
	
	[cell setNeedsDisplay];
	
	[[TIBLEDevicesManager sharedTIBLEDevicesManager] connectToPeripheral:peripheral];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return SENSOR_INFO_CELL_HEIGHT;
}


@end
