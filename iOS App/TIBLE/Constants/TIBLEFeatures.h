/*
 *  TIBLEFeatures.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#ifndef TIBLE_TIBLEFeatures_h
#define TIBLE_TIBLEFeatures_h

//keep enabled for release
__unused static const BOOL TIBLE_FEATURE_ENABLE_NO_SENSOR_AVAILABLE_UI = YES;
__unused static const BOOL TIBLE_FEATURE_ENABLE_SETTINGS = YES;
__unused static const BOOL TIBLE_FEATURE_ENABLE_CALIBRATION_DISPLAY = YES;
__unused static const BOOL TIBLE_FEATURE_ENABLE_SENSOR_PICKER_DIALOG = YES;
__unused static const BOOL TIBLE_FEATURE_ENABLE_APP_RUNNNING_IN_BACKGROUND = YES;
__unused static const BOOL TIBLE_FEATURE_ENABLE_SHARE_ACTIVITY_VIEW_CONTROLLER = YES;

__unused static const BOOL TIBLE_FEATURE_ENABLE_LOGS_DEVICE_MANAGER = YES;
__unused static const BOOL TIBLE_FEATURE_ENABLE_LOGS_BLUETOOTH = YES;

//for debugging purposes, enable.
__unused static const BOOL TIBLE_DEBUG_SIMULATE_SENSOR_WITH_NO_UUID = NO; //this can be accomplish by resetting settings on device.
__unused static const BOOL TIBLE_DEBUG_PRINT_DISCOVERED_PERIPHERALS_ON_REFRESH = NO;

#endif
