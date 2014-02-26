/*
 *  TIBLEScatterPlotViewController+RealTimeRefresh.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEScatterPlotViewController.h"
#import "TIBLEDevicesManager.h"
#import "TIBLESettingsManager.h"
#import "TIBLEPlotConstants.h"

@interface TIBLEScatterPlotViewController (RealTimeRefresh)

- (void) refreshPlot;
- (void) refreshPlotForSampleAdded;

//ranges
- (void) refreshYAxisRange;
- (void) refreshXAxisRange;

//labels
- (void) refreshYAxesLabels: (NSArray *) values; //@[min, max, cal]
- (void) refreshAxisCaptions;

//bands
- (void) refreshBands;
- (CPTLimitBand *) addBandToYAxis:(CPDBandType) band
							color:(CPTColor *) colorForband
					 offsetBottom: (float) offsetBottom
						offsetTop: (float) offsetTop;

//annotation
- (void) refreshDisplayCurrentValue;

//scale
- (void) setYAxisScale:(BOOL) logEnabled;
- (void) refreshYAxisLogScale;
- (BOOL) readIfLogScaleIsEnabledCharValue;

@end
