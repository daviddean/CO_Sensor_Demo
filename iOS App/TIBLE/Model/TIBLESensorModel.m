/*
 *  TIBLESensorModel.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLESensorModel.h"
#import "TIBLECharacteristicsSingleton.h"
#import "TIBLESensorConstants.h"
#import "TIBLESensorProfile.h"
#import "TIBLEUIConstants.h"
#import "TIBLEUtilities.h"
#import "TIBLESensorMath.h"
#import "math.h"
#import "TIBLESavedSensor.h"
#import "TIBLESettingsManager.h"
#import "UIColor+LightAndDark.h"
#import "TIBLEInputValidator.h"

/* each sensor model belongs to a peripheral. */
 
@interface TIBLESensorModel ()


@property (nonatomic, assign) BOOL calibrating;
@property (nonatomic, strong) NSMutableArray * calibrationSamplesArray;

@end

@implementation TIBLESensorModel

- (id)copyWithZone:(NSZone *)zone{

	TIBLESensorModel * dataModel = [[self class] allocWithZone:zone];
	
	if(dataModel != nil){

		dataModel.peripheral = self.peripheral;
		dataModel.isCalibrated = self.isCalibrated;
		dataModel.sensorProfile = [self.sensorProfile copy];
		dataModel.sensorSamples = [self.sensorSamples copy];
		dataModel.adc_cal = self.adc_cal;
		dataModel.calibrating = self.calibrating;
		dataModel.calibrationSamplesArray = [self.calibrationSamplesArray copy];
	}
	
	return dataModel;
}

- (void) dealloc{
	
	self.peripheral = nil;
	self.sensorProfile = nil;
	[self.sensorSamples.queueArray removeAllObjects];
	self.sensorSamples = nil;
	[self.calibrationSamplesArray removeAllObjects];
	self.calibrationSamplesArray = nil;
}

- (id) initWithPeripheral: (TIBLEPeripheral *) ti_peripheral{
    
    self = [super init];
    
    if(self != nil){
        
		self.peripheral = ti_peripheral;
		
		self.sensorProfile = [[TIBLESensorProfile alloc] init];
		
		self.calibrating = NO;
		self.isCalibrated = NO;
		self.adc_cal = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
		
		self.sensorSamples = [[TIBLESampleQueue alloc] initWithModel:self];
		self.calibrationSamplesArray = [[NSMutableArray alloc] initWithCapacity:TIBLE_SENSOR_CALIBRATION_SAMPLES_AMOUNT];
    }
    
    return self;
}

- (void) updateSensorData:(NSString *) characteristic value:(TIBLERawDataModel *) valueModel{
    	
	NSDictionary * dictionary = [[TIBLECharacteristicsSingleton sharedTIBLECharacteristicsSingleton] dictionaryUUIDStrings];
	
	NSString * selectorKeyName = [dictionary objectForKey:[characteristic uppercaseString]];
    
    //other characteristics handled in Sensor Data Model
    NSString * selector = [NSString stringWithFormat:@"set%@:", selectorKeyName];
    SEL selectorMethod = NSSelectorFromString(selector);
    
    if([self.sensorProfile respondsToSelector:selectorMethod]){
		
		//this ARC leak is harmeless, so we suppress it.
		SuppressPerformSelectorLeakWarning(
			[self.sensorProfile performSelector:selectorMethod withObject:valueModel]
		);
		
		
		[self sendNotificationCharacteristicValueUpdated];
    }
	else if([self.sensorSamples respondsToSelector:selectorMethod]){
		
		//this ARC leak is harmeless, so we suppress it.
		SuppressPerformSelectorLeakWarning(
			[self.sensorSamples performSelector:selectorMethod withObject:valueModel];
		);
		
		[self sendNotificationMeasurementSampleReceived];
	}
}

#pragma mark - Calibration

- (void) calibrate{
	
	[TIBLELogger info:@"TIBLESensorModel - Calibrate called.\n"];
	
	if(self.latestSample == nil){
		
		[TIBLELogger info:@"TIBLESensorModel - Can't calibrate since there are no samples.\n"];
		return;
	}
	
	if(self.calibrating == NO){

		self.calibrating = YES;
	}
}

- (void) calibrateIfNeeded{

	if(self.calibrating == YES){
		
		[self performingCalibration];
	}
}

- (void) performingCalibration{
	
	[TIBLELogger info:@"TIBLESensorModel - Calibrating Helper called.\n"];
	
	//check if have enough samples
	if([self.calibrationSamplesArray count] < TIBLE_SENSOR_CALIBRATION_SAMPLES_AMOUNT){
	
		//if first sample being added,
		
		if([self.calibrationSamplesArray count] == 0){
			//then make sure to flag to UI that started calibrating
			[self sendNotificationCalibrationStarted];
		}
		
		//grab latest sample
		float_t adc_val_latest = self.latestSample.adc_val;
		
		//store it in array
		[TIBLELogger info:@"\t Adding value to calibration array: %f\n", adc_val_latest];
		
		[self.calibrationSamplesArray addObject:[NSNumber numberWithInt:adc_val_latest]];
	}
	else{
	
		//calculate average
		
		float average = 0.0f;
		float count = [self.calibrationSamplesArray count];
		
		for(NSNumber * tmpNumber in self.calibrationSamplesArray){
			
			float tmpFloat = [tmpNumber floatValue];
			average = average + tmpFloat;
		}
		
		average = average / count;
		
		//set var for future calculations
		[TIBLELogger info:@"\t Setting Calibration Value (adc_cal) to: %f\n", average];
		
		self.adc_cal = average;
		
		//empty array
		[self.calibrationSamplesArray removeAllObjects];
		
		//set var to not calibrating
		self.calibrating = NO;
		
		//set var to calibrated
		self.isCalibrated = YES;
		
		//send notification for UI to update that calibration is done
		[self sendNotificationCalibrationEnded];
	}
}

#pragma mark - Notifications

- (void) sendNotificationCalibrationStarted{

	[TIBLELogger info:@"TIBLESensorModel - Sending Notification NOTIFICATION_BLE_CALIBRATION_STARTED\n"];

	NSNotification * updateUINotif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_BLE_CALIBRATION_STARTED
																   object:nil
																 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:updateUINotif];

}

- (void) sendNotificationCalibrationEnded{
	
	[TIBLELogger info:@"TIBLESensorModel - Sending Notification NOTIFICATION_BLE_CALIBRATION_ENDED\n"];

	NSNotification * updateUINotif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_BLE_CALIBRATION_ENDED
																   object:nil
																 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:updateUINotif];

}

- (void) sendNotificationCharacteristicValueUpdated{
	
	[TIBLELogger detail:@"TIBLESensorModel - Sending Notification NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED\n"];
	
	NSNotification * updateUINotif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED
																   object:nil
																 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:updateUINotif];
}

- (void) sendNotificationMeasurementSampleReceived{
	
	[TIBLELogger detail:@"TIBLESensorModel - Sending Notification NOTIFICATION_UPDATE_MEASUREMENT_SAMPLE_RECEIVED\n"];
	
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithObject:self.sensorSamples.latestSample forKey:TIBLE_NOTIFICATION_UPDATE_MEASUREMENT_SAMPLE_RECEIVED_USER_INFO_KEY];
	NSNotification * updateUINotif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_UPDATE_MEASUREMENT_SAMPLE_RECEIVED
																   object:nil
																 userInfo:dictionary];
	
	[[NSNotificationCenter defaultCenter] postNotification:updateUINotif];
	
	[self calibrateIfNeeded];
}

#pragma mark - Helpers

- (TIBLESampleModel *) latestSample{
	
	TIBLESampleModel * latestSampleModel = self.sensorSamples.latestSample;
	
	return latestSampleModel;
	
}

- (UIColor *) colorForLatestSample{
	
    TIBLESensorProfile * sensorProfile = [[TIBLESettingsManager sharedTIBLESettingsManager] setting];
	TIBLESampleModel * latestSample = [self.sensorSamples latestSample];
	UIColor * colorForLatestSample = nil;
	
	if(latestSample == nil){
		return colorForLatestSample;
	}
	
	//1. Get valid boundaries
	TIBLEInputValidator * inputValidator = [[TIBLEInputValidator alloc] initWithSensorModel:self andProfile:sensorProfile];
	
	NSDictionary * pBoundaries = [inputValidator recommendedBoundaryValues];
	
	if(pBoundaries == nil){
		return colorForLatestSample;
	}
	
	float_t y_axis_pval_max = [[pBoundaries objectForKey:kSensorInputValidationBoundaryMax] floatValue];
	float_t y_axis_pval_min = [[pBoundaries objectForKey:kSensorInputValidationBoundaryMin] floatValue];
	float_t y_axis_pval_top_mid_boundary = [[pBoundaries objectForKey:kSensorInputValidationBoundaryTopMid] floatValue];
	float_t y_axis_pval_mid_low_boundary = [[pBoundaries objectForKey:kSensorInputValidationBoundaryMidLow] floatValue];
	
	//2. Get pval for current sample within boundaries.
	NSDictionary * pValue = [inputValidator validateSampleValueWithinBoundaries:latestSample.adc_val];
	
	if(pValue == nil){
		return colorForLatestSample;
	}
	
	float_t y_axis_pval_current_value = [[pValue objectForKey:kSensorInputValidationBoundarySampleValue] floatValue];
	
	//3. Based on pval, get color.
	if(y_axis_pval_current_value <= y_axis_pval_min){
		
		colorForLatestSample = sensorProfile.graph_color_low_value;
	}
	else if(y_axis_pval_current_value <= y_axis_pval_mid_low_boundary){
		
		colorForLatestSample = sensorProfile.graph_color_low_value;
	}
	else if(y_axis_pval_current_value <= y_axis_pval_top_mid_boundary){
		
		colorForLatestSample = sensorProfile.graph_color_mid_value;
	}
	else if(y_axis_pval_current_value <= y_axis_pval_max){

		colorForLatestSample = sensorProfile.graph_color_top_value;
	}
	else{ //> y_axis_pval_max
		
		colorForLatestSample = sensorProfile.graph_color_top_value;
	}
	
	//[TIBLELogger info:@"TIBLESensorModel - Returning color for latest sample: %@\n", [colorForLatestSample description]];
	return colorForLatestSample;
}

#pragma mark - Math Methods

- (float) voutValue: (float) adc_val{
	
	//check if coefficients set up
	if([self.sensorProfile isFormulaReady] == NO){
		return TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
	}
	
	if(self.adc_cal == TIBLE_SENSOR_NOT_INITIALIZED_VALUE){
		
		self.adc_cal = adc_val;
	}
	
	//get sensor math
    TIBLESensorProfile *s = [[TIBLESettingsManager sharedTIBLESettingsManager] setting];
	TIBLESensorMath * sensorMath = [[TIBLESensorMath alloc] initWithProfile:s
													 andCalibrationADCValue:self.adc_cal];
	
	
	//get vout
	float vout = [sensorMath vout:adc_val];
	
	return vout;
}

- (float) formulaValue: (float) adc_val{
	
	//check if coefficients set up
	if([self.sensorProfile isFormulaReady] == NO){
		
		return TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
	}
		
	if(self.adc_cal == TIBLE_SENSOR_NOT_INITIALIZED_VALUE){
		
		self.adc_cal = adc_val;
	}
	
	float clipped_adc_val = adc_val;
	float min = fminf(self.sensorProfile.graph_y_axis_display_max, self.sensorProfile.graph_y_axis_display_min);
	float max = fmaxf(self.sensorProfile.graph_y_axis_display_max, self.sensorProfile.graph_y_axis_display_min);
	
	if(adc_val > max){
		
		//[TIBLELogger info:@"Clipped ADC value: %f to max value: %f\n", adc_val, max];
		clipped_adc_val = max;
	}
	else if(adc_val < min){

		//[TIBLELogger info:@"Clipped ADC value: %f to min value: %f\n", adc_val, min];
		clipped_adc_val = min;
	}
	
	//get sensor math
    TIBLESensorProfile *s = [[TIBLESettingsManager sharedTIBLESettingsManager] setting];
	TIBLESensorMath * sensorMath = [[TIBLESensorMath alloc] initWithProfile:s
													 andCalibrationADCValue:self.adc_cal];
	
	//get fval
	float fval = [sensorMath fval:clipped_adc_val];
	
	return fval;
}

- (float) value: (float) adc_val{
	
	if(self.adc_cal == TIBLE_SENSOR_NOT_INITIALIZED_VALUE){
		
		self.adc_cal = adc_val;
	}
	
	//get fval
	float fval = [self formulaValue:adc_val];
	
	if(fval == TIBLE_SENSOR_NOT_INITIALIZED_VALUE){
		
		return TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
	}
	
	//get sensor math
    TIBLESensorProfile *s = [[TIBLESettingsManager sharedTIBLESettingsManager] setting];
	TIBLESensorMath * sensorMath = [[TIBLESensorMath alloc] initWithProfile:s
													 andCalibrationADCValue:self.adc_cal];

	//[TIBLELogger detail:@"TIBLESensorMath - Calculating value ...\n"
	//			 "\t adc_val: %.3f \n", adc_val];
	
	//get pval
	float pval = [sensorMath val:fval];
	
	return pval;
}

- (float) latestValue{
	
	float pval = [self value:self.sensorSamples.latestSample.adc_val];
	
	return pval;
}

/* Does not have to equal 100 %. */
- (float) maxValue{
	
	//For O2, adc_val = 700 => 24.48 %
	float pmax = [self value:self.sensorProfile.graph_y_axis_display_max];
	
	return pmax;
}

/* Does not have to equal 0 %. */
- (float) minValue{
	
	//For O2, adc_val = 1000 => 13.5 %
	float pmin = [self value:self.sensorProfile.graph_y_axis_display_min];
	
	return pmin;
}

- (BOOL)isCalibrating {
    return self.calibrating;
}

@end
