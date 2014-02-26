/*
 *  TIBLESensorSettingsViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLESensorSettingsViewController.h"
#import "TIBLESelectableCell.h"
#import "TIBLESensorConstants.h"
#import "TIBLESettingsManager.h"
#import "TIBLEDevicesManager.h"
#import "TIBLECharacteristicsSingleton.h"
#import "TIBLEService.h"
#import "TIBLEUserDefaultConstants.h"
#import "TIBLEResourceConstants.h"
#import "TIBLEUIConstants.h"

@interface TIBLESensorSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table; /*!< Used to display all sensor settings and writable values for each setting. */
@property (strong, nonatomic) TIBLESettingsManager *settingsManager;

/**
 * This method is used to find which value the user just chose for the corresponding setting.
 *
 * @param index The index of the setting that is being viewed/modified.
 * @return Returns the index of the of the value that was selected for that setting.
 */
- (int)getSelectedValue:(int)index;

/**
 * This method is used write the selected value to the sensor and the SettingsManager singleton.
 *
 * @param settingIndex The index of the setting that we are going to write to the sensor.
 * @return Returns the value to write to the sensor.
 */
- (uint8_t)setValues:(int)settingIndex;

@end

@implementation TIBLESensorSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
	if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Settings.SensorSettings.title", nil);
    
        self.settingsManager = [TIBLESettingsManager sharedTIBLESettingsManager];
        
        self.content = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kSensorConfigurationConstantsPlistFileName
																							   ofType:kFileExtensionPlist]];
        self.childIndex = NO_SETTING_SELECTED;
    }
    
    return self;
}

#pragma mark - view methods
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
    [self.table registerNib:[UINib nibWithNibName:@"TIBLESelectableCell" bundle:nil] forCellReuseIdentifier:@"TIBLESelectableCell"];
    if (self.childIndex != NO_SETTING_SELECTED)
        self.title = [[self.content objectAtIndex:self.childIndex] valueForKey:kSettingTitleKey];
}

- (void)viewDidUnload {
    [self setTable:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [self registerForNotifications];
    [self.table reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self unregisterForNotifications];
}

#pragma mark - UITableViewSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.childIndex != NO_SETTING_SELECTED) // if we are in one of the subsections
        return [[[self.content objectAtIndex: self.childIndex] objectForKey: kSettingRowsKey] count];
    
    return [self.content count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    TIBLESelectableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TIBLESelectableCell"];
    
    if (self.childIndex != NO_SETTING_SELECTED) { // cells for subsection
        cell.cellTitleLabel.text = [[[self.content objectAtIndex:self.childIndex] objectForKey:kSettingRowsKey] objectAtIndex:indexPath.row];
        cell.cellValueLabel.text = @"";

        if ([self getSelectedValue:self.childIndex] == indexPath.row)
            cell.checkmark.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
        else
            cell.checkmark.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
    }
    else { // cells for main window
        cell.cellTitleLabel.text = [[self.content objectAtIndex:indexPath.row] valueForKey:kSettingTitleKey];
        cell.cellValueLabel.text = [[[self.content objectAtIndex:indexPath.row] objectForKey:kSettingRowsKey] objectAtIndex:[self getSelectedValue:indexPath.row]];

		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.checkmark.image = nil;
    }
    
    return cell;
}

#pragma mark - UITableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.childIndex != NO_SETTING_SELECTED) { // we selected a value in a sub section
 
        int8_t valueToWrite = [self setValues:indexPath.row];
        
        [tableView reloadData];
        
        [self writeToDeviceWithValue:valueToWrite atIndex:self.childIndex];
        
        [self  sendNotificationCharacteristicValueUpdated];
    }
    else { // we are going to a subsection
        TIBLESensorSettingsViewController *childSetting = [[TIBLESensorSettingsViewController alloc] init];
        childSetting.childIndex = indexPath.row;
        
        [self.navigationController pushViewController:childSetting animated:YES];
    }
}

#pragma mark - device communication

- (void)writeToDeviceWithValue:(uint8_t)value atIndex:(int)index {
    
    TIBLECharacteristics *characteristics = [[[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedService] characteristics];
    
    NSString *c = [[self.content objectAtIndex:index] valueForKey:kSettingSensorCharacteristicsKey];
    CBCharacteristic *characteristic = [characteristics characteristicForUUID:c];

    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    CBPeripheral *peripheral = [[[[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor] peripheral] peripheral];
    
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark - SensorSettings setter and getter

- (int)getSelectedValue:(int)index {
    int selectedValue = 0;
    
    if (index == 0) { // operation mode
        switch (self.settingsManager.setting.config_op_mode) {
            case OP_MODE_DEEP_SLEEP:
                selectedValue = 0;
                break;
            case OP_MODE_2_LEAD:
                selectedValue = 1;
                break;
            case OP_MODE_STANDBY:
                selectedValue = 2;
                break;
            case OP_MODE_3_LEAD:
                selectedValue = 3;
                break;
            case OP_MODE_TEMP_MEAS_TIA_OFF:
                selectedValue = 4;
                break;
            case OP_MODE_TEMP_MEAS_TIoA_ON:
                selectedValue = 5;
                break;
        }
    }
    else if (index == 1) { // tia feedback gain
        switch (self.settingsManager.setting.config_TIA_gain) {
            case TIA_GAIN_EXT_RESIST:
                selectedValue = 0;
                break;
            case TIA_GAIN_EXT_2_75_OHM:
                selectedValue = 1;
                break;
            case TIA_GAIN_EXT_3_5_OHM:
                selectedValue = 2;
                break;
            case TIA_GAIN_EXT_7_OHM:
                selectedValue = 3;
                break;
            case TIA_GAIN_EXT_14_OHM:
                selectedValue = 4;
                break;
            case TIA_GAIN_EXT_35_OHM:
                selectedValue = 5;
                break;
            case TIA_GAIN_EXT_120_OHM:
                selectedValue = 6;
                break;
            case TIA_GAIN_EXT_350_OHM:
                selectedValue = 7;
                break;
        }
    }
    else if (index == 2) { // r load
        switch (self.settingsManager.setting.config_R_load) {
            case R_LOAD_10_OHM:
                selectedValue = 0;
                break;
            case R_LOAD_30_OHM:
                selectedValue = 1;
                break;
            case R_LOAD_50_OHM:
                selectedValue = 2;
                break;
            case R_LOAD_100_OHM:
                selectedValue = 3;
                break;
        }
    }
    else if (index == 3) { // internal zero
        switch (self.settingsManager.setting.config_internal_zero) {
            case INT_Z_SEL_20_PERCENT:
                selectedValue = 0;
                break;
            case INT_Z_SEL_50_PERCENT:
                selectedValue = 1;
                break;
            case INT_Z_SEL_67_PERCENT:
                selectedValue = 2;
                break;
            case INT_Z_SEL_BYPASS_PERCENT:
                selectedValue = 3;
        }
    }
    else if (index == 4) { // voltage source
        switch (self.settingsManager.setting.config_reference_voltage_source) {
            case REF_SOURCE_INTERNAL:
                selectedValue = 0;
                break;
            case REF_SOURCE_EXTERNAL:
                selectedValue = 1;
                break;
        }
    }

    return selectedValue;
}

- (uint8_t)setValues:(int)settingIndex {
    
    uint8_t settingValue = 0;
    
    if (self.childIndex == 0) { // operation mode
        switch (settingIndex) {
            case 0:
                self.settingsManager.setting.config_op_mode = OP_MODE_DEEP_SLEEP;
                break;
            case 1:
                self.settingsManager.setting.config_op_mode = OP_MODE_2_LEAD;
                break;
            case 2:
                self.settingsManager.setting.config_op_mode = OP_MODE_STANDBY;
                break;
            case 3:
                self.settingsManager.setting.config_op_mode = OP_MODE_3_LEAD;
                break;
            case 4:
                self.settingsManager.setting.config_op_mode = OP_MODE_TEMP_MEAS_TIA_OFF;
                break;
            case 5:
                self.settingsManager.setting.config_op_mode = OP_MODE_TEMP_MEAS_TIoA_ON;
                break;
        }
        
        settingValue = self.settingsManager.setting.config_op_mode;
    }

    else if (self.childIndex == 1) { // tia feedback gain
        switch (settingIndex) {
            case 0:
                self.settingsManager.setting.config_TIA_gain = TIA_GAIN_EXT_RESIST;
                break;
            case 1:
                self.settingsManager.setting.config_TIA_gain = TIA_GAIN_EXT_2_75_OHM;
                break;
            case 2:
                self.settingsManager.setting.config_TIA_gain = TIA_GAIN_EXT_3_5_OHM;
                break;
            case 3:
                self.settingsManager.setting.config_TIA_gain = TIA_GAIN_EXT_7_OHM;
                break;
            case 4:
                self.settingsManager.setting.config_TIA_gain = TIA_GAIN_EXT_14_OHM;
                break;
            case 5:
                self.settingsManager.setting.config_TIA_gain = TIA_GAIN_EXT_35_OHM;
                break;
            case 6:
                self.settingsManager.setting.config_TIA_gain = TIA_GAIN_EXT_120_OHM;
                break;
            case 7:
                self.settingsManager.setting.config_TIA_gain = TIA_GAIN_EXT_350_OHM;
                break;
        }
        
        settingValue = self.settingsManager.setting.config_TIA_gain;
    }
    
    else if (self.childIndex == 2) { // r load
        switch (settingIndex) {
            case 0:
                self.settingsManager.setting.config_R_load = R_LOAD_10_OHM;
                break;
            case 1:
                self.settingsManager.setting.config_R_load = R_LOAD_30_OHM;
                break;
            case 2:
                self.settingsManager.setting.config_R_load = R_LOAD_50_OHM;
                break;
            case 3:
                self.settingsManager.setting.config_R_load = R_LOAD_100_OHM;
                break;
        }
        
        settingValue = self.settingsManager.setting.config_R_load;
    }
    
    else if (self.childIndex == 3) { //internal zero
        switch (settingIndex) {
            case 0:
                self.settingsManager.setting.config_internal_zero = INT_Z_SEL_20_PERCENT;
                break;
            case 1:
                self.settingsManager.setting.config_internal_zero = INT_Z_SEL_50_PERCENT;
                break;
            case 2:
                self.settingsManager.setting.config_internal_zero = INT_Z_SEL_67_PERCENT;
                break;
            case 3:
                self.settingsManager.setting.config_internal_zero = INT_Z_SEL_BYPASS_PERCENT;
                break;
        }
        
        settingValue = self.settingsManager.setting.config_internal_zero;
    }
    
    else if (self.childIndex == 4) { // voltage source
        switch (settingIndex) {
            case 0:
                self.settingsManager.setting.config_reference_voltage_source = REF_SOURCE_INTERNAL;
                break;
            case 1:
                self.settingsManager.setting.config_reference_voltage_source = REF_SOURCE_EXTERNAL;
                break;
        }
        
        settingValue = self.settingsManager.setting.config_reference_voltage_source;
    }

    return settingValue;
}

- (void)writeAllValues {
    
    int index = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedSettingIndexKey];
    
    if ([[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor].peripheral.peripheral.isConnected && index != NO_SETTING_SELECTED) {

        for (int i = 0; i < [self.content count]; i++) { // loop through each setting writing the appropriate values
            self.childIndex = i;
            int selectedValue = [self getSelectedValue:i]; // get setting that is selected
            int8_t valueToWrite = [self setValues:selectedValue]; // get the value for that setting
            
            [self writeToDeviceWithValue:valueToWrite atIndex:i]; // write the value to the device
        }
        
        self.childIndex = NO_SETTING_SELECTED;
    }
}

#pragma mark -- notifications

- (void) sendNotificationCharacteristicValueUpdated{
	
	[TIBLELogger info:@"TIBLESensorSettingsViewController - Sending Notification: Characteristic Value Updated.\n"];
	
	NSNotification * updateUINotif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED
																   object:nil
																 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:updateUINotif];
}

- (void) registerForNotifications{
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateFields:)
												 name:TIBLE_NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED
											   object:nil];
}

- (void)updateFields: (NSNotification *) notif{
    
    [self.table reloadData];

}

- (void) unregisterForNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
