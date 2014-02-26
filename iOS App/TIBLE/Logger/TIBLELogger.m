/*
 *  TIBLELogger.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLELogger.h"

@implementation TIBLELogger


#pragma mark -
#pragma mark Public methods

+ (void)log:(NSString *)format arguments:(va_list)argList
{
	NSLogv(format, argList);
}

+ (void)log:(NSString *)format, ...
{
    if (TIBLE_LOG_LEVEL > TIBLELogLevelNone &&
		TIBLE_LOG_LEVEL <= TIBLELogLevelAll)
    {
        va_list argList;
        va_start(argList,format);
        [self log:format arguments:argList];
        va_end(argList);
    }
}

+ (void)detail:(NSString *)format, ...{
	
	if (TIBLE_LOG_LEVEL >= TIBLELogLevelDetail)
    {
        va_list argList;
        va_start(argList, format);
        [self log:[@"DETAIL: " stringByAppendingString:format] arguments:argList];
        va_end(argList);
    }
}

+ (void)info:(NSString *)format, ...
{
    if (TIBLE_LOG_LEVEL >= TIBLELogLevelInfo)
    {
        va_list argList;
        va_start(argList, format);
        [self log:[@"INFO: " stringByAppendingString:format] arguments:argList];
        va_end(argList);
    }
}

+ (void)warn:(NSString *)format, ...
{
	if (TIBLE_LOG_LEVEL >= TIBLELogLevelWarning)
    {
        va_list argList;
        va_start(argList, format);
        [self log:[@"WARNING: " stringByAppendingString:format] arguments:argList];
        va_end(argList);
    }
}

+ (void)error:(NSString *)format, ...
{
    if (TIBLE_LOG_LEVEL >= TIBLELogLevelError)
    {
        va_list argList;
        va_start(argList, format);
        [self log:[@"ERROR: " stringByAppendingString:format] arguments:argList];
        va_end(argList);
    }
}

+ (void)crash:(NSString *)format, ...
{
    if (TIBLE_LOG_LEVEL >= TIBLELogLevelCrash)
    {
        va_list argList;
        va_start(argList, format);
        [self log:[@"CRASH: " stringByAppendingString:format] arguments:argList];
        va_end(argList);
    }
}

@end
