/*
 *  TIBLERawDataModel.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import "TIBLERawSampleModel.h"

@interface TIBLERawDataModel : NSObject

@property (nonatomic, strong) NSData * data;

- (TIBLERawSampleModel *) rawSampleValue;

- (uint32_t) uint32Value;
- (uint16_t) uint16Value;
- (uint8_t)  uint8Value;

- (int32_t) int32Value;
- (int16_t) int16Value;
- (int8_t) int8Value;

- (NSString *) stringValue;
- (NSString *) description;

@end
