/*
 *  TIBLEFormulaSettingsViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEFormulaSettingsViewController.h"
#import "TIBLESettingsManager.h"
#import "TIBLETextFieldCell.h"
#import "TIBLEHeaderView.h"
#import "TIBLEUIConstants.h"
#import "TIBLEDevicesManager.h"
#import "TIBLESensorProfile.h"
#import "TIBLESensorConstants.h"

@interface TIBLEFormulaSettingsViewController () <UITableViewDataSource, UITableViewDelegate, TIBLETextFieldCellDelegate> {
    
    CGRect tableRect; /*!< Used to shift the view when a editable cell is being covered by the keyboard. */
    
    int index; /*!< Keeps track of the index of the last edited cell. */
}
@property (strong, nonatomic) TIBLESettingsManager *settingsManager; 
@property (strong, nonatomic) UITextField *selectedTextField; /*!< Reference to the currently selected text field */
@property (weak, nonatomic) IBOutlet UITableView *table; /*!< Displays all editable formula values */

@end

@implementation TIBLEFormulaSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        self.title = NSLocalizedString(@"Settings.FormulaSettings.title", nil);
        
        self.settingsManager = [TIBLESettingsManager sharedTIBLESettingsManager];
        self.selectedTextField = [[UITextField alloc] init];
    }
    return self;
}

#pragma mark -- TIBLETextFieldDelegate

- (void)textFieldUpdatedWithCell:(TIBLETextFieldCell *)cell {
    
    int indexValue = [[self.table indexPathForRowAtPoint:cell.center] row];
    
    if (indexValue == 0)
        self.settingsManager.setting.formula_sub_x_0 = [cell.valueTextField.text floatValue];
    else if (indexValue == 1)
        self.settingsManager.setting.formula_denom_0 = [cell.valueTextField.text floatValue];
    else if (indexValue == 2)
        self.settingsManager.setting.formula_num_0 = [cell.valueTextField.text floatValue];
    else if (indexValue == 3)
        self.settingsManager.setting.formula_denom_1 = [cell.valueTextField.text floatValue];
    else if (indexValue == 4){
		
		float_t value = [cell.valueTextField.text floatValue];
        self.settingsManager.setting.formula_scaling_factor_num = value;
		
		if(value == TIBLE_SENSOR_DO_NOT_SCALE_VALUE){
			cell.valueTextField.placeholder = NSLocalizedString(@"Settings.Input.DoNotScale.String", nil);
			cell.valueTextField.text = nil;
		}
	}
    else if (indexValue == 5){
		
		float_t value = [cell.valueTextField.text floatValue];
        self.settingsManager.setting.formula_scaling_factor_denom = value;

		if(value == TIBLE_SENSOR_DO_NOT_SCALE_VALUE){
			cell.valueTextField.placeholder = NSLocalizedString(@"Settings.Input.DoNotScale.String", nil);
			cell.valueTextField.text = nil;
		}
	}
	
	[self sendNotificationCharacteristicValueUpdated];
}

- (void)textFieldDidEndEditingWithCell:(TIBLETextFieldCell *)cell {
	
	self.selectedTextField = cell.valueTextField;
	
	[self.selectedTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditingWithCell:(TIBLETextFieldCell *)cell {

	self.selectedTextField = cell.valueTextField;
}

- (void)textFieldSelectedWithCell:(TIBLETextFieldCell *)cell {
    
    self.selectedTextField = cell.valueTextField;
    index = [[self.table indexPathForRowAtPoint:cell.center] row];
    
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -- Keyboard Notifications

- (void) keyboardWillShow: (NSNotification *) notification {
    
    if (!(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        // if we are using an iphone or an ipad in landscape
        
        NSDictionary* info = [notification userInfo];
        CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
        CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat screenSize = [[UIScreen mainScreen] bounds].size.height;
        NSTimeInterval animationTime = [self keyboardAnimationDurationForNotification:notification];
        
        tableRect = self.table.frame;
        CGRect t = tableRect;
        CGFloat yOrigin = self.table.frame.origin.y;
        
        [UIView beginAnimations:@"ResizeAnimation" context:NULL];
        [UIView setAnimationDuration:animationTime];
        
        // set the frame origin at the beginning of the table
        self.view.frame = CGRectMake(0, -1 * yOrigin,
                                         self.view.bounds.size.width, self.view.bounds.size.height);
        
        [UIView commitAnimations];
        
        //change the table frame size to the size of the view
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            t.size.height = self.view.frame.size.height;
        }
        else {
            t.size.height = screenSize - kbHeight- statusBarHeight - navigationBarHeight;
        }
        
        self.table.frame = t;
    }
}

- (void) keyboardDidShow: (NSNotification *) notification {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
        [UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait)
    {
            [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void) keyboardWillHide: (NSNotification *) notification{
    
    if (!(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        NSTimeInterval animationTime = [self keyboardAnimationDurationForNotification:notification];
        
        [UIView beginAnimations:@"ResizeAnimation" context:NULL];
        [UIView setAnimationDuration:animationTime];
        
        //shift the view frame back to (0,0) and change the table frame back
        self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        
        [UIView commitAnimations];
        
        self.table.frame = tableRect;
    }
}

- (void) characteristicValueUpdated: (NSNotification *) notification{
    
    if (notification.object != self) {
        [self.table reloadData];
    }
}

#pragma mark -- View Methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];

	[self registerForNotifications];
	
    [self.headerSensorFormula setTitleString :NSLocalizedString(@"Settings.Formula.DisplayFormula.Header", nil)];
    
    [self.table registerNib:[UINib nibWithNibName:@"TIBLETextFieldCell" bundle:nil] forCellReuseIdentifier:@"TIBLETextFieldCell"];
	
	[self.stretchableBackgroundFormulaSettingsImageView setImageForName:@"gradient_bg_stretch.png" withLeftCapWidth:25 andTopCapHeight:25];
}

- (void)viewDidUnload {
    [self setTable:nil];
    [self setHeaderSensorFormula:nil];
    [self setStretchableBackgroundFormulaSettingsImageView:nil];
	[self unregisterForNotifications];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
                                    
    TIBLETextFieldCell *cell = (TIBLETextFieldCell *)[self.table cellForRowAtIndexPath:
                                                      [NSIndexPath indexPathForRow:index inSection:0]];
    [cell.valueTextField resignFirstResponder];
}

- (void) dealloc {
    
    self.table.delegate = nil;
    self.table.dataSource = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TIBLETextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TIBLETextFieldCell"];
	
	cell.isFloatValue = YES;
	cell.delegate = self;
    cell.valueTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	float_t value = 0;
	
    if(indexPath.row == 0) {
        cell.textTitleLabel.text = NSLocalizedString(@"Settings.Formula.X0", nil);
		value = self.settingsManager.setting.formula_sub_x_0;
    }
    else if(indexPath.row == 1) {
        cell.textTitleLabel.text = NSLocalizedString(@"Settings.Formula.D0", nil);
		value = self.settingsManager.setting.formula_denom_0;

        cell.isNonZeroValue = YES;
    }
    else if(indexPath.row == 2) {
        cell.textTitleLabel.text = NSLocalizedString(@"Settings.Formula.N0", nil);
		value = self.settingsManager.setting.formula_num_0;
    }
    else if(indexPath.row == 3) {
        cell.textTitleLabel.text = NSLocalizedString(@"Settings.Formula.D1", nil);
		value = self.settingsManager.setting.formula_denom_1;

        cell.isNonZeroValue = YES;
    }
    else if(indexPath.row == 4) {
        cell.textTitleLabel.text = NSLocalizedString(@"Settings.Formula.ScaleFactor.Num", nil);
		value = self.settingsManager.setting.formula_scaling_factor_num;
    }
    else if(indexPath.row == 5) {
        cell.textTitleLabel.text = NSLocalizedString(@"Settings.Formula.ScaleFactor.Denom", nil);
		value = self.settingsManager.setting.formula_scaling_factor_denom;
    }
    
	if(value == TIBLE_SENSOR_NOT_INITIALIZED_VALUE){

		cell.valueTextField.placeholder = NSLocalizedString(@"Settings.Input.NotAvailable.Number", nil);
		cell.valueTextField.text = nil;
	}
	else if((indexPath.row == 5 || indexPath.row == 4) &&
			value == TIBLE_SENSOR_DO_NOT_SCALE_VALUE){
		
		cell.valueTextField.placeholder = NSLocalizedString(@"Settings.Input.DoNotScale.String", nil);
		cell.valueTextField.text = nil;
	}
	else{
		cell.valueTextField.text = [NSString stringWithFormat:@"%.2f",  value];
		cell.valueTextField.placeholder = nil;
	}
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
    TIBLETextFieldCell *cell = (TIBLETextFieldCell *)[tableView cellForRowAtIndexPath: indexPath];
    
    [cell makeTextFieldFirstResponder];
    
}

#pragma mark -- notifications

- (void) sendNotificationCharacteristicValueUpdated{
	
	[TIBLELogger info:@"TIBLEFormulaSettingsViewController - Sending Notification: NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED.\n"];
	
	NSNotification * updateUINotif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED
																   object:self
																 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:updateUINotif];
}

- (void) registerForNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackGroundNotification:)
                                                 name:kAppEnteredBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
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

- (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification*)notification {
    
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue:&duration];
    
    return duration;
}

- (void)didEnterBackGroundNotification:(NSNotification*)notification {
    [self.view endEditing:YES];
}

@end
