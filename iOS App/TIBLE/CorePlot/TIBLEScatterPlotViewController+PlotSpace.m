/*
 *  TIBLEScatterPlotViewController+PlotSpace.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEScatterPlotViewController+PlotSpace.h"
#import "TIBLEDevicesManager.h"
#import "TIBLEScatterPlotViewController+Annotation.h"
#import "TIBLEPlotConstants.h"
#import "TIBLEGraphViewController.h"

@implementation TIBLEScatterPlotViewController (PlotSpace) 

#pragma mark - Plot Space Delegate Methods

-(void)plotSpace:(CPTPlotSpace *)space didChangePlotRangeForCoordinate:(CPTCoordinate)coordinate{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - plotSpace didChangePlotRangeForCoordinate.\n"];
	
	//hide annnotation if it gets outside of the visible range.
	CPTPlotRange * newRange = [space plotRangeForCoordinate:coordinate];
	
	if(coordinate == CPTCoordinateX){
		
		NSNumber * annotationXValueNum = [self.valueAnnotation.anchorPlotPoint objectAtIndex:0];
		float annotationXvalue = [annotationXValueNum floatValue];
		
		if([newRange containsDouble:annotationXvalue] == NO){
			[self hideAnnotation];
		}
	}
	else if(coordinate == CPTCoordinateY){
		
		NSNumber * annotationYValueNum = [self.valueAnnotation.anchorPlotPoint objectAtIndex:1];
		double annotationYvalue = [annotationYValueNum floatValue];
		
		if([newRange containsDouble:annotationYvalue] == NO){
			[self hideAnnotation];
		}
	}
	
	return;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - plotSpace shouldScaleBy scale: %.3f at point: x: %.3f y: %.3f\n",
	 interactionScale,
	 interactionPoint.x,
	 interactionPoint.y];
	
	return YES;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - plotSpace shouldHandlePointingDeviceDraggedEvent at point: x: %.3f y: %.3f\n",
	 interactionPoint.x,
	 interactionPoint.y];
	
	//if user is panning in plot space, then pause the graph as a convienence to user.
	
	if([self.parentViewController isKindOfClass:[TIBLEGraphViewController class]] &&
		[self.parentViewController respondsToSelector:@selector(setIsPaused:)]
	   ){

		TIBLEGraphViewController * graphVC = (TIBLEGraphViewController *) self.parentViewController;
		[graphVC setIsPaused:YES];
	}
	
    return YES;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - plotSpace shouldHandlePointingDeviceDownEvent at point: x: %.3f y: %.3f\n",
	 interactionPoint.x,
	 interactionPoint.y];
	
    return YES;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - plotSpace shouldHandlePointingDeviceUpEvent at point: x: %.3f y: %.3f\n",
	 interactionPoint.x,
	 interactionPoint.y];
	
    return YES;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceCancelledEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - plotSpace shouldHandlePointingDeviceCancelledEvent at point: x: %.3f y: %.3f\n",
	 interactionPoint.x,
	 interactionPoint.y];
	
    return YES;
}

-(CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)proposedDisplacementVector{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - plotSpace willDisplaceBy x:%.3f y:%.3f \n",
	 proposedDisplacementVector.x,
	 proposedDisplacementVector.y];
	
	return proposedDisplacementVector;
}

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate{
	
	CPTMutablePlotRange * retRange = [newRange mutableCopy];
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - will change plot range for axis: %d to range:%@\n",
	 coordinate, newRange];
	
	if(retRange.lengthDouble < GRAPH_MIN_RANGE_LENGHT){
		
		[TIBLELogger detail:@"\t Capping range to %f\n", GRAPH_MIN_RANGE_LENGHT];
		
		retRange.length = CPTDecimalFromFloat(GRAPH_MIN_RANGE_LENGHT);
	}
	
	return retRange;
}

@end
