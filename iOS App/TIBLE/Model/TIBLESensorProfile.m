/*
 *  TIBLESensorProfile.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLESensorProfile.h"
#import "TIBLESensorConstants.h"
#import "TIBLEUtilities.h"
#import "TIBLEUserDefaultConstants.h"
#import "TIBLEUIConstants.h"

@implementation TIBLESensorProfile

//What do we get as NSNumber value for the for the characteristics received?
//we need to map to correct data type.

- (id)copyWithZone:(NSZone *)zone{
	
	TIBLESensorProfile * dataModel = [[self class] allocWithZone:zone];
	
	if(dataModel != nil){
		
        dataModel.settingName = self.settingName;
        
		dataModel.calibrationValue = self.calibrationValue;
		dataModel.sensorType = self.sensorType;
		dataModel.shortCaption = self.shortCaption;
		
		dataModel.formula_denom_0 = self.formula_denom_0;
		dataModel.formula_num_0 = self.formula_num_0;
		dataModel.formula_sub_x_0 = self.formula_sub_x_0;
		dataModel.formula_denom_1 = self.formula_denom_1;
		dataModel.formula_scaling_factor_num = self.formula_scaling_factor_num;
		dataModel.formula_scaling_factor_denom = self.formula_scaling_factor_denom;
		
		dataModel.graph_title = [self.graph_title copy];
		dataModel.graph_subTitle = [self.graph_subTitle copy];
		dataModel.graph_x_axis_caption = [self.graph_x_axis_caption copy];
		dataModel.graph_y_axis_caption = [self.graph_y_axis_caption copy];
		
		//UIColor does not support copy method in iOS 5.
		UIColor * colorTop = [[UIColor alloc] initWithCGColor:
							  self.graph_color_top_value.CGColor];
		dataModel.graph_color_top_value = colorTop;
		
		UIColor * colorMid = [[UIColor alloc] initWithCGColor:
							  self.graph_color_mid_value.CGColor];
		dataModel.graph_color_mid_value = colorMid;
		
		UIColor * colorLow = [[UIColor alloc] initWithCGColor:
							  self.graph_color_low_value.CGColor];
		dataModel.graph_color_low_value = colorLow;
		
		dataModel.graph_y_axis_display_min = self.graph_y_axis_display_min;
		dataModel.graph_y_axis_display_max = self.graph_y_axis_display_max;
		dataModel.graph_color_top_mid_boundary = self.graph_color_top_mid_boundary;
		dataModel.graph_color_mid_low_boundary = self.graph_color_mid_low_boundary;

		dataModel.graph_display_current_value = self.graph_display_current_value;
		dataModel.graph_log_scale_enabled = self.graph_log_scale_enabled;
		dataModel.config_op_mode = self.config_op_mode;
		dataModel.config_TIA_gain = self.config_TIA_gain;
		dataModel.config_R_load = self.config_R_load;
		dataModel.config_internal_zero = self.config_internal_zero;
		dataModel.config_reference_voltage_source = self.config_reference_voltage_source;
	}
	
	return dataModel;
}

#pragma mark - NSCoder

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.settingName forKey:kSettingName];
    
    [aCoder encodeFloat:self.calibrationValue forKey:kSensorProfileSettingCalibrationKey];
    [aCoder encodeObject:self.shortCaption forKey:kSensorProfileSettingShortDescriptionCaptionKey];
	
    [aCoder encodeFloat:self.formula_denom_0 forKey:kSensorProfileSettingFormulaDenom0Key];
    [aCoder encodeFloat:self.formula_num_0   forKey:kSensorProfileSettingFormulaNum0Key];
    [aCoder encodeFloat:self.formula_sub_x_0 forKey:kSensorProfileSettingFormulaSubX0Key];
    [aCoder encodeFloat:self.formula_denom_1 forKey:kSensorProfileSettingFormulaDenom1Key];

	[aCoder encodeFloat:self.formula_scaling_factor_num forKey:kSensorProfileSettingFormulaScalingFactorNumKey];
    [aCoder encodeFloat:self.formula_scaling_factor_denom forKey:kSensorProfileSettingFormulaScalingFactorDenomKey];
	
    [aCoder encodeObject:self.graph_title forKey:kSensorProfileSettingGraphTitleKey];
    [aCoder encodeObject:self.graph_subTitle forKey:kSensorProfileSettingGraphSubTitleKey];
    [aCoder encodeObject:self.graph_x_axis_caption forKey:kSensorProfileSettingGraphXAxisCaptionKey];
    [aCoder encodeObject:self.graph_y_axis_caption forKey:kSensorProfileSettingGraphYAxisCaptionKey];
    [aCoder encodeFloat:self.graph_y_axis_display_min forKey:kSensorProfileSettingGraphYAxisDisplayMinKey];
    [aCoder encodeFloat:self.graph_y_axis_display_max forKey:kSensorProfileSettingGraphYAxisDisplayMaxKey];
    [aCoder encodeFloat:self.graph_color_top_mid_boundary forKey:kSensorProfileSettingGraphColorTopMidBoundaryKey];
    [aCoder encodeFloat:self.graph_color_mid_low_boundary forKey:kSensorProfileSettingGraphColorMidLowBoundaryKey];
    [aCoder encodeObject:self.graph_color_top_value forKey:kSensorProfileSettingGraphColorTopValueKey];
    [aCoder encodeObject:self.graph_color_mid_value forKey:kSensorProfileSettingGraphColorMidValueKey];
    [aCoder encodeObject:self.graph_color_low_value forKey:kSensorProfileSettingGraphColorLowValueKey];
    
    [aCoder encodeBool:self.graph_display_current_value forKey:kSensorProfileSettingGraphDisplayCurrentValueKey];
    [aCoder encodeBool:self.graph_log_scale_enabled forKey:kSensorProfileSettingGraphLogScaleEnabledKey];
    
    [aCoder encodeFloat:self.config_op_mode forKey:kSensorProfileSettingConfigOpModeKey];
    [aCoder encodeFloat:self.config_TIA_gain forKey:kSensorProfileSettingConfigTIAGainKey];
    [aCoder encodeFloat:self.config_R_load forKey:kSensorProfileSettingConfigRLoadKey];
    [aCoder encodeFloat:self.config_internal_zero forKey:kSensorProfileSettingConfigInternalZeroKey];
    [aCoder encodeFloat:self.config_reference_voltage_source forKey:kSensorProfileSettingConfigReferenceVoltageSourceKey];
}

- (id) init {
	
	self = [super init];
	
	if(self != nil){
		
		self.settingName = TIBLE_SENSOR_NOT_INITIALIZED_STRING;
		self.graph_title = TIBLE_SENSOR_NOT_INITIALIZED_STRING;
		self.shortCaption = TIBLE_SENSOR_NOT_INITIALIZED_STRING;
		
        self.graph_subTitle = TIBLE_SENSOR_NOT_INITIALIZED_STRING;
        self.graph_x_axis_caption = TIBLE_SENSOR_NOT_INITIALIZED_STRING;
        self.graph_y_axis_caption = TIBLE_SENSOR_NOT_INITIALIZED_STRING;
				
		self.calibrationValue = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
		self.formula_sub_x_0 = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
        self.formula_denom_0 = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
        self.formula_num_0 = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
        self.formula_denom_1 = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
		self.formula_scaling_factor_num = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
		self.formula_scaling_factor_denom = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
		
		self.graph_y_axis_display_min = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
        self.graph_y_axis_display_max = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
		self.graph_color_top_mid_boundary = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
        self.graph_color_mid_low_boundary = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
        self.config_op_mode =  TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
        self.config_TIA_gain = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
        self.config_R_load = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
        self.config_internal_zero = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
        self.config_reference_voltage_source = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;

        self.graph_color_top_value = nil;
        self.graph_color_mid_value = nil;
        self.graph_color_low_value = nil;
        
        self.graph_display_current_value = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
        self.graph_log_scale_enabled = TIBLE_SENSOR_NOT_INITIALIZED_VALUE;
	}
	
	return self;
}

- (BOOL) areAllCharacteristicsRead{
	
	BOOL retVal = YES;
	
	if(
	   ([self.graph_title isEqualToString:TIBLE_SENSOR_NOT_INITIALIZED_STRING]) ||
	   ([self.shortCaption isEqualToString:TIBLE_SENSOR_NOT_INITIALIZED_STRING]) ||
	   ([self.graph_subTitle isEqualToString:TIBLE_SENSOR_NOT_INITIALIZED_STRING]) ||
	   ([self.graph_x_axis_caption isEqualToString:TIBLE_SENSOR_NOT_INITIALIZED_STRING]) ||
	   ([self.graph_y_axis_caption isEqualToString:TIBLE_SENSOR_NOT_INITIALIZED_STRING]) ||
	   (self.calibrationValue == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.formula_sub_x_0 == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.formula_denom_0 == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.formula_num_0 == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.formula_denom_1 == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.formula_scaling_factor_num == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.formula_scaling_factor_denom == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.graph_y_axis_display_min == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.graph_y_axis_display_max == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.graph_color_top_mid_boundary == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.graph_color_mid_low_boundary == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.config_op_mode ==  TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.config_TIA_gain == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.config_R_load == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.config_internal_zero == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.config_reference_voltage_source == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.graph_color_top_value == nil) ||
	   (self.graph_color_mid_value == nil) ||
	   (self.graph_color_low_value == nil) ||
	   (self.graph_display_current_value == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) ||
	   (self.graph_log_scale_enabled == TIBLE_SENSOR_NOT_INITIALIZED_VALUE) )
		
	{
		retVal = NO;
		return retVal;
	}
	
	return retVal;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        [self setSettingName:[aDecoder decodeObjectForKey:kSettingName]];

        [self setCalibrationValue:[aDecoder decodeFloatForKey:kSensorProfileSettingCalibrationKey]];
		[self setShortCaption:[aDecoder decodeObjectForKey:kSensorProfileSettingShortDescriptionCaptionKey]];
		
        [self setFormula_sub_x_0:[aDecoder decodeFloatForKey:kSensorProfileSettingFormulaSubX0Key]];
        [self setFormula_denom_0:[aDecoder decodeFloatForKey:kSensorProfileSettingFormulaDenom0Key]];
        [self setFormula_num_0:[aDecoder decodeFloatForKey:kSensorProfileSettingFormulaNum0Key]];
        [self setFormula_denom_1:[aDecoder decodeFloatForKey:kSensorProfileSettingFormulaDenom1Key]];
		[self setFormula_scaling_factor_num:[aDecoder decodeFloatForKey:kSensorProfileSettingFormulaScalingFactorNumKey]];
		[self setFormula_scaling_factor_denom:[aDecoder decodeFloatForKey:kSensorProfileSettingFormulaScalingFactorDenomKey]];
        
        [self setGraph_title:[aDecoder decodeObjectForKey:kSensorProfileSettingGraphTitleKey]];
        [self setGraph_subTitle:[aDecoder decodeObjectForKey:kSensorProfileSettingGraphSubTitleKey]];
        [self setGraph_x_axis_caption:[aDecoder decodeObjectForKey:kSensorProfileSettingGraphXAxisCaptionKey]];
        [self setGraph_y_axis_caption:[aDecoder decodeObjectForKey:kSensorProfileSettingGraphYAxisCaptionKey]];
		
        [self setGraph_y_axis_display_min:[aDecoder decodeFloatForKey:kSensorProfileSettingGraphYAxisDisplayMinKey]];
        [self setGraph_y_axis_display_max:[aDecoder decodeFloatForKey:kSensorProfileSettingGraphYAxisDisplayMaxKey]];
        
        [self setGraph_color_top_mid_boundary:[aDecoder decodeFloatForKey:kSensorProfileSettingGraphColorTopMidBoundaryKey]];
        [self setGraph_color_mid_low_boundary:[aDecoder decodeFloatForKey:kSensorProfileSettingGraphColorMidLowBoundaryKey]];
        
        [self setGraph_color_top_value:[aDecoder decodeObjectForKey:kSensorProfileSettingGraphColorTopValueKey]];
        [self setGraph_color_mid_value:[aDecoder decodeObjectForKey:kSensorProfileSettingGraphColorMidValueKey]];
        [self setGraph_color_low_value:[aDecoder decodeObjectForKey:kSensorProfileSettingGraphColorLowValueKey]];
        
        [self setGraph_display_current_value:[aDecoder decodeBoolForKey:kSensorProfileSettingGraphDisplayCurrentValueKey]];
        [self setGraph_log_scale_enabled:[aDecoder decodeBoolForKey:kSensorProfileSettingGraphLogScaleEnabledKey]];
        
        [self setConfig_op_mode:[aDecoder decodeFloatForKey:kSensorProfileSettingConfigOpModeKey]];
        [self setConfig_TIA_gain:[aDecoder decodeFloatForKey:kSensorProfileSettingConfigTIAGainKey]];
        [self setConfig_R_load:[aDecoder decodeFloatForKey:kSensorProfileSettingConfigRLoadKey]];
        [self setConfig_internal_zero:[aDecoder decodeFloatForKey:kSensorProfileSettingConfigInternalZeroKey]];
        [self setConfig_reference_voltage_source:[aDecoder decodeFloatForKey:kSensorProfileSettingConfigReferenceVoltageSourceKey]];
    }
    
    return self;
}

- (BOOL) isFormulaReady{
	
	BOOL retVal = YES;
	
	if(self.calibrationValue == TIBLE_SENSOR_NOT_INITIALIZED_VALUE ||
	   self.graph_y_axis_display_min == TIBLE_SENSOR_NOT_INITIALIZED_VALUE ||
	   self.graph_y_axis_display_max == TIBLE_SENSOR_NOT_INITIALIZED_VALUE ||
	   self.formula_sub_x_0 == TIBLE_SENSOR_NOT_INITIALIZED_VALUE ||
	   self.formula_denom_0 == TIBLE_SENSOR_NOT_INITIALIZED_VALUE ||
	   self.formula_denom_1 == TIBLE_SENSOR_NOT_INITIALIZED_VALUE ||
	   self.formula_num_0 == TIBLE_SENSOR_NOT_INITIALIZED_VALUE ||
	   self.formula_scaling_factor_num == TIBLE_SENSOR_NOT_INITIALIZED_VALUE ||
	   self.formula_scaling_factor_denom == TIBLE_SENSOR_NOT_INITIALIZED_VALUE){
		
		retVal = NO;
	}
	
	return retVal;
}

- (NSString *) sensorTypeDescription{
	
	return self.shortCaption;
}

#pragma mark - Formula Constants

-(void) setSensor_Denom_0_Characteristic: (TIBLERawDataModel *) value{
    
	int32_t intValue = [value int32Value];
    float_t denom_0 = ((float_t)intValue / TIBLE_SENSOR_FORMULA_CONSTANT_MULTIPLICATION_FACTOR);
	
	//denominator can't be 0.
	if(denom_0 == 0){
		denom_0 = TIBLE_SENSOR_DEFAULT_DENOMINATOR_VALUE;
	}
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Formula Denom 0\" to %.2f\n", denom_0];
    [self setFormula_denom_0:denom_0];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Num_0_Characteristic: (TIBLERawDataModel *) value{

	int32_t intValue = [value int32Value];
    float_t num_0 = ((float_t)intValue / TIBLE_SENSOR_FORMULA_CONSTANT_MULTIPLICATION_FACTOR);

	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Formula Num 0\" to %.2f\n", num_0];
    [self setFormula_num_0:num_0];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Sub_X_0_Characteristic: (TIBLERawDataModel *) value{
    
	int32_t intValue = [value int32Value];
    float_t sub_x_0 = ((float_t)intValue / TIBLE_SENSOR_FORMULA_CONSTANT_MULTIPLICATION_FACTOR);

	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Formula Sub X 0\" to %.2f\n", sub_x_0];
	
    [self setFormula_sub_x_0:sub_x_0];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Denom_1_Characteristic: (TIBLERawDataModel *) value{
    
	int32_t intValue = [value int32Value];
    float_t denom_1 = ((float_t)intValue / TIBLE_SENSOR_FORMULA_CONSTANT_MULTIPLICATION_FACTOR);

	//denominator can't be 0.
	if(denom_1 == 0){
		denom_1 = TIBLE_SENSOR_DEFAULT_DENOMINATOR_VALUE;
	}
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Formula Denom 1\" to %.2f\n", denom_1];
	
    [self setFormula_denom_1:denom_1];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Scaling_Factor_Num_Characteristic: (TIBLERawDataModel *) value{
	
	float_t floatValue = (float_t) [value int32Value];
	
	//scaling factor is 0, make it 1 which does nothing.
	if(floatValue == 0){
		floatValue = TIBLE_SENSOR_DEFAULT_DENOMINATOR_VALUE;
	}
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Formula Scaling Factor Num\" to %f\n", floatValue];
	
    [self setFormula_scaling_factor_num:floatValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Scaling_Factor_Denom_Characteristic: (TIBLERawDataModel *) value{
	
	float_t floatValue = (float_t) [value int32Value];
	
	//scaling factor is 0, make it 1 which does nothing.
	if(floatValue == 0){
		floatValue = 1;
	}
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Formula Scaling Factor Denom\" to %f\n", floatValue];
	
    [self setFormula_scaling_factor_denom:floatValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

#pragma mark - Graph Display Settings

-(void) setSensor_Graph_Title_Characteristic: (TIBLERawDataModel *) value{

	NSString * tmpStr = [value stringValue];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Graph Title to\" to \"%@\"\n", tmpStr];
	
	[self setGraph_title:tmpStr];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Graph_SubTitle_Characteristic: (TIBLERawDataModel *) value{
    
	NSString * tmpStr = [value stringValue];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Graph SubTitle to\" to \"%@\"\n", tmpStr];
	
	[self setGraph_subTitle:tmpStr];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Graph_X_Axis_Caption_Characteristic: (TIBLERawDataModel *) value{
    
	NSString * tmpStr = [value stringValue];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Graph X Axis Caption\" to \"%@\"\n", tmpStr];
	
	[self setGraph_x_axis_caption:tmpStr];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Graph_Y_Axis_Caption_Characteristic: (TIBLERawDataModel *) value{
    
	NSString * tmpStr = [value stringValue];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Graph Y Axis Caption\" to \"%@\"\n", tmpStr];
	
	[self setGraph_y_axis_caption:tmpStr];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Graph_Y_Axis_Display_Min_Characteristic: (TIBLERawDataModel *) value{
	
	uint32_t uintValue = (uint32_t) [value uint16Value];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Graph Y Axis Display Min\" to %d\n", uintValue];
	
	[self setGraph_y_axis_display_min:uintValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Graph_Y_Axis_Display_Max_Characteristic: (TIBLERawDataModel *) value{
	
	uint32_t uintValue = (uint32_t) [value uint16Value];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Graph Y Axis Display Max\" to %d\n", uintValue];
	
	[self setGraph_y_axis_display_max:uintValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Graph_Color_Top_Mid_Boundary_Characteristic: (TIBLERawDataModel *) value{
	
	uint32_t uintValue = (uint32_t) [value uint16Value];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Graph Y Axis Top-Mid Boundary\" to %d\n", uintValue];
	
	[self setGraph_color_top_mid_boundary:uintValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Graph_Color_Mid_Low_Boundary_Characteristic: (TIBLERawDataModel *) value{
	
	uint32_t uintValue = (uint32_t) [value uint16Value];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Graph Y Axis Mid-Low Boundary\" to %d\n", uintValue];
	
	[self setGraph_color_mid_low_boundary:uintValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Graph_Color_Top_Value_Characteristic: (TIBLERawDataModel *) value{
	
	uint32_t uintValue = [value uint32Value];
	
	UIColor * color = [TIBLEUtilities colorFromIntARGB4444Value: uintValue];

	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Graph Y Axis Top Band Color\" to %@\n", [color description]];
	
	[self setGraph_color_top_value:color];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Graph_Color_Mid_Value_Characteristic: (TIBLERawDataModel *) value{
	
	uint32_t uintValue = [value uint32Value];
	
	UIColor * color = [TIBLEUtilities colorFromIntARGB4444Value: uintValue];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Graph Y Axis Mid Band Color\" to %@\n", [color description]];
	
	[self setGraph_color_mid_value:color];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Graph_Color_Low_Value_Characteristic: (TIBLERawDataModel *) value{

	uint32_t untValue = [value uint32Value];
	
	UIColor * color = [TIBLEUtilities colorFromIntARGB4444Value: untValue];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Graph Y Axis Low Band Color\" to %@\n", [color description]];
	
	[self setGraph_color_low_value:color];
	
	[self checkIfAllCharacteristicsAreRead];
}

#pragma mark - Graph Display Options


-(void) setSensor_Graph_Display_Current_Value_Characteristic: (TIBLERawDataModel *) value{
	
	uint32_t uintValue = (uint32_t) [value uint8Value];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Graph Display Current Value\" to %@\n", uintValue?@"YES":@"NO"];
	
	[self setGraph_display_current_value:uintValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Graph_Log_Scale_Characteristic: (TIBLERawDataModel *) value{
    
	uint32_t uintValue = (uint32_t) [value uint8Value];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Graph Display Log Scale\" to %@\n", uintValue?@"YES":@"NO"];
	
	[self setGraph_log_scale_enabled:uintValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

#pragma mark - Sensor General

-(void) setSensor_Type_Characteristic: (TIBLERawDataModel *) value{
	
	uint32_t uintValue = (uint32_t) [value uint8Value];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Sensor Type\" to %d\n", uintValue];
	
	[self setSensorType:uintValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Calibration_Value_Characteristic: (TIBLERawDataModel *) value{
	
	float_t floatValue = (float_t) [value int32Value];
	
	if(floatValue != TIBLE_SENSOR_DO_NOT_CALIBRATE_VALUE){
		
		floatValue = (floatValue / TIBLE_SENSOR_FORMULA_CONSTANT_MULTIPLICATION_FACTOR);
		
		[TIBLELogger info:@"TIBLESensorProfile - Setting \"Calibration Value\" to %.2f\n", floatValue];
	}
	else{
		[TIBLELogger info:@"TIBLESensorProfile - Setting \"Calibration Value\" to DO_NOT_CALIBRATE\n"];
	}
	
	[self setCalibrationValue:floatValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Short_Caption_Characteristic: (TIBLERawDataModel *) value{
	
	NSString * tmpStr = [value stringValue];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Short Caption\" to \"%@\"\n", tmpStr];
	
	[self setShortCaption:tmpStr];
	
	[self checkIfAllCharacteristicsAreRead];
}

#pragma mark - Sensor Configuration

-(void) setSensor_Config_Op_Mode_Characteristic: (TIBLERawDataModel *) value{ //done
    
	uint32_t uintValue = (uint32_t) [value uint8Value];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Configuration Op Mode\" to %d\n", uintValue];
	
	[self setConfig_op_mode:uintValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Config_TIA_Gain_Characteristic: (TIBLERawDataModel *) value{
    
	uint32_t uintValue = (uint32_t) [value uint8Value];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Configuration TIA Gain\" to %d\n", uintValue];
	
	[self setConfig_TIA_gain:uintValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Config_R_Load_Characteristic: (TIBLERawDataModel *) value{
    
	uint32_t uintValue = (uint32_t) [value uint8Value];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Configuration R Load\" to %d\n", uintValue];
	
	[self setConfig_R_load:uintValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Config_Internal_Zero_Characteristic: (TIBLERawDataModel *) value{
	
	uint32_t uintValue = (uint32_t) [value uint8Value];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Internal Zero\" to %d\n", uintValue];
	
	[self setConfig_internal_zero:uintValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

-(void) setSensor_Config_Reference_Voltage_Source_Characteristic: (TIBLERawDataModel *) value{

	uint32_t uintValue = (uint32_t) [value uint8Value];
	
	[TIBLELogger info:@"TIBLESensorProfile - Setting \"Reference Voltage Source\" to %d\n", uintValue];
	
	[self setConfig_reference_voltage_source:uintValue];
	
	[self checkIfAllCharacteristicsAreRead];
}

- (void) sendNotificationAllCharacterisicsAreRead{
	
	[TIBLELogger info:@"TIBLESensorProfile - Sending Notification NOTIFICATION_BLE_CHARACTERISTICS_READING_ENDED.\n"];
	
	NSNotification * notif = [NSNotification notificationWithName:TIBLE_NOTIFICATION_BLE_CHARACTERISTICS_READING_ENDED
														   object:nil
														 userInfo:nil];
	
	[[NSNotificationCenter defaultCenter] postNotification:notif];
}

- (void) checkIfAllCharacteristicsAreRead{
	
	if([self areAllCharacteristicsRead]){
		[self sendNotificationAllCharacterisicsAreRead];
	}
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\ncalibration value %f\n x0: %f\n d0: %f\n graph title: %@\n graph subtitle: %@\n color top value %@",
			self.calibrationValue,
			self.formula_sub_x_0,
			self.formula_denom_0,
			self.graph_title,
			self.graph_subTitle,
			self.graph_color_top_value];
}

- (BOOL) doesSensorCalibrate{

	BOOL requiresCalibration = (self.calibrationValue != TIBLE_SENSOR_DO_NOT_CALIBRATE_VALUE)?YES:NO;
	
	return requiresCalibration;
}
	
@end
