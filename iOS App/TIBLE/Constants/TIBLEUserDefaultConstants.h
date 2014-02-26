/*
 *  TIBLEUserDefaultConstants.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#ifndef TIBLE_TIBLEUserDefaultConstants_h
#define TIBLE_TIBLEUserDefaultConstants_h

//setting name / index
__unused static NSString *kSettingName = @"settingName";
__unused static NSString *kSelectedSettingIndexKey = @"selected_setting_index";

//sensor info
__unused static NSString *kSensorProfileSettingShortDescriptionCaptionKey = @"shortCaption";
__unused static NSString *kSensorProfileSettingCalibrationKey = @"calibrationValue";

//sensor formula
__unused static NSString *kSensorProfileSettingFormulaDenom0Key = @"formula_denom_0";
__unused static NSString *kSensorProfileSettingFormulaDenom1Key = @"formula_denom_1";
__unused static NSString *kSensorProfileSettingFormulaNum0Key = @"formula_num_0";
__unused static NSString *kSensorProfileSettingFormulaSubX0Key = @"formula_sub_x_0";
__unused static NSString *kSensorProfileSettingFormulaScalingFactorNumKey = @"formula_scaling_factor_num";
__unused static NSString *kSensorProfileSettingFormulaScalingFactorDenomKey = @"formula_scaling_factor_denom";

//graph
__unused static NSString *kSensorProfileSettingGraphTitleKey = @"graph_title";
__unused static NSString *kSensorProfileSettingGraphSubTitleKey = @"graph_subTitle";
__unused static NSString *kSensorProfileSettingGraphXAxisCaptionKey = @"graph_x_axis_caption";
__unused static NSString *kSensorProfileSettingGraphYAxisCaptionKey = @"graph_y_axis_caption";
__unused static NSString *kSensorProfileSettingGraphYAxisDisplayMinKey = @"graph_y_axis_display_min";
__unused static NSString *kSensorProfileSettingGraphYAxisDisplayMaxKey = @"graph_y_axis_display_max";
__unused static NSString *kSensorProfileSettingGraphColorTopMidBoundaryKey = @"graph_color_top_mid_boundary";
__unused static NSString *kSensorProfileSettingGraphColorMidLowBoundaryKey = @"graph_color_mid_low_boundary";
__unused static NSString *kSensorProfileSettingGraphColorTopValueKey = @"graph_color_top_value";
__unused static NSString *kSensorProfileSettingGraphColorMidValueKey = @"graph_color_mid_value";
__unused static NSString *kSensorProfileSettingGraphColorLowValueKey = @"graph_color_low_value";
__unused static NSString *kSensorProfileSettingGraphDisplayCurrentValueKey = @"graph_display_current_value";
__unused static NSString *kSensorProfileSettingGraphLogScaleEnabledKey = @"graph_log_scale_enabled";

//sensor configuration
__unused static NSString *kSensorProfileSettingConfigOpModeKey = @"config_op_mode";
__unused static NSString *kSensorProfileSettingConfigTIAGainKey = @"config_TIA_gain";
__unused static NSString *kSensorProfileSettingConfigRLoadKey = @"config_R_load";
__unused static NSString *kSensorProfileSettingConfigInternalZeroKey = @"config_internal_zero";
__unused static NSString *kSensorProfileSettingConfigReferenceVoltageSourceKey = @"config_reference_voltage_source";

#endif