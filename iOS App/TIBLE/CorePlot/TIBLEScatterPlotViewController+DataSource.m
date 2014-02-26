/*
 *  TIBLEScatterPlotViewController+DataSource.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEScatterPlotViewController+DataSource.h"
#import "TIBLEScatterPlotViewController+RealTimeRefresh.h"
#import "TIBLEScatterPlotViewController+Annotation.h"
#import "TIBLEScatterPlotViewController+Range.h"
#import "TIBLEDevicesManager.h"
#import "TIBLEUIConstants.h"

@implementation TIBLEScatterPlotViewController (DataSource)

#pragma mark - Reload Data

- (void) setPaused:(BOOL) value{
	
	self.isPaused = value;
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Setting Plot PAUSE: %@", self.isPaused?@"YES":@"NO"];	
}

#pragma mark - Reload Data

- (void) reloadPlotData{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Reloading Data called (%p)\n", self];
	
	TIBLESensorModel * sensor = [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
	
	if(sensor != nil){
		
		if(self.hostView != nil){
			
			CPTGraph *graph = self.hostView.hostedGraph;
			
			//every time we reload, we don't want to be paused.
			[self setPaused:NO];
		
			self.plotData = [sensor.sensorSamples.queueArray mutableCopy];
			
			[self refreshPlot];
			
			[graph reloadData];
			
			[self.view setNeedsDisplay];
		}
	}
}

#pragma mark - Notification Callbacks

- (void) characteristicUpdated:(NSNotification *) notif{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Characteristics Updated Callback called (%p)\n", self];
	
	TIBLESensorModel * connectedSensor = [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
	
	if(connectedSensor != nil){
		
		BOOL allCharsRead = [connectedSensor.sensorProfile areAllCharacteristicsRead];
		BOOL viewLoaded = self.isViewLoaded;
		BOOL atLeastOneSample = ([self.plotData count] > 0)?YES:NO;
		
		//Delete previous data, ranges may be different.
		//Need at least one sample, otherwise core plot boundary errors.
		
		if(allCharsRead && viewLoaded && atLeastOneSample){
		
			[self removeSamplesAndReload];
		}
	}
}

- (void) sampleAdded:(NSNotification *) notif{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Sample Added Callback called (%p)\n", self];
	
	if(self.isViewLoaded){
		
		if(self.plotData.count == 0){
			
			//if first sample, refresh plot.
			[self refreshPlot];
		}
		
		//get index of sample added
		NSDictionary * dictionary = [notif userInfo];
		int index = -1;
		
		TIBLESampleModel * sampleadded = [dictionary objectForKey:TIBLE_NOTIFICATION_UPDATE_MEASUREMENT_SAMPLE_RECEIVED_USER_INFO_KEY];
		//uint32_t index = sampleadded.index;
		
		CPTGraph *graph = self.hostView.hostedGraph;
		CPTPlot * plot = [graph plotWithIdentifier:kPlotIdentifier];
		
		int numberOfSamples = [self.plotData count];
		
		//when numOfSamples == 600, new index is 600, we have reached max queue size
		//start removing first object
		if (numberOfSamples == TIBLE_MAX_SAMPLE_QUEUE_SIZE) {
			
			//delete the first data point in plot
			
			[TIBLELogger detail:@"\t Removing sample for plot at index: 0.\n"];
			//[TIBLELogger detail:@"\t\t Graph: %p Plot: %p\n", graph, plot];
			//[TIBLELogger detail:@"\t\t Sample Index: %d\n", sampleadded.index];
			
			[self.plotData removeObjectAtIndex:0]; //reduces count, shifts all objct indexes by -1.
			if (plot != nil)
				[plot deleteDataInIndexRange:NSMakeRange(0, 1)];
			
			index = self.plotData.count; //count is 499, and this is index to insert next item.
			
			[TIBLELogger detail:@"\t Adding sample for plot at index: %d\n", index];
			//[TIBLELogger detail:@"\t\t Graph: %p Plot: %p\n", graph, plot];
			//[TIBLELogger detail:@"\t\t Sample Index: %d\n", sampleadded.index];
			
			[self.plotData insertObject:sampleadded atIndex:index];
			
			if (plot != nil)
				[plot insertDataAtIndex:index numberOfRecords:1];
		}
		else{
			
			index = self.plotData.count;
			
			[TIBLELogger detail:@"\t Adding sample for plot at index: %d\n", index];
			//[TIBLELogger detail:@"\t\t Graph: %p Plot: %p\n", graph, plot];
			//[TIBLELogger detail:@"\t\t Sample Index: %d\n", sampleadded.index];
			
			[self.plotData insertObject:sampleadded atIndex:index];
			
			if (plot != nil)
				[plot insertDataAtIndex:index numberOfRecords:1];
		}
	
		[self refreshPlotForSampleAdded];
	}
}

- (void) removeSamplesAndReload{

	TIBLESensorModel * sensor = [[TIBLEDevicesManager sharedTIBLEDevicesManager]
								 connectedSensor];
	
	[sensor.sensorSamples flushQueue];
	
	[self reloadPlotData];
}

#pragma mark - CPTPlotDataSource

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
	int count = [self.plotData count];
    return count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;
	//get sample model with raw data
	TIBLESampleModel * sampleModel = [self.plotData objectAtIndex:index];
	
    switch ( fieldEnum ) {
			
        case CPTScatterPlotFieldX:
		{
			
			float xValue = [sampleModel time_sec_total];
			
			num = [NSNumber numberWithFloat:xValue];
			
			[TIBLELogger detail:@"Plotting - x = %.2f, idx = %d\n", xValue, index];
			
            break;
		}
        case CPTScatterPlotFieldY:
		{
			
			//calculate calibrated value
			float yValue = [sampleModel val];
			
            //num = [plotData objectAtIndex:index];
			num = [NSNumber numberWithFloat:yValue];
			
			[TIBLELogger detail:@"Plotting - y = %.2f, idx = %d\n", yValue, index];
			
            break;
		}
        default:
            break;
    }
	
    return num;
}

@end
