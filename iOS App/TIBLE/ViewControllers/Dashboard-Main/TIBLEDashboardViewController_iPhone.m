/*
 *  TIBLEDashboardViewController_iPhone.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEDashboardViewController_iPhone.h"
#import "TIBLEUIConstants.h"
#import "TIBLEDevicesManager.h"
#import "TIBLENoSensorAvailableViewController.h"
#import "TIBLEStretchableImageView.h"
#import "TIBLEFeatures.h"
#import "TIBLELoadingViewController.h"

@interface TIBLEDashboardViewController_iPhone ()


@property (strong, nonatomic) IBOutlet UIView *sensorInfoView;
@property (strong, nonatomic) IBOutlet UIView *progressView;
@property (strong, nonatomic) IBOutlet UIView *dashboardParentContainerView;

@property (nonatomic, strong) TIBLENoSensorAvailableViewController * noSensorAvailableVC;
@property (nonatomic, assign) BOOL displayNoSensorAvailableUI;

@property (nonatomic, strong) TIBLELoadingViewController * loadingVC;
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation TIBLEDashboardViewController_iPhone

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	
    if (self) {

		self.title = NSLocalizedString(@"Dashboard.title", nil);
        self.navigationController.title = NSLocalizedString(@"Dashboard.title", @"Dashboard title");
        
		self.accessibilityLabel = TIBLE_UI_COMPONENT_DASHBOARD_VC_IDENTIFIER;
		self.navigationController.accessibilityLabel = TIBLE_UI_COMPONENT_DASHBOARD_VC_IDENTIFIER;
		
		//init view controllers
		self.progressVC = [[TIBLEProgressViewController alloc] initWithNibName:@"TIBLEProgressViewController" bundle:nil];
		self.sensorInfoVC = [[TIBLESensorInfoViewController alloc] initWithNibName:@"TIBLESensorInfoViewController" bundle:nil];
		self.noSensorAvailableVC = [[TIBLENoSensorAvailableViewController alloc] initWithNibName:@"TIBLENoSensorAvailableViewController" bundle:nil];
		
		self.loadingVC = [[TIBLELoadingViewController alloc] initWithNibName:@"TIBLELoadingViewController" bundle:nil];
		self.isLoading = self.service.isReadingCharacteristics;
		
		self.displayNoSensorAvailableUI = TIBLE_FEATURE_ENABLE_NO_SENSOR_AVAILABLE_UI;
    }
	
    return self;
}

- (void) registerForNotifications{
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorChanged:)
												 name:TIBLE_NOTIFICATION_UPDATE_CONNECTED_SENSOR_CHANGED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorStartedReadingCharacteristics:)
												 name:TIBLE_NOTIFICATION_BLE_CHARACTERISTICS_READING_STARTED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorEndedReadingCharacteristics:)
												 name:TIBLE_NOTIFICATION_BLE_CHARACTERISTICS_READING_ENDED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorIsReceivingSamples:)
												 name:TIBLE_NOTIFICATION_BLE_RECEIVING_SAMPLES
											   object:nil];
}

- (TIBLEService *) service{
	
	return [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedService];
}

- (TIBLESensorModel * ) sensor{
	
	return [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
}

- (void) connectedSensorStartedReadingCharacteristics: (NSNotification *) notif{
	
	//do nothing.
}

- (void) connectedSensorEndedReadingCharacteristics: (NSNotification *) notif{
	//do nothing.
}

- (void) connectedSensorIsReceivingSamples: (NSNotification *) notif{
	
	self.isLoading = NO;
	
	[self updateViews];
}

- (void) connectedSensorChanged: (NSNotification *) notif{
	
	self.isLoading = YES;
	
	[self updateViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//add
	[self.sensorInfoView addSubview:self.sensorInfoVC.view];
	[self.progressView addSubview:self.progressVC.view];
	
	//resize
	self.sensorInfoVC.view.frame = self.sensorInfoView.bounds;
	self.progressVC.view.frame = self.progressView.bounds;
	
	//add the following view controllers as children.
	[self addChildViewController:self.progressVC];
	[self addChildViewController:self.sensorInfoVC];
	[self addChildViewController:self.noSensorAvailableVC];
	[self addChildViewController:self.loadingVC];
	
	[self registerForNotifications];
	
	[self updateViews];
}

- (void) displaySensorAvailableViews{

	//remove
	if([self.noSensorAvailableVC.view isDescendantOfView:self.view] == YES){
		[self.noSensorAvailableVC.view removeFromSuperview];
	}
	
	if([self.loadingVC.view isDescendantOfView:self.view] == YES){
		[self.loadingVC.view removeFromSuperview];
	}
	
	//add
	if([self.dashboardParentContainerView isDescendantOfView:self.view] == NO){
		[self.view addSubview:self.dashboardParentContainerView];
	}
	
	//resize
	self.dashboardParentContainerView.frame = CGRectMake(0.0f,
														 0.0f,
														 self.view.bounds.size.width,
														 self.view.bounds.size.height);
}

- (void) displaySensorNotAvailableViews{
	
	//remove
	if([self.dashboardParentContainerView isDescendantOfView:self.view] == YES)
		[self.dashboardParentContainerView removeFromSuperview];

	if([self.loadingVC.view isDescendantOfView:self.view] == YES){
		[self.loadingVC.view removeFromSuperview];
	}

	//add
	if([self.noSensorAvailableVC.view isDescendantOfView:self.view] == NO)
		[self.view addSubview:self.noSensorAvailableVC.view];
	
	//resize
	self.noSensorAvailableVC.view.frame = CGRectMake(0.0f,
													 0.0f,
													 self.view.bounds.size.width,
													 self.view.bounds.size.height);
}

- (void) displayLoadingView{
	
	//remove
	if([self.dashboardParentContainerView isDescendantOfView:self.view] == YES)
		[self.dashboardParentContainerView removeFromSuperview];
		
	if([self.noSensorAvailableVC.view isDescendantOfView:self.view] == YES)
		[self.noSensorAvailableVC.view removeFromSuperview];
	
	//add
	if([self.loadingVC.view isDescendantOfView:self.view] == NO){
		[self.view addSubview:self.loadingVC.view];
	}
	
	//resize
	self.loadingVC.view.frame = CGRectMake(0.0f,
										   0.0f,
										   self.view.bounds.size.width,
										   self.view.bounds.size.height);
}

- (void) updateViews{
	
	
	if(self.isViewLoaded == NO){
		
		[TIBLELogger detail:@"TIBLEDashboardViewController_iPhone - Not updating views since view is not loaded."];
	}
	else if(self.sensor != nil){

		if(self.isLoading == YES){
			
			[self displayLoadingView];
		}
		else{
			[self displaySensorAvailableViews];
		}
	}
	else { //sensor = nil
	
		if(self.displayNoSensorAvailableUI){
			
			[self displaySensorNotAvailableViews];
		}
		else{
			[self displaySensorAvailableViews];
		}
	}
	
	[self.view setNeedsLayout];
	[self.view setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) unregisterForNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) dealloc{

	[self unregisterForNotifications];
	
	[self setDashboardParentContainerView:nil];
	[self setSensorInfoView:nil];
	[self setProgressView:nil];
}

@end
