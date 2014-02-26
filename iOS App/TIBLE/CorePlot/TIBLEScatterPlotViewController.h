/*
 *  TIBLEScatterPlotViewController.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */


#import <UIKit/UIKit.h>
#import "TIBLEPlotConstants.h"

@interface TIBLEScatterPlotViewController : UIViewController

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTPlotSpaceAnnotation * valueAnnotation;
@property (nonatomic, strong) NSMutableArray * plotData;
@property (assign, nonatomic) BOOL isPaused;
@property (nonatomic, strong) NSMutableArray * limitBandsArray;
@property (nonatomic, assign) BOOL displayCurrentValue;
@property (nonatomic, assign) BOOL displayLogarithmicScale;

- (void) cleanup;

@end
