//******************************************************************************
//  Description:  This file contains functions that allow the CC2541 device to
//  access the I2C interface of the LMP91000, by using the OSAL I2C HAL. 
// 
//   Texas Instruments Inc.
//   October 2012
//******************************************************************************
// Change Log:
//******************************************************************************
// Version:  1.00
// Comments: Initial Release Version
//******************************************************************************

/* 
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
  PROVIDED �AS IS� WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
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

extern uint8 lmp91kOK; // Set to 0 if we have difficulty talking to the LMP91000
extern uint8 lmp91KinitComplete; // Set to 1 when init is completed

#ifdef __cplusplus
extern "C"
{
#endif
void LMP91000_I2CWriteReg(unsigned char device_i2c_address, unsigned char reg_address , unsigned char data);
unsigned char LMP91000_I2CReadReg(unsigned char device_i2c_address, unsigned char reg_address);
unsigned char LMP91000_I2CWriteAndConfirmReg(unsigned char device_i2c_address, unsigned char reg_address , unsigned char data);
unsigned char LMP91000_I2CSetMode(unsigned char device_i2c_address, unsigned char newmode);
unsigned char LMP91000_I2CInitialSetup(unsigned char tia_gain, unsigned char  r_load, 
                                       unsigned char ref_source, unsigned char internal_zero,
                                       unsigned char op_mode);
unsigned char LMP91000_I2CSwitchVoutToO2Sensor(unsigned char op_mode);
unsigned char LMP91000_I2CSwitchVoutToTempSensor(void);
unsigned char LMP91000_I2CConfigureForO2Sensor(unsigned char tia_gain, unsigned char r_load, 
                                               unsigned char ref_source, unsigned char internal_zero);


#ifdef __cplusplus
}
#endif
