/*
 *  TIBLESettingsManager.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLESettingsManager.h"
#import "TIBLESensorProfile.h"
#import "TIBLEFormulaSettingsViewController.h"
#import "TIBLEGraphDisplaySettingsViewController.h"
#import "TIBLESensorSettingsViewController.h"
#import "TIBLEUserDefaultConstants.h"
#import "TIBLEDevicesManager.h"
#import "TIBLEUIConstants.h"
#import "TIBLEResourceConstants.h"

@interface TIBLESettingsManager ()

@property (nonatomic, strong) TIBLESensorProfile * emptySensorProfile;

@end
@implementation TIBLESettingsManager

+ (TIBLESettingsManager *)sharedTIBLESettingsManager {
    static TIBLESettingsManager *sharedTIBLESettingsmanager = nil;
    if(!sharedTIBLESettingsmanager) {
        sharedTIBLESettingsmanager = [[super allocWithZone:nil] init];
    }

    return sharedTIBLESettingsmanager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedTIBLESettingsManager];
}

- (id)init {
    self = [super init];
    if(self) {
        allSettings = [NSKeyedUnarchiver unarchiveObjectWithFile:[self settingsArchivePath]];
        
        if (!allSettings) {
            allSettings = [[NSMutableArray alloc] init];
        }
        
		self.emptySensorProfile = [[TIBLESensorProfile alloc] init];
		
        [self setSeletedSettingIndex:NO_SETTING_SELECTED];
        
        [self registerForNotifications];
    }
    
    return self;
}

- (NSMutableArray *)allSettings {
    return allSettings;
}

- (void)createSetting {
    TIBLESensorProfile *tempSetting = [self.setting copy];
    [allSettings addObject:tempSetting];
     self.setting = tempSetting;
}

- (NSString *)settingsArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:kSettingsArchiveFileName];
}

- (BOOL)saveSettings {
    NSString *path = [self settingsArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:allSettings toFile:path];
}

- (void)removeSetting:(TIBLESensorProfile *)setting {
    [allSettings removeObjectIdenticalTo:setting];
    
    [self saveSettings];
}

- (void)setSetting {
    TIBLESensorProfile *setting = nil;
    
    int selectedSettingIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedSettingIndexKey];
    
    if (selectedSettingIndex != NO_SETTING_SELECTED) {
        // one of the settings is selected
        setting = [self.allSettings objectAtIndex:selectedSettingIndex];
    }
    
    else if ([[[[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor] peripheral].peripheral  isConnected]) {
        // no setting selected, but device is connected
        setting = [[[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor] sensorProfile];
    }
    else {
        // no setting selected and there is no device connected
        setting = self.emptySensorProfile;
    }

    [self setSetting:setting];
}

#pragma mark - notificaions
- (void) registerForNotifications{
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorChanged:)
												 name:TIBLE_NOTIFICATION_UPDATE_CONNECTED_SENSOR_CHANGED
											   object:nil];
}


- (void) connectedSensorChanged:(NSNotification *) notif {
    
    if ([[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor]) {
        [self setSeletedSettingIndex:NO_SETTING_SELECTED];
    }
    else {
        [self setSetting];
    }
}

- (void)setSeletedSettingIndex:(int)index {
    
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:kSelectedSettingIndexKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setSetting];
}

- (void) dealloc{
	
	allSettings = nil;
	self.setting = nil;
	self.emptySensorProfile = nil;
}

@end
