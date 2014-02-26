/*
 *  TIBLESampleQueue.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLESampleQueue.h"
#import "TIBLESensorModel.h"
#import "TIBLEUIConstants.h"

@interface TIBLESampleQueue ()

@property (nonatomic, assign) uint32_t indexCounter;
@property (weak, nonatomic) TIBLESensorModel * model;

@end

@implementation TIBLESampleQueue


- (id)copyWithZone:(NSZone *)zone{
	
	TIBLESampleQueue * queue = [[self class] allocWithZone:zone];
	
	if(queue != nil){
		
		queue.queueArray = [self.queueArray copy];
		queue.indexCounter = self.indexCounter;
	}
	
	return queue;
}

- (id) initWithModel: (TIBLESensorModel *) model{

	self = [super init];
	
	if(self != nil){
		
		self.queueArray = [NSMutableArray arrayWithCapacity:TIBLE_MAX_SAMPLE_QUEUE_SIZE];
		self.indexCounter = 0;
		self.model = model;
	}
	
	return self;
}

- (uint32_t) queueSize{

	@synchronized(self) {
		
		return [self.queueArray count];
	}
}

- (TIBLESampleModel *) latestSample{
	
	@synchronized(self) {
		
		return [self.queueArray lastObject];
	}
}

- (void) addSample: (TIBLESampleModel *) sample{
	
	@synchronized(self) {
		
		int arrayCount = [self.queueArray count];
		
		if(sample.time_sec < 1.0f){
			//clear queue and start over
			self.timeReference = self.timeReference + self.previousSampleTime;
			//[TIBLELogger detail:@"Settings sample time reference to: %f + %f", self.timeReference, self.previousSampleTime];
		}
		
		sample.time_reference_msec = self.timeReference;
		
		if(arrayCount < TIBLE_MAX_SAMPLE_QUEUE_SIZE){ //keep queue with max no. of samples
			
			//increase counter
			sample.index = self.indexCounter; //first
			self.indexCounter++; //seconds
			
			//add
			[self.queueArray addObject:sample];
			
			//notify after adding sample
			if(sample.index == 0){
				//first sample to be added to queue
				[self sendNotificationSensorReceivingSamples];
			}
			
			//log
			//[TIBLELogger detail:@"Adding Sample to Queue ... (size: %d)\n", [self.queueArray count]];
			[TIBLELogger detail:@"Adding Sample...\n"];
			[TIBLELogger detail:[sample description]];
		}
		else{
			
			//remove
			[self.queueArray removeObjectAtIndex:0]; //indexes are updated.
			
			//log
			//TIBLESampleModel * oldestSample = [self.queueArray objectAtIndex:0];
			//[TIBLELogger detail:@"TIBLESampleQueue - Removing Oldest Sample from Queue...\n"];
			//[TIBLELogger detail:@"%@", [oldestSample description]];
			
			//increase counter
			sample.index = self.indexCounter; //first
			self.indexCounter++; //seconds
			
			//add
			[self.queueArray addObject:sample];
			
			//log
			//[TIBLELogger detail:@"Adding Sample to Queue ... (size: %d)\n", [self.queueArray count]];
			[TIBLELogger detail:@"Adding Sample...\n"];
			[TIBLELogger detail:[sample description]];
		}
	}
}

- (void) flushQueue{
	
	@synchronized(self) {
		[self.queueArray removeAllObjects];
	}
}

-(void) setSensor_Command_Characteristic: (TIBLERawDataModel *) value{
	
	if(self.queueSize == 0){
		
		//this is our first sample, set the the adc value as calibration default.
		self.model.adc_cal = value.rawSampleValue.uintValue4;
	}
	
	TIBLESampleModel * sample = [[TIBLESampleModel alloc] initWithValue:value andModel:self.model];
	[self addSample:sample];
	
	self.previousSampleTime = sample.time_msec;
}

- (int) deltaTime{
	
	int deltaTime = 0;
	
	if(self.queueSize > 1){ //at least 2 elements, then compare
	
		TIBLESampleModel * lastSample = [self.queueArray objectAtIndex:[self.queueArray count] - 1];
		TIBLESampleModel * semiLastSample = [self.queueArray objectAtIndex:[self.queueArray count] - 2];
		
		deltaTime = lastSample.time_msec - semiLastSample.time_msec;

		if(deltaTime < 0){ //if negative, means time reset between samples
			
			deltaTime = 0;
		}
	}
	
	return deltaTime;
}

- (void) sendNotificationSensorReceivingSamples{
	
	[TIBLELogger info:@"TIBLESensorProfile - Sending Notification NOTIFICATION_BLE_RECEIVING_SAMPLES.\n"];
	
	NSNotification * notif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_BLE_RECEIVING_SAMPLES
														   object:nil
														 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:notif];
}

- (BOOL) containsSamples{
	
	BOOL retVal = NO;
	
	if(self.queueSize > 0){
		retVal = YES;
	}
	
	return retVal;
}

@end
