/*
 *  TIBLESensorMath.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import "TIBLESensorProfile.h"


@interface TIBLESensorMath : NSObject

- (float_t) val: (float_t) formula_val;
- (float_t) vout: (float_t) adc_val;
- (float_t) fval: (float_t) adc_val;

- (id) initWithProfile:(TIBLESensorProfile *) profile
andCalibrationADCValue:(float_t) adc_cal;

@end

