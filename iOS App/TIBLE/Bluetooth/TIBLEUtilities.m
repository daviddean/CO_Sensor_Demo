/*
 *  TIBLEUtilities.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEUtilities.h"
#import "CBUUID+StringExtraction.h"
#import "UIColor+LightAndDark.h"
#import "TIBLEUIConstants.h"
#import "CoreFoundation/CFByteOrder.h"
#import "TIBLEFeatures.h"
#import "TIBLESensorConstants.h"

@implementation TIBLEUtilities


+ (TIBLERawDataModel *) valueForMeasurementSample:(CBCharacteristic *) characteristic{
	
	if(characteristic == nil){
		
		[TIBLELogger error:@"TIBLEUtilities - Error - valueForMeasurementSample method. Characteristic is nil.\n"];
		
		return nil;
	}
	
	NSData * data = [characteristic value];
	
	if(data == nil){
		
		[TIBLELogger error:@"TIBLEUtilities - Error - valueForMeasurementSample method. Data is nil.\n"];
		
		return nil;
	}

	TIBLERawDataModel * valueModel = [[TIBLERawDataModel alloc] init];
	
	valueModel.data = data;
	
	return valueModel;
}

+ (NSString *) stringForUUID: (CBUUID *) uuid{
	
	NSString * uuidStr  = nil;
	
	if(TIBLE_DEBUG_SIMULATE_SENSOR_WITH_NO_UUID == NO){
		
		if(uuid != nil){
			uuidStr = [uuid representativeString];
		}
	}
	
    return uuidStr;
}

+ (NSString *) stringForCFUUID: (CFUUIDRef) uuid{
	
	NSString * uuidStr  = nil;
	
	if(TIBLE_DEBUG_SIMULATE_SENSOR_WITH_NO_UUID == NO){
		
		if(uuid != nil){
			CBUUID * uuidObj = [CBUUID UUIDWithCFUUID:uuid];
			uuidStr = [uuidObj representativeString];
		}
	}
	
    return uuidStr;
}

+ (UIColor *) colorFromIntARGB4444Value: (int32_t) intValue{
	
	//if intValue is 0, it is black, return default light gray color.
	if(intValue == 0){
		
		return [UIColor lightGrayColor];
	}
	
	//alpha in UIKit - 0.0 represents totally transparent and 1.0 represents totally opaque.
	float alpha = 1.0f - ((intValue & 0xFF000000) >> 24)/255.0f;
	float red = ((intValue & 0xFF0000) >> 16)/255.0f;
	float green = ((intValue & 0xFF00) >> 8)/255.0f;
	float blue = ((intValue & 0xFF))/255.0f;
	
	UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
	
	return [color lessSaturated];
}

+ (NSString *) dateAndTimeStampString{

	NSString * dateAndTime = @"";
	
	NSDate * date = [NSDate date];
	
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterShortStyle;
	dateFormatter.timeStyle = NSDateFormatterShortStyle;


	[dateFormatter setDateFormat:@"dd MMMM' at 'hh:mm a"];
	dateAndTime = [dateAndTime stringByAppendingFormat:@"%@ %@",
				   NSLocalizedString(@"Email.Body.Timestamp", nil),
				   [dateFormatter stringFromDate:date]];
	
	return dateAndTime;
}

+ (NSString *) dateAndTimeStampShortPathString{
	
	NSString * dateAndTime = @"";
	
	NSDate * date = [NSDate date];
	
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterShortStyle;
	dateFormatter.timeStyle = NSDateFormatterShortStyle;
	
	
	[dateFormatter setDateFormat:@"dd MMMM' at 'hh:mm a"];
	dateAndTime = [dateAndTime stringByAppendingFormat:@"%@",
				   [dateFormatter stringFromDate:date]];
	
	return dateAndTime;
}


+ (NSString *) formattedStringForValue: (float_t) value{
	
	//create format. If too big of a number, use scientific notation.
	NSString * format = @"%.1f";
	
	if((abs(value) > DISPLAY_LABEL_SCIENTIFIC_NOTATION_MAX_THRESHOLD) ||
	   (abs(value) < DISPLAY_LABEL_SCIENTIFIC_NOTATION_MIN_THRESHOLD)){
		
		//need to format with less digits, if using this logic, it displays
		//to many digits.
		
		format = @"%.4e";
	}
	
	//label for calibration value
	NSString * formattedString = [NSString stringWithFormat:format, value];

	return formattedString;
}

@end
