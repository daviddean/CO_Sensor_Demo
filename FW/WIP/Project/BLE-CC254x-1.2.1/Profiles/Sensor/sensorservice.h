/**************************************************************************************************
  Filename:       sensorservice.h
  Revised:        $Date $
  Revision:       $Revision $

  Description:    This file contains the Heart Rate service definitions and
                  prototypes.

**************************************************************************************************/

#ifndef SENSORSERVICE_H
#define SENSORSERVICE_H

#ifdef __cplusplus
extern "C"
{
#endif


/*********************************************************************
 * INCLUDES
 */

/*********************************************************************
 * CONSTANTS
 */

#define O2_SENSOR_TYPE                          1
#define CO_SENSOR_TYPE                          2    
    
 // Sensor Service Parameters
#define SENS_COMMAND_PARAM                      0
#define SENS_DENOM_0_PARAM                      1
#define SENS_NUM_0_PARAM                        2
#define SENS_SUB_X_0_PARAM                      3
#define SENS_DENOM_1_PARAM                      4
#define SENS_Y_AXIS_DISPLAY_MIN_PARAM           5
#define SENS_Y_AXIS_DISPLAY_MAX_PARAM           6
#define SENS_COLOR_BAND_TOP_MID_LEVEL_PARAM     7
#define SENS_COLOR_BAND_MID_LOW_LEVEL_PARAM     8
#define SENS_COLOR_BAND_TOP_LEVEL_COLOR_PARAM   9
#define SENS_COLOR_BAND_MID_LEVEL_COLOR_PARAM   10
#define SENS_COLOR_BAND_LOW_LEVEL_COLOR_PARAM   11
#define SENS_CALIBIRATION_VALUE_PARAM           12     
#define SENS_TYPE_PARAM                         13
#define SENS_TYPE_DISPLAY_CURRENT_VALUE_PARAM   14
#define SENS_GRAPH_LOG_SCALE_PARAM              15    
#define SENS_MODE_OP_PARAM                      16
#define SENS_TIA_GAIN_PARAM                     17
#define SENS_R_LOAD_PARAM                       18
#define SENS_INT_Z_SEL_PARAM                    19
#define SENS_REF_VOLTAGE_SOURCE_PARAM           20
#define SENS_SCALE_FACTOR_NUM_PARAM             21
#define SENS_SCALE_FACTOR_DENOM_PARAM           22
    
// Heart Rate Service UUIDs
#define SENS_SERV_UUID                          0x2D8D
#define SENS_COMMAND_UUID                       0x2DA7
#define SENS_DENOM_0_X_100_UUID                 0x2DA8
#define SENS_NUM_0_X_100_UUID                   0x2DA9
#define SENS_SUB_X_0_X_100_UUID                 0x2DAA
#define SENS_DENOM_1_X_100_UUID                 0x2DAB
#define SENS_GRAPH_TITLE_UUID                   0x2DAC
#define SENS_GRAPH_SUBTITLE_UUID                0x2DAD
#define SENS_GRAPH_X_AXIS_CAPTION_UUID          0x2DAE
#define SENS_GRAPH_Y_AXIS_CAPTION_UUID          0x2DAF
#define SENS_GRAPH_Y_AXIS_DISPLAY_MIN_UUID      0x2DB0
#define SENS_GRAPH_Y_AXIS_DISPLAY_MAX_UUID      0x2DB1
#define SENS_GRAPH_COLOR_TOP_MID_BOUNDARY_UUID  0x2DB2
#define SENS_GRAPH_COLOR_MID_LOW_BOUNDARY_UUID  0x2DB3
#define SENS_GRAPH_COLOR_TOP_VALUE_UUID         0x2DB4
#define SENS_GRAPH_COLOR_MID_VALUE_UUID         0x2DB5
#define SENS_GRAPH_COLOR_LOW_VALUE_UUID         0x2DB6
#define SENS_CALIBIRATION_VALUE_X_100_UUID      0x2DB7    
#define SENS_SENSOR_TYPE_UUID                   0x2DB8
#define SENS_DISPLAY_CURRENT_VALUE_UUID         0x2DB9    
#define SENS_GRAPH_LOG_SCALE_UUID               0x2DBA    
#define SENS_MODE_OP_UUID                       0x2DBB
#define SENS_TIA_GAIN_UUID                      0x2DBC
#define SENS_R_LOAD_UUID                        0x2DBD
#define SENS_INT_Z_SEL_UUID                     0x2DBE
#define SENS_REF_VOLTAGE_SOURCE_UUID            0x2DBF
#define SENS_SHORT_CAPTION_UUID                 0x2E00    
#define SENS_SCALE_FACTOR_NUM_UUID              0x2E01    
#define SENS_SCALE_FACTOR_DENOM_UUID            0x2E02

// ATT Error code
// Control point value not supported
#define SENS_ERR_NOT_SUP              0x80

// Value for command characteristic
#define SENS_COMMAND_ENERGY_EXP       0x01

// Heart Rate Service bit fields
#define SENS_SERVICE                  0x00000001

// Callback events
#define SENS_MEAS_NOTI_ENABLED        1
#define SENS_MEAS_NOTI_DISABLED       2
#define SENS_COMMAND_SET              3
#define SENS_HARDWARE_SET             4

#define SENS_RANGE_X_10               33           // 3.3 Volts
#define SENS_PRECISION_BITS           12          
    
/*********************************************************************
 * TYPEDEFS
 */

// Heart Rate Service callback function
typedef void (*sensServiceCB_t)(uint8 event);

/*********************************************************************
 * MACROS
 */

/*********************************************************************
 * Profile Callbacks
 */


/*********************************************************************
 * API FUNCTIONS 
 */

/*
 * HeartRate_AddService- Initializes the Heart Rate service by registering
 *          GATT attributes with the GATT server.
 *
 * @param   services - services to add. This is a bit map and can
 *                     contain more than one service.
 */

extern bStatus_t sens_AddService( uint32 services );

/*
 * HeartRate_Register - Register a callback function with the
 *          Heart Rate Service
 *
 * @param   pfnServiceCB - Callback function.
 */

extern void sens_Register( sensServiceCB_t pfnServiceCB );

/*
 * HeartRate_SetParameter - Set a Heart Rate parameter.
 *
 *    param - Profile parameter ID
 *    len - length of data to right
 *    value - pointer to data to write.  This is dependent on
 *          the parameter ID and WILL be cast to the appropriate 
 *          data type (example: data type of uint16 will be cast to 
 *          uint16 pointer).
 */
extern bStatus_t sens_SetParameter( uint8 param, uint8 len, void *value );
  
/*
 * HeartRate_GetParameter - Get a Heart Rate parameter.
 *
 *    param - Profile parameter ID
 *    value - pointer to data to write.  This is dependent on
 *          the parameter ID and WILL be cast to the appropriate 
 *          data type (example: data type of uint16 will be cast to 
 *          uint16 pointer).
 */
extern bStatus_t sens_GetParameter( uint8 param, void *value );

/*********************************************************************
 * @fn          HeartRate_MeasNotify
 *
 * @brief       Send a notification containing a heart rate
 *              measurement.
 *
 * @param       connHandle - connection handle
 * @param       pNoti - pointer to notification structure
 *
 * @return      Success or Failure
 */
extern bStatus_t sens_MeasNotify( uint16 connHandle, attHandleValueNoti_t *pNoti );

/*********************************************************************
 * @fn          HeartRate_HandleConnStatusCB
 *
 * @brief       Heart Rate Service link status change handler function.
 *
 * @param       connHandle - connection handle
 * @param       changeType - type of change
 *
 * @return      none
 */
extern void sens_HandleConnStatusCB( uint16 connHandle, uint8 changeType );

/*********************************************************************
*********************************************************************/

extern void get_SensHardwareSettings (uint8 *modeOp, uint8 *tiaGain, uint8 *rLoad, uint8 *refVoltageSource, uint8 *intZSel);


#ifdef __cplusplus
}
#endif

#endif /* SENSORSERVICE_H */
