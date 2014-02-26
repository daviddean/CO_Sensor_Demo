/**************************************************************************************************
  Filename:       hiddev.h
  Revised:        $Date: 2011-11-10 15:29:40 -0800 (Thu, 10 Nov 2011) $
  Revision:       $Revision: 53 $

  Description:    This file contains the common HID Device profile.

 Copyright 2011 Texas Instruments Incorporated. All rights reserved.

  IMPORTANT: Your use of this Software is limited to those specific rights
  granted under the terms of a software license agreement between the user
  who downloaded the software, his/her employer (which must be your employer)
  and Texas Instruments Incorporated (the "License").  You may not use this
  Software unless you agree to abide by the terms of the License. The License
  limits your use, and you acknowledge, that the Software may not be modified,
  copied or distributed unless embedded on a Texas Instruments microcontroller
  or used solely and exclusively in conjunction with a Texas Instruments radio
  frequency transceiver, which is integrated into your product.  Other than for
  the foregoing purpose, you may not use, reproduce, copy, prepare derivative
  works of, modify, distribute, perform, display or sell this Software and/or
  its documentation for any purpose.

  YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
  PROVIDED “AS IS” WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
  INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
  NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
  TEXAS INSTRUMENTS OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT,
  NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER
  LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
  INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE
  OR CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT
  OF SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
  (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.

  Should you have any questions regarding your right to use this Software,
  contact Texas Instruments Incorporated at www.TI.com.
**************************************************************************************************/

#ifndef HIDDEV_H
#define HIDDEV_H

#include "hid_uuid.h"

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

// HID read/write operation
#define HID_DEV_OPER_WRITE       0  // Write operation
#define HID_DEV_OPER_READ        1  // Read operation
#define HID_DEV_OPER_ENABLE      2  // Notification enabled for report ID
#define HID_DEV_OPER_DISABLE     3  // Notifications disabled for report ID

// HID callback events
#define HID_DEV_SUSPEND_EVT      0  // HID suspend
#define HID_DEV_EXIT_SUSPEND_EVT 1  // HID exit suspend
#define HID_DEV_SET_BOOT_EVT     2  // HID set boot mode
#define HID_DEV_SET_REPORT_EVT   3  // HID set report mode
  
/*********************************************************************
 * TYPEDEFS
 */

// HID report mapping table
typedef struct
{
  uint16    handle;           // Handle of report characteristic
  uint16    cccdHandle;       // Handle of CCCD for report characteristic
  uint8     id;               // Report ID
  uint8     type;             // Report type
  uint8     mode;             // Protocol mode (report or boot)
} hidRptMap_t;

// HID dev configuration structure
typedef struct
{
  uint16    idleTimeout;      // Idle timeout in milliseconds
  uint8     hidFlags;         // HID feature flags
  
} hidDevCfg_t;

/*********************************************************************
 * Global Variables
 */

// These variables are defined in the service .c file that uses HID Dev

// HID report map length
extern uint8 hidReportMapLen;

// HID protocol mode
extern uint8 hidProtocolMode;

/*********************************************************************
 * Profile Callbacks
 */
 
// HID Report callback
typedef uint8 (*hidDevReportCB_t)( uint8 id, uint8 type, uint8 oper,
                                   uint8 *pLen, uint8 *pData );

// HID event callback
typedef void (*hidDevEvtCB_t)( uint8 evt );

typedef struct
{
  hidDevReportCB_t  reportCB;
  hidDevEvtCB_t     evtCB;
} hidDevCB_t;

/*********************************************************************
 * @fn      HidDev_Init
 *
 * @brief   Initialization function for the Hid Dev Task.
 *          This is called during initialization and should contain
 *          any application specific initialization (ie. hardware
 *          initialization/setup, table initialization, power up
 *          notificaiton ... ).
 *
 * @param   task_id - the ID assigned by OSAL.  This ID should be
 *                    used to send messages and set timers.
 *
 * @return  none
 */
extern void HidDev_Init( uint8 task_id );

/*********************************************************************
 * @fn      HidDev_ProcessEvent
 *
 * @brief   Hid Dev Task event processor.  This function
 *          is called to process all events for the task.  Events
 *          include timers, messages and any other user defined events.
 *
 * @param   task_id  - The OSAL assigned task ID.
 * @param   events - events to process.  This is a bit map and can
 *                   contain more than one event.
 *
 * @return  events not processed
 */
extern uint16 HidDev_ProcessEvent( uint8 task_id, uint16 events );

/*********************************************************************
 * @fn      HidDev_Register
 *
 * @brief   Register a callback function with HID Dev.
 *
 * @param   pCfg - Parameter configuration.
 * @param   pCBs - Callback function.
 *
 * @return  None.
 */
extern void HidDev_Register( hidDevCfg_t *pCfg, hidDevCB_t *pCBs );

/*********************************************************************
 * @fn      HidDev_RegisterReports
 *
 * @brief   Register the report table with HID Dev.
 *
 * @param   numReports - Length of report table.
 * @param   pRpt - Report table.
 *
 * @return  None.
 */
extern void HidDev_RegisterReports( uint8 numReports, hidRptMap_t *pRpt );

/*********************************************************************
 * @fn      HidDev_Report
 *
 * @brief   Send a HID report.
 *
 * @param   id - HID report ID.
 * @param   type - HID report type.
 * @param   len - Length of report.
 * @param   pData - Report data.
 *
 * @return  None.
 */
extern void HidDev_Report( uint8 id, uint8 type, uint8 len, uint8 *pData );

/*********************************************************************
 * @fn      HidDev_Close
 *
 * @brief   Close the connection or stop advertising.
 *
 * @return  None.
 */
extern void HidDev_Close( void );

/*********************************************************************
 * @fn      HidDev_SetParameter
 *
 * @brief   Set a HID Dev parameter.
 *
 * @param   param - Profile parameter ID
 * @param   len - length of data to right
 * @param   value - pointer to data to write.  This is dependent on
 *          the parameter ID and WILL be cast to the appropriate 
 *          data type (example: data type of uint16 will be cast to 
 *          uint16 pointer).
 *
 * @return  bStatus_t
 */
extern bStatus_t HidDev_SetParameter( uint8 param, uint8 len, void *value );
  
/*********************************************************************
 * @fn      HidDev_GetParameter
 *
 * @brief   Get a HID Dev parameter.
 *
 * @param   param - Profile parameter ID
 * @param   value - pointer to data to get.  This is dependent on
 *          the parameter ID and WILL be cast to the appropriate 
 *          data type (example: data type of uint16 will be cast to 
 *          uint16 pointer).
 *
 * @return  bStatus_t
 */
extern bStatus_t HidDev_GetParameter( uint8 param, void *value );

/*********************************************************************
 * @fn          HidDev_ReadAttrCB
 *
 * @brief       HID Dev attribute read callback.
 *
 * @param       connHandle - connection message was received on
 * @param       pAttr - pointer to attribute
 * @param       pValue - pointer to data to be read
 * @param       pLen - length of data to be read
 * @param       offset - offset of the first octet to be read
 * @param       maxLen - maximum length of data to be read
 *
 * @return      Success or Failure
 */
extern uint8 HidDev_ReadAttrCB( uint16 connHandle, gattAttribute_t *pAttr, 
                                uint8 *pValue, uint8 *pLen, uint16 offset, uint8 maxLen );

/*********************************************************************
 * @fn      HidDev_WriteAttrCB
 *
 * @brief   HID Dev attribute read callback.
 *
 * @param   connHandle - connection message was received on
 * @param   pAttr - pointer to attribute
 * @param   pValue - pointer to data to be written
 * @param   len - length of data
 * @param   offset - offset of the first octet to be written
 * @param   complete - whether this is the last packet
 * @param   oper - whether to validate and/or write attribute value  
 *
 * @return  Success or Failure
 */
extern bStatus_t HidDev_WriteAttrCB( uint16 connHandle, gattAttribute_t *pAttr,
                                     uint8 *pValue, uint8 len, uint16 offset );

/*********************************************************************
*********************************************************************/

#ifdef __cplusplus
}
#endif

#endif /* HIDDEV_H */
