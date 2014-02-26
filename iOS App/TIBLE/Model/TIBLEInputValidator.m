/*
 *  TIBLEInputValidation.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEInputValidator.h"
#import "TIBLESettingsManager.h"

@interface TIBLEInputValidator ()

@property (nonatomic, weak) TIBLESensorModel * sensorModel;
@property (nonatomic, weak) TIBLESensorProfile * sensorProfile;

@property (nonatomic, assign) float_t recommendedMax;
@property (nonatomic, assign) float_t recommendedMin;
@property (nonatomic, assign) float_t recommendedTopMid;
@property (nonatomic, assign) float_t recommendedMidLow;

@end

@implementation TIBLEInputValidator

- (id) initWithSensorModel: (TIBLESensorModel *) model andProfile: (TIBLESensorProfile *) profile{
	
	self = [super init];
	
	if(self != nil){
		
		self.sensorModel = model;
		self.sensorProfile = profile;
		
		self.recommendedMax = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
		self.recommendedMin = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
		self.recommendedTopMid = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
		self.recommendedMidLow = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
		
		[self calculateRecommendedBoundaryValues];
	}
	
	return self;
}

//make sure boundaries comply rules min < mid_low < mid_top < top.
- (void) calculateRecommendedBoundaryValues{

	if(self.sensorModel == nil || self.sensorProfile  == nil){
		
		return;
	}
	
	int16_t y_axis_adc_value_mid_low_boundary = self.sensorProfile.graph_color_mid_low_boundary;
	int16_t y_axis_adc_value_top_mid_boundary = self.sensorProfile.graph_color_top_mid_boundary;
	int16_t y_axis_adc_value_max = self.sensorProfile.graph_y_axis_display_max;
	int16_t y_axis_adc_value_min = self.sensorProfile.graph_y_axis_display_min;

	if((y_axis_adc_value_mid_low_boundary == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (y_axis_adc_value_top_mid_boundary == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (y_axis_adc_value_max == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (y_axis_adc_value_min == TIBLE_SENSOR_NOT_INITIALIZED_VALUE)){
		
		return;
	}
	
	float y_axis_pval_mid_low_boundary = [self.sensorModel value:y_axis_adc_value_mid_low_boundary];
	float y_axis_pval_top_mid_boundary = [self.sensorModel value:y_axis_adc_value_top_mid_boundary];
	float y_axis_pval_max = [self.sensorModel value:y_axis_adc_value_max];
	float y_axis_pval_min = [self.sensorModel value:y_axis_adc_value_min];
	
	BOOL valid = (y_axis_pval_min <= y_axis_pval_mid_low_boundary) &&
	(y_axis_pval_mid_low_boundary <= y_axis_pval_top_mid_boundary) &&
	(y_axis_pval_top_mid_boundary <= y_axis_pval_max) &&
	(y_axis_pval_min < y_axis_pval_max);
	
	if(valid == NO)
	{
		[TIBLELogger warn:@"TIBLEInputValidation - Boundaries don't meet rules, making them comply."];
		
		//1. check if max is less than min.
		if(y_axis_pval_max < y_axis_pval_min){
			
			//flip them if necessary.
			float_t tmpValue = y_axis_pval_min;
			y_axis_pval_min = y_axis_pval_max;
			y_axis_pval_max = tmpValue;
		}
		
		//2. make sure max > min by at least 1.
		if(y_axis_pval_max == y_axis_pval_min){
			
			//make max at least 1+
			y_axis_pval_max = y_axis_pval_max + 1;
			y_axis_pval_min = y_axis_pval_min - 1;
		}
		
		//3. make sure top-mid boundary is greater than mid-low boundary.
		if(y_axis_pval_top_mid_boundary < y_axis_pval_mid_low_boundary){
			
			//flip them if necessary.
			float_t tmpValue = y_axis_pval_mid_low_boundary;
			y_axis_pval_mid_low_boundary = y_axis_pval_top_mid_boundary;
			y_axis_pval_top_mid_boundary = tmpValue;
		}
		
		
		//4. make sure band boudaries are within range.
		if(y_axis_pval_mid_low_boundary < y_axis_pval_min){
			
			y_axis_pval_mid_low_boundary = y_axis_pval_min;
		}
		
		if(y_axis_pval_top_mid_boundary > y_axis_pval_max){
			
			y_axis_pval_top_mid_boundary = y_axis_pval_max;
		}
		
		//if equal draw the boundaries somewhere in between.
		if(y_axis_pval_mid_low_boundary == y_axis_pval_top_mid_boundary){
			
			float_t difference = abs(y_axis_pval_max - y_axis_pval_min);
			
			y_axis_pval_top_mid_boundary = y_axis_pval_max - difference/TIBLE_SENSOR_NUMBER_OF_BANDS;
			y_axis_pval_mid_low_boundary = y_axis_pval_min + difference/TIBLE_SENSOR_NUMBER_OF_BANDS;
		}
	}
	
	self.recommendedMax = y_axis_pval_max;
	self.recommendedMin = y_axis_pval_min;
	self.recommendedMidLow = y_axis_pval_mid_low_boundary;
	self.recommendedTopMid = y_axis_pval_top_mid_boundary;
}

- (NSDictionary *) recommendedBoundaryValues {
	
	if(self.recommendedMax == TIBLE_SENSOR_NOT_INITIALIZED_VALUE ||
	   self.recommendedMin == TIBLE_SENSOR_NOT_INITIALIZED_VALUE ||
	   self.recommendedMidLow == TIBLE_SENSOR_NOT_INITIALIZED_VALUE ||
	   self.recommendedTopMid == TIBLE_SENSOR_NOT_INITIALIZED_VALUE){
		
		return nil;
	}
	
	NSMutableDictionary * values = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithFloat:self.recommendedMax], kSensorInputValidationBoundaryMax,
									[NSNumber numberWithFloat:self.recommendedMin], kSensorInputValidationBoundaryMin,
									[NSNumber numberWithFloat:self.recommendedMidLow], kSensorInputValidationBoundaryMidLow,
									[NSNumber numberWithFloat:self.recommendedTopMid], kSensorInputValidationBoundaryTopMid,
									nil];
	
	return values;
}

//make sure sampe is within range.
- (NSDictionary *) validateSampleValueWithinBoundaries: (float_t) adc_val{
	
	if(self.sensorModel == nil || self.sensorProfile  == nil){
		
		return nil;
	}
	
	//get valid values
	float_t y_axis_pval_max = self.recommendedMax;
	float_t y_axis_pval_min = self.recommendedMin;
	float_t y_axis_pval_sample = [self.sensorModel value:adc_val];
	
	//clip pval value if necessary
	if(y_axis_pval_sample < y_axis_pval_min){
		y_axis_pval_sample = y_axis_pval_min;
	}
	
	if(y_axis_pval_sample > y_axis_pval_max){
		y_axis_pval_sample = y_axis_pval_max;
	}
	
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithFloat:y_axis_pval_sample], kSensorInputValidationBoundarySampleValue,
										nil];
	
	return dictionary;
}

- (BOOL) shouldLogScaleBeEnabled{
	
	BOOL retVal = NO;
	
	if(self.sensorModel == nil || self.sensorProfile  == nil){
		
		return retVal;
	}
		
	if(self.sensorModel.sensorProfile.graph_log_scale_enabled != GRAPH_DISPLAY_CURRENT_VALUE_YES){
		
		return retVal;
	}
	
	//get valid boundaries and values.
	float_t y_axis_pval_min = self.recommendedMin;

	if(y_axis_pval_min < TIBLE_GRAPH_DISPLAY_LOG_SCALE_MIN){
	
		return retVal;
	}

	retVal = YES;
	
	return retVal;
}

@end
