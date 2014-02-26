//
//  TIBLEScatterPlotViewController+Utils.m
//  TIBLE
//
//  Created by meli on 5/21/13.
//  Copyright (c) 2013 Krasamo. All rights reserved.
//

#import "TIBLEScatterPlotViewController+Utils.h"
#import "TIBLEPlotConstants.h"
#import "TIBLEUIConstants.h"
#import "TIBLESensorConstants.h"

@implementation TIBLEScatterPlotViewController (Utils)

- (CPTMutableTextStyle *) getAxisTitleStyle{
	
	static CPTMutableTextStyle * axisTitleStyle = nil;
	
	if (axisTitleStyle == nil) {
		
		axisTitleStyle = [CPTMutableTextStyle textStyle];
		axisTitleStyle.color = [CPTColor whiteColor];
		axisTitleStyle.fontName = TIBLE_APP_FONT_NAME;
		axisTitleStyle.fontSize = CPDPlotAxisTitleFontSize;
		
	}
	return axisTitleStyle;
}

- (CPTMutableLineStyle *) getAxisLineStyle{
	
	static CPTMutableLineStyle * axisLineStyle = nil;
	
	if(axisLineStyle == nil){
		
		axisLineStyle = [CPTMutableLineStyle lineStyle];
		axisLineStyle.lineWidth = 1.0f;
		axisLineStyle.lineColor = [CPTColor whiteColor];		
	}
	
	return axisLineStyle;
}

- (CPTMutableTextStyle *) getAxisTextStyle{
	
	static CPTMutableTextStyle * axisTextStyle = nil;
	
	if (axisTextStyle == nil) {
		
		axisTextStyle = [[CPTMutableTextStyle alloc] init];
		axisTextStyle.color = [CPTColor whiteColor];
		axisTextStyle.fontName = TIBLE_APP_FONT_NAME;
		axisTextStyle.fontSize = CPDPlotAxisTextFontSize;
		
	}
	
	return axisTextStyle;
}

- (CPTMutableLineStyle *) getTickLineStyle{
	
	static CPTMutableLineStyle * tickLineStyle = nil;
	
	if(tickLineStyle == nil){
		
		tickLineStyle = [CPTMutableLineStyle lineStyle];
		tickLineStyle.lineColor = [CPTColor whiteColor];
		tickLineStyle.lineWidth = 1.0f;
	}
	
	return tickLineStyle;
}

- (CPTMutableLineStyle *) getGridLineStyle{
	
	static CPTMutableLineStyle * gridLineStyle = nil;
	
	if (gridLineStyle == nil) {
		
		gridLineStyle = [CPTMutableLineStyle lineStyle];
		gridLineStyle.lineColor = [CPTColor lightGrayColor];
		gridLineStyle.lineWidth = 1.0f;
	}
	
	return gridLineStyle;
}

- (CPTMutableTextStyle *) getAnnotationTextStyle{
	
	static CPTMutableTextStyle * annotationTextStyle = nil;
	
	if (annotationTextStyle == nil) {
		
		annotationTextStyle = [CPTMutableTextStyle textStyle];
		annotationTextStyle.color= [CPTColor darkGrayColor];
		annotationTextStyle.fontSize = TIBLE_APP_FONT_GRAPH_ANNOTATION_SIZE;
		annotationTextStyle.fontName = TIBLE_APP_FONT_NAME;
		annotationTextStyle.textAlignment = CPTTextAlignmentCenter;
	}
	
	return annotationTextStyle;
}

- (CPTColor *) colorForUIColor: (UIColor *) colorUIObj{
	
	CPTColor * color = [CPTColor colorWithCGColor:colorUIObj.CGColor];
    return color;
	
}

- (NSNumberFormatter *) getLabelFormatter:(float_t) value{
	
	static NSNumberFormatter * numberFormatter = nil;
	static NSNumberFormatter * scientifFormater = nil;
	
	NSNumberFormatter * formatter = nil;
	
	if((abs(value) >= DISPLAY_LABEL_SCIENTIFIC_NOTATION_MAX_THRESHOLD) ||
	   (abs(value) < DISPLAY_LABEL_SCIENTIFIC_NOTATION_MIN_THRESHOLD)){
		
		if(scientifFormater == nil){
			scientifFormater = [[NSNumberFormatter alloc] init];
		}
		
		[self setScientificFormat:scientifFormater];
		
		formatter = scientifFormater;
	}
	else{
		
		if(numberFormatter == nil){
			numberFormatter = [[NSNumberFormatter alloc] init];
		}
		
		[self setDecimalFormat:numberFormatter];
		
		formatter = numberFormatter;
		
	}
	
	return formatter;
}

- (void) setDecimalFormat: (NSNumberFormatter *) formatter{
	
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	formatter.roundingMode = kCFNumberFormatterRoundUp;
	
	[formatter setMinimumFractionDigits:1];
	[formatter setMaximumFractionDigits:2];
}

- (void) setScientificFormat: (NSNumberFormatter *) formatter{
	
	[formatter setNumberStyle:NSNumberFormatterScientificStyle];
	
	formatter.roundingMode = kCFNumberFormatterRoundUp;
	formatter.exponentSymbol = @"e";
	
	//decimals (right of period)
	[formatter setMinimumFractionDigits:1];
	[formatter setMaximumFractionDigits:2];
	
	//integer (left of period)
	[formatter setMinimumIntegerDigits:1];
	[formatter setMaximumIntegerDigits:1];
	
	//significant digits
	[formatter setMaximumSignificantDigits:6];
}

@end
