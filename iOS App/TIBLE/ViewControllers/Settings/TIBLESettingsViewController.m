/*
 *  TIBLESettingsViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLESettingsViewController.h"
#import "TIBLESelectableCell.h"
#import "TIBLEFormulaSettingsViewController.h"
#import "TIBLEGraphDisplaySettingsViewController.h"
#import "TIBLESensorProfile.h"
#import "TIBLESettingsManager.h"
#import "TIBLESensorSettingsViewController.h"
#import "TIBLEUserDefaultConstants.h"
#import "TIBLEDevicesManager.h"
#import "TIBLEUIConstants.h"
#import "TIBLEResourceConstants.h"
#import "TIBLENoSensorAvailableViewController.h"
#import "TIBLELoadingViewController.h"
#import "TIBLEFeatures.h"

@interface TIBLESettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView * table; /*!< Table where all saved settings are displayed */
@property (strong, nonatomic) TIBLESettingsManager *settingsManager;
@property (strong, nonatomic) UIAlertView *alertMessage; /*!< Alert message shown when user creates/renames a setting */
@property (weak, nonatomic) IBOutlet UILabel *saveSettingsLabel;

@property (nonatomic, strong) TIBLENoSensorAvailableViewController * noSensorAvailableVC;
@property (nonatomic, assign) BOOL displayNoSensorAvailableUI;

@property (nonatomic, strong) TIBLELoadingViewController * loadingVC;
@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, strong) UIView *blankView;

/**
 * Used by alertMessage. Checks if setting name provided by the user already exists.
 * If it does, the existing setting is overwritten with the currently set values.
 */
- (void)overWriteSetting;

@end

@implementation TIBLESettingsViewController

#pragma mark - Init

- (void) configure{

	self.title = NSLocalizedString(@"Settings.title", @"Settings title");
    self.navigationController.title = NSLocalizedString(@"Settings.title", @"Settings title");
	
	self.accessibilityLabel = TIBLE_UI_COMPONENT_SETTINGS_VC_IDENTIFIER;
	self.navigationController.accessibilityLabel = TIBLE_UI_COMPONENT_SETTINGS_VC_IDENTIFIER;
	
	[self registerForNotifications];
	self.settingsManager = [TIBLESettingsManager sharedTIBLESettingsManager];
	
	self.alertMessage = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Settings.SaveSettings.Alert.SaveSetting.Button",nil)
												   message:NSLocalizedString(@"Settings.SaveSettings.Alert.EnterSettingName", nil)
												  delegate:nil
										 cancelButtonTitle:nil
										 otherButtonTitles:NSLocalizedString(@"Button.Save", nil), nil];
    
    self.alertMessage.delegate = self;
    self.alertMessage.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.alertMessage textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.noSensorAvailableVC = [[TIBLENoSensorAvailableViewController alloc] initWithNibName:@"TIBLENoSensorAvailableViewController" bundle:nil];
    
    self.loadingVC = [[TIBLELoadingViewController alloc] initWithNibName:@"TIBLELoadingViewController" bundle:nil];
    
    self.blankView = [[UIView alloc] init];
    self.blankView.backgroundColor = self.view.backgroundColor;
    
    self.isLoading = self.service.isReadingCharacteristics;
    
    self.displayNoSensorAvailableUI = TIBLE_FEATURE_ENABLE_NO_SENSOR_AVAILABLE_UI;
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if(self != nil){
		
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

- (id) init{
	
	self = [super init];
	
	if(self){

		[self configure];
	}
	
	return self;
}

#pragma mark - notifications
- (void) registerForNotifications{
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorChanged:)
												 name:TIBLE_NOTIFICATION_UPDATE_CONNECTED_SENSOR_CHANGED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorStartedReadingCharacteristics:)
												 name:TIBLE_NOTIFICATION_BLE_CHARACTERISTICS_READING_STARTED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorEndedReadingCharacteristics:)
												 name:TIBLE_NOTIFICATION_BLE_CHARACTERISTICS_READING_ENDED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorIsReceivingSamples:)
												 name:TIBLE_NOTIFICATION_BLE_RECEIVING_SAMPLES
											   object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateViews];
}

- (void) unregisterForNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) connectedSensorChanged:(NSNotification *) notif {
    
    if ([[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor]) {

        [self.table reloadData];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    self.isLoading = YES;
    
    [self updateViews];
}

- (void) connectedSensorStartedReadingCharacteristics: (NSNotification *) notif{
	
	//do nothing.
}

- (void) connectedSensorEndedReadingCharacteristics: (NSNotification *) notif{
	//do nothing.
}

- (void) connectedSensorIsReceivingSamples: (NSNotification *) notif{
	
	self.isLoading = NO;
	
	[self updateViews];
}

#pragma mark - view

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.saveSettingsLabel setText:NSLocalizedString(@"Settings.SaveSettings.Label", nil)];
    
    [self.table registerNib:[UINib nibWithNibName:@"TIBLESelectableCell" bundle:nil] forCellReuseIdentifier:@"TIBLESelectableCell"];
    
    [self.headerSettingsOptions setTitleString:NSLocalizedString(@"Settings.ViewAndConfigure.Header", nil)];
    [self.headerSaveSettings setTitleString:NSLocalizedString(@"Settings.SelectToLoad.Header", nil)];

	[self.stretchableSettingsViewControllerBackgroundImageView setImageForName:@"gradient_bg_stretch.png"
															  withLeftCapWidth:25 andTopCapHeight:25];

    [self addChildViewController:self.noSensorAvailableVC];
	[self addChildViewController:self.loadingVC];
    
    [self updateViews];
}

- (void)viewDidUnload {
    
    [self unregisterForNotifications];
    
    [self setHeaderSettingsOptions:nil];
    [self setHeaderSaveSettings:nil];
    [self setTable:nil];
    [self setStretchableSettingsViewControllerBackgroundImageView:nil];
    [self setStretchableSettingsViewControllerBackgroundImageView:nil];
    
    [super viewDidUnload];
}

#pragma mark - no sensor and loading views

- (void) displaySensorAvailableViews{
    
	//remove
	if([self.noSensorAvailableVC.view isDescendantOfView:self.view] == YES){
		[self.noSensorAvailableVC.view removeFromSuperview];
	}
	
	if([self.loadingVC.view isDescendantOfView:self.view] == YES){
		[self.loadingVC.view removeFromSuperview];
	}
    
    if ([self.blankView isDescendantOfView:self.view] == YES) {
        [self.blankView removeFromSuperview];
        [self.navigationController setNavigationBarHidden:NO];
    }
}

- (void) displaySensorNotAvailableViews{
	
	//remove
    [self.navigationController setNavigationBarHidden:YES];
    
	if([self.loadingVC.view isDescendantOfView:self.view] == YES)
		[self.loadingVC.view removeFromSuperview];
	
	//add
    if ([self.blankView isDescendantOfView:self.view] == NO)
        [self.view addSubview:self.blankView];
	
    if([self.noSensorAvailableVC.view isDescendantOfView:self.view] == NO)
		[self.view addSubview:self.noSensorAvailableVC.view];

	//resize
	self.noSensorAvailableVC.view.frame = CGRectMake(0.0f,
													 0.0f,
													 self.view.bounds.size.width,
													 self.view.bounds.size.height);
    
    CGFloat navBarSize = self.navigationController.navigationBar.frame.size.height;
    
    self.blankView.frame = CGRectMake(0.0f,
                                      0.0f,
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height + navBarSize);
}

- (void) displayLoadingView{
	
	//remove
    [self.navigationController setNavigationBarHidden:YES];
	
	//remove 
	if([self.noSensorAvailableVC.view isDescendantOfView:self.view] == YES)
		[self.noSensorAvailableVC.view removeFromSuperview];
	
	//add
	if ([self.blankView isDescendantOfView:self.view] == NO)
        [self.view addSubview:self.blankView];
	
	if([self.loadingVC.view isDescendantOfView:self.view] == NO){
		[self.view addSubview:self.loadingVC.view];
	}
	
	//resize
	self.loadingVC.view.frame = CGRectMake(0.0f,
										   0.0f,
										   self.view.bounds.size.width,
										   self.view.bounds.size.height);
	
	CGFloat navBarSize = self.navigationController.navigationBar.frame.size.height;
    
    self.blankView.frame = CGRectMake(0.0f,
                                      0.0f,
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height + navBarSize);
}

- (void) updateViews{
	
	if(self.isViewLoaded == NO){
		
		[TIBLELogger detail:@"TIBLESettingsViewController - Not updating views since view is not loaded."];
	}
	else if(self.sensor != nil){
        
		if(self.isLoading == YES && TIBLE_FEATURE_ENABLE_NO_SENSOR_AVAILABLE_UI == YES){
			[self displayLoadingView];
		}
		else{
			[self displaySensorAvailableViews];
		}
	}
	else { //sensor = nil
        
		if(self.displayNoSensorAvailableUI && TIBLE_FEATURE_ENABLE_NO_SENSOR_AVAILABLE_UI == YES){
			
			[self displaySensorNotAvailableViews];
		}
		else{
			[self displaySensorAvailableViews];
		}
	}
	
	[self.view setNeedsLayout];
	[self.view setNeedsDisplay];
}

#pragma mark - Actions

- (IBAction)showSensorSettings:(id)sender {
    
    TIBLESensorSettingsViewController *sensorSettingsViewController = [[TIBLESensorSettingsViewController alloc] init];
    
    [self.navigationController pushViewController:sensorSettingsViewController animated:YES];
}

- (IBAction)showGraphDisplaySettings:(id)sender {
    
    TIBLEGraphDisplaySettingsViewController *graphDisplaySettingsView = [[TIBLEGraphDisplaySettingsViewController alloc] init];
    
    [self.navigationController pushViewController:graphDisplaySettingsView animated:YES];
}

- (IBAction)showFormulaSettings:(id)sender {
    
    TIBLEFormulaSettingsViewController *formulaSettingsView = [[TIBLEFormulaSettingsViewController alloc] init];
    
    [self.navigationController pushViewController:formulaSettingsView animated:YES];
}

- (IBAction)saveSettings:(id)sender {
    
    [self showMessage];
}

#pragma mark - alert view

- (void)showMessage{
    
    if ([self.settingsManager.setting.settingName isEqualToString:TIBLE_SENSOR_NOT_INITIALIZED_STRING]) {
		
        [[self.alertMessage textFieldAtIndex:0] setPlaceholder:NSLocalizedString(@"Settings.SaveSettings.SettingName.Placeholder", nil)];
    }
    else {
        [[self.alertMessage textFieldAtIndex:0] setText:self.settingsManager.setting.settingName];
    }
    
    [self.alertMessage show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self overWriteSetting];
    
    int selectedSettingIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedSettingIndexKey];
    
    if (selectedSettingIndex  == NO_SETTING_SELECTED) {
        // no setting is selected and we didn't overwrite one so we'll create a new one
        [self.settingsManager createSetting];
    }

    int row = [self.settingsManager.allSettings indexOfObject:self.settingsManager.setting];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    if (selectedSettingIndex == NO_SETTING_SELECTED) {
        // if new setting, insert it into table and select it
        [self.table insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.table.delegate tableView:self.table didSelectRowAtIndexPath:indexPath];
    }
    
    self.settingsManager.setting.settingName = [self.alertMessage textFieldAtIndex:0].text;
    [[self.alertMessage textFieldAtIndex:0] setText:@""];
    
    [self.settingsManager saveSettings];
    [self.table reloadData];
}

- (void)overWriteSetting {
    
    NSString *newSettingName = [self.alertMessage textFieldAtIndex:0].text;
    NSArray *settings = [self.settingsManager allSettings];
    
    int i = 0;
    
    for (TIBLESensorProfile __strong *s in settings) {
        
        // check if we are saving a setting with an existing name
        if ([newSettingName isEqualToString:s.settingName]) {
            
            //overwrite the setting
            [[self.settingsManager allSettings]
                replaceObjectAtIndex:i withObject:self.settingsManager.setting.copy];
            
            s.settingName = newSettingName;
            
            // select the setting that we overwrote
            [self.settingsManager setSeletedSettingIndex:i];
            
            return;
        }
        
        i++;
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    UITextField *textField = [alertView textFieldAtIndex:0];
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    
    if ([[textField.text stringByTrimmingCharactersInSet: set] length] == 0) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.settingsManager.allSettings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TIBLESelectableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TIBLESelectableCell"];
    
    TIBLESensorProfile *setting = [[self.settingsManager allSettings] objectAtIndex:indexPath.row];
    cell.cellTitleLabel.text = [NSString stringWithFormat:@"%@", setting.settingName];
    
    int selectedSettingIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedSettingIndexKey];
    
    if(indexPath.row == selectedSettingIndex) {
        cell.checkmark.alpha = 1.0f;
    }
    else {
        cell.checkmark.alpha = 0.0f;
    }
    
    //we dont need this label, so well set it to an empty string
    cell.cellValueLabel.text = @"";
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSArray *settings = [self.settingsManager allSettings];
        TIBLESensorProfile *settingToRemove = [settings objectAtIndex:indexPath.row];
        
        int selectedSettingIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedSettingIndexKey];

        if (indexPath.row == selectedSettingIndex) {
            // we deleted the selected setting
            selectedSettingIndex = NO_SETTING_SELECTED;
        }
        else if (indexPath.row < selectedSettingIndex) {
            // the deleted setting is above our currently selected setting
            // so we need to decrement the selected setting index
            selectedSettingIndex--;
        }
        
        [self.settingsManager removeSetting:settingToRemove];
        [self.settingsManager setSeletedSettingIndex:selectedSettingIndex];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self sendNotificationCharacteristicValueUpdated];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
    int selectedSettingIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedSettingIndexKey];
    
    if (indexPath.row == selectedSettingIndex) {
        // we are deselecting a setting
        selectedSettingIndex = NO_SETTING_SELECTED;
    }
    else {
        selectedSettingIndex = indexPath.row;
    }
    
    [self.settingsManager setSeletedSettingIndex:selectedSettingIndex];
    
    [self sendNotificationCharacteristicValueUpdated];
    
    // write the settings to the sensor
    TIBLESensorSettingsViewController *s = [[TIBLESensorSettingsViewController alloc] init];
    [s writeAllValues];
    
    [tableView reloadData];
}

- (void) sendNotificationCharacteristicValueUpdated {
	
	[TIBLELogger info:@"TIBLESettingsViewController - Sending Notification: Characteristic Value Updated.\n"];
	
	NSNotification * updateUINotif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED
																   object:nil
																 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:updateUINotif];
}

#pragma mark - Getters
- (TIBLEService *) service{
	
	return [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedService];
}

- (TIBLESensorModel * ) sensor{
	
	return [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
}

@end
