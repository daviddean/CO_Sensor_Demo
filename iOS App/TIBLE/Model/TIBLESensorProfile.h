/*
 *  TIBLESensorProfile.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import "TIBLERawDataModel.h"
#import "TIBLESensorConstants.h"

@interface TIBLESensorProfile : NSObject <NSCoding>

@property (nonatomic, copy) NSString *settingName;

//signed, 4 bytes.
@property (nonatomic, assign) float_t calibrationValue; //(x 100)
//unsigned, 1 byte
@property (nonatomic, assign) TIBLE_Sensor_Type sensorType; //O2 is 1, CO2 is 2.
//string
@property (nonatomic, strong) NSString * shortCaption;

//signed, 4 bytes.
@property (nonatomic, assign) float_t formula_denom_0;
@property (nonatomic, assign) float_t formula_num_0;
@property (nonatomic, assign) float_t formula_sub_x_0;
@property (nonatomic, assign) float_t formula_denom_1;
@property (nonatomic, assign) float_t formula_scaling_factor_num;
@property (nonatomic, assign) float_t formula_scaling_factor_denom;

//strings, var length
@property (nonatomic, strong) NSString * graph_title; //14 bytes
@property (nonatomic, strong) NSString * graph_subTitle; //nil Error
@property (nonatomic, strong) NSString * graph_x_axis_caption; //16 bytes
@property (nonatomic, strong) NSString * graph_y_axis_caption; //nil Error

//unsigned, 4 bytes, ARGB4444
@property (nonatomic, strong) UIColor * graph_color_top_value;
@property (nonatomic, strong) UIColor * graph_color_mid_value;
@property (nonatomic, strong) UIColor * graph_color_low_value;

//unsigned, 1 byte
@property (nonatomic, assign) TIBLE_Graph_Display_Current_Value graph_display_current_value;
@property (nonatomic, assign) TIBLE_Graph_Display_Using_Logarithmic_Scale graph_log_scale_enabled;

//unsigned int, 2 bytes
@property (nonatomic, assign) float_t graph_y_axis_display_min;
@property (nonatomic, assign) float_t graph_y_axis_display_max;
@property (nonatomic, assign) float_t graph_color_top_mid_boundary;
@property (nonatomic, assign) float_t graph_color_mid_low_boundary;

//unsigned, 1 byte
@property (nonatomic, assign) TIBLE_Config_Op_Mode config_op_mode;
@property (nonatomic, assign) TIBLE_Config_TIA_Gain config_TIA_gain;
@property (nonatomic, assign) TIBLE_Config_R_Load config_R_load;
@property (nonatomic, assign) TIBLE_Config_Internal_Zero config_internal_zero;
@property (nonatomic, assign) TIBLE_Config_Reference_Voltage_Source config_reference_voltage_source;

- (NSString *) sensorTypeDescription;

- (BOOL) doesSensorCalibrate;
- (BOOL) areAllCharacteristicsRead;
- (BOOL) isFormulaReady;

-(void) setSensor_Calibration_Value_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Type_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Short_Caption_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Denom_0_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Num_0_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Sub_X_0_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Denom_1_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Scaling_Factor_Num_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Scaling_Factor_Denom_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Graph_Title_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Graph_SubTitle_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Graph_X_Axis_Caption_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Graph_Y_Axis_Caption_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Graph_Y_Axis_Display_Min_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Graph_Y_Axis_Display_Max_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Graph_Color_Top_Mid_Boundary_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Graph_Color_Mid_Low_Boundary_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Graph_Color_Top_Value_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Graph_Color_Mid_Value_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Graph_Color_Low_Value_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Graph_Display_Current_Value_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Graph_Log_Scale_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Config_Op_Mode_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Config_TIA_Gain_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Config_R_Load_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Config_Internal_Zero_Characteristic: (TIBLERawDataModel *) value;
-(void) setSensor_Config_Reference_Voltage_Source_Characteristic: (TIBLERawDataModel *) value;

@end
