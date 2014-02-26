/*
 *  TIBLESampleQueue.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import "TIBLESampleModel.h"

@class TIBLESensorModel;

#define TIBLE_MAX_SAMPLE_QUEUE_SIZE 600 //(10 samples/sec or 10 min)
//FIFO queue. holds MAX number of samples. raw ADC data.

@interface TIBLESampleQueue : NSObject

- (TIBLESampleModel *) latestSample;
- (void) addSample: (TIBLESampleModel *) sample;
-(void) setSensor_Command_Characteristic: (TIBLERawDataModel *) value;

@property(nonatomic, strong) NSMutableArray * queueArray;

@property (nonatomic, assign) uint32_t timeReference;
@property (nonatomic, assign) uint32_t previousSampleTime;

- (void) flushQueue;
- (BOOL) containsSamples;
- (id) initWithModel: (TIBLESensorModel *) model;
- (int) deltaTime;

@end
