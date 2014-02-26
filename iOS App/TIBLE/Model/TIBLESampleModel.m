/*
 *  TIBLESampleModel.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLESampleModel.h"
#import "TIBLEDevicesManager.h"
#import <Math.h>

#define TIBLE_MSEC_PER_SEC 1000.0f
#define TIBLE_TEMPERATURE_CELCIUS_FACTOR_DENOM 10.0f

@interface TIBLESampleModel(){
	
}

@property (nonatomic, weak) TIBLESensorModel * model;

@end

@implementation TIBLESampleModel


- (id)copyWithZone:(NSZone *)zone{
	
	TIBLESampleModel * sample = [[self class] allocWithZone:zone];
	
	if(sample != nil){
		
		sample.counter = self.counter;
		sample.rawBytesString = [self.description copy];
		sample.time_reference_msec = self.time_reference_msec;
		
		sample.adc_val = self.adc_val;
		sample.vout = self.vout;
		
		sample.temp = self.temp;
		
		sample.time_sec = self.time_sec;
		sample.time_msec = self.time_msec;
		
		sample.val = self.val;
		sample.fval = self.fval;
	}
	
	return sample;
}

- (id) initWithValue: (TIBLERawDataModel *) value andModel: (TIBLESensorModel *) model{
	
	self = [super init];
	
	if(self != nil){
		
		self.counter = value.rawSampleValue.uintValue1;
		self.rawBytesString = value.description;

		//will be set later
		self.time_reference_msec = 0;
		self.index = 0;
		
		self.adc_val = value.rawSampleValue.uintValue4;
		
		self.temp = (float)(value.rawSampleValue.uintValue3 / TIBLE_TEMPERATURE_CELCIUS_FACTOR_DENOM); //in Celcius
		
		self.time_sec = ((float)(value.rawSampleValue.uintValue2))/TIBLE_MSEC_PER_SEC;
		self.time_msec = value.rawSampleValue.uintValue2;
		
		self.vout = [model voutValue:self.adc_val];
		self.fval = [model formulaValue:self.adc_val];
		self.val = [model value:self.adc_val];
	}
	
	return self;
}

- (float_t) time_sec_total{
	
	return ((float)(self.time_msec + self.time_reference_msec))/TIBLE_MSEC_PER_SEC;
}

- (NSString *) description{
	
	NSString * description = @"\n";

	description = [description stringByAppendingFormat:@" counter: %d\n", self.counter];
	description = [description stringByAppendingFormat:@" bytes: %@\n", self.rawBytesString];
	
	description = [description stringByAppendingFormat:@" adc_val: %.3f\n", self.adc_val];
	description = [description stringByAppendingFormat:@" vout: %.2f V\n", self.vout];
	//description = [description stringByAppendingFormat:@" fval: %f\n", self.fval];
	description = [description stringByAppendingFormat:@" val: %.2f\n", self.val];
	
	//description = [description stringByAppendingFormat:@" time_reference_msec: %d ms\n", self.time_reference_msec];
	//description = [description stringByAppendingFormat:@" time_sec: %.2f s\n", self.time_sec];
	description = [description stringByAppendingFormat:@" time_msec: %d ms\n", (int)self.time_msec];
	description = [description stringByAppendingFormat:@" time_sec_total: %.2f s\n", self.time_sec_total];

	description = [description stringByAppendingFormat:@" temp: %.2f C\n", self.temp];
	
	
	return description;
}

@end
