/*
 *  TIBLEAppDelegate.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <UIKit/UIKit.h>
#import "TIBLERootViewControllerProtocol.h"
#import "TIBLESensorConstants.h"

@interface TIBLEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (weak, nonatomic) UIViewController * rootViewController;
@property (weak, nonatomic) id<TIBLERootViewControllerProtocol> rootVC;
@property (nonatomic, assign) BOOL showSettings;

@end



/*
App ID Description (Product Name):      TI Gas Sensor
Identifier:                             TLEVLB8B5D.com.ti.sc.tigassensor 

*/