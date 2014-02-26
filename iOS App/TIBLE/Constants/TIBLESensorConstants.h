/*
 *  TIBLESensorConstants.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#ifndef TIBLE_TIBLESensorConstants_h
#define TIBLE_TIBLESensorConstants_h
#import <math.h>

__unused static NSString * TIBLE_SENSOR_SERVICE_UUID = @"2D8D";
__unused static NSString * TIBLE_SENSOR_COMMAND_CHARACTERISTIC_UUID = @"2DA7";
__unused static NSString * TIBLE_SENSOR_NOT_INITIALIZED_STRING = @"Not Initialized";

__unused static NSString * kSensorCommandCharacteristicKey = @"Sensor_Command_Characteristic";
__unused static NSString * kSavedSensorNamesKey = @"SavedSensorNames";

__unused static NSString * kAppEnteredBackgroundNotification = @"kAppServiceEnteredBackgroundNotification";
__unused static NSString * kAppEnteredForegroundNotification = @"kAppServiceEnteredForegroundNotification";

__unused static NSString *kSensorInputValidationBoundaryMin = @"kSensorInputValidationBoundaryMin";
__unused static NSString *kSensorInputValidationBoundaryMax = @"kSensorInputValidationBoundaryMax";
__unused static NSString *kSensorInputValidationBoundaryTopMid= @"kSensorInputValidationBoundaryMidTop";
__unused static NSString *kSensorInputValidationBoundaryMidLow = @"kSensorInputValidationBoundaryLowMid";
__unused static NSString *kSensorInputValidationBoundarySampleValue = @"kSensorInputValidationSampleValue";

#define TIBLE_SENSOR_CALIBRATION_TIMEOUT 20.0f //secs
#define TIBLE_CONNECTION_TIMEOUT 20.0f //secs
#define TIBLE_SCANNING_TIMEOUT 20.0f //secs
#define TIBLE_SENSOR_CALIBRATION_SAMPLES_AMOUNT 10

__unused static NSString * kStoredDevicesKey = @"StoredDevices";

#define TIBLE_SENSOR_REGISTER_FOR_SENSOR_COMMAND_NOTIFICATIONS 1

#define TIBLE_GRAPH_DISPLAY_LOG_SCALE_MIN 10 * pow(10, -20)

#define TIBLE_SENSOR_DO_NOT_CALIBRATE_VALUE -1
#define TIBLE_SENSOR_DO_NOT_SCALE_VALUE 0
#define TIBLE_SENSOR_NOT_INITIALIZED_VALUE nan("")

#define TIBLE_SENSOR_NUMBER_OF_BANDS 3.0f
#define TIBLE_SENSOR_DEFAULT_DENOMINATOR_VALUE 1.0f
#define TIBLE_SENSOR_DEFAULT_UNSIGNED_INTEGER_VALUE 0
#define TIBLE_SENSOR_FORMULA_CONSTANT_MULTIPLICATION_FACTOR 100.0f

#define OP_MODE_SHIFT  0
#define TIA_GAIN_SHIFT  2
#define R_LOAD_SHIFT  0
#define INT_Z_SHIFT  5
#define REF_SOURCE_SHIFT  7

typedef enum{
    OP_MODE_DEEP_SLEEP = (0 << OP_MODE_SHIFT),
    OP_MODE_2_LEAD = (1 << OP_MODE_SHIFT),
	OP_MODE_STANDBY = (2 << OP_MODE_SHIFT),
	OP_MODE_3_LEAD = (3 << OP_MODE_SHIFT),
	OP_MODE_TEMP_MEAS_TIA_OFF = (6 << OP_MODE_SHIFT),
	OP_MODE_TEMP_MEAS_TIoA_ON = (7 << OP_MODE_SHIFT)
}TIBLE_Config_Op_Mode;

typedef enum{ 
    TIA_GAIN_EXT_RESIST = (0 << TIA_GAIN_SHIFT),
    TIA_GAIN_EXT_2_75_OHM = (1 << TIA_GAIN_SHIFT),
	TIA_GAIN_EXT_3_5_OHM = (2 << TIA_GAIN_SHIFT),
	TIA_GAIN_EXT_7_OHM = (3 << TIA_GAIN_SHIFT),
	TIA_GAIN_EXT_14_OHM = (4 << TIA_GAIN_SHIFT),
	TIA_GAIN_EXT_35_OHM = (5 << TIA_GAIN_SHIFT),
	TIA_GAIN_EXT_120_OHM = (6 << TIA_GAIN_SHIFT),
	TIA_GAIN_EXT_350_OHM = (7 << TIA_GAIN_SHIFT)
}TIBLE_Config_TIA_Gain;

typedef enum{
    R_LOAD_10_OHM = (0 << R_LOAD_SHIFT),
    R_LOAD_30_OHM = (1 << R_LOAD_SHIFT),
	R_LOAD_50_OHM = (2 << R_LOAD_SHIFT),
	R_LOAD_100_OHM = (3 << R_LOAD_SHIFT)
}TIBLE_Config_R_Load;

typedef enum{
    INT_Z_SEL_20_PERCENT = (0 << INT_Z_SHIFT),
    INT_Z_SEL_50_PERCENT = (1 << INT_Z_SHIFT),
	INT_Z_SEL_67_PERCENT = (2 << INT_Z_SHIFT),
	INT_Z_SEL_BYPASS_PERCENT = (3 << INT_Z_SHIFT)
}TIBLE_Config_Internal_Zero;

typedef enum{
    REF_SOURCE_INTERNAL = (0 << REF_SOURCE_SHIFT),
	REF_SOURCE_EXTERNAL = (1 << REF_SOURCE_SHIFT)
}TIBLE_Config_Reference_Voltage_Source;

typedef enum{
	SENSOR_TYPE_UNKNOWN = 0,
    SENSOR_TYPE_O2 = 1,
    SENSOR_TYPE_CO = 2
}TIBLE_Sensor_Type;

typedef enum{
    GRAPH_DISPLAY_CURRENT_VALUE_NO = 0,
    GRAPH_DISPLAY_CURRENT_VALUE_YES = 1
}TIBLE_Graph_Display_Current_Value;

typedef enum{
    GRAPH_DISPLAY_USING_LOGARITHMIC_SCALE_NO = 0,
    GRAPH_DISPLAY_USING_LOGARITHMIC_SCALE_YES = 1
}TIBLE_Graph_Display_Using_Logarithmic_Scale;

#endif
