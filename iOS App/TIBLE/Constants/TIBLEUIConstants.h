/*
 *  TIBLEUIConstants.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#ifndef TIBLE_TIBLEUIConstants_h
#define TIBLE_TIBLEUIConstants_h

//BLE
__unused  static NSString * TIBLE_NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED = @"kSensorUpdateCharacteristicValueUpdated";
__unused  static NSString * TIBLE_NOTIFICATION_UPDATE_MEASUREMENT_SAMPLE_RECEIVED = @"kSensorUpdateMeasurementSampleReceived";
__unused  static NSString * TIBLE_NOTIFICATION_UPDATE_MEASUREMENT_SAMPLE_RECEIVED_USER_INFO_KEY = @"kSensorUpdateMeasurementSampleReceivedUserInfoKey";
__unused  static NSString * TIBLE_NOTIFICATION_UPDATE_DEVICE_LIST = @"kSensorUpdateDeviceList";
__unused  static NSString * TIBLE_NOTIFICATION_UPDATE_CONNECTED_SENSOR_CHANGED = @"kSensorUpdateConnectedSensorChanged";
__unused  static NSString * TIBLE_NOTIFICATION_BLE_CHARACTERISTICS_READING_STARTED = @"kSensorCharacteristicsReadingStarted";
__unused  static NSString * TIBLE_NOTIFICATION_BLE_CHARACTERISTICS_READING_ENDED = @"kSensorAllCharacteristicsReadingEnded";
__unused  static NSString * TIBLE_NOTIFICATION_BLE_RECEIVING_SAMPLES = @"kSensorAlreadyHasReceivedSamples";
__unused  static NSString * TIBLE_NOTIFICATION_BLE_SCANNING = @"kSensorBLEScanning";
__unused  static NSString * TIBLE_NOTIFICATION_BLE_CONNECTING = @"kSensorBLEConnecting";
__unused  static NSString * TIBLE_NOTIFICATION_BLE_CALIBRATION_STARTED = @"kSensorCalibrationStarted";
__unused  static NSString * TIBLE_NOTIFICATION_BLE_CALIBRATION_ENDED = @"kSensorCalibrationEnded";

//UI
__unused  static NSString * TIBLE_APP_FONT_NAME = @"Avenir";
__unused  static float_t TIBLE_APP_FONT_H1_HEADER_SIZE = 22.0f;
__unused  static float_t TIBLE_APP_FONT_H2_HEADER_SIZE = 18.0f;
__unused  static float_t TIBLE_APP_FONT_H3_HEADER_SIZE = 17.0f;
__unused  static float_t TIBLE_APP_FONT_NORMAL_SIZE = 12.0f;
__unused  static float_t TIBLE_APP_FONT_GRAPH_ANNOTATION_SIZE = 12.0f;

__unused  static float_t TIBLE_UI_COMPONENT_VISIBLE_ALPHA = 1.0f;
__unused  static float_t TIBLE_UI_COMPONENT_INVISIBLE_ALPHA = 0.0f;

__unused  static NSString * TIBLE_SHOW_SETTINGS_IDENTIFIER = @"show_settings";

__unused  static NSString * TIBLE_UI_COMPONENT_DASHBOARD_VC_IDENTIFIER = @"Dashboard";
__unused  static NSString * TIBLE_UI_COMPONENT_MAIN_VC_IDENTIFIER = @"Main";
__unused  static NSString * TIBLE_UI_COMPONENT_GRAPH_VC_IDENTIFIER = @"Graph";
__unused  static NSString * TIBLE_UI_COMPONENT_CONNECT_VC_IDENTIFIER = @"Connect";
__unused  static NSString * TIBLE_UI_COMPONENT_SETTINGS_VC_IDENTIFIER = @"Settings";
__unused  static NSString * TIBLE_UI_COMPONENT_INFO_VC_IDENTIFIER = @"Info";
__unused  static NSString * TIBLE_UI_COMPONENT_NO_SENSOR_VC_IDENTIFIER = @"NoSensorAvailable";
__unused  static NSString * TIBLE_UI_COMPONENT_SHARE_VC_IDENTIFIER = @"Share";
__unused  static NSString * TIBLE_UI_COMPONENT_LOADING_VC_IDENTIFIER = @"Loading";

__unused static NSString * TIBLE_COPYRIGHTS_IDENTIFIER = @"Copyrights";
__unused static NSString * TIBLE_COPYRIGHTS_ALERT_WINDOW = @"TIBLECopyrightAlertWindow";
__unused static NSString * TIBLE_ABOUT_IDENTIFIER = @"About";
__unused static NSString * TIBLE_ABOUT_ALERT_WINDOW = @"TIBLEAboutAlertWindow";

#define DISPLAY_LABEL_SCIENTIFIC_NOTATION_MAX_THRESHOLD 1000.0f
#define DISPLAY_LABEL_SCIENTIFIC_NOTATION_MIN_THRESHOLD 0.1f

#endif
