/*
 *  TIBLEScatterPlotViewController+Export.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEScatterPlotViewController+Export.h"
#import "TIBLEScatterPlotViewController+Annotation.h"
#import "TIBLEPlotConstants.h"
#import "TIBLEDevicesManager.h"
#import "TIBLEUIConstants.h"
#import "TIBLEResourceConstants.h"
#import "TIBLESettingsManager.h"

@implementation TIBLEScatterPlotViewController (Export)

#pragma mark - Share

- (NSURL *) pdfGraphDataURL{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Calling to Obtain PDF Graph Data (%p)\n", self];
	
	//removing annotation since image shows with scaling issue.
	CPTGraph *graph = self.hostView.hostedGraph;
	
	if(self.valueAnnotation != nil){
		[graph.plotAreaFrame.plotArea removeAllAnnotations];
	}
	
	NSData * pdfData = [self.hostView.hostedGraph dataForPDFRepresentationOfLayer];
	
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
	
	NSString * shortTimeStamp = [TIBLEUtilities dateAndTimeStampShortPathString];
	NSString * graphPDFFileName = [NSString stringWithFormat:@"%@ - %@.%@",
								   NSLocalizedString(@"Email.Attachment.FileName", nil),
								   shortTimeStamp,
								   kFileExtensionPDF];
	
	NSString * docFilePath = [docPath stringByAppendingPathComponent:graphPDFFileName];
	[pdfData writeToFile:docFilePath options:NSDataWritingAtomic error:nil];
	
	//restore annotation.
	if(self.valueAnnotation != nil){
	  [graph.plotAreaFrame.plotArea addAnnotation:self.valueAnnotation];
	}
	
	return [NSURL fileURLWithPath:docFilePath];
}

- (NSURL *) csvGraphDataURL{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Calling to Obtain CSV Graph Data (%p)\n", self];
	
	NSString * csvString = [self csvGraphString];
	
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
	
	NSString * shortTimeStamp = [TIBLEUtilities dateAndTimeStampShortPathString];
	NSString * graphCSVFileName = [NSString stringWithFormat:@"%@ - %@.%@",
								   NSLocalizedString(@"Email.Attachment.FileName", nil),
								   shortTimeStamp,
								   kFileExtensionCSV];
	
	NSString * docFilePath = [docPath stringByAppendingPathComponent:graphCSVFileName];
	
	[csvString writeToFile:docFilePath
				atomically:YES encoding:NSUTF8StringEncoding error:nil];
	
	return [NSURL fileURLWithPath:docFilePath];
}

- (NSString *) csvGraphString{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Calling to Obtain CSV Graph String (%p)\n", self];
	
	//create the string that will become the csv file data
	NSMutableString *csvString = [[NSMutableString alloc] init];
	
	TIBLESensorModel * connectedSensor = [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
	TIBLESensorProfile * sensorProfile = [[TIBLESettingsManager sharedTIBLESettingsManager] setting];
	
	//row one contains titles
	NSString *xCaption = [[sensorProfile graph_x_axis_caption]
						  substringWithRange:NSMakeRange(0, [sensorProfile.graph_x_axis_caption length] - 1)];
	NSString *yCaption = [[sensorProfile graph_y_axis_caption]
						  substringWithRange:NSMakeRange(0, [sensorProfile.graph_y_axis_caption length] - 1)];
	
	NSString *rowOne = [NSString stringWithFormat:@"\"%@\",\"%@\"\n", xCaption, yCaption];
	[csvString setString:rowOne];
	
	//loop through data and place in appropriate column
	for (int i = 0; i < [connectedSensor.sensorSamples.queueArray count]; i++) {
		
		TIBLESampleModel * sampleModel = [connectedSensor.sensorSamples.queueArray objectAtIndex:i];
		
		float xValue = [sampleModel time_sec_total];
		float yValue = [sampleModel val];
		
		NSString *yVal = [NSString stringWithFormat:@"%.3f", xValue];
		NSString *xVal = [NSString stringWithFormat:@"%.3f", yValue];
		
		NSString *tempStr = [NSString stringWithFormat:@"%@,%@\n", yVal, xVal];
		[csvString appendString:tempStr];
	}
	
	return csvString;
}


@end
