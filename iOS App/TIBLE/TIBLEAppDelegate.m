/*
 *  TIBLEAppDelegate.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEAppDelegate.h"
#import "TIBLEDevicesManager.h"
#import "TIBLELogger.h"
#import "TIBLEUIConstants.h"
#import "TIBLEFeatures.h"
#import "TIBLEResourceConstants.h"

@interface TIBLEAppDelegate ()

@end

@implementation TIBLEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

	UIStoryboard * mainStoryboard = nil;
	
	//Get story board
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		// The device is an iPad running iPhone 3.2 or later.
		mainStoryboard = [UIStoryboard storyboardWithName:kMain_Storyboard_iPad bundle:nil];
	}
	else
	{
		// The device is an iPhone or iPod touch.
		mainStoryboard = [UIStoryboard storyboardWithName:kMain_Storyboard_iPhone bundle:nil];
	}

	self.rootViewController = [mainStoryboard instantiateInitialViewController];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	[self.window setRootViewController:self.rootViewController];
	
	[self.window makeKeyAndVisible];

	if([self.rootViewController conformsToProtocol:@protocol(TIBLERootViewControllerProtocol)])
	{
		self.rootVC = (id<TIBLERootViewControllerProtocol>) self.rootViewController;
	}
	
	[[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
	
	[self addOrRemoveSettings];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppEnteredBackgroundNotification object:self];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppEnteredForegroundNotification object:self];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	
	[self addOrRemoveSettings];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) addOrRemoveSettings{
	
	if(TIBLE_FEATURE_ENABLE_SETTINGS){
	
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		self.showSettings = [[NSUserDefaults standardUserDefaults] boolForKey:(NSString *)TIBLE_SHOW_SETTINGS_IDENTIFIER];
		
		//UI is constructed showing settings.
		//By default this property is NO in settings bundle, thus we need to hide settings UI.
		
		if(self.showSettings){
			[self.rootVC showSettings];
		}
		else{
			[self.rootVC hideSettings];
		}
		
	}
	else{
		//make sure it is not visible
		[self.rootVC hideSettings];
	}
}


@end
