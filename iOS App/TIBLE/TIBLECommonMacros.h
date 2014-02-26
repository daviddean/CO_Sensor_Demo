/*
 *  TIBLECommonMacros.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#ifndef TIBLE_TIBLECommonMacros_h
#define TIBLE_TIBLECommonMacros_h

#define SINGLETON_FOR_CLASS(classname) \
\
+ (id) shared##classname \
{ \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = [[self alloc] init]; \
}); \
return _sharedObject;\
}

#endif
