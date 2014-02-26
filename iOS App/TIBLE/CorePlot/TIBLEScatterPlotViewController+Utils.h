//
//  TIBLEScatterPlotViewController+Utils.h
//  TIBLE
//
//  Created by meli on 5/21/13.
//  Copyright (c) 2013 Krasamo. All rights reserved.
//

#import "TIBLEScatterPlotViewController.h"

@interface TIBLEScatterPlotViewController (Utils)

- (CPTMutableLineStyle *) getGridLineStyle;
- (CPTMutableLineStyle *) getTickLineStyle;
- (CPTMutableTextStyle *) getAxisTextStyle;
- (CPTMutableLineStyle *) getAxisLineStyle;
- (CPTMutableTextStyle *) getAxisTitleStyle;
- (CPTMutableTextStyle *) getAnnotationTextStyle;
- (CPTColor *) colorForUIColor: (UIColor *) colorUIObj;
- (NSNumberFormatter *) getLabelFormatter:(float_t) value;

@end
