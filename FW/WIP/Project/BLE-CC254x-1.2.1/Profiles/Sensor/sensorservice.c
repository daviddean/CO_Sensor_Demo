/**************************************************************************************************
  Filename:       heartrateservice.c
  Revised:        $Date $
  Revision:       $Revision $

  Description:    This file contains the Heart Rate sample service 
                  for use with the Heart Rate sample application.

**************************************************************************************************/

/*********************************************************************
 * INCLUDES
 */
#include "bcomdef.h"
#include "OSAL.h"
#include "linkdb.h"
#include "att.h"
#include "gatt.h"
#include "gatt_uuid.h"
#include "gattservapp.h"

#include "TI_LMP91000.h"
#include "sensorservice.h"

#if defined O2_SENSOR
#include "O2_Sensor_Settings.h"
#elif defined CO_SENSOR  
#include "CO_Sensor_Settings.h"
#endif


/*********************************************************************
 * MACROS
 */

/*********************************************************************
 * CONSTANTS
 */

// Position of heart rate measurement value in attribute array
// ???Where/how is this used? 
#define SENS_MEAS_VALUE_POS            2

/*********************************************************************
 * TYPEDEFS
 */

/*********************************************************************
 * GLOBAL VARIABLES
 */
// Sensor service
CONST uint8 sensServUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_SERV_UUID), HI_UINT16(SENS_SERV_UUID)
};

// Sensor measurement characteristic
CONST uint8 sensMeasUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_COMMAND_UUID), HI_UINT16(SENS_COMMAND_UUID)
};


// Conversion equation D0 (x 100) characteristic   ((((VALUE / D0) * N0) - X0) / D1)
CONST uint8 sensDenom0_x_100UUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_DENOM_0_X_100_UUID), HI_UINT16(SENS_DENOM_0_X_100_UUID)
};

// Conversion equation N0 (x 100) characteristic   ((((VALUE / D0) * N0) - X0) / D1)
CONST uint8 sensNum0_x_100UUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_NUM_0_X_100_UUID), HI_UINT16(SENS_NUM_0_X_100_UUID)
};

// Conversion equation X0 (x 100) characteristic   ((((VALUE / D0) * N0) - X0) / D1)
CONST uint8 sensX0_x_100UUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_SUB_X_0_X_100_UUID), HI_UINT16(SENS_SUB_X_0_X_100_UUID)
};

// Conversion equation D1 (x 100) characteristic   ((((VALUE / D0) * N0) - X0) / D1)
CONST uint8 sensDenom1_x_100UUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_DENOM_1_X_100_UUID), HI_UINT16(SENS_DENOM_1_X_100_UUID)
};

// Graph Main Title characteristic   
CONST uint8 graph_TitleUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_GRAPH_TITLE_UUID), HI_UINT16(SENS_GRAPH_TITLE_UUID)
};

// Graph Main SubTitle characteristic   
CONST uint8 graph_SubTitleUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_GRAPH_SUBTITLE_UUID), HI_UINT16(SENS_GRAPH_SUBTITLE_UUID)
};

// Graph X Axis Caption characteristic   
CONST uint8 graph_XAxisCaptionUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_GRAPH_X_AXIS_CAPTION_UUID), HI_UINT16(SENS_GRAPH_X_AXIS_CAPTION_UUID)
};

// Graph Y Axis Caption characteristic   
CONST uint8 graph_YAxisCaptionUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_GRAPH_Y_AXIS_CAPTION_UUID), HI_UINT16(SENS_GRAPH_Y_AXIS_CAPTION_UUID)
};

// Graph Y Axis Minimum Display Value characteristic - Raw ADC output value, not converted   
CONST uint8 graph_YAxisMinimumUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_GRAPH_Y_AXIS_DISPLAY_MIN_UUID), HI_UINT16(SENS_GRAPH_Y_AXIS_DISPLAY_MIN_UUID)
};

// Graph Y Axis Maximum Display Value characteristic - Raw ADC output value, not converted
CONST uint8 graph_YAxisMaximumUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_GRAPH_Y_AXIS_DISPLAY_MAX_UUID), HI_UINT16(SENS_GRAPH_Y_AXIS_DISPLAY_MAX_UUID)
};

// Graph Value Defining Boundary Between Top and Middle Color Areas characteristic - Raw ADC output value, not converted
//       Use 0 if there is no color difference
CONST uint8 graph_ColorTopMidBoundaryUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_GRAPH_COLOR_TOP_MID_BOUNDARY_UUID), HI_UINT16(SENS_GRAPH_COLOR_TOP_MID_BOUNDARY_UUID)
};

// Graph Value Defining Boundary Between Middle and Lower Color Areas characteristic - Raw ADC output value, not converted
//       Use 0 if there is no color difference
CONST uint8 graph_ColorMidLowBoundaryUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_GRAPH_COLOR_MID_LOW_BOUNDARY_UUID), HI_UINT16(SENS_GRAPH_COLOR_MID_LOW_BOUNDARY_UUID)
};

// Color of Top Color Area characteristic - ARGB 4444
CONST uint8 graph_ColorTopValueUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_GRAPH_COLOR_TOP_VALUE_UUID), HI_UINT16(SENS_GRAPH_COLOR_TOP_VALUE_UUID)
};

// Color of Middle Color Area characteristic - ARGB 4444
CONST uint8 graph_ColorMidValueUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_GRAPH_COLOR_MID_VALUE_UUID), HI_UINT16(SENS_GRAPH_COLOR_MID_VALUE_UUID)
};

// Color of Low Color Area characteristic - ARGB 4444
CONST uint8 graph_ColorLowValueUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_GRAPH_COLOR_LOW_VALUE_UUID), HI_UINT16(SENS_GRAPH_COLOR_LOW_VALUE_UUID)
};

// Calibration Value x 100
CONST uint8 sens_CalibrationValueUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_CALIBIRATION_VALUE_X_100_UUID), HI_UINT16(SENS_CALIBIRATION_VALUE_X_100_UUID)
};

// Sensor Type
CONST uint8 sens_SensorTypeUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_SENSOR_TYPE_UUID), HI_UINT16(SENS_SENSOR_TYPE_UUID)
};

// Display Current Value Indication
CONST uint8 sens_DisplayCurrentValueUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_DISPLAY_CURRENT_VALUE_UUID), HI_UINT16(SENS_DISPLAY_CURRENT_VALUE_UUID)
};

// Use Logarithmetic Scaling Indication
CONST uint8 graph_UseLogScaleUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_GRAPH_LOG_SCALE_UUID), HI_UINT16(SENS_GRAPH_LOG_SCALE_UUID)
};

// Command characteristic
CONST uint8 sensCommandUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_COMMAND_UUID), HI_UINT16(SENS_COMMAND_UUID)
};

// Mode of Operation characteristic
CONST uint8 sensModeOpUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_MODE_OP_UUID), HI_UINT16(SENS_MODE_OP_UUID)
};

// TIA Gain characteristic
CONST uint8 sensTIAGainUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_TIA_GAIN_UUID), HI_UINT16(SENS_TIA_GAIN_UUID)
};

// RLoad Gain characteristic
CONST uint8 sensRLoadUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_R_LOAD_UUID), HI_UINT16(SENS_R_LOAD_UUID)
};

// Internal Zero Selection characteristic
CONST uint8 sensIntZSelUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_INT_Z_SEL_UUID), HI_UINT16(SENS_INT_Z_SEL_UUID)
};

// Reference Voltage Source characteristic
CONST uint8 sensRefVoltSourceUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_REF_VOLTAGE_SOURCE_UUID), HI_UINT16(SENS_REF_VOLTAGE_SOURCE_UUID)
};

// nuSOCKET Light Control characteristic
CONST uint8 nuSOCKET_LightOnUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(NUSOCKET_LIGHT_ON_UUID), HI_UINT16(NUSOCKET_LIGHT_ON_UUID)
};

// Short Caption characteristic
CONST uint8 sensShortCaptionUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_SHORT_CAPTION_UUID), HI_UINT16(SENS_SHORT_CAPTION_UUID)
};

// Scaling Factor Numerator characteristic   
CONST uint8 sensScaleFactorNumUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_SCALE_FACTOR_NUM_UUID), HI_UINT16(SENS_SCALE_FACTOR_NUM_UUID)
};

// Scaling Factor Denominator characteristic   
CONST uint8 sensScaleFactorDenomUUID[ATT_BT_UUID_SIZE] =
{ 
  LO_UINT16(SENS_SCALE_FACTOR_DENOM_UUID), HI_UINT16(SENS_SCALE_FACTOR_DENOM_UUID)
};

/*********************************************************************
 * EXTERNAL VARIABLES
 */

/*********************************************************************
 * EXTERNAL FUNCTIONS
 */

/*********************************************************************
 * LOCAL VARIABLES
 */

static sensServiceCB_t sensServiceCB;

/*********************************************************************
 * Profile Attributes - variables
 */

// Sensor Service attribute
static CONST gattAttrType_t sensService = { ATT_BT_UUID_SIZE, sensServUUID };

// Command Characteristic
static uint8 sensCommandProps = GATT_PROP_NOTIFY;
static uint8 sensCommand = 0;
static gattCharCfg_t sensCommandClientCharCfg[GATT_MAX_NUM_CONN];
static uint8 sensCommandUserDesp[15] = "Sensor Command\0";

// Note that the Equation to convert the value returned from the ADC is 
//      ((X0 - ((VALUE / D0) * N0)) / D1)

// Sensor Denomenator D0 Characteristic, multiplied by 100
static uint8 sens_Denom_0_x_100_Props = GATT_PROP_READ;
static int32 sens_Denom_0_x_100 = SENS_DENOM_0;
static uint8 sens_Denom_0_x_100UserDesp[38] = "Denominator D0 to convert Measurement\0";

// Sensor Numerator N0 Characteristic, multiplied by 100
static uint8 sens_Numer_0_x_100_Props = GATT_PROP_READ;
static int32 sens_Numer_0_x_100 = SENS_NUMER_0;
static uint8 sens_Numer_0_x_100UserDesp[36] = "Numerator N0 to convert Measurement\0";

// Sensor Median Value X0 Characteristic, multiplied by 100
static uint8 sens_Sub_0_x_100_Props = GATT_PROP_READ;
static int32 sens_Sub_0_x_100 = SENS_SUB_0;
static uint8 sens_Sub_0_x_100UserDesp[59] = "Median Value used in subtraction X0 to convert Measurement\0";

// Sensor Denomenator D1 Characteristic, multiplied by 100
static uint8 sens_Denom_1_x_100_Props = GATT_PROP_READ;
static int32 sens_Denom_1_x_100 = SENS_DENOM_1;
static uint8 sens_Denom_1_x_100UserDesp[38] = "Denominator D1 to convert Measurement\0";

// Graph Title 
static uint8 sens_Graph_Title_Props = GATT_PROP_READ;
static uint8 sens_Graph_TitleUserDesp[SENS_GRAPH_TITLE_SIZE] = SENS_GRAPH_TITLE;

// Graph SubTitle 
static uint8 sens_Graph_SubTitle_Props = GATT_PROP_READ;
static uint8 sens_Graph_SubTitleUserDesp[SENS_GRAPH_SUBTITLE_SIZE] = SENS_GRAPH_SUBTITLE;

// X Axis Caption
static uint8 sens_Graph_X_Axis_Caption_Props = GATT_PROP_READ;
static uint8 sens_Graph_X_Axis_CaptionUserDesp[SENS_GRAPH_X_AXIS_CAPTION_SIZE] = SENS_GRAPH_X_AXIS_CAPTION;

// Y Axis Caption
static uint8 sens_Graph_Y_Axis_Caption_Props = GATT_PROP_READ;
static uint8 sens_Graph_Y_Axis_CaptionUserDesp[SENS_GRAPH_Y_AXIS_CAPTION_SIZE] = SENS_GRAPH_Y_AXIS_CAPTION;

// Y Axis Minimum Displayed Value - This value is a Raw ADC number. All values below this are clipped 
static uint8 sens_Graph_Y_Axis_Display_Min_Props = GATT_PROP_READ;
static uint16 sens_Graph_Y_Axis_Display_Min = SENS_Y_DISPLAY_MIN;
static uint8 sens_Graph_Y_Axis_Display_MinUserDesp[58] = "Minimum value on the Y Axis. All lower values are clipped\0";

// Y Axis Maximum Displayed Value - This value is a Raw ADC number. All values above this are clipped 
static uint8 sens_Graph_Y_Axis_Display_Max_Props = GATT_PROP_READ;
static uint16 sens_Graph_Y_Axis_Display_Max = SENS_Y_DISPLAY_MAX;
static uint8 sens_Graph_Y_Axis_Display_MaxUserDesp[60] = "Maximum value on the Y Axis. All greater values are clipped\0";

// Graph Color Level between Top and Middle Color bands Value - This value is a Raw ADC number. 
static uint8 sens_Graph_Color_Top_Mid_Boundary_Props = GATT_PROP_READ;
static uint16 sens_Graph_Color_Top_Mid_Boundary = SENS_GRAPH_TOP_MID_BOUNDARY;
static uint8 sens_Graph_Color_Top_Mid_BoundaryUserDesp[70] = "Value of the boundary between the top and middle color bands on graph\0";

// Graph Color Level between Middle and Low Color bands Value - This value is a Raw ADC number. 
static uint8 sens_Graph_Color_Mid_Low_Boundary_Props = GATT_PROP_READ;
static uint16 sens_Graph_Color_Mid_Low_Boundary = SENS_GRAPH_MID_LOW_BOUNDARY;
static uint8 sens_Graph_Color_Mid_Low_BoundaryUserDesp[70] = "Value of the boundary between the middle and low color bands on graph\0";

// Graph Color Level for Top Color band Value - ARGB4444. 
static uint8 sens_Graph_Color_Top_Value_Props = GATT_PROP_READ;
static uint32 sens_Graph_Color_Top_Value = SENS_GRAPH_TOP_COLOR;
static uint8 sens_Graph_Color_Top_ValueUserDesp[51] = "Value of the color for the top color band on graph\0";

// Graph Color Level for Mid Color band Value - ARGB4444. 
static uint8 sens_Graph_Color_Mid_Value_Props = GATT_PROP_READ;
static uint32 sens_Graph_Color_Mid_Value = SENS_GRAPH_MID_COLOR;
static uint8 sens_Graph_Color_Mid_ValueUserDesp[54] = "Value of the color for the middle color band on graph\0";

// Graph Color Level for Low Color band Value - ARGB4444. 
static uint8 sens_Graph_Color_Low_Value_Props = GATT_PROP_READ;
static uint32 sens_Graph_Color_Low_Value = SENS_GRAPH_LOW_COLOR;
static uint8 sens_Graph_Color_Low_ValueUserDesp[53] = "Value of the color for the lower color band on graph\0";

// Sensor Calibration Value, multiplied by 100. This is the setting of the sensor when calibration occurs. Set to 0 to not use
static uint8 sens_Calib_Value_x_100_Props = GATT_PROP_READ;
static uint32 sens_Calib_Value_x_100 = SENS_CALIB;
static uint8 sens_Calib_Value_x_100UserDesp[44] = "Value of the sensor when calibration occurs\0";

// Sensor Type 
static uint8 sens_Type_Props = GATT_PROP_READ;
static uint8 sens_Type = SENS_TYPE;
static uint8 sens_TypeUserDesp[12] = "Sensor Type\0";

// Display the Current Value on Graph 
static uint8 sens_Display_Current_Value_Props = GATT_PROP_READ;
static uint8 sens_Display_Current_Value = SENS_DISPLAY_CURRENT_VALUE;
static uint8 sens_Display_Current_ValueUserDesp[36] = "Display the Current Value on Screen\0";

// Display the Graph using Logarithmic Scale 
static uint8 sens_Display_Log_Scale_Props = GATT_PROP_READ;
static uint8 sens_Display_Log_Scale = SENS_DISPLAY_LOG_SCALE;
static uint8 sens_Display_Log_ScaleUserDesp[42] = "Display the Graph using Logarithmic Scale\0";

// Mode of Operation for sensor
static uint8 sensModeOpProps = GATT_PROP_READ | GATT_PROP_WRITE;
uint8 sensModeOp = (FET_SHORT_DISABLED | SENS_OPERATIONAL_MODE);
static uint8 sens_ModeOpUserDesp[37] = "LMP91000 Operational Mode for Sensor\0";

// TIA Feedback Gain 
static uint8 sensTIAGainProps = GATT_PROP_READ | GATT_PROP_WRITE;
uint8 sensTIAGain = SENS_FEEDBACK_GAIN;
static uint8 sens_TIAGainUserDesp[44] = "LMP91000 TIA Feedback Resistance for Sensor\0";

// RLOAD  
static uint8 sensRLoadProps = GATT_PROP_READ | GATT_PROP_WRITE;
uint8 sensRLoad = SENS_RLOAD;
static uint8 sens_RLoadUserDesp[36] = "LMP91000 Resistance Load for Sensor\0";

// Internal Zero Selection  
static uint8 sensIntZSelProps = GATT_PROP_READ | GATT_PROP_WRITE;
uint8 sensIntZSel = SENS_INT_Z_REF_DIVIDER;
static uint8 sens_IntZSelUserDesp[52] = "LMP91000 Internal Zero Selection Setting for Sensor\0";

// Reference Voltage Source Selection  
static uint8 sensRefVoltageSourceProps = GATT_PROP_READ | GATT_PROP_WRITE;
uint8 sensRefVoltageSource = SENS_REF_SOURCE;
static uint8 sens_RefVoltageSourceUserDesp[53] = "LMP91000 Reference Voltage Source Setting for Sensor\0";

// nuSOCKET Light Control 
static uint8 nuSOCKET_LightOnProps = GATT_PROP_READ | GATT_PROP_WRITE;
uint8 nuSOCKET_LightOn = NUSOCKET_LIGHT_ON;
static uint8 nuSOCKET_LightOnUserDesp[23] = "nuSOCKET Light Control\0";

// Short Caption 
static uint8 sens_Short_Caption_Props = GATT_PROP_READ;
static uint8 sens_Short_CaptionUserDesp[SENS_SHORT_CAPTION_SIZE] = SENS_SHORT_CAPTION_VALUE;

// Sensor Scale Factor Numerator Characteristic
static uint8 sens_Scale_Factor_Num_Props = GATT_PROP_READ;
static int32 sens_Scale_Factor_Num = SENS_SCALE_FACTOR_NUM;
static uint8 sens_Scale_Factor_NumUserDesp[25] = "Scaling Factor Numerator\0";

// Sensor Scale Factor Denominator Characteristic
static uint8 sens_Scale_Factor_Denom_Props = GATT_PROP_READ;
static int32 sens_Scale_Factor_Denom = SENS_SCALE_FACTOR_DENOM;
static uint8 sens_Scale_Factor_DenomUserDesp[27] = "Scaling Factor Denominator\0";

/*********************************************************************
 * Profile Attributes - Table
 */

static gattAttribute_t sensAttrTbl[] = 
{
  // Sensor Service
  { 
    { ATT_BT_UUID_SIZE, primaryServiceUUID }, /* type */
    GATT_PERMIT_READ,                         /* permissions */
    0,                                        /* handle */
    (uint8 *)&sensService                     /* pValue */
  },

    // Sensor Measurement Declaration - Characteristic 1
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sensCommandProps 
    },

      // Sensor Measurement Values for one sample - Characteristic 1
    { 
      { ATT_BT_UUID_SIZE, sensMeasUUID },
      0, 
      0, 
      &sensCommand 
    },

    // Sensor Measurement Client Characteristic Configuration - Characteristic 1
    { 
      { ATT_BT_UUID_SIZE, clientCharCfgUUID },
      GATT_PERMIT_READ | GATT_PERMIT_WRITE, 
      0, 
      (uint8 *) &sensCommandClientCharCfg 
    },      


    // Sensor Measure User Description - Characteristic 1
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sensCommandUserDesp 
    },           
//-------------------    
    // Sensor Denominator D0, multiplied by 100 Properties- Characteristic 2
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Denom_0_x_100_Props 
    },

    // Sensor Denominator D0, multiplied by 100 Value - Characteristic 2
    { 
      { ATT_BT_UUID_SIZE, sensDenom0_x_100UUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Denom_0_x_100 
    },

    // Sensor Denominator D0, multiplied by 100 User Description - Characteristic 2
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Denom_0_x_100UserDesp 
    },  
//-------------------    
    // Sensor Numerator N0, multiplied by 100 Properties - Characteristic 3
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Numer_0_x_100_Props
    },

    // Sensor Numerator N0, multiplied by 100 Value - Characteristic 3
    { 
      { ATT_BT_UUID_SIZE, sensNum0_x_100UUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Numer_0_x_100 
    },

    // Sensor Numerator N0, multiplied by 100 User Description - Characteristic 3
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Numer_0_x_100UserDesp 
    },           
//-------------------    
    // Sensor Median Value X0, multiplied by 100 Properties - Characteristic 4
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Sub_0_x_100_Props 
    },

    // Sensor Median Value X0, multiplied by 100 Value - Characteristic 4
    { 
      { ATT_BT_UUID_SIZE, sensX0_x_100UUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Sub_0_x_100 
    },

    // Sensor Median Value X0, multiplied by 100 User Description - Characteristic 4
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Sub_0_x_100UserDesp 
    },           
//-------------------    
    // Sensor Denominator D1, multiplied by 100 Properties- Characteristic 5
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Denom_1_x_100_Props 
    },

    // Sensor Denominator D1, multiplied by 100 Value - Characteristic 5
    { 
      { ATT_BT_UUID_SIZE, sensDenom1_x_100UUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Denom_1_x_100 
    },

    // Sensor Denominator D1, multiplied by 100 User Description - Characteristic 5
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Denom_1_x_100UserDesp 
    },  
//-------------------    
    // Sensor Graph Title Properties - Characteristic 6
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Graph_Title_Props 
    },

    // Sensor Graph Title Display Value - Characteristic 6
    { 
      { ATT_BT_UUID_SIZE, graph_TitleUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_TitleUserDesp 
    },

    // Sensor Graph Title User Description - Characteristic 6
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_TitleUserDesp 
    },  
//-------------------    
    // Sensor Graph Subtitle Properties - Characteristic 7
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Graph_SubTitle_Props 
    },
    
    // Sensor Graph SubTitle Display Value - Characteristic 7
    { 
      { ATT_BT_UUID_SIZE, graph_SubTitleUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_SubTitleUserDesp 
    },

    // Sensor Graph Subtitle User Description - Characteristic 7
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_SubTitleUserDesp 
    },  
//-------------------    
    // Sensor X Axis Caption Properties - Characteristic 8
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Graph_X_Axis_Caption_Props 
    },
    
    // Sensor X Axis Caption Display Value - Characteristic 8
    { 
      { ATT_BT_UUID_SIZE, graph_XAxisCaptionUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_X_Axis_CaptionUserDesp 
    },

    // Sensor X Axis Caption User Description - Characteristic 8
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_X_Axis_CaptionUserDesp 
    },  
//-------------------    
    // Sensor Y Axis Caption Properties - Characteristic 9
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Graph_Y_Axis_Caption_Props 
    },

    // Sensor Y Axis Caption Display Value - Characteristic 9
    { 
      { ATT_BT_UUID_SIZE, graph_YAxisCaptionUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_Y_Axis_CaptionUserDesp 
    },

    // Sensor Y Axis Caption User Description - Characteristic 9
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_Y_Axis_CaptionUserDesp 
    },  
//-------------------    
    // Sensor Y Axis Minimum Display Value Properties- Characteristic 10
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Graph_Y_Axis_Display_Min_Props 
    },

    // Sensor Y Axis Minimum Display Value - Characteristic 10
    { 
      { ATT_BT_UUID_SIZE, graph_YAxisMinimumUUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Graph_Y_Axis_Display_Min 
    },

    // Sensor Y Axis Minimum Display Value User Description - Characteristic 10
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_Y_Axis_Display_MinUserDesp 
    },  
//-------------------    
    // Sensor Y Axis Maximum Display Value Properties- Characteristic 11
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Graph_Y_Axis_Display_Max_Props 
    },

    // Sensor Y Axis Maximum Display Value - Characteristic 11
    { 
      { ATT_BT_UUID_SIZE, graph_YAxisMaximumUUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Graph_Y_Axis_Display_Max 
    },

    // Sensor Y Axis Maximum Display Value User Description - Characteristic 11
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_Y_Axis_Display_MaxUserDesp 
    },  
//-------------------    
    // Sensor Color Level Between Top and Middle Color Bands Value Properties- Characteristic 12
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Graph_Color_Top_Mid_Boundary_Props 
    },

    // Sensor Color Level Between Top and Middle Color Bands Value - Characteristic 12
    { 
      { ATT_BT_UUID_SIZE, graph_ColorTopMidBoundaryUUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Graph_Color_Top_Mid_Boundary 
    },

    // Sensor Color Level Between Top and Middle Color Bands Value User Description - Characteristic 12
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_Color_Top_Mid_BoundaryUserDesp 
    },  
//-------------------    
    // Sensor Color Level Between Middle and Lower Color Bands Value Properties- Characteristic 13
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Graph_Color_Mid_Low_Boundary_Props 
    },

    // Sensor Color Level Between Middle and Lower Color Bands Value - Characteristic 13
    { 
      { ATT_BT_UUID_SIZE, graph_ColorMidLowBoundaryUUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Graph_Color_Mid_Low_Boundary 
    },

    // Sensor Color Level Between Middle and Lower Color Bands Value User Description - Characteristic 13
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_Color_Mid_Low_BoundaryUserDesp 
    },  
//-------------------    
    // Sensor Color Value for Top Color Band Properties- Characteristic 14
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Graph_Color_Top_Value_Props 
    },

    // Sensor Color Value for Top Color Band - Characteristic 14
    { 
      { ATT_BT_UUID_SIZE, graph_ColorTopValueUUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Graph_Color_Top_Value 
    },

    // Sensor Color Value for Top Color Band User Description - Characteristic 14
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_Color_Top_ValueUserDesp 
    },  
//-------------------    
    // Sensor Color Value for Middle Color Band Properties- Characteristic 15
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Graph_Color_Mid_Value_Props 
    },

    // Sensor Color Value for Middle Color Band - Characteristic 15
    { 
      { ATT_BT_UUID_SIZE, graph_ColorMidValueUUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Graph_Color_Mid_Value 
    },

    // Sensor Color Value for Middle Color Band User Description - Characteristic 15
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_Color_Mid_ValueUserDesp 
    },  
//-------------------    
    // Sensor Color Value for Lower Color Band Properties- Characteristic 16
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Graph_Color_Low_Value_Props 
    },

    // Sensor Color Value for Lower Color Band - Characteristic 16
    { 
      { ATT_BT_UUID_SIZE, graph_ColorLowValueUUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Graph_Color_Low_Value 
    },

    // Sensor Color Value for Lower Color Band User Description - Characteristic 16
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Graph_Color_Low_ValueUserDesp 
    },  
//-------------------    
    // Sensor Calibration Value, multiplied by 100 Properties - Characteristic 17
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      (uint8 *)&sens_Calib_Value_x_100_Props 
    },

    // Sensor Calibration Value, multiplied by 100  - Characteristic 17
    { 
      { ATT_BT_UUID_SIZE, sens_CalibrationValueUUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Calib_Value_x_100 
    },

    // Sensor Calibration Value, multiplied by 100 User Description - Characteristic 17
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Calib_Value_x_100UserDesp 
    },           
//-------------------    
    // Sensor Type Properties- Characteristic 18
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Type_Props 
    },

    // Sensor Type - Characteristic 18
    { 
      { ATT_BT_UUID_SIZE, sens_SensorTypeUUID },
      GATT_PERMIT_READ, 
      0, 
      &sens_Type 
    },

    // Sensor Type User Description - Characteristic 18
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_TypeUserDesp 
    },  
//-------------------    
    // Sensor Display Current Value Properties- Characteristic 19
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Display_Current_Value_Props 
    },

    // Sensor Display Current Value - Characteristic 19
    { 
      { ATT_BT_UUID_SIZE, sens_DisplayCurrentValueUUID },
      GATT_PERMIT_READ, 
      0, 
      &sens_Display_Current_Value 
    },

    // Sensor Display Current Value User Description - Characteristic 19
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Display_Current_ValueUserDesp 
    },  
//-------------------    
    // Sensor Display Graph using Logarithmic Scaling Properties- Characteristic 20
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Display_Log_Scale_Props 
    },

    // Sensor Display Graph using Logarithmic Scaling Value - Characteristic 20
    { 
      { ATT_BT_UUID_SIZE, graph_UseLogScaleUUID },
      GATT_PERMIT_READ, 
      0, 
      &sens_Display_Log_Scale 
    },

    // Sensor Display Graph using Logarithmic Scaling User Description - Characteristic 20
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Display_Log_ScaleUserDesp 
    },  
//-------------------    
    // Mode Operation Properties - Characteristic 21
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sensModeOpProps 
    },

    // ModeOp - Characteristic 21
    { 
      { ATT_BT_UUID_SIZE, sensModeOpUUID },
      GATT_PERMIT_READ | GATT_PERMIT_WRITE, 
      0, 
      &sensModeOp 
    },

    // Sensor Mode Operation User Description - Characteristic 21
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_ModeOpUserDesp 
    },  


//-------------------    
    // TIA Feedback Gain Properties - Characteristic 22
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sensTIAGainProps 
    },

    // TIA Feedback Gain - Characteristic 22
    { 
      { ATT_BT_UUID_SIZE, sensTIAGainUUID },
      GATT_PERMIT_READ | GATT_PERMIT_WRITE, 
      0, 
      &sensTIAGain 
    },

    // TIA Feedback Gain User Description - Characteristic 22
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_TIAGainUserDesp 
    },  

//-------------------    
    // R Load Properties - Characteristic 23
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sensRLoadProps 
    },

    // R Load - Characteristic 23
    { 
      { ATT_BT_UUID_SIZE, sensRLoadUUID },
      GATT_PERMIT_READ | GATT_PERMIT_WRITE, 
      0, 
      &sensRLoad 
    },

    // R Load User Description - Characteristic 23
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_RLoadUserDesp 
    },  

//-------------------    
    // Internal Zero Selection Properties - Characteristic 24
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sensIntZSelProps 
    },

    // Internal Zero Selection - Characteristic 24
    { 
      { ATT_BT_UUID_SIZE, sensIntZSelUUID },
      GATT_PERMIT_READ | GATT_PERMIT_WRITE, 
      0, 
      &sensIntZSel 
    },

    // Internal Zero Selection User Description - Characteristic 24
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_IntZSelUserDesp 
    },  

//-------------------    
    // Reference Voltage Source Selection Properties - Characteristic 25
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sensRefVoltageSourceProps 
    },

    // Reference Voltage Source Selection - Characteristic 25
    { 
      { ATT_BT_UUID_SIZE, sensRefVoltSourceUUID },
      GATT_PERMIT_READ | GATT_PERMIT_WRITE, 
      0, 
      &sensRefVoltageSource 
    },
    
    // Reference Voltage Source Selection User Description - Characteristic 25
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_RefVoltageSourceUserDesp 
    },
//-------------------  
    // nuSOCKET Light Control Properties - Characteristic 26
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &nuSOCKET_LightOnProps 
    },

    // nuSOCKET Light Control - Characteristic 26
    { 
      { ATT_BT_UUID_SIZE, nuSOCKET_LightOnUUID },
      GATT_PERMIT_READ | GATT_PERMIT_WRITE, 
      0, 
      &nuSOCKET_LightOn 
    },

    // nuSOCKET Light Control User Description - Characteristic 26
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      nuSOCKET_LightOnUserDesp 
    },  

//-------------------    
    // Sensor Short Caption Properties - Characteristic 27
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Short_Caption_Props 
    },

    // Sensor Short Caption Display Value - Characteristic 27
    { 
      { ATT_BT_UUID_SIZE, sensShortCaptionUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Short_CaptionUserDesp 
    },

    // Sensor Short Caption User Description - Characteristic 27
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Short_CaptionUserDesp 
    },  
//-------------------    
    // Sensor Scale Factor Numerator Properties - Characteristic 28
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Scale_Factor_Num_Props 
    },

    // Sensor Scale Factor Numerator Value - Characteristic 28
    { 
      { ATT_BT_UUID_SIZE, sensScaleFactorNumUUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Scale_Factor_Num 
    },

    // Sensor Scale Factor Numerator User Description - Characteristic 28
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Scale_Factor_NumUserDesp 
    },  
//-------------------    
    // Sensor Scale Factor Denominator Properties - Characteristic 29
    { 
      { ATT_BT_UUID_SIZE, characterUUID },
      GATT_PERMIT_READ, 
      0,
      &sens_Scale_Factor_Denom_Props 
    },

    // Sensor Scale Factor Denominator Value - Characteristic 29
    { 
      { ATT_BT_UUID_SIZE, sensScaleFactorDenomUUID },
      GATT_PERMIT_READ, 
      0, 
      (uint8 *)&sens_Scale_Factor_Denom 
    },

    // Sensor Scale Factor Denominator User Description - Characteristic 29
    { 
      { ATT_BT_UUID_SIZE, charUserDescUUID },
      GATT_PERMIT_READ, 
      0, 
      sens_Scale_Factor_DenomUserDesp 
    },  
    
};


/*********************************************************************
 * LOCAL FUNCTIONS
 */
static uint8 sens_ReadAttrCB( uint16 connHandle, gattAttribute_t *pAttr, 
                              uint8 *pValue, uint8 *pLen, uint16 offset, uint8 maxLen );
static bStatus_t sens_WriteAttrCB( uint16 connHandle, gattAttribute_t *pAttr,
                                   uint8 *pValue, uint8 len, uint16 offset );

/*********************************************************************
 * PROFILE CALLBACKS
 */
// Heart Rate Service Callbacks
CONST gattServiceCBs_t sensCBs =
{
  sens_ReadAttrCB,  // Read callback function pointer
  sens_WriteAttrCB, // Write callback function pointer
  NULL                   // Authorization callback function pointer
};

/*********************************************************************
 * PUBLIC FUNCTIONS
 */

/*********************************************************************
 * @fn      HeartRate_AddService
 *
 * @brief   Initializes the Heart Rate service by registering
 *          GATT attributes with the GATT server.
 *
 * @param   services - services to add. This is a bit map and can
 *                     contain more than one service.
 *
 * @return  Success or Failure
 */
bStatus_t sens_AddService( uint32 services )
{
  uint8 status = SUCCESS;

  // Initialize Client Characteristic Configuration attributes
  GATTServApp_InitCharCfg( INVALID_CONNHANDLE, sensCommandClientCharCfg );

  if ( services & SENS_SERVICE )
  {
    // Register GATT attribute list and CBs with GATT Server App
    status = GATTServApp_RegisterService( sensAttrTbl, 
                                          GATT_NUM_ATTRS( sensAttrTbl ),
                                          &sensCBs );
  }

  return ( status );
}

/*********************************************************************
 * @fn      HeartRate_Register
 *
 * @brief   Register a callback function with the Heart Rate Service.
 *
 * @param   pfnServiceCB - Callback function.
 *
 * @return  None.
 */
extern void sens_Register( sensServiceCB_t pfnServiceCB )
{
  sensServiceCB = pfnServiceCB;
}

/*********************************************************************
 * @fn      HeartRate_SetParameter
 *
 * @brief   Set a Heart Rate parameter.
 *
 * @param   param - Profile parameter ID
 * @param   len - length of data to write
 * @param   value - pointer to data to write.  This is dependent on
 *          the parameter ID and WILL be cast to the appropriate 
 *          data type (example: data type of uint16 will be cast to 
 *          uint16 pointer).
 *
 * @return  bStatus_t
 */
bStatus_t sens_SetParameter( uint8 param, uint8 len, void *value )
{
  bStatus_t ret = SUCCESS;
  switch ( param )
  {
    case SENS_DENOM_0_PARAM:  
      sens_Denom_0_x_100 = *(uint32 *)value ;
      break;

    case SENS_NUM_0_PARAM:  
      sens_Numer_0_x_100 = *(uint32 *)value;
      break;
      
    case SENS_SUB_X_0_PARAM:  
      sens_Sub_0_x_100 = *(uint32 *)value;
      break;

    case SENS_DENOM_1_PARAM:  
      sens_Denom_1_x_100 = *(uint32 *)value;
      break;

    case SENS_Y_AXIS_DISPLAY_MIN_PARAM:  
      sens_Graph_Y_Axis_Display_Min = *(uint16 *)value;
      break;

    case SENS_Y_AXIS_DISPLAY_MAX_PARAM:  
      sens_Graph_Y_Axis_Display_Max = *(uint16 *)value;
      break;
      
    case SENS_COLOR_BAND_TOP_MID_LEVEL_PARAM:  
      sens_Graph_Color_Top_Mid_Boundary = *(uint16 *)value;
      break;

    case SENS_COLOR_BAND_MID_LOW_LEVEL_PARAM:  
      sens_Graph_Color_Mid_Low_Boundary = *(uint16 *)value;
      break;

    case SENS_COLOR_BAND_TOP_LEVEL_COLOR_PARAM:  
      sens_Graph_Color_Top_Value = *(uint32 *)value;
      break;

    case SENS_COLOR_BAND_MID_LEVEL_COLOR_PARAM:  
      sens_Graph_Color_Mid_Value = *(uint32 *)value;
      break;

    case SENS_COLOR_BAND_LOW_LEVEL_COLOR_PARAM:  
      sens_Graph_Color_Low_Value = *(uint32 *)value;
      break;

    case SENS_CALIBIRATION_VALUE_PARAM:  
      sens_Calib_Value_x_100 = *(uint32 *)value;
      break;

    case SENS_TYPE_PARAM:  
      sens_Type = *(uint8 *)value;
      break;

    case SENS_TYPE_DISPLAY_CURRENT_VALUE_PARAM:  
      sens_Display_Current_Value = *(uint8 *)value;
      break;

    case SENS_GRAPH_LOG_SCALE_PARAM:  
      sens_Display_Log_Scale = *(uint8 *)value;
      break;

    case SENS_MODE_OP_PARAM:
      sensModeOp = *(uint8 *)value;
      break;

    case SENS_TIA_GAIN_PARAM:
      sensTIAGain = *(uint8 *)value;
      break;
      
    case SENS_R_LOAD_PARAM:
      sensRLoad = *(uint8 *)value;
      break;

    case SENS_INT_Z_SEL_PARAM:
      sensIntZSel = *(uint8 *)value;
      break;

    case SENS_REF_VOLTAGE_SOURCE_PARAM:
      sensRefVoltageSource = *(uint8 *)value;
      break;

    case NUSOCKET_LIGHT_ON_PARAM:
      nuSOCKET_LightOn = *(uint8 *)value;
      break;  
  
    case SENS_SCALE_FACTOR_NUM_PARAM:  
      sens_Scale_Factor_Num = *(uint32 *)value;
      break;
      
    case SENS_SCALE_FACTOR_DENOM_PARAM:  
      sens_Scale_Factor_Denom = *(uint32 *)value;
      break;

    default:
      ret = INVALIDPARAMETER;
      break;
  }
  
  return ( ret );
}

/*********************************************************************
 * @fn      HeartRate_GetParameter
 *
 * @brief   Get a Heart Rate parameter.
 *
 * @param   param - Profile parameter ID
 * @param   value - pointer to data to get.  This is dependent on
 *          the parameter ID and WILL be cast to the appropriate 
 *          data type (example: data type of uint16 will be cast to 
 *          uint16 pointer).
 *
 * @return  bStatus_t
 */
bStatus_t sens_GetParameter( uint8 param, void *value )
{
  bStatus_t ret = SUCCESS;
  switch ( param )
  {
      
    case SENS_DENOM_0_PARAM:  
      *(int32 *)value = sens_Denom_0_x_100;
      break;

    case SENS_NUM_0_PARAM:  
      *(int32 *)value = sens_Numer_0_x_100;
      break;
      
    case SENS_SUB_X_0_PARAM:  
      *(int32 *)value = sens_Sub_0_x_100;
      break;

    case SENS_DENOM_1_PARAM:  
      *(int32 *)value = sens_Denom_1_x_100;
      break;

    case SENS_Y_AXIS_DISPLAY_MIN_PARAM:  
      *(uint16 *)value = sens_Graph_Y_Axis_Display_Min;
      break;

    case SENS_Y_AXIS_DISPLAY_MAX_PARAM:  
      *(uint16 *)value = sens_Graph_Y_Axis_Display_Max;
      break;
      
    case SENS_COLOR_BAND_TOP_MID_LEVEL_PARAM:  
      *(uint16 *)value = sens_Graph_Color_Top_Mid_Boundary;
      break;

    case SENS_COLOR_BAND_MID_LOW_LEVEL_PARAM:  
      *(uint16 *)value = sens_Graph_Color_Mid_Low_Boundary;
      break;

    case SENS_COLOR_BAND_TOP_LEVEL_COLOR_PARAM:  
      *(uint32 *)value = sens_Graph_Color_Top_Value;
      break;

    case SENS_COLOR_BAND_MID_LEVEL_COLOR_PARAM:  
      *(uint32 *)value = sens_Graph_Color_Mid_Value;
      break;

    case SENS_COLOR_BAND_LOW_LEVEL_COLOR_PARAM:  
      *(uint32 *)value = sens_Graph_Color_Low_Value;
      break;

    case SENS_CALIBIRATION_VALUE_PARAM:  
      *(uint32 *)value = sens_Calib_Value_x_100;
      break;

    case SENS_TYPE_PARAM:  
      *(uint8 *)value = sens_Type;
      break;

    case SENS_TYPE_DISPLAY_CURRENT_VALUE_PARAM:  
      *(uint8 *)value = sens_Display_Current_Value;
      break;

    case SENS_GRAPH_LOG_SCALE_PARAM:  
      *(uint8 *)value = sens_Display_Log_Scale;
      break;

    case SENS_MODE_OP_PARAM:
      *(uint8 *)value = sensModeOp;
      break;

    case SENS_TIA_GAIN_PARAM:
      *(uint8 *)value = sensTIAGain;
      break;
      
    case SENS_R_LOAD_PARAM:
      *(uint8 *)value = sensRLoad;
      break;

    case SENS_INT_Z_SEL_PARAM:
      *(uint8 *)value = sensIntZSel;
      break;

    case SENS_REF_VOLTAGE_SOURCE_PARAM:
      *(uint8 *)value = sensRefVoltageSource;
      break;

    case NUSOCKET_LIGHT_ON_PARAM:
      *(uint8 *)value = nuSOCKET_LightOn;
      break;
      
    case SENS_SCALE_FACTOR_NUM_PARAM:  
      *(int32 *)value = sens_Scale_Factor_Num;
      break;
      
    case SENS_SCALE_FACTOR_DENOM_PARAM:  
      *(int32 *)value = sens_Scale_Factor_Denom;
      break;
 
    default:
      ret = INVALIDPARAMETER;
      break;
  }
  
  return ( ret );
}

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
bStatus_t sens_MeasNotify( uint16 connHandle, attHandleValueNoti_t *pNoti )
{
  uint16 value = GATTServApp_ReadCharCfg( connHandle, sensCommandClientCharCfg );

  // If notifications enabled
  if ( value & GATT_CLIENT_CFG_NOTIFY )
  {
    // Set the handle
    pNoti->handle = sensAttrTbl[SENS_MEAS_VALUE_POS].handle;
  
    // Send the notification
    return GATT_Notification( connHandle, pNoti, FALSE );
  }

  return bleIncorrectMode;
}
                               
/*********************************************************************
 * @fn          heartRate_ReadAttrCB
 *
 * @brief       Read an attribute.
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
static uint8 sens_ReadAttrCB( uint16 connHandle, gattAttribute_t *pAttr, 
                              uint8 *pValue, uint8 *pLen, uint16 offset, uint8 maxLen )
{
  uint8  i;  
  bStatus_t status = SUCCESS;

  // Make sure it's not a blob operation (no attributes in the profile are long)
  if ( offset > 0 )
  {
    return ( ATT_ERR_ATTR_NOT_LONG );
  }

  uint16 uuid = BUILD_UINT16( pAttr->type.uuid[0], pAttr->type.uuid[1]);
  switch (uuid)
  {
    case SENS_DENOM_0_X_100_UUID:  
      *pLen = 4;
      pValue[0] = BREAK_UINT32 ((uint32)sens_Denom_0_x_100,0);
      pValue[1] = BREAK_UINT32 ((uint32)sens_Denom_0_x_100,1);
      pValue[2] = BREAK_UINT32 ((uint32)sens_Denom_0_x_100,2);
      pValue[3] = BREAK_UINT32 ((uint32)sens_Denom_0_x_100,3);
      break;

    case SENS_NUM_0_X_100_UUID:  
      *pLen = 4;
      pValue[0] = BREAK_UINT32 ((uint32)sens_Numer_0_x_100,0);
      pValue[1] = BREAK_UINT32 ((uint32)sens_Numer_0_x_100,1);
      pValue[2] = BREAK_UINT32 ((uint32)sens_Numer_0_x_100,2);
      pValue[3] = BREAK_UINT32 ((uint32)sens_Numer_0_x_100,3);
      break;
      
    case SENS_SUB_X_0_X_100_UUID:  
      *pLen = 4;
      pValue[0] = BREAK_UINT32 ((uint32)sens_Sub_0_x_100,0);
      pValue[1] = BREAK_UINT32 ((uint32)sens_Sub_0_x_100,1);
      pValue[2] = BREAK_UINT32 ((uint32)sens_Sub_0_x_100,2);
      pValue[3] = BREAK_UINT32 ((uint32)sens_Sub_0_x_100,3);
      break;

    case SENS_DENOM_1_X_100_UUID:  
      *pLen = 4;
      pValue[0] = BREAK_UINT32 ((uint32)sens_Denom_1_x_100,0);
      pValue[1] = BREAK_UINT32 ((uint32)sens_Denom_1_x_100,1);
      pValue[2] = BREAK_UINT32 ((uint32)sens_Denom_1_x_100,2);
      pValue[3] = BREAK_UINT32 ((uint32)sens_Denom_1_x_100,3);
      break;

    case SENS_GRAPH_TITLE_UUID:
      *pLen = SENS_GRAPH_TITLE_SIZE;
      for (i=0; i<SENS_GRAPH_TITLE_SIZE; i++)
        pValue[i] = sens_Graph_TitleUserDesp[i];
      break;

    case SENS_GRAPH_SUBTITLE_UUID:
      *pLen = SENS_GRAPH_SUBTITLE_SIZE;
      for (i=0; i<SENS_GRAPH_SUBTITLE_SIZE; i++)
        pValue[i] = sens_Graph_SubTitleUserDesp[i];
      break;
      
    case SENS_GRAPH_X_AXIS_CAPTION_UUID:
      *pLen = SENS_GRAPH_X_AXIS_CAPTION_SIZE;
      for (i=0; i<SENS_GRAPH_X_AXIS_CAPTION_SIZE; i++)
        pValue[i] = sens_Graph_X_Axis_CaptionUserDesp[i];
      break;

    case SENS_GRAPH_Y_AXIS_CAPTION_UUID:
      *pLen = SENS_GRAPH_Y_AXIS_CAPTION_SIZE;
      for (i=0; i<SENS_GRAPH_Y_AXIS_CAPTION_SIZE; i++)
        pValue[i] = sens_Graph_Y_Axis_CaptionUserDesp[i];
      break;

    case SENS_GRAPH_Y_AXIS_DISPLAY_MIN_UUID:  
      *pLen = 2;
      pValue[0] = LO_UINT16 (sens_Graph_Y_Axis_Display_Min);
      pValue[1] = HI_UINT16 (sens_Graph_Y_Axis_Display_Min);
      break;

    case SENS_GRAPH_Y_AXIS_DISPLAY_MAX_UUID:  
      *pLen = 2;
      pValue[0] = LO_UINT16 (sens_Graph_Y_Axis_Display_Max);
      pValue[1] = HI_UINT16 (sens_Graph_Y_Axis_Display_Max);
      break;
      
    case SENS_GRAPH_COLOR_TOP_MID_BOUNDARY_UUID:  
      *pLen = 2;
      pValue[0] = LO_UINT16 (sens_Graph_Color_Top_Mid_Boundary);
      pValue[1] = HI_UINT16 (sens_Graph_Color_Top_Mid_Boundary);
      break;

    case SENS_GRAPH_COLOR_MID_LOW_BOUNDARY_UUID:  
      *pLen = 2;
      pValue[0] = LO_UINT16 (sens_Graph_Color_Mid_Low_Boundary);
      pValue[1] = HI_UINT16 (sens_Graph_Color_Mid_Low_Boundary);
      break;

    case SENS_GRAPH_COLOR_TOP_VALUE_UUID:  
      *pLen = 4;
      pValue[0] = BREAK_UINT32 (sens_Graph_Color_Top_Value,0);
      pValue[1] = BREAK_UINT32 (sens_Graph_Color_Top_Value,1);
      pValue[2] = BREAK_UINT32 (sens_Graph_Color_Top_Value,2);
      pValue[3] = BREAK_UINT32 (sens_Graph_Color_Top_Value,3);
      break;

    case SENS_GRAPH_COLOR_MID_VALUE_UUID:  
      *pLen = 4;
      pValue[0] = BREAK_UINT32 (sens_Graph_Color_Mid_Value,0);
      pValue[1] = BREAK_UINT32 (sens_Graph_Color_Mid_Value,1);
      pValue[2] = BREAK_UINT32 (sens_Graph_Color_Mid_Value,2);
      pValue[3] = BREAK_UINT32 (sens_Graph_Color_Mid_Value,3);
      break;

    case SENS_GRAPH_COLOR_LOW_VALUE_UUID:  
      *pLen = 4;
      pValue[0] = BREAK_UINT32 (sens_Graph_Color_Low_Value,0);
      pValue[1] = BREAK_UINT32 (sens_Graph_Color_Low_Value,1);
      pValue[2] = BREAK_UINT32 (sens_Graph_Color_Low_Value,2);
      pValue[3] = BREAK_UINT32 (sens_Graph_Color_Low_Value,3);
      break;

    case SENS_CALIBIRATION_VALUE_X_100_UUID:  
      *pLen = 4;
      pValue[0] = BREAK_UINT32 (sens_Calib_Value_x_100,0);
      pValue[1] = BREAK_UINT32 (sens_Calib_Value_x_100,1);
      pValue[2] = BREAK_UINT32 (sens_Calib_Value_x_100,2);
      pValue[3] = BREAK_UINT32 (sens_Calib_Value_x_100,3);
      break;

    case SENS_SENSOR_TYPE_UUID:  
      *pLen = 1;
      pValue[0] = sens_Type;
      break;

    case SENS_DISPLAY_CURRENT_VALUE_UUID:  
      *pLen = 1;
      pValue[0] = sens_Display_Current_Value;
      break;

    case SENS_GRAPH_LOG_SCALE_UUID:  
      *pLen = 1;
      pValue[0] = sens_Display_Log_Scale;
      break;

    case SENS_MODE_OP_UUID:  
      *pLen = 1;
      pValue[0] = sensModeOp;
      break;

    case SENS_TIA_GAIN_UUID:  
      *pLen = 1;
      pValue[0] = sensTIAGain;
      break;

    case SENS_R_LOAD_UUID:  
      *pLen = 1;
      pValue[0] = sensRLoad;
      break;

    case SENS_INT_Z_SEL_UUID:  
      *pLen = 1;
      pValue[0] = sensIntZSel;
      break;

    case SENS_REF_VOLTAGE_SOURCE_UUID:  
      *pLen = 1;
      pValue[0] = sensRefVoltageSource;
      break;

    case NUSOCKET_LIGHT_ON_UUID:  
      *pLen = 1;
      pValue[0] = nuSOCKET_LightOn;
      break;
      
    case SENS_SHORT_CAPTION_UUID:
      *pLen = SENS_SHORT_CAPTION_SIZE;
      for (i=0; i<SENS_SHORT_CAPTION_SIZE; i++)
        pValue[i] = sens_Short_CaptionUserDesp[i];
      break;
      
    case SENS_SCALE_FACTOR_NUM_UUID:  
      *pLen = 4;
      pValue[0] = BREAK_UINT32 ((uint32)sens_Scale_Factor_Num,0);
      pValue[1] = BREAK_UINT32 ((uint32)sens_Scale_Factor_Num,1);
      pValue[2] = BREAK_UINT32 ((uint32)sens_Scale_Factor_Num,2);
      pValue[3] = BREAK_UINT32 ((uint32)sens_Scale_Factor_Num,3);
      break;
      
    case SENS_SCALE_FACTOR_DENOM_UUID:  
      *pLen = 4;
      pValue[0] = BREAK_UINT32 ((uint32)sens_Scale_Factor_Denom,0);
      pValue[1] = BREAK_UINT32 ((uint32)sens_Scale_Factor_Denom,1);
      pValue[2] = BREAK_UINT32 ((uint32)sens_Scale_Factor_Denom,2);
      pValue[3] = BREAK_UINT32 ((uint32)sens_Scale_Factor_Denom,3);
      break;
       
    default:
      status = ATT_ERR_ATTR_NOT_FOUND;
      
  }

  return ( status );
}

/*********************************************************************
 * @fn      heartRate_WriteAttrCB
 *
 * @brief   Validate attribute data prior to a write operation
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
static bStatus_t sens_WriteAttrCB( uint16 connHandle, gattAttribute_t *pAttr,
                                   uint8 *pValue, uint8 len, uint16 offset )
{
  bStatus_t status = SUCCESS;
 
  uint16 uuid = BUILD_UINT16( pAttr->type.uuid[0], pAttr->type.uuid[1]);
  switch ( uuid )
  {
    case SENS_COMMAND_UUID:
      if ( offset > 0 )
      {
        status = ATT_ERR_ATTR_NOT_LONG;
      }
      else if (len != 1)
      {
        status = ATT_ERR_INVALID_VALUE_SIZE;
      }
      else if (*pValue != SENS_COMMAND_ENERGY_EXP)
      {
        status = SENS_ERR_NOT_SUP;
      }
      else
      {
        *(pAttr->pValue) = pValue[0];
        
        (*sensServiceCB)(SENS_COMMAND_SET);
        
      }
      break;

    case SENS_MODE_OP_UUID:
    case SENS_TIA_GAIN_UUID:
    case SENS_R_LOAD_UUID:
    case SENS_INT_Z_SEL_UUID:
    case SENS_REF_VOLTAGE_SOURCE_UUID:
    case NUSOCKET_LIGHT_ON_UUID:
      if ( offset > 0 )
      {
        status = ATT_ERR_ATTR_NOT_LONG;
      }
      else if (len != 1)
      {
        status = ATT_ERR_INVALID_VALUE_SIZE;
      }
      else
      {
        *(pAttr->pValue) = pValue[0];
        
//        (*sensServiceCB)(SENS_HARDWARE_SET);
      }
      break;

    case GATT_CLIENT_CHAR_CFG_UUID:
      status = GATTServApp_ProcessCCCWriteReq( connHandle, pAttr, pValue, len,
                                               offset, GATT_CLIENT_CFG_NOTIFY );
      if ( status == SUCCESS )
      {
        uint16 charCfg = BUILD_UINT16( pValue[0], pValue[1] );

        (*sensServiceCB)( (charCfg == GATT_CFG_NO_OPERATION) ?
                                      SENS_MEAS_NOTI_DISABLED :
                                      SENS_MEAS_NOTI_ENABLED );
      }
      break;       
 
    default:
      status = ATT_ERR_ATTR_NOT_FOUND;
      break;
  }

  return ( status );
}

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
void sens_HandleConnStatusCB( uint16 connHandle, uint8 changeType )
{ 
  // Make sure this is not loopback connection
  if ( connHandle != LOOPBACK_CONNHANDLE )
  {
    // Reset Client Char Config if connection has dropped
    if ( ( changeType == LINKDB_STATUS_UPDATE_REMOVED )      ||
         ( ( changeType == LINKDB_STATUS_UPDATE_STATEFLAGS ) && 
           ( !linkDB_Up( connHandle ) ) ) )
    { 
      GATTServApp_InitCharCfg( connHandle, sensCommandClientCharCfg );
    }
  }
}


/**************************************************************************************************
 * @fn          get_SensHardwareSettings
 *
 * @brief       Returns the configuration settings used to configure the LMP91000 for sensors
 *
 * @param[out]  uint8 *op_mode - LMP91000 Operational Mode
 *                                       OP_MODE_DEEP_SLEEP, OP_MODE_2_LEAD, OP_MODE_STANDBY,
 *                                       OP_MODE_3_LEAD, OP_MODE_TEMP_MEAS_TIA_OFF, or OP_MODE_TEMP_MEAS_TIA_ON 
 * @param[out]  uint8 *tiaGain - LMP91000 TIA Gain
 *                                       TIA_GAIN_EXT_RESIST, TIA_GAIN_2_75_OHM, TIA_GAIN_3_5_OHM,
 *                                       TIA_GAIN_7_OHM, TIA_GAIN_14_OHM, TIA_GAIN_35_OHM,
 *                                       TIA_GAIN_120_OHM, or TIA_GAIN_350_OHM 
 * @param[out]  uint8 *rLoad - LMP91000 Resistive Load
 *                                       R_LOAD_10_OHM, R_LOAD_30_OHM, R_LOAD_50_OHM, or R_LOAD_100_OHM 
 * @param[out]  uint8 *refVoltageSource - LMP91000 Reference Source
 *                                       REF_SOURCE_INTERNALor REF_SOURCE_EXTERNAL
 * @param[out]  uint8 intZSel - LMP91000 Internal Zero (VREF Divider)
 *                                       INT_Z_SEL_20_PERCENT, INT_Z_SEL_50_PERCENT, 
 *                                       INT_Z_SEL_67_PERCENT, or INT_Z_SEL_BYPASS
 *
 * @return      none
 **************************************************************************************************
 */
void get_SensHardwareSettings (uint8 *modeOp, uint8 *tiaGain, uint8 *rLoad, uint8 *refVoltageSource, uint8 *intZSel)
{
   *modeOp = sensModeOp;
   *tiaGain = sensTIAGain;
   *rLoad = sensRLoad;
   *intZSel = sensIntZSel;
   *refVoltageSource = sensRefVoltageSource;
}

/**************************************************************************************************
 * @fn          get_nuSOCKET_LightSettings
 *
 * @brief       Returns the nuSOCKET light characteristics
 *
 * @param[out]  uint8 *lightOn - nuSOCKET Light Control 
 *
 * @return      none
 **************************************************************************************************
 */
void get_nuSOCKET_LightSettings (uint8 *lightOn)
{
   *lightOn = nuSOCKET_LightOn;
}
/*********************************************************************
*********************************************************************/
