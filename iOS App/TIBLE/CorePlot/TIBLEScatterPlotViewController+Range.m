/*
 *  TIBLEScatterPlotViewController+Range.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEScatterPlotViewController+Range.h"


@implementation TIBLEScatterPlotViewController (Range)

#pragma mark - Range Checking for Annotations

- (CPTPlotRange *) rangeForXAxis{
	
	CPTGraph *graph = self.hostView.hostedGraph;
	
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	
	return plotSpace.xRange;
}

- (CPTPlotRange *) rangeForYAxis{
	
	CPTGraph *graph = self.hostView.hostedGraph;
	
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	
	return plotSpace.yRange;
}

-(BOOL) isSampleWithinCurrentPlotRanges: (TIBLESampleModel *) sample{
	
	float xValue = [sample time_sec_total];
	float yValue = [sample val];
	
	CPTPlotRange * xRange = [self rangeForXAxis];
	CPTPlotRange * yRange = [self rangeForYAxis];
	
	BOOL retVal = NO;
	
	if(([xRange contains:CPTDecimalFromFloat(xValue)]) &&
	   ([yRange contains:CPTDecimalFromFloat(yValue)])){
		retVal = YES;
	}
	
	return retVal;
}


@end
