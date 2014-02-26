/*
 *  TIBLESensorMath.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLESensorMath.h"

@interface TIBLESensorMathFormula : NSObject

@property (nonatomic, assign) float_t x0;
@property (nonatomic, assign) float_t d0;
@property (nonatomic, assign) float_t n0;
@property (nonatomic, assign) float_t d1;
@property (nonatomic, assign) float_t scale_factor_num;
@property (nonatomic, assign) float_t scale_factor_denum;


@end

@interface TIBLESensorMath ()


@property (nonatomic, assign) float_t cval;
@property (nonatomic, assign) float_t fcal;
@property (nonatomic, assign) float_t adc_cal;

@property (nonatomic, retain) TIBLESensorMathFormula * fconstants;

@end

@implementation TIBLESensorMathFormula

@end

@implementation TIBLESensorMath

- (id) initWithProfile:(TIBLESensorProfile *) profile andCalibrationADCValue:(float_t) adc_cal{

	self = [super init];
	
	if(self != nil){
		
		if(profile != nil){
			
			//set up constants first.
			self.fconstants = [[TIBLESensorMathFormula alloc] init];
			self.fconstants.d0 = [profile formula_denom_0];
			self.fconstants.n0 = [profile formula_num_0];
			self.fconstants.x0 = [profile formula_sub_x_0];
			self.fconstants.d1 = [profile formula_denom_1];
			self.fconstants.scale_factor_num = [profile formula_scaling_factor_num];
			self.fconstants.scale_factor_denum = [profile formula_scaling_factor_denom];
			
			//calculate fcal
			self.adc_cal = adc_cal;
			
			self.fcal = [self fval:adc_cal];
			
			//get pcal
			self.cval = [profile calibrationValue];
		}
	}
	
	return self;
}

/*
 * Voltage Out.
 * vout = (adc_val/d0) * n0
 * Used for displaying to user and also
 * could be used in calculating fval.
 */

- (float_t) vout: (float_t) adc_val{

	float_t d0 = self.fconstants.d0;
	float_t n0 = self.fconstants.n0;
	
	float vout = (adc_val/d0) * n0;
	
	return vout;
}

/*
 * Formula Value
 * f = (x0 - ((adc_val/d0) * n0))/d1
 */

- (float_t) fval: (float_t) adc_val{
	
	float_t x0 = self.fconstants.x0;
	float_t d0 = self.fconstants.d0;
	float_t n0 = self.fconstants.n0;
	float_t d1 = self.fconstants.d1;
	
	float_t f = (x0 - ((adc_val/d0) * n0))/d1;
	
	return f;
}

/*
 * Scaled value
 */

- (float_t) scale: (float_t) formula_val{
	
	float_t scale_num = (float_t) self.fconstants.scale_factor_num;
	float_t scale_denum = (float_t) self.fconstants.scale_factor_denum;
	
	float_t f = formula_val;
	
	BOOL scale = (scale_num != TIBLE_SENSOR_DO_NOT_SCALE_VALUE &&
				  scale_denum != TIBLE_SENSOR_DO_NOT_SCALE_VALUE);
	BOOL valid = (scale_num != TIBLE_SENSOR_NOT_INITIALIZED_VALUE &&
				  scale_denum != TIBLE_SENSOR_NOT_INITIALIZED_VALUE);
	
	if(scale && valid){
		
		f = (formula_val * scale_num) / scale_denum;
	}

	return f;
}
/*
 * Final Value. Percentage Value (for O2) pr PPM (for CO2).
 * It may be scaled accordingly.
 */

- (float_t) val: (float_t) formula_val{
	
	float_t scaleVal = [self scale:formula_val];
	float_t val = scaleVal;
	
	BOOL calibrate = (self.cval != TIBLE_SENSOR_DO_NOT_CALIBRATE_VALUE);
	BOOL valid = (self.cval != TIBLE_SENSOR_NOT_INITIALIZED_VALUE);
	
//	[TIBLELogger detail:@""
//	 "\t formula_val: %f \n"
//	 "\t adc_cal: %.2f (cval = %.2f, fcal = %f) \n"
//	 "\t scaling_value: %.2f \n"
//	 "...\n",
//	 formula_val,
//	 self.adc_cal, self.cval, self.fcal,
//	 (self.fconstants.scale_factor_num/self.fconstants.scale_factor_denum)];
	
	if(calibrate && valid && self.fcal > 0){
		
		float_t fval = formula_val;
		float_t cval = self.cval;
		float_t fcal = self.fcal;
		
		val = (fval * cval) / fcal;
	}
	
//	[TIBLELogger detail:@"\t val: %.2f\n", val];
	
	return val;
}

@end
