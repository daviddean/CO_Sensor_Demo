/*
 *  TIBLEPlotConstants.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "CorePlot-CocoaTouch.h"

__unused static const NSUInteger kMaxTimeSamples = 20;

__unused static const NSString * kPlotIdentifier = @"TI_BLE_Scatter_Plot";

__unused static const float CPDPlotTitleFontSize = 16.0f;
__unused static const float CPDPlotAxisTitleFontSize = 12.0f;
__unused static const float CPDPlotAxisTextFontSize = 11.0f;

#define DEFAULT_NUMBER_OF_BANDS 3
#define EXTRA_SPACE_PERCENT_Y_AXIS_FOR_ANNOTATION 0.4f
#define EXTRA_SPACE_PERCENT_X_AXIS_FOR_ANNOTATION 0.4f
#define GRAPH_MIN_RANGE_LENGHT 0.5f

typedef enum {
    BAND_LOW = 1,
    BAND_MID = 2,
    BAND_TOP = 3
} CPDBandType;


@interface TIBLEPlotConstants : NSObject


@end