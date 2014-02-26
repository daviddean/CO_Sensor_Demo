/*
 *  TIBLEProgressViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEProgressViewController.h"
#import "UIColor+LightAndDark.h"
#import "TIBLEProgressView.h"
#import "TIBLEUIConstants.h"
#import "TIBLESensorModel.h"
#import "TIBLEDevicesManager.h"
#import "UIColor+LightAndDark.h"
#import "TIBLESettingsManager.h"
#import "math.h"
#import "TIBLEUtilities.h"
#import "TIBLEInputValidator.h"

#define kPercentValueMinimum 0.0f
#define kPercentValueMaximum 1.0f

@interface TIBLEProgressViewController ()

@property (weak, nonatomic) IBOutlet UIView *minValueView;
@property (weak, nonatomic) IBOutlet UIView *maxValueView;
@property (weak, nonatomic) IBOutlet UIView *currentValueView;

@property (weak, nonatomic) IBOutlet UILabel *minShortCaptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxShortCaptionLabel;

@property (weak, nonatomic) IBOutlet TIBLEProgressView * trackProgressView;

@property (weak, nonatomic) IBOutlet UILabel * currentValueLabel;
@property (weak, nonatomic) IBOutlet UILabel * maxValueLabel;
@property (weak, nonatomic) IBOutlet UILabel * minValueLabel;

@property (nonatomic, retain) UIColor * progressColor;
@end

@implementation TIBLEProgressViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        //nothing so far.
    }
    
    return self;
	
}

- (TIBLESensorModel * ) sensor{
	
	return [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
}


- (void) refreshUI: (NSNotification *) notif{
	
	//if there is a sensor connected and at least one sample, then refresh.
	
	if(self.isViewLoaded == NO){
			
		[TIBLELogger detail:@"TIBLEProgressViewController - Not updating views since view is not loaded."];
		return;
	}
		
	if(self.sensor != nil && self.sensor.latestSample != nil){
		
		//3. Get valid pval value for latest sample and boundaries.
		TIBLESensorProfile * sensorProfile = [[TIBLESettingsManager sharedTIBLESettingsManager] setting];
		
		TIBLEInputValidator * inputValidator = [[TIBLEInputValidator alloc] initWithSensorModel:self.sensor
																					 andProfile:sensorProfile];
		
		NSDictionary * pBoundaries = [inputValidator recommendedBoundaryValues];
		
		if(pBoundaries == nil){
			
			[TIBLELogger info:@"TIBLEProgressViewController - Not refreshing since NOT INITIALIZED"];
			[self setProgressBarUIToNotInitialized];
			return;
		}
		
		float_t y_axis_pval_max = [[pBoundaries objectForKey:kSensorInputValidationBoundaryMax] floatValue];
		float_t y_axis_pval_min = [[pBoundaries objectForKey:kSensorInputValidationBoundaryMin] floatValue];
		
		NSDictionary * pValue = [inputValidator validateSampleValueWithinBoundaries:self.sensor.latestSample.adc_val];
		
		if(pValue == nil){
		
			[TIBLELogger info:@"TIBLEProgressViewController - Not refreshing since NOT INITIALIZED"];
			[self setProgressBarUIToNotInitialized];
			return;
		}
		
		float_t y_axis_pval_current_value = [[pValue objectForKey:kSensorInputValidationBoundarySampleValue] floatValue];

		
		float_t percentage = [self calculatePercentageValue:y_axis_pval_current_value
														Min:y_axis_pval_min
														Max:y_axis_pval_max];
			
			
		[self updateProgressBarSampleDisplayValue:y_axis_pval_current_value
								  PercentageValue:percentage
								  MinDisplayValue:y_axis_pval_min
								  MaxDisplayValue:y_axis_pval_max];
	}
	else{
		
		//do nothing, should be displaying No Available Sensor VC.
		[self setProgressBarUIToNotInitialized];
		return;
	}
}

- (void) setProgressBarUIToNotInitialized{
	
	self.minValueView.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
	self.maxValueView.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
	self.currentValueView.alpha = TIBLE_UI_COMPONENT_INVISIBLE_ALPHA;
	self.trackProgressView.normalizedValue = kPercentValueMinimum;
	[self.view setNeedsDisplay];
}

- (void) setProgressBarUIComponentsToVisible{
	
	self.minValueView.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
	self.maxValueView.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
	self.currentValueView.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
	[self.view setNeedsDisplay];
}

- (float_t) calculatePercentageValue: (float_t) samplePVal Min:(float_t) minPValue Max: (float_t) maxPValue{
	
	float percentValue = kPercentValueMinimum;
	
	//3. Get valid pval value for latest sample and boundaries.
	TIBLESensorProfile * sensorProfile = [[TIBLESettingsManager sharedTIBLESettingsManager] setting];
	
	TIBLEInputValidator * inputValidator = [[TIBLEInputValidator alloc] initWithSensorModel:self.sensor
																				 andProfile:sensorProfile];
	
	//if have negative values, don't want to calculate logarithmic. log(0) = nan (infinity).
	if([inputValidator shouldLogScaleBeEnabled] == YES){

		//On a semi-log graph the spacing of the scale on the y-axis (or x-axis) is proportional to
		//the logarithm of the number, not the number itself. It is equivalent to converting the
		//y values (or x values) to their log, and plotting the data on lin-lin scales.
		float currentValueLogValue = log10f(samplePVal);
		float maxDisplayRangeValueLogValue = log10f(maxPValue);
		float minDisplayRangeValueLogValue = log10f(minPValue);
		
		percentValue = ((currentValueLogValue - minDisplayRangeValueLogValue) / (maxDisplayRangeValueLogValue - minDisplayRangeValueLogValue));
	}
	else{
		
		//calculate percentage to draw i.e., (20-10) out of (30-10), is 0.5 or 50% to draw.
		percentValue = ((samplePVal - minPValue) / (maxPValue - minPValue));
	}
	
	return percentValue;
}

- (void) updateProgressBarSampleDisplayValue:(float_t) y_axis_pval_current_value
						  PercentageValue:(float_t) percentage
						  MinDisplayValue:(float_t) y_axis_pval_min
						  MaxDisplayValue:(float_t) y_axis_pval_max{

	//make sure components are visible.
	[self setProgressBarUIComponentsToVisible];
	
	//set current value label.
	NSString * strValue = [TIBLEUtilities formattedStringForValue:y_axis_pval_current_value];
	self.currentValueLabel.text = strValue;

	//set percetage for coloring bar.
	self.trackProgressView.normalizedValue = percentage;

	//color and move current percentage label
	[self.currentValueLabel setTextColor:[[self.sensor colorForLatestSample] lessSaturated]];
	[self moveCurrentValueLabel];

	//set color for progress.
	self.trackProgressView.progressColor = [self.sensor colorForLatestSample];
	[self.trackProgressView colorProgress];
	
	//set text for min, max labels
	NSString * strMaxValue = [TIBLEUtilities formattedStringForValue:y_axis_pval_max];
	NSString * strMinValue = [TIBLEUtilities formattedStringForValue:y_axis_pval_min];
	
	self.maxValueLabel.text = strMaxValue;
	self.minValueLabel.text = strMinValue;

	//set text for short caption labels.
	self.maxShortCaptionLabel.text = self.sensor.sensorProfile.shortCaption;
	self.minShortCaptionLabel.text =self.sensor.sensorProfile.shortCaption;	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self registerForNotifications];
	
	[self refreshUI:nil];
}


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
}

- (void) unregisterForNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) moveCurrentValueLabel{
    
	CGPoint point = [self.trackProgressView currentValuePointInView];
	
	//since they are aligned no need to convert.
	//CGPoint point2 = [self.currentValueView convertPoint:point fromView:self.view];
	CGPoint finalPoint = point;
	
	//make new position
	float offset = self.currentValueLabel.frame.size.height / 2.0f;
	CGRect frame = CGRectMake(finalPoint.x, finalPoint.y - offset,
							  self.currentValueLabel.bounds.size.width,
							  self.currentValueLabel.bounds.size.height);
	
	//set new position
	[self.currentValueLabel setFrame:frame];
	
}

- (void)viewDidUnload {
	
	[self unregisterForNotifications];
	
	self.progressColor = nil;
	self.maxValueLabel = nil;
	self.minValueLabel = nil;
	self.currentValueLabel = nil;
	self.trackProgressView = nil;

    [super viewDidUnload];
}

@end
