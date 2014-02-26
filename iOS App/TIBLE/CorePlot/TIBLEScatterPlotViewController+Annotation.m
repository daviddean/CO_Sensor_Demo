/*
 *  TIBLEScatterPlotViewController+Annotation.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEScatterPlotViewController+Annotation.h"
#import "TIBLEScatterPlotViewController+DataSource.h"
#import "TIBLEScatterPlotViewController+Utils.h"
#import "TIBLEUIConstants.h"

@implementation TIBLEScatterPlotViewController (Annotation)

#pragma mark - External

- (void) hideAnnotation {
    
    if (self.valueAnnotation != nil) {
		
		[TIBLELogger detail:@"TIBLEScatterPlotViewController - Hiding Annotation (%p)\n", self];
		
        CPTGraph *graph = self.hostView.hostedGraph;
        [graph.plotAreaFrame.plotArea removeAnnotation:self.valueAnnotation];
        self.valueAnnotation = nil;
    }
}

- (void) showAnnotationAtIndex:(NSUInteger) idx{
	
	CPTGraph *graph = self.hostView.hostedGraph;
	CPTScatterPlot * plot = (CPTScatterPlot *) [graph plotWithIdentifier:kPlotIdentifier];
	
	//Don't display annotation if plot is hidden.
    if (plot.isHidden == YES) {
		[TIBLELogger error:@"\t Error - Plot is HIDDEN, could NOT display annotation."];
        return;
    }
    
    //Hide annotation if already showing.
    [self hideAnnotation];
    
    //Get value for annotation.
    NSNumber * valueX = [self numberForPlot:plot field:CPTScatterPlotFieldX recordIndex:idx];
    NSNumber * valueY = [self numberForPlot:plot field:CPTScatterPlotFieldY recordIndex:idx];
	
    self.valueAnnotation = [self annotationWithPlotSpace:plot withXValue:valueX andYValue:valueY];
    
    //Add the annotation
    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.valueAnnotation];
	[plot repositionAllLabelAnnotations];
}

#pragma mark - Internal

- (CPTPlotSpaceAnnotation *) annotationWithPlotSpace: (CPTScatterPlot *) plot
										  withXValue:(NSNumber *) valueX
										   andYValue:(NSNumber *) valueY
											andScale: (float_t) scale{
	//get annotation image
	UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graph_annotation.png"]];
	
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	
	CPTBorderedLayer *newImagelLayer = [[CPTBorderedLayer alloc] initWithFrame:
										imageView.bounds];
	CPTImage * image = [CPTImage imageWithCGImage:imageView.image.CGImage
											scale:scale];
	newImagelLayer.fill = [CPTFill fillWithImage:image];
    
    //create anchor point
    NSNumber * anchorX = [NSNumber numberWithFloat:[valueX floatValue]];
    NSNumber * anchorY = [NSNumber numberWithFloat:[valueY floatValue]];
    NSArray *anchorPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
    
    //Create a number formatter if one doesn’t exist
	
	NSNumberFormatter * timeFormatter = [self getLabelFormatter:[anchorX floatValue]];
	NSNumberFormatter * valueFormatter = [self getLabelFormatter:[anchorY floatValue]];
	
    //create the annotation string text "(x,y)"
    NSString * valueStrX = [timeFormatter stringFromNumber:valueX];
    NSString * valueStrY = [valueFormatter stringFromNumber:valueY];
	
    NSString * annotationStr = [NSString stringWithFormat:@"%@,\n%@", valueStrX, valueStrY];
	
	//Create style for text layer
    CPTMutableTextStyle *style = [self getAnnotationTextStyle];
    
    //Create text layer for annotation (with style)
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:annotationStr style:style];
	textLayer.bounds = imageView.bounds;
	
	//create the annotation object
	CPTPlotSpaceAnnotation *imageAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace
																				anchorPlotPoint:anchorPoint];
    imageAnnotation.contentLayer = newImagelLayer; //set image layer
    imageAnnotation.anchorPlotPoint = anchorPoint; //set anchor point
	
	//pass the displacement in points,
	//internally it must convert it to plot coordinates, even when zooming,
	//because it keeps annotation right above the symbol even though after zoom.
	CGPoint displacement = CGPointMake(0, imageView.bounds.size.height/2.0f);
	imageAnnotation.displacement = displacement;
    
	[imageAnnotation.contentLayer addSublayer:textLayer];// set text layer
	
    return imageAnnotation;
}

- (CPTPlotSpaceAnnotation *) annotationWithPlotSpace: (CPTScatterPlot *) plot
										  withXValue:(NSNumber *) valueX
										   andYValue:(NSNumber *) valueY{
    
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Annotation With Plot Space called (%p)\n", self];
	
	UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graph_annotation.png"]];
	
	CPTPlotSpaceAnnotation * imageAnnotation = [self annotationWithPlotSpace:plot
					   withXValue:valueX
						andYValue:valueY
						 andScale:imageView.image.scale];
	
    return imageAnnotation;
}

#pragma mark - CPTScatterPlotDelegate

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx{
    
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Plot Symbol was selected at record index %d\n", idx];
	
	[self showAnnotationAtIndex:idx];
}


@end
