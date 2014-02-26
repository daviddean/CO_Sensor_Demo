/*
 *  TIBLEGraphDisplaySettingsViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEGraphDisplaySettingsViewController.h"
#import "TIBLESettingsManager.h"
#import "TIBLETextFieldCell.h"
#import "TIBLEColorCell.h"
#import "TIBLESwitchCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NEOColorPickerHueGridViewController.h"
#import "TIBLEUIConstants.h"
#import "TIBLETextFieldCellLarge.h"

@interface TIBLEGraphDisplaySettingsViewController () <UITableViewDataSource, UITableViewDelegate, TIBLETextFieldCellDelegate, TIBLEColorCellDelegate, TIBLESwitchCellDelegate> {
    
    int index; /*!< Keeps track of which color cell was selected. */
    
    CGRect tableRect;
}

@property (strong, nonatomic) TIBLESettingsManager *settingsManager;
@property (strong, nonatomic) UITextField *selectedTextField; /*!< Reference to the currently selected text field. */
@property (weak, nonatomic) IBOutlet UITableView *table; /*!< Displays all editable graph values. */
@property (weak, nonatomic) UIButton *activeButton; /*!< Reference to the currently selected color button used with the color picker. */

@end

@implementation TIBLEGraphDisplaySettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {

        self.title = NSLocalizedString(@"Settings.GraphSettings.title", nil);
        
        self.selectedTextField = [[UITextField alloc] init];
        self.settingsManager = [TIBLESettingsManager sharedTIBLESettingsManager];
    }
    return self;
}

#pragma mark -- TIBLETextFieldDelegate

- (void)textFieldUpdatedWithCell:(TIBLETextFieldCell *)cell {
    
    int indexValue = [[self.table indexPathForRowAtPoint:cell.center] row];
    
    if (indexValue == 0)
        self.settingsManager.setting.graph_title = cell.valueTextField.text;
    else if (indexValue == 1)
        self.settingsManager.setting.graph_subTitle = cell.valueTextField.text;
    else if (indexValue == 2)
        self.settingsManager.setting.graph_x_axis_caption = cell.valueTextField.text;
    else if (indexValue == 3)
        self.settingsManager.setting.graph_y_axis_caption = cell.valueTextField.text;
    else if (indexValue == 4)
        self.settingsManager.setting.graph_y_axis_display_min = [cell.valueTextField.text integerValue];
    else if (indexValue == 5)
        self.settingsManager.setting.graph_y_axis_display_max = [cell.valueTextField.text integerValue];
    else if (indexValue == 6)
        self.settingsManager.setting.graph_color_top_mid_boundary = [cell.valueTextField.text integerValue];
    else if (indexValue == 7)
        self.settingsManager.setting.graph_color_mid_low_boundary = [cell.valueTextField.text integerValue];
    else if (indexValue == 8){
		
		float_t value = [cell.valueTextField.text floatValue];
		
		if(value == TIBLE_SENSOR_DO_NOT_CALIBRATE_VALUE ||
            [cell.valueTextField.placeholder isEqualToString:NSLocalizedString(@"Settings.Input.DoNotCalibrate.String", @"No calibration")])
        {
			cell.valueTextField.placeholder = NSLocalizedString(@"Settings.Input.DoNotCalibrate.String", nil);
			cell.valueTextField.text = nil;
            value = TIBLE_SENSOR_DO_NOT_CALIBRATE_VALUE;
		}
        
        self.settingsManager.setting.calibrationValue = value;
	}

	[self sendNotificationCharacteristicValueUpdated];
}

- (void)textFieldSelectedWithCell:(TIBLETextFieldCell *)cell {
    
    index = [[self.table indexPathForRowAtPoint:cell.center] row];
    self.selectedTextField = cell.valueTextField;
    
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                      atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textFieldDidEndEditingWithCell:(TIBLETextFieldCell *)cell {
	
	self.selectedTextField = cell.valueTextField;
	
	[self.selectedTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditingWithCell:(TIBLETextFieldCell *)cell {
	
	self.selectedTextField = cell.valueTextField;

}

#pragma mark - keyboard notifications

- (void) keyboardDidShow: (NSNotification *) notification {
    
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                      atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    if (!(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        
        NSDictionary* info = [notification userInfo];
        CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
        CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
        
        tableRect = self.table.frame;
        CGRect t = tableRect;
        
        t.size.height = t.size.height + navigationBarHeight - kbHeight;
        
        self.table.frame = t;
    }
}

- (void) keyboardDidHide: (NSNotification *) notification {
    
    if (!(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        self.table.frame = tableRect;
    }
    
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                      atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -- TIBLESwitchCellDelegate

- (void)switchFlippedInCell:(TIBLESwitchCell *)cell {
    
    int indexValue = [[self.table indexPathForRowAtPoint:cell.center] row];
    
    if (indexValue == 12)
        self.settingsManager.setting.graph_display_current_value = cell.cellSwitch.isOn;
    else if (indexValue == 13)
        self.settingsManager.setting.graph_log_scale_enabled = cell.cellSwitch.isOn;
    
    [self sendNotificationCharacteristicValueUpdated];
}

#pragma mark -- TIBLEColorCellDelegate

- (void)colorButtonSelectedWithCell:(TIBLEColorCell *)cell {
    
    NEOColorPickerHueGridViewController *colorController = [[NEOColorPickerHueGridViewController alloc] init];
    colorController.delegate = self;
    
    self.activeButton = cell.colorButton;
    index = [[self.table indexPathForRowAtPoint:cell.center] row];
    
    if (index == 9)
        colorController.selectedColor = self.settingsManager.setting.graph_color_top_value;
    else if (index == 10)
        colorController.selectedColor = self.settingsManager.setting.graph_color_mid_value;
    else if (index == 11)
        colorController.selectedColor = self.settingsManager.setting.graph_color_low_value;
    
    [self.navigationController pushViewController:colorController animated:YES];
}

#pragma mark -- color picker delegate
- (void) colorPickerViewController:(NEOColorPickerBaseViewController *)controller didSelectColor:(UIColor *)color {
    
    if (index == 9)
        self.settingsManager.setting.graph_color_top_value = color;
    else if (index == 10)
        self.settingsManager.setting.graph_color_mid_value = color;
    else if (index == 11)
        self.settingsManager.setting.graph_color_low_value = color;
    
    self.activeButton.backgroundColor = color;
	
	[self sendNotificationCharacteristicValueUpdated];
}

#pragma mark -- View Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self registerForNotifications];
	
    [self.table registerNib:[UINib nibWithNibName:@"TIBLETextFieldCell" bundle:nil] forCellReuseIdentifier:@"TIBLETextFieldCellUnsigned"];
    [self.table registerNib:[UINib nibWithNibName:@"TIBLETextFieldCell" bundle:nil] forCellReuseIdentifier:@"TIBLETextFieldCellFloat"];
    [self.table registerNib:[UINib nibWithNibName:@"TIBLETextFieldCellLarge" bundle:nil] forCellReuseIdentifier:@"TIBLETextFieldCellLarge"];
    [self.table registerNib:[UINib nibWithNibName:@"TIBLEColorCell" bundle:nil] forCellReuseIdentifier:@"TIBLEColorCell"];
    [self.table registerNib:[UINib nibWithNibName:@"TIBLESwitchCell" bundle:nil] forCellReuseIdentifier:@"TIBLESwitchCell"];
}

- (void)viewDidUnload {
	
    [self setTable:nil];
	[self unregisterForNotifications];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    
	[self.selectedTextField resignFirstResponder];
    
    [self sendNotificationCharacteristicValueUpdated];
}

- (void) dealloc {
    self.table.delegate = nil;
    self.table.dataSource = nil;
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 14;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < 4) {
		
        TIBLETextFieldCellLarge *cell = [tableView dequeueReusableCellWithIdentifier:@"TIBLETextFieldCellLarge"];
		cell.valueTextField.keyboardType = UIKeyboardTypeAlphabet;
        NSString * valueStr = TIBLE_SENSOR_NOT_INITIALIZED_STRING;
		
        if (indexPath.row == 0) {
            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.Title.Label", @"graph title");
			valueStr = self.settingsManager.setting.graph_title;
        }
        else if (indexPath.row == 1) {
            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.SubTitle.Label", @"graph sub title");
            valueStr = self.settingsManager.setting.graph_subTitle;
        }
        else if (indexPath.row == 2) {
            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.X_Axis.Caption.Label", @"x axis caption");
            valueStr = [NSString stringWithFormat:@"%@", self.settingsManager.setting.graph_x_axis_caption];
        }
        else if (indexPath.row == 3) {
            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.Y_Axis.Caption.Label", @"y axis caption");
            valueStr = [NSString stringWithFormat:@"%@", self.settingsManager.setting.graph_y_axis_caption];
        }
        
		if(valueStr == TIBLE_SENSOR_NOT_INITIALIZED_STRING){
			
			cell.valueTextField.placeholder = NSLocalizedString(@"Settings.Input.NotAvailable.String", nil);
			cell.valueTextField.text = nil;
		}
		else{
			cell.valueTextField.placeholder = nil;
			cell.valueTextField.text = [NSString stringWithFormat:@"%@", valueStr];
		}
		
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
        return cell;
    }
    
    else if (indexPath.row < 8) {
        
        TIBLETextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TIBLETextFieldCellUnsigned"];
		
		cell.valueTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.isUnsignedIntegerValue = YES;
		
		uint32_t uintValue = 0;
		
        if (indexPath.row == 4) {
            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.Y_Axis.Display.Minimum", @"y axis display min");
			uintValue = self.settingsManager.setting.graph_y_axis_display_min;
        }
        else if (indexPath.row == 5) {
            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.Y_Axis.Display.Maximum", @"y axis display max");
			uintValue = self.settingsManager.setting.graph_y_axis_display_max;
        }
        else if (indexPath.row == 6) {
            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.Value.Top_Mid.Band", @"value top mid boundary");
            uintValue = self.settingsManager.setting.graph_color_top_mid_boundary;
        }
        else if (indexPath.row == 7) {
            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.Value.Mid_Low.Band", @"value mid low boundary");
			uintValue = self.settingsManager.setting.graph_color_mid_low_boundary;;
        }
		
		if(uintValue == TIBLE_SENSOR_NOT_INITIALIZED_VALUE){
			cell.valueTextField.placeholder = NSLocalizedString(@"Settings.Input.NotAvailable.Number", nil);
			cell.valueTextField.text = nil;
		}
		else{
			cell.valueTextField.placeholder = nil;
			cell.valueTextField.text = [NSString stringWithFormat:@"%u", uintValue];
		}
        
		return cell;
    }
	else if (indexPath.row < 9){

		TIBLETextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TIBLETextFieldCellFloat"];
		
		cell.valueTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.isFloatValue = YES;
		
		float_t floatValue = 0;
		
		if (indexPath.row == 8) {

            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.Sensor.Calibration.Value", @"sensor calibration");
			
			floatValue = self.settingsManager.setting.calibrationValue;
        }
        
		if(floatValue == TIBLE_SENSOR_NOT_INITIALIZED_VALUE){

			cell.valueTextField.placeholder = NSLocalizedString(@"Settings.Input.NotAvailable.Number", nil);
			cell.valueTextField.text = nil;
		}
		else if(floatValue == TIBLE_SENSOR_DO_NOT_CALIBRATE_VALUE){
		
			cell.valueTextField.placeholder = NSLocalizedString(@"Settings.Input.DoNotCalibrate.String", nil);
			cell.valueTextField.text = nil;
		}
		else{
			
			cell.valueTextField.placeholder = nil;
			cell.valueTextField.text = [NSString stringWithFormat:@"%.2f", floatValue];
		}
		
        return cell;
	}
    else if (indexPath.row < 12) {
		
        TIBLEColorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TIBLEColorCell"];

        if (indexPath.row == 9) {
            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.Color.Top.Band", @"color top in graph settings");
            cell.colorButton.backgroundColor = self.settingsManager.setting.graph_color_top_value;
        }
        else if (indexPath.row == 10) {
            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.Color.Middle.Band", @"color middle in graph settings");
            cell.colorButton.backgroundColor = self.settingsManager.setting.graph_color_mid_value;
        }
        else if (indexPath.row == 11) {
            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.Color.Lower.Band", @"color lower in graph settings");
            cell.colorButton.backgroundColor = self.settingsManager.setting.graph_color_low_value;
        }
        
        [cell.colorButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cell.colorButton.layer.borderColor = [UIColor blackColor].CGColor;
        cell.colorButton.layer.borderWidth = 0.5f;
        cell.colorButton.layer.cornerRadius = 10.0f;
        
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return  cell;
    }
    else {
        TIBLESwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TIBLESwitchCell"];
        
        if (indexPath.row == 12) {
            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.Show.Current.Value", @"show current value label in graph settings");
            cell.cellSwitch.on = self.settingsManager.setting.graph_display_current_value;
        }
        else if (indexPath.row == 13) {
            cell.textTitleLabel.text = NSLocalizedString(@"Settings.Graph.Enable.Logarithmic.Scale", @"show log scale in graph settings");
            cell.cellSwitch.on = self.settingsManager.setting.graph_log_scale_enabled;
        }

        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

#pragma mark - uitable delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell.frame.size.height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < 9) { // if row has a text field
        
        TIBLETextFieldCell *cell = (TIBLETextFieldCell *)[tableView cellForRowAtIndexPath: indexPath];
        
        [cell makeTextFieldFirstResponder];
    }
}

#pragma mark -- notifications

- (void) characteristicValueUpdated: (NSNotification *) notification{
    
    if (notification.object != self) {
        [self.table reloadData];
    }
}

- (void) sendNotificationCharacteristicValueUpdated{
	
	[TIBLELogger info:@"TIBLEGraphDisplaySettingsViewController - Sending Notification: NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED\n"];
	
	NSNotification * updateUINotif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED
																   object:self
																 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:updateUINotif];
}

- (void) registerForNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
	
	//In this case, the log can be disabled from the graph if the max, min become negative
	//and log was enabled.
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(characteristicValueUpdated:)
												 name:TIBLE_NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED
                                               object:nil];
}

- (void) unregisterForNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
