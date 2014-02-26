/*
 *  TIBLEScatterPlotViewController+RealTimeRefresh.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEScatterPlotViewController+RealTimeRefresh.h"
#import "TIBLEScatterPlotViewController+Utils.h"
#import "TIBLEScatterPlotViewController+DataSource.h"
#import "TIBLEScatterPlotViewController+Range.h"
#import "TIBLEScatterPlotViewController+Annotation.h"
#import "TIBLEUIConstants.h"
#import "TIBLEPlotConstants.h"
#import "TIBLEInputValidator.h"

@implementation TIBLEScatterPlotViewController (RealTimeRefresh)

#pragma mark - Main Refresh Method

- (void) refreshPlot{
	
	TIBLESensorModel * connectedSensor = [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
	
	BOOL allCharsRead = [connectedSensor.sensorProfile areAllCharacteristicsRead];
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Refresh called (%p)\n", self];
	
	if(connectedSensor != nil && allCharsRead){
		
		[self refreshPlotForSampleAdded];
		
		//axis scale
		[self refreshYAxisLogScale];
		
		//axis ranges
		[self refreshYAxisRange];
		
		//axis labels
		[self refreshAxisCaptions];
		
		//bands
		[self refreshBands];
	}
	else{
		[TIBLELogger info:@"\t Could not refresh (either connected sensor is nil or all characteristics have not been read.\n"];
	}
}

- (void) refreshPlotForSampleAdded{
	
	//x-axis
	[self refreshXAxisRange];
	
	//annotations
	[self refreshDisplayCurrentValue];
	[self refreshAnnotations];
}

#pragma mark - Refreshing Annotations

- (void) refreshAnnotations{
		
	//when paused, let the user handle the annotations.
	
	if(self.isPaused == NO &&
	   self.displayCurrentValue == YES){
		
		//remove previous annotations
		[self hideAnnotation];
		
		TIBLESampleModel * lastSample = [self.plotData lastObject];
		int index = [self.plotData count] - 1;
		
		if(lastSample != nil && index >= 0){

			//show last sample annotation if within range.
			if([self isSampleWithinCurrentPlotRanges:lastSample]){
				
				[self showAnnotationAtIndex:index];
			}
		}
	}
}

#pragma mark - Refreshing Ranges

- (void) refreshXAxisRange{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Adjusting Plot X Range called (%p)\n", self];
	
	TIBLESampleModel * sampleAdded = [self.plotData lastObject];
	
	CPTGraph *graph = self.hostView.hostedGraph;
	
	//before reload data, make sure plot range shows latest values and fits samples
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;

	float latestXVal = [sampleAdded time_sec_total];
	float location = latestXVal - kMaxTimeSamples;
	
	CPTMutablePlotRange * xRange = [plotSpace.xRange mutableCopy];
	
	if(location >= 0){
		xRange.location = CPTDecimalFromFloat(location);
	}
	else{
		xRange.location = CPTDecimalFromFloat(0.0f);
	}
	
	uint32_t length = kMaxTimeSamples;
	float extra_space_percent_for_annotation = length * EXTRA_SPACE_PERCENT_X_AXIS_FOR_ANNOTATION;
	xRange.length = CPTDecimalFromFloat(length + extra_space_percent_for_annotation);

	//set the x-range.
	if(self.isPaused == NO){
		plotSpace.xRange = xRange;
	}
	else{
		//when paused user is managing the visible range.
	}

	//Bug 68
	//set the x-global range. the user can not get outside this range when panning or zooming.
	CPTMutablePlotRange * globalXRange = [xRange mutableCopy];
	
	globalXRange.location = CPTDecimalFromFloat(0.0f);
	globalXRange.length = CPTDecimalFromFloat(location + xRange.lengthDouble);
	plotSpace.globalXRange = globalXRange;
}

- (void) sendNotificationCharacteristicValueUpdated{
	
	[TIBLELogger info:@"TIBLEFormulaSettingsViewController - Sending Notification: NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED.\n"];
	
	NSNotification * updateUINotif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED
																   object:self
																 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:updateUINotif];
}

- (void) exitYAxisLogScale{
	
	TIBLESensorModel * connectedSensor = [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
	connectedSensor.sensorProfile.graph_log_scale_enabled = NO;
	
	[self refreshYAxisLogScale];
	
	//send notification for UI. break the cycle by performing this call later.
	//since we may be here due to the user chaning the value of the log switch.
	[self performSelector:@selector(sendNotificationCharacteristicValueUpdated) withObject:self afterDelay:0.0f]; //as soon as possible, still queues in run loop.
	
	//alert user
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Settings.Alert.CanNotEnableLogScale.Title", nil)
													 message:NSLocalizedString(@"Settings.Alert.CanNotEnableLogScale", nil)
													delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
	[alert show];
}

- (void) refreshYAxisRange{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Refresh Y Axis called (%p)\n", self];
	
	TIBLESensorModel * connectedSensor = [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
	TIBLESensorProfile * sensorProfile = [[TIBLESettingsManager sharedTIBLESettingsManager] setting];
	
	int16_t y_axis_adc_value_max = sensorProfile.graph_y_axis_display_max;
	int16_t y_axis_adc_value_min = sensorProfile.graph_y_axis_display_min;
	
	float y_axis_pval_max = [connectedSensor value:y_axis_adc_value_max];
	float y_axis_pval_min = [connectedSensor value:y_axis_adc_value_min];
	float y_axis_pcal = connectedSensor.sensorProfile.calibrationValue;

	CPTGraph *graph = self.hostView.hostedGraph;
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];

	[TIBLELogger detail:@"\t max: %.3f min: %.3f cal: %.3f\n", y_axis_pval_max, y_axis_pval_min, y_axis_pcal];
	
	//1. check if not initialized
	if(y_axis_pval_max == TIBLE_SENSOR_NOT_INITIALIZED_VALUE ||
	   y_axis_pval_min == TIBLE_SENSOR_NOT_INITIALIZED_VALUE ||
	   y_axis_pcal == TIBLE_SENSOR_NOT_INITIALIZED_VALUE){
		
		[TIBLELogger error:@"\t Error: Could not refresh Y axis since values are not initialized."];
		return;
	}
		
	//2. Get valid boundaries.
	TIBLEInputValidator * inputValidator = [[TIBLEInputValidator alloc] initWithSensorModel:connectedSensor andProfile:sensorProfile];
	NSDictionary * pBoundaries = [inputValidator recommendedBoundaryValues];
	
	if(pBoundaries == nil){
		
		[TIBLELogger error:@"\t Error: Could not refresh Y axis since values are not initialized."];
		return;
	}
	
	y_axis_pval_max = [[pBoundaries objectForKey:kSensorInputValidationBoundaryMax] floatValue];
	y_axis_pval_min = [[pBoundaries objectForKey:kSensorInputValidationBoundaryMin] floatValue];
		
	//3. check if should dislay log scale on y-axis.
	if([inputValidator shouldLogScaleBeEnabled] == NO &&
	   self.displayLogarithmicScale == YES){

		[TIBLELogger warn:@"\t Warning: Exiting Log Scale since it should not be enabled. Min boundary too large or negative."];
		
		[self exitYAxisLogScale];
		
		return;
	}
	
	//4. Set global and y-axis range.
	if(self.displayLogarithmicScale){

		//add extra padding to min and max for display purposes.
		float_t logMax = log10f(y_axis_pval_max);
		float_t logMin = log10f(y_axis_pval_min);
		float_t logDelta = (logMax - logMin) * EXTRA_SPACE_PERCENT_Y_AXIS_FOR_ANNOTATION;
		float_t newMin = pow(10, logMin - logDelta/2.0f);
		float_t newMax = pow(10, logMax + logDelta/2.0f);
		
		yRange.location = CPTDecimalFromFloat(newMin);
		yRange.length = CPTDecimalFromFloat(newMax - newMin);
		
		plotSpace.yRange = yRange;
		
		CPTMutablePlotRange * yGlobalRange = [yRange mutableCopy];
		plotSpace.globalYRange = yGlobalRange;
	}
	else{
		
		float_t delta = (y_axis_pval_max - y_axis_pval_min) * EXTRA_SPACE_PERCENT_Y_AXIS_FOR_ANNOTATION;
		float_t newMin = y_axis_pval_min - delta/2.0f;
		float_t newMax = y_axis_pval_max + delta/2.0f;
		
		yRange.location = CPTDecimalFromFloat(newMin);
		yRange.length = CPTDecimalFromFloat(newMax - newMin);
		
		plotSpace.yRange = yRange;
		
		CPTMutablePlotRange * yGlobalRange = [yRange mutableCopy];
		plotSpace.globalYRange = yGlobalRange;
	}
	
	//5. Set the y-axis labels.
	NSNumber * min = [NSNumber numberWithFloat:y_axis_pval_min];
	NSNumber * max = [NSNumber numberWithFloat:y_axis_pval_max];
	NSNumber * cal = [NSNumber numberWithFloat:y_axis_pcal];
	NSArray * labels = @[min, max, cal];
	
	[self refreshYAxesLabels:labels];
}

#pragma mark - Refreshing Labels

-(void) refreshYAxesLabels: (NSArray *) values{

	NSNumber * min = [values objectAtIndex:0];
	NSNumber * max = [values objectAtIndex:1];
	NSNumber * cal = [values objectAtIndex:2];
	
	float displayMin = [min floatValue];
	float displayMax = [max floatValue];
	float displayCalibration = [cal floatValue];
	    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    CPTXYAxis *y = axisSet.yAxis;
    
	//create locations of y-axis labels. Use with CPTAxisLabelingPolicyLocationsProvided.
	//formatting comes from y-axis formatter.
	float_t maxAbs = abs([max floatValue]); //could be 1.
	float_t minAbs = abs([min floatValue]); //could be -10,000. more digits.
	float_t biggerNumber = maxAbs > minAbs ? maxAbs : minAbs;
	y.labelFormatter = [self getLabelFormatter:biggerNumber];
	
	NSMutableSet *majorTickLocations = [NSMutableSet setWithObjects:
										[NSDecimalNumber numberWithFloat:displayMax],
										[NSDecimalNumber numberWithFloat:displayMin],
										nil];
	
	if(displayCalibration != TIBLE_SENSOR_DO_NOT_CALIBRATE_VALUE){
		
		[majorTickLocations addObject:[NSDecimalNumber numberWithFloat:displayCalibration]];
	}
	
	y.majorTickLocations = majorTickLocations;
}

//set x and y axis captions
- (void) refreshAxisCaptions{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Refresh Axis Captions called (%p)\n", self];
	
	TIBLESensorProfile * sensorProfile = [[TIBLESettingsManager sharedTIBLESettingsManager] setting];
    
	NSString * xAxisCaption = sensorProfile.graph_x_axis_caption;
	NSString * yAxisCaption = sensorProfile.graph_y_axis_caption;
	
	if(xAxisCaption != nil && yAxisCaption != nil){
		
		CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
		CPTAxis *x = axisSet.xAxis;
		x.title = xAxisCaption;
		CPTAxis *y = axisSet.yAxis;
		y.title = yAxisCaption;
	}
}

#pragma mark - Refreshing Bands

- (CPTLimitBand *) addBandToYAxis:(CPDBandType) band
							color:(CPTColor *) colorForband
					 offsetBottom: (float) offsetBottom
						offsetTop: (float) offsetTop{
    
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Adding BAND to Y Axis ...\n"];
	[TIBLELogger detail:@"\t Color: %@\n", [colorForband description]];
	[TIBLELogger detail:@"\t From: %.3f\n", offsetBottom];
	[TIBLELogger detail:@"\t To: %.3f\n", offsetTop];
	
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    CPTAxis *y = axisSet.yAxis;
    
    CPTPlotRange * range = [[CPTPlotRange alloc] initWithLocation:CPTDecimalFromFloat(offsetBottom) length:CPTDecimalFromFloat(offsetTop - offsetBottom)];
    
	//do not use gradient because two bands can have the same color.
	
	CPTFill * colorFill = [CPTFill fillWithColor:colorForband];
    
	CPTLimitBand * limitBand = [CPTLimitBand limitBandWithRange:range fill:colorFill];
    
    [y addBackgroundLimitBand:limitBand];
	
	return limitBand;
}

- (void) refreshBands{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Refresh Band Colors called (%p)\n", self];
	
	//1. Get sensor model and profile.
	TIBLESensorModel * sensorModel = [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
    TIBLESensorProfile * sensorProfile = [[TIBLESettingsManager sharedTIBLESettingsManager] setting];
	
	//2. Get band colors.
	UIColor * colorBottom = sensorProfile.graph_color_low_value;
	UIColor * colorMiddle = sensorProfile.graph_color_mid_value;
	UIColor * colorTop = sensorProfile.graph_color_top_value;
	
	if(colorBottom == nil || colorMiddle == nil || colorTop == nil){
		
		[TIBLELogger warn:@"TIBLEScatterPlotViewController - Can't Refresh Band Colors, not initialized yet. (%p)\n", self];
		return;
	}
	
	//3. Get input validator.
	TIBLEInputValidator * inputValidator = [[TIBLEInputValidator alloc] initWithSensorModel:sensorModel andProfile:sensorProfile];
	NSDictionary * pBoundaries = [inputValidator recommendedBoundaryValues];
	
	if(pBoundaries == nil){
	
		[TIBLELogger warn:@"TIBLEScatterPlotViewController - Can't Refresh Band Colors, boundaries not initialized yet. (%p)\n", self];
		return;
	}
	
	float_t y_axis_pval_max = [[pBoundaries objectForKey:kSensorInputValidationBoundaryMax] floatValue];
	float_t y_axis_pval_min = [[pBoundaries objectForKey:kSensorInputValidationBoundaryMin] floatValue];
	float_t y_axis_pval_top_mid_boundary = [[pBoundaries objectForKey:kSensorInputValidationBoundaryTopMid] floatValue];
	float_t y_axis_pval_mid_low_boundary = [[pBoundaries objectForKey:kSensorInputValidationBoundaryMidLow] floatValue];
	
	//4. Calculate band offsets.
	float_t offsetBottomBand_Min = y_axis_pval_min;
	float_t offsetBottomBand_Max = y_axis_pval_mid_low_boundary;

	float_t offsetMidBand_Min = y_axis_pval_mid_low_boundary;
	float_t offsetMidBand_Max = y_axis_pval_top_mid_boundary;
	
	float_t offsetTopBand_Min = y_axis_pval_top_mid_boundary;
	float_t offsetTopBand_Max = y_axis_pval_max;
	
	
	//4. Remove previoius bands.
	[self removeBands];
	
	//5. Create new bands.
	CPTLimitBand * bottomBand = [self addBandToYAxis:BAND_LOW
											   color:[self colorForUIColor:colorBottom]
										offsetBottom:offsetBottomBand_Min
										   offsetTop:offsetBottomBand_Max];
	
	
	
	CPTLimitBand * middleBand = [self addBandToYAxis:BAND_MID
											   color:[self colorForUIColor:colorMiddle]
										offsetBottom:offsetMidBand_Min
										   offsetTop:offsetMidBand_Max];
	

	
	CPTLimitBand * topBand = [self addBandToYAxis:BAND_TOP
											color:[self colorForUIColor:colorTop]
									 offsetBottom:offsetTopBand_Min
										offsetTop:offsetTopBand_Max];
	
	//6. Add bands.
	[self.limitBandsArray addObject:bottomBand];
	[self.limitBandsArray addObject:middleBand];
	[self.limitBandsArray addObject:topBand];
}

//remove previous bands
- (void) removeBands{

	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
	CPTAxis *y = axisSet.yAxis;
	
	for(CPTLimitBand * band in self.limitBandsArray){
		
		[y removeBackgroundLimitBand:band];
	}
	
	[self.limitBandsArray removeAllObjects];
}

#pragma mark - Refreshing Annotation

- (void) refreshDisplayCurrentValue{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Refresh Display Current Value called (%p)\n", self];
	
	TIBLESensorModel * connectedSensor = [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
	TIBLESensorProfile * sensorProfile = connectedSensor.sensorProfile;
	
	TIBLE_Graph_Display_Current_Value displayCurrentValue = sensorProfile.graph_display_current_value;
	
	if(displayCurrentValue == GRAPH_DISPLAY_CURRENT_VALUE_YES){
		self.displayCurrentValue = YES;
	}
	else{ //NO
		self.displayCurrentValue = NO;
	}
}

#pragma mark - Refreshing Log Scale

- (void) setYAxisScale:(BOOL) logEnabled{
	
	CPTGraph *graph = self.hostView.hostedGraph;
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	
	if(logEnabled){
		plotSpace.yScaleType = CPTScaleTypeLog;
		plotSpace.xScaleType = CPTScaleTypeLinear;
		[plotSpace setScaleType:CPTScaleTypeLog forCoordinate:CPTCoordinateY];
	}
	else{
		plotSpace.yScaleType = CPTScaleTypeLinear;
		plotSpace.xScaleType = CPTScaleTypeLinear;
		[plotSpace setScaleType:CPTScaleTypeLinear forCoordinate:CPTCoordinateY];
	}
}

- (BOOL) readIfLogScaleIsEnabledCharValue{
	
	BOOL logScaleEnabledValue = NO;
	
	TIBLESensorModel * connectedSensor = [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
	if(connectedSensor != nil){
		TIBLESensorProfile * sensorProfile = connectedSensor.sensorProfile;
		
		TIBLE_Graph_Display_Using_Logarithmic_Scale logScaleEnabled = sensorProfile.graph_log_scale_enabled;
		logScaleEnabledValue = (logScaleEnabled == GRAPH_DISPLAY_USING_LOGARITHMIC_SCALE_YES)?YES:NO;
	}
	
#if GRAPH_SIMULATE_LOGARITHMIC_SCALE_ENABLED
	logScaleEnabledValue = YES;
#endif
	
	return logScaleEnabledValue;
}

- (void) refreshYAxisLogScale{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Refresh Display Logarithmic Scale called (%p)\n", self];
	
	BOOL value = [self readIfLogScaleIsEnabledCharValue];
	
	[self setYAxisScale:value];
	
	BOOL changeInLogScale = (value != self.displayLogarithmicScale);
	
	if(changeInLogScale){
		
		//if internal value does not match, then set and reload data.
		self.displayLogarithmicScale = value;
		
		[self removeSamplesAndReload];
	}
}

@end
