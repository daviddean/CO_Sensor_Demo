/*
 *  TIBLEScatterPlotViewController+Annotation.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEScatterPlotViewController.h"
#import "TIBLEPlotConstants.h"

@interface TIBLEScatterPlotViewController (Annotation) <CPTScatterPlotDelegate>

-(void) hideAnnotation;
-(void) showAnnotationAtIndex:(NSUInteger) idx;

- (CPTPlotSpaceAnnotation *) annotationWithPlotSpace: (CPTScatterPlot *) plot
										  withXValue:(NSNumber *) valueX
										   andYValue:(NSNumber *) valueY
											andScale: (float_t) scale;
@end
