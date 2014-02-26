/*
 *  TIBLEMainScreenViewController_iPad.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEMainScreenViewController_iPad.h"
#import "TIBLELoadingViewController.h"
#import "TIBLENoSensorAvailableViewController.h"
#import "TIBLEDevicesManager.h"
#import "TIBLEUIConstants.h"
#import "TIBLEFeatures.h"

@interface TIBLEMainScreenViewController_iPad ()

@property (weak, nonatomic) IBOutlet UIView *sensorInfoView;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIView *graphView;
@property (nonatomic, assign) BOOL displayNoSensorAvailableUI;
@property (nonatomic, strong) TIBLENoSensorAvailableViewController * noSensorAvailableVC;
@property (nonatomic, strong) TIBLELoadingViewController * loadingVC;
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation TIBLEMainScreenViewController_iPad


- (NSString*) nibNameRotated:(UIInterfaceOrientation)orientation className:(NSString *) className
{
    if( UIInterfaceOrientationIsLandscape(orientation))
		return [NSString stringWithFormat:@"%@-landscape", className];

    return [NSString stringWithFormat:@"%@", className];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	
	if(nibNameOrNil == nil){
		nibNameOrNil = [self nibNameRotated:orientation
								  className:NSStringFromClass([self class])];
	}
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		
		self.title = NSLocalizedString(@"MainScreen.title", nil);
		self.accessibilityLabel = TIBLE_UI_COMPONENT_MAIN_VC_IDENTIFIER;
		self.navigationController.accessibilityLabel = TIBLE_UI_COMPONENT_MAIN_VC_IDENTIFIER;
		
		NSString * nibname = [self nibNameRotated:orientation className:@"TIBLEProgressViewController"];
		
		self.progressVC = [[TIBLEProgressViewController alloc] initWithNibName:nibname
																		bundle:nil];
		
		nibname = [self nibNameRotated:orientation className:@"TIBLESensorInfoViewController"];
		
		self.sensorInfoVC = [[TIBLESensorInfoViewController alloc] initWithNibName:nibname
																			bundle:nil];
		
		nibname = [self nibNameRotated:orientation className:@"TIBLEGraphViewController"];
		
		self.graphVC = [[TIBLEGraphViewController alloc] initWithNibName:nibname
																  bundle:nil];
	
		self.noSensorAvailableVC = [[TIBLENoSensorAvailableViewController alloc] initWithNibName:@"TIBLENoSensorAvailableViewController" bundle:nil];
		
		self.loadingVC = [[TIBLELoadingViewController alloc] initWithNibName:@"TIBLELoadingViewController" bundle:nil];
		
		self.isLoading = self.service.isReadingCharacteristics;
		
		self.displayNoSensorAvailableUI = TIBLE_FEATURE_ENABLE_NO_SENSOR_AVAILABLE_UI;
    }
    return self;
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

- (void) updateViews{
	
	
	if(self.isViewLoaded == NO){
		
		[TIBLELogger detail:@"TIBLEDashboardViewController_iPad - Not updating views since view is not loaded."];
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

- (void) displaySensorNotAvailableViews{
	
	//remove
	if([self.mainScreenParentContainerView isDescendantOfView:self.view] == YES){
		[self.mainScreenParentContainerView removeFromSuperview];
	}
	
	if([self.loadingVC.view isDescendantOfView:self.view] == YES){
		[self.loadingVC.view removeFromSuperview];
	}
	
	//add
	if([self.noSensorAvailableVC.view isDescendantOfView:self.view] == NO){
		[self.view addSubview:self.noSensorAvailableVC.view];
	}
	
	//resize
	self.noSensorAvailableVC.view.frame = self.view.bounds;
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
	if([self.mainScreenParentContainerView isDescendantOfView:self.view] == NO)
		[self.view addSubview:self.mainScreenParentContainerView];
	
	//resize
	self.mainScreenParentContainerView.frame = self.view.bounds;
}

- (void) displayLoadingView{
	
	//remove
	if([self.mainScreenParentContainerView isDescendantOfView:self.view] == YES)
		[self.mainScreenParentContainerView removeFromSuperview];
	
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

- (void) unregisterForNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
	
	[self unregisterForNotifications];

	[self setSensorInfoView:nil];
	[self setProgressView:nil];
	[self setGraphView:nil];
	
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	//[TIBLELogger detail:@"MainScreen view: frame:\n"];
	//[self printViewFrame:self.view];
	
	//[TIBLELogger detail:@"MainScreen parent container frame: \n"];
	//[self printViewFrame:self.mainScreenParentContainerView];
	
	//add views
	[self.progressView addSubview:self.progressVC.view];
	[self.sensorInfoView addSubview:self.sensorInfoVC.view];
	[self.graphView addSubview:self.graphVC.view];
	
	//resize views
	self.progressVC.view.frame = self.progressView.bounds;
	self.sensorInfoVC.view.frame = self.sensorInfoView.bounds;
	self.graphVC.view.frame = self.graphView.bounds;
	
	//add VC
	[self addChildViewController:self.progressVC];
	[self addChildViewController:self.sensorInfoVC];
	[self addChildViewController:self.graphVC];
	[self addChildViewController:self.noSensorAvailableVC];
	[self addChildViewController:self.loadingVC];
	
	[self registerForNotifications];
	
	[self updateViews];
}

- (void) printViewFrame:(UIView *) uiview{
	
	[TIBLELogger detail:@"\t frame: x:%f y:%f w:%f h:%f",
		  uiview.frame.origin.x,
		  uiview.frame.origin.y,
		  uiview.frame.size.width,
		  uiview.frame.size.height];
}

- (void) printViewBounds:(UIView *) uiview{
	
	[TIBLELogger detail:@"\t bounds: x:%f y:%f w:%f h:%f",
		  uiview.bounds.origin.x,
		  uiview.bounds.origin.y,
		  uiview.bounds.size.width,
		  uiview.bounds.size.height];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
