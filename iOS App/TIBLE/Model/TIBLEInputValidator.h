/*
 *  TIBLEInputValidation.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import "TIBLESensorProfile.h"
#import "TIBLESensorModel.h"
#import "TIBLESensorConstants.h"

@interface TIBLEInputValidator : NSObject

- (id) initWithSensorModel: (TIBLESensorModel *) model andProfile: (TIBLESensorProfile *) profile;

- (NSDictionary *) recommendedBoundaryValues;
- (NSDictionary *) validateSampleValueWithinBoundaries: (float_t) adc_val;

- (BOOL) shouldLogScaleBeEnabled;

@end
