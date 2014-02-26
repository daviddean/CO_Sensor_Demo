/*
 *  TIBLERawDataModel.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLERawDataModel.h"
#import "TIBLESensorConstants.h"

@implementation TIBLERawDataModel

#define TIBLE_PAYLOAD_DATA_SIZE_8_BYTES 8
#define TIBLE_PAYLOAD_DATA_SIZE_4_BYTES 4
#define TIBLE_PAYLOAD_DATA_SIZE_2_BYTES 2
#define TIBLE_PAYLOAD_DATA_SIZE_1_BYTES 1

#pragma mark - Sample Data

- (TIBLERawSampleModel *) rawSampleValue{

	TIBLERawSampleModel * value = nil;
	
	if(self.data != nil && self.data.length == TIBLE_PAYLOAD_DATA_SIZE_8_BYTES){
		
		value = [[TIBLERawSampleModel alloc] init];
		
		int arraySize = TIBLE_PAYLOAD_DATA_SIZE_8_BYTES/2;
		uint16_t loSensorData[arraySize];
		[self.data getBytes:loSensorData length:sizeof (loSensorData)];
		
		value.uintValue1 = loSensorData[0];
		value.uintValue2 = loSensorData[1];
		value.uintValue3 = loSensorData[2];
		value.uintValue4 = loSensorData[3];
		
		[TIBLELogger detail:@"TIBLEUtilities - Printing measurement value: ...\n"];
		[TIBLELogger detail:@"\t counter: %u\n", value.uintValue1];
		[TIBLELogger detail:@"\t time: %u\n", value.uintValue2];
		[TIBLELogger detail:@"\t temp: %u\n", value.uintValue3];
		[TIBLELogger detail:@"\t adc_value: %u\n", value.uintValue4];

	}
	else{
		
		//if self.data is nil, or I get other than 8 bytes, initialize the rawSampleValue to 0s.
		value.uintValue1 = 0;
		value.uintValue2 = 0;
		value.uintValue3 = 0;
		value.uintValue4 = 0;
	}
	
	return value;
}

#pragma mark - Unsigned Int Routines

- (uint8_t) uint8Value{
	
	uint8_t value = 0;
	
	if(self.data != nil && self.data.length == TIBLE_PAYLOAD_DATA_SIZE_1_BYTES){
		
		[self.data getBytes:&value length:sizeof (value)];
		
		[TIBLELogger detail:@"TIBLEUtilities - Printing characteristic value: ...\n"];
		[TIBLELogger detail:@"\t uint_value: %u\n", value];
	}
	
	return value;
}

- (uint16_t) uint16Value{
	
	uint16_t value = 0;
	
	if(self.data != nil && self.data.length == TIBLE_PAYLOAD_DATA_SIZE_2_BYTES){
		
		[self.data getBytes:&value length:sizeof (value)];
		
		[TIBLELogger detail:@"TIBLEUtilities - Printing characteristic value: ...\n"];
		[TIBLELogger detail:@"\t uint_value: %u\n", value];
	}
	
	return value;
}

- (uint32_t) uint32Value{
	
	uint32_t value = 0;
		
	if(self.data != nil && self.data.length == TIBLE_PAYLOAD_DATA_SIZE_4_BYTES){
		
		[self.data getBytes:&value length:sizeof (value)];
		
		[TIBLELogger detail:@"TIBLEUtilities - Printing characteristic value: ...\n"];
		[TIBLELogger detail:@"\t uint_value: %u\n", value];
	}
	
	return value;
}

#pragma mark - Signed Int Routines

- (int32_t) int32Value{
	
	int32_t value = 0;
	
	if(self.data != nil && self.data.length == TIBLE_PAYLOAD_DATA_SIZE_4_BYTES){
		
		[self.data getBytes:&value length:sizeof (value)];
		
		[TIBLELogger detail:@"TIBLEUtilities - Printing characteristic value: ...\n"];
		[TIBLELogger detail:@"\t int_value: %u\n", value];
	}
	
	return value;
}

- (int16_t) int16Value{
	
	int16_t value = 0;
	
	if(self.data != nil && self.data.length == TIBLE_PAYLOAD_DATA_SIZE_2_BYTES){
		
		[self.data getBytes:&value length:sizeof (value)];
		
		[TIBLELogger detail:@"TIBLEUtilities - Printing characteristic value: ...\n"];
		[TIBLELogger detail:@"\t int_value: %u\n", value];
	}
	
	return value;
}

- (int8_t) int8Value{

	int8_t value = 0;
	
	if(self.data != nil && self.data.length == TIBLE_PAYLOAD_DATA_SIZE_1_BYTES){
		
		[self.data getBytes:&value length:sizeof (value)];
		
		[TIBLELogger detail:@"TIBLEUtilities - Printing characteristic value: ...\n"];
		[TIBLELogger detail:@"\t int_value: %u\n", value];
	}
	
	return value;
}

#pragma mark - String Routines

- (NSString *) stringValue{
	
	NSString * string = @"";
	
	if(self.data != nil && self.data.length > 0){
		
		string = [[NSString alloc] initWithData:self.data
									   encoding:NSUTF8StringEncoding];
		
		[TIBLELogger detail:@"TIBLEUtilities - Printing value procesed as a string...\n"];
		[TIBLELogger detail:@"\t str_value: %@\n", string];
	}
	
	return string;
}

- (NSString *) description{
	
	NSString * string = @"";
	
	if(self.data != nil && self.data.length > 0){
		
		string = [self.data description];
		
		[TIBLELogger detail:@"TIBLEUtilities - Printing value procesed as a string...\n"];
		[TIBLELogger detail:@"\t description_str: %@\n", string];
	}
	
	return string;
}

@end
