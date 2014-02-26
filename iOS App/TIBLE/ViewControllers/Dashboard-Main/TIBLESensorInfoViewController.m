/*
 *  TIBLESensorInfoViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLESensorInfoViewController.h"
#import "TIBLEDiscovery.h"
#import "TIBLECheckmark.h"
#import "TIBLEUIConstants.h"
#import "TIBLEDevicesManager.h"
#import "TIBLEStretchableImageView.h"
#import "TIBLEFeatures.h"
#import "UIColor+LightAndDark.h"
#import "TIBLESensorConstants.h"

@interface TIBLESensorInfoViewController () <UITableViewDataSource, UITableViewDelegate>

//live labels
@property (weak, nonatomic) IBOutlet UILabel *infoSensorName;
@property (weak, nonatomic) IBOutlet UILabel *infoSensorAddress;
@property (weak, nonatomic) IBOutlet UILabel *infoSensorTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoValueDeltaTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoValueTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoValueTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoValueVoutLabel;

//calibrate
@property (weak, nonatomic) IBOutlet UIButton *calibrateButton;
@property (weak, nonatomic) IBOutlet TIBLECheckmark *calibrateStatusView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *calibrationProgressIndicator;

//cells
@property (strong, nonatomic) IBOutlet UITableViewCell *typeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *sensorNameOrAddress;
@property (strong, nonatomic) IBOutlet UITableViewCell *deltaTimeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *tempCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *vOutCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *timeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *calibrateCell;

//tables and footer view
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UITableView *table2; //for ipad landscape, nil o/w.
@property (strong, nonatomic) IBOutlet UITextView *footerView;

//stretchable images
@property (strong, nonatomic) IBOutlet TIBLEStretchableImageView *stretchableBackground;
@property (weak, nonatomic) IBOutlet TIBLEStretchableImageView *stretchableSensorStatusBackgroundImageView;
@property (weak, nonatomic) IBOutlet TIBLEStretchableImageView *stretchableSensorStatusBackgroundPortraitImageView;

//for progress bar and constantly changing labels.
@property (nonatomic, strong) UIColor * activeColor;

@property (nonatomic, assign) BOOL isCalibrating;

@end

@implementation TIBLESensorInfoViewController

- (NSString*) nibNameRotated:(UIInterfaceOrientation)orientation
{
    if( UIInterfaceOrientationIsLandscape(orientation))
		return [NSString stringWithFormat:@"%@-landscape", NSStringFromClass([self class])];
	
    return [NSString stringWithFormat:@"%@", NSStringFromClass([self class])];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if(nibNameOrNil == nil)
		nibNameOrNil = [self nibNameRotated:[[UIApplication sharedApplication] statusBarOrientation]];
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        
        self.title = NSLocalizedString(@"Dashboard.title", nil);
        UITabBarItem *tabBar = [self tabBarItem];
        [tabBar setTitle:NSLocalizedString(@"Dashboard.title", nil)];
        [tabBar setImage:[UIImage imageNamed:@"tab_bar_percentage_icon"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//show not calibrated and not calibrating
    BOOL isCalibrated = [self.sensor isCalibrated];
	[self.calibrateStatusView setChecked:isCalibrated];
	

    if ([self.sensor isCalibrating]) {
        [self.calibrationProgressIndicator startAnimating]; //make sure it is hidden.
        self.isCalibrating = YES;
        self.calibrateStatusView.hidden = YES;
        
        [self.calibrateButton setTitle: NSLocalizedString(@"SensorInfo.Calibrating.button", @"Re-Calibrate button") forState:UIControlStateNormal];
    }
    else { // not calibrating
        [self.calibrationProgressIndicator stopAnimating];
        self.isCalibrating = NO;
        
        if (isCalibrated) {
            [self.calibrateButton setTitle: NSLocalizedString(@"SensorInfo.ReCalibrate.button", @"Re-Calibrate button") forState:UIControlStateNormal];
        }
        else { // not calibrated
            [self.calibrateButton setTitle: NSLocalizedString(@"SensorInfo.Calibrate.button", @"Re-Calibrate button") forState:UIControlStateNormal];
        }
    }
	
	[self registerForNotifications];
	
	[self refreshUI:nil];
	
	[self.stretchableBackground setImageForName:@"gradient_bg_stretch.png"
							   withLeftCapWidth:25 andTopCapHeight:25];
    
    //ipad landscape mode sensor info background
    [self.stretchableSensorStatusBackgroundImageView setImageForName:@"background_sensor_info_landscape.png"
														   andInsets:UIEdgeInsetsMake(55, 235, 25, 25)];
    //ipad portrait mode sensor info background
    [self.stretchableSensorStatusBackgroundPortraitImageView setImageForName:@"background_sensor_info_portrait.png"
																   andInsets:UIEdgeInsetsMake(55, 235, 25, 25)];

    self.footerView.text = NSLocalizedString(@"SensorInfo.TextView", nil);
}

#pragma mark - notifications

- (void) registerForNotifications{
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshUI:)
												 name:TIBLE_NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshUI:)
												 name:TIBLE_NOTIFICATION_UPDATE_MEASUREMENT_SAMPLE_RECEIVED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshUI:)
												 name:TIBLE_NOTIFICATION_UPDATE_CONNECTED_SENSOR_CHANGED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(calibrationStarted:)
												 name:TIBLE_NOTIFICATION_BLE_CALIBRATION_STARTED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(calibrationEnded:)
												 name:TIBLE_NOTIFICATION_BLE_CALIBRATION_ENDED
											   object:nil];
}

- (void) unregisterForNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (TIBLESensorModel * ) sensor{
	
	return [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
}

#pragma mark - Calibration Action

- (IBAction)calibrateButtonTapped:(id)sender {
	
	if(self.sensor != nil){
		
		[self.sensor calibrate];
	}
}

#pragma mark - Calibration Notifications

- (void) calibrationStarted: (NSNotification *) notif{
	
	if([self.sensor isCalibrating] == YES){
	
		[TIBLELogger info:@"TIBLESensorInfoViewController - Calibration Started callback called.\n"];
		
		self.isCalibrating = YES;
		
		//show progress
		[self.calibrationProgressIndicator startAnimating];
		
		//hide checkmark or cross
		self.calibrateStatusView.hidden = YES;
		 
		//make button disable and update the text
		[self.calibrateButton setTitle: NSLocalizedString(@"SensorInfo.Calibrating.button", nil) forState: UIControlStateNormal];
		self.calibrateButton.enabled = NO;

		
		[self.calibrateButton setNeedsDisplay];
		[self.view setNeedsDisplay];
		
		//if it doesn't stop calibrating after few seconds for whatever reason give up.
		[self performSelector:@selector(calibrationEnded:) withObject:nil afterDelay:TIBLE_SENSOR_CALIBRATION_TIMEOUT];
	}
}

- (void) calibrationEnded: (NSNotification *) notif{
	
	if([self.sensor isCalibrating] == NO){
	
		[TIBLELogger info:@"TIBLESensorInfoViewController - Calibration Ended callback called.\n"];
		
		self.isCalibrating = NO;
		
		//hide progress
		[self.calibrationProgressIndicator stopAnimating];
		
		//show checkmark or cross
		self.calibrateStatusView.hidden = NO;
		
		//make button enabled
		self.calibrateButton.enabled = YES;
		
		//set to calibrated after first successfull calibration
		//in case of error, isCalibrated should be NO.
		[self setCalibrationStatus:[self.sensor isCalibrated]];
	}
}

- (void) setCalibrationStatus: (BOOL) value{
	
	if(value == YES){
		[self.calibrateStatusView setChecked:YES];
		[self.calibrateButton setTitle: NSLocalizedString(@"SensorInfo.ReCalibrate.button", nil) forState: UIControlStateNormal];
		
	}
	else{ //NO
		[self.calibrateStatusView setChecked:NO];
		[self.calibrateButton setTitle: NSLocalizedString(@"SensorInfo.Calibrate.button", nil) forState: UIControlStateNormal];
	}
	
	//[self.calibrateButton setNeedsLayout];
	[self.calibrateButton setNeedsDisplay];
	[self.view setNeedsDisplay];
}

- (void) refreshUI: (NSNotification *) notif{
		
	if(self.isViewLoaded == NO){
		
		[TIBLELogger detail:@"TIBLEProgressViewController - Not updating views since view is not loaded."];
		return;
	}
	
	if(self.sensor != nil){
		
		TIBLESampleModel * sample = self.sensor.sensorSamples.latestSample;
		
		self.activeColor = self.sensor.colorForLatestSample;

		self.infoSensorName.text = [self.sensor.peripheral nameStr];
		
		self.infoSensorAddress.text = [self.sensor.peripheral uuidStr];

		[self.infoSensorTypeLabel setText:[self.sensor.sensorProfile sensorTypeDescription]];
		
		[self.infoValueDeltaTimeLabel setTextColor:self.activeColor];
		
		NSString * microSecondsUnitsStr = NSLocalizedString(@"SensorInfo.Units.MicroSeconds.Short", nil);
		NSString * secondsUnitsStr = NSLocalizedString(@"SensorInfo.Units.Seconds.Short", nil);
		NSString * degreesCelciusUnitsStr = NSLocalizedString(@"SensorInfo.Units.Degrees.Celcius.Short", nil);
		NSString * voltsUnitsStr = NSLocalizedString(@"SensorInfo.Units.Volts.Short", nil);
		
		[self.infoValueDeltaTimeLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%d %@", nil),
											   self.sensor.sensorSamples.deltaTime,
											   microSecondsUnitsStr]];
		
		[self.infoValueTimeLabel setTextColor:self.activeColor];
		[self.infoValueTimeLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%.2f %@", nil),
										  sample.time_sec_total,
										  secondsUnitsStr]];
		
		[self.infoValueTempLabel setTextColor:self.activeColor];
		[self.infoValueTempLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%.2f %@", nil),
										  sample.temp,
										  degreesCelciusUnitsStr]];
		
		[self.infoValueVoutLabel setTextColor:self.activeColor];
		[self.infoValueVoutLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%.2f %@", nil),
										  sample.vout,
										  voltsUnitsStr]];
	}
	
	[self.view setNeedsDisplay];
	
	[self.table reloadData];
	[self.table2 reloadData];
    
    [self resizeTable2];
    [self resizeTextView];
}

#pragma mark - table datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	int rows = 0;
	
	//ipad landscape
	if(self.table2 != nil){
		
		if(tableView == self.table){
			rows = 4;
		}
		else{ //table2
			
			if(TIBLE_FEATURE_ENABLE_CALIBRATION_DISPLAY && self.isCalibrationAvailable){
				rows = 3;
			}
			else{
				rows = 2;
			}
		}
	}
	else{ //iphone and ipad portrait
		
		if(TIBLE_FEATURE_ENABLE_CALIBRATION_DISPLAY && self.isCalibrationAvailable){
			rows = 7;
		}
		else{
			rows = 6;
		}
	}
	
	return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

	CGFloat footerHeight = 0.0f;
	
	if(self.isTable2Available){
		
		footerHeight = 0.0f;
	}
	else{ //for table if table2 does not exist.
		footerHeight = self.footerView.bounds.size.height;
	}
	
	return footerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

	UIView * footerView = nil;
	
	if(self.isTable2Available){
		
		footerView = nil;
	}
	else{ //for table if table2 does not exist.
		footerView = self.footerView;
	}
	
	return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell * cell = [self cellForTable:tableView forRowAtIndexPath:indexPath];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell * cell = [self cellForTable:tableView forRowAtIndexPath:indexPath];
	
	return cell.bounds.size.height;
}

- (BOOL) isTable2Available{

	BOOL retVal = NO;
	
	if(self.table2 != nil){
		
		retVal = YES;
	}
	
	return retVal;
}

- (BOOL) isCalibrationAvailable{

	BOOL retVal = NO;
	
	if((self.sensor != nil) &&
	   [self.sensor.sensorProfile doesSensorCalibrate]){
		
		retVal = YES;
	}
	
	return retVal;
}

- (UITableViewCell *) cellForTable:(UITableView *) tableView forRowAtIndexPath:(NSIndexPath *) indexPath{
	
	UITableViewCell * cell = nil;
	
	//ipad landscape
	if(self.isTable2Available){
		
		if(tableView == self.table){
			
			if(indexPath.row == 0){
				cell = self.sensorNameOrAddress;
			}
			else if(indexPath.row == 1){
				cell = self.typeCell;
			}
			else if(indexPath.row == 2){
				cell = self.deltaTimeCell;
			}
			else if(indexPath.row == 3){
				cell = self.timeCell;
			}
		}
		else{ //table2
			
			if(indexPath.row == 0){
				cell = self.tempCell;
			}
			else if(indexPath.row == 1){
				cell = self.vOutCell;
			}
			else if(indexPath.row == 2){
				cell = self.calibrateCell;
			}
		}
	}
	else{ //iphone and ipad portrait
		
		if(indexPath.row == 0){
			cell = self.sensorNameOrAddress;
		}
		else if(indexPath.row == 1){
			cell = self.typeCell;
		}
		else if(indexPath.row == 2){
			cell = self.deltaTimeCell;
		}
		else if(indexPath.row == 3){
			cell = self.timeCell;
		}
		else if(indexPath.row == 4){
			cell = self.tempCell;
		}
		else if(indexPath.row == 5){
			cell = self.vOutCell;
		}
		else if(indexPath.row == 6){
			cell = self.calibrateCell;
		}
	}
	
	return cell;
}

/*
 * This will hide the extra column when the iPad
 * is in landscape mode and there is no calibration button
*/

- (void)resizeTable2 {
    
    if (self.table2 != nil) {
        
        CGRect table2Rect = self.table2.frame;
        table2Rect.size.height = self.table.frame.size.height;
        
        if (TIBLE_FEATURE_ENABLE_CALIBRATION_DISPLAY && !self.isCalibrationAvailable) {
            
            // hide the 3rd row if we have no calibrate button
            table2Rect.size.height = 133.0f;
        }

        self.table2.frame = table2Rect;
    }
}

/*
 * This will fix the text view overlap
 * on 3.5" devices when there is a calibrate button
 */

- (void)resizeTextView {
    
    CGFloat deviceHeight = [UIScreen mainScreen].bounds.size.height;
    if (deviceHeight < 568.0f && [self.table numberOfRowsInSection:0] == 7) {
        // if we have a 3.5" device and the calibrate button is showing
        // we need to resize the footer so it doesn't overlap
        
        CGRect footerRect = self.footerView.frame;
        footerRect.size.height = 75.0f;
        
        self.footerView.frame = footerRect;
    }
}

- (void)viewDidUnload {
	
	[self unregisterForNotifications];

    [self setInfoSensorTypeLabel:nil];
    [self setInfoValueDeltaTimeLabel:nil];
    [self setInfoValueTimeLabel:nil];
    [self setInfoValueTempLabel:nil];
    [self setInfoValueVoutLabel:nil];
    [self setCalibrateStatusView:nil];
	[self setCalibrateButton:nil];
	[self setTable:nil];
	[self setTypeCell:nil];
	[self setDeltaTimeCell:nil];
	[self setTempCell:nil];
	[self setVOutCell:nil];
	[self setTimeCell:nil];
	[self setCalibrateCell:nil];
	[self setSensorNameOrAddress:nil];
	[self setStretchableBackground:nil];
	[self setInfoSensorName:nil];
	[self setInfoSensorAddress:nil];
	[self setTable2:nil];
    [super viewDidUnload];
}
@end
