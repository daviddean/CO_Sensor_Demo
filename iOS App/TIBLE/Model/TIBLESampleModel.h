/*
 *  TIBLESampleModel.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import "TIBLERawDataModel.h"

@class TIBLESensorModel;

@interface TIBLESampleModel : NSObject

- (id) initWithValue: (TIBLERawDataModel *) value andModel:(TIBLESensorModel *) model;

@property (nonatomic, assign) int32_t counter; //from sensor
@property (nonatomic, assign) float_t vout;
@property (nonatomic, assign) float_t fval;
@property (nonatomic, assign) float_t temp;
@property (nonatomic, assign) float_t time_sec;
@property (nonatomic, assign) float_t time_msec;
@property (nonatomic, assign, readonly) float_t time_sec_total;
@property (nonatomic, assign) float_t val;
@property (nonatomic, assign) float_t adc_val;

@property (nonatomic, retain) NSString * rawBytesString;

@property (nonatomic, assign) int32_t index; //position in queue
@property (nonatomic, assign) int32_t time_reference_msec; //time value at counter 0.

- (NSString *) description;


@end
