/*
 *  TIBLEScatterPlotViewController+DataSource.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEScatterPlotViewController.h"
#import "TIBLEPlotConstants.h"

@interface TIBLEScatterPlotViewController (DataSource)<CPTPlotDataSource>

- (void) reloadPlotData;
- (void) setPaused:(BOOL) value;
- (void) removeSamplesAndReload;

@end
