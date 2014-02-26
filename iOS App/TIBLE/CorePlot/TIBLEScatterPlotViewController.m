/*
 *  TIBLEScatterPlotViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEScatterPlotViewController.h"
#import "TIBLEResourceConstants.h"
#import "TIBLEUIConstants.h"

#import "TIBLEScatterPlotViewController+DataSource.h"
#import "TIBLEScatterPlotViewController+RealTimeRefresh.h"
#import "TIBLEScatterPlotViewController+Utils.h"
#import "TIBLEScatterPlotViewController+Annotation.h"
#import "TIBLEScatterPlotViewController+PlotSpace.h"

@interface TIBLEScatterPlotViewController (){
	
}

@end

@implementation TIBLEScatterPlotViewController

@synthesize hostView = hostView_;

#pragma mark - Init

- (id) init{
	
	self = [super init];
	
	if(self != nil){
		
		self.title = NSLocalizedString(@"GraphScreen.ScatterPlot.Title",
									   @"TI Gas Sensor Real Time Plot");
		
		self.limitBandsArray = [NSMutableArray arrayWithCapacity:DEFAULT_NUMBER_OF_BANDS];
		
		self.displayCurrentValue = NO;
		self.displayLogarithmicScale = NO;
	}
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Init called (%p)\n", self];
	
	return self;
}

#pragma mark - View Controller

//called first.
- (void) viewDidLoad{
	
	[super viewDidLoad];
	
	self.plotData = [[NSMutableArray alloc] initWithCapacity:TIBLE_MAX_SAMPLE_QUEUE_SIZE];
	
	self.isPaused = NO;
	self.displayLogarithmicScale = [self readIfLogScaleIsEnabledCharValue]; //defaults to NO.
	
	[self initPlot];
	
	[self reloadPlotData];
	
	[self registerForNotifications];
	
	[self.view setNeedsLayout];
	[self.view setNeedsDisplay];
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - View Did load called (%p)\n", self];
}

//called second.
- (void) viewDidAppear:(BOOL)animated{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - View Did Appear called (%p)\n", self];
	
	[super viewDidAppear:animated];
	
	[self refreshPlot];
	
	[self.view setNeedsLayout];
	[self.view setNeedsDisplay];
}

- (void)viewDidLayoutSubviews{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - View Did Layout Subviews called (%p)\n", self];
	
	self.hostView.frame = self.view.bounds;
	[self.hostView setNeedsLayout];
	[self.hostView setNeedsDisplay];
}

- (void)viewDidUnload
{
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - View Did Unload called (%p)\n", self];
	
	[self unregisterForNotifications];
	
	[super viewDidUnload];
}

#pragma mark - Memory

-(void) dealloc{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Dealloc Plot called (%p)\n", self];
}

- (void)didReceiveMemoryWarning{
	
    [super didReceiveMemoryWarning];
}

- (void) cleanup{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Cleanup Plot called (%p)\n", self];
	
	self.hostView.hostedGraph.defaultPlotSpace.delegate = nil;
	[self.hostView.hostedGraph plotWithIdentifier:kPlotIdentifier].delegate = nil;
	self.hostView.hostedGraph = nil;
	self.hostView = nil;
	[self.plotData removeAllObjects];
	[self unregisterForNotifications];
}

#pragma mark - Rotation

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return NO;
}

#pragma mark - Notifications

- (void) registerForNotifications{
	
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Registering for Notifications (%p)\n", self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(calibrationStarted:)
												 name:TIBLE_NOTIFICATION_BLE_CALIBRATION_STARTED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(calibrationEnded:)
												 name:TIBLE_NOTIFICATION_BLE_CALIBRATION_ENDED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(sampleAdded:)
												 name:TIBLE_NOTIFICATION_UPDATE_MEASUREMENT_SAMPLE_RECEIVED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(characteristicUpdated:)
												 name:TIBLE_NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED
											   object:nil];
}

- (void) unregisterForNotifications{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Unregistering for Notifications (%p)\n", self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Callbacks

- (void) calibrationStarted:(NSNotification *) notif{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Calibration Started Callback called (%p)\n", self];
}

- (void) calibrationEnded:(NSNotification *) notif{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Calibration Ended Callback called (%p)\n", self];
	[self refreshPlot];
}

#pragma mark - Configure Graph

-(void)initPlot {
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Init Plot called (%p)\n", self];
	
    [self configureHost];
    [self configureGraph];
    [self configurePlot];
	[self configureAxis];
}

-(void)configureHost {
    
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Configure Host called (%p)\n", self];
	
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    self.hostView.allowPinchScaling = YES; //enabled by default.
	
    [self.view addSubview:self.hostView];
}

-(void)configureGraph {
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Configure Graph called (%p)\n", self];
	
    //Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
	
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
	
	graph.fill = nil; //so it is clear but perfomance faster.
	graph.paddingTop = 0.0f;
	graph.paddingBottom = 0.0f;
	graph.paddingLeft = 0.0f;
	graph.paddingRight = 0.0f;
	
    self.hostView.hostedGraph = graph;
    
    //Set graph title
	graph.title = nil;
	
    //Set padding for plot area
    //add padding to the left and bottom to accommodate for axis labels and titles.
    [graph.plotAreaFrame setPaddingLeft:50.0f];
    [graph.plotAreaFrame setPaddingBottom:50.0f];
    [graph.plotAreaFrame setPaddingRight:10.0f];
    //[graph.plotAreaFrame setPaddingTop:15.0f];
	[graph.plotAreaFrame setPaddingTop:50.0f];
	
    //frame black shadow.
    graph.plotAreaFrame.shadowOffset = CGSizeMake(0.0, -1.0);
    graph.plotAreaFrame.shadowColor = [[UIColor blackColor] CGColor];
    graph.plotAreaFrame.shadowRadius = 2.0f;
    graph.plotAreaFrame.shadowOpacity = 1.0;
    
    //Enable user interactions for plot space
    //necessary for the pinch and zoom to work.
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
	plotSpace.delegate = self;
}

-(void)configurePlot {
    
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Configure Plot called (%p)\n", self];
	
    //Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    //samples
    CPTScatterPlot *samplesPlot = [[CPTScatterPlot alloc] init];
    samplesPlot.dataSource = self;
    samplesPlot.delegate = self;
    
	samplesPlot.identifier     = kPlotIdentifier;
    samplesPlot.cachePrecision = CPTPlotCachePrecisionDouble;
	
	// The default is 0, which means you have to hit the center of the point exactly to register a touch.
	samplesPlot.plotSymbolMarginForHitDetection = 5.0f;
	
    [graph addPlot:samplesPlot toPlotSpace:plotSpace];
    
    //add style to the samples
    CPTMutableLineStyle *samplesSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    samplesSymbolLineStyle.lineColor = [CPTColor blackColor];
    samplesPlot.dataLineStyle = nil;
    CPTPlotSymbol *samplesSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    samplesSymbol.fill = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
    samplesSymbol.lineStyle = samplesSymbolLineStyle;
    samplesSymbol.size = CGSizeMake(10.0, 10.0f); //FIX TODO how to make the touch area of the symbol tappabe or bigger?
    samplesPlot.plotSymbol = samplesSymbol;
	
	//set scale type.
	[self setYAxisScale:self.displayLogarithmicScale];
}

- (void) configureAxis{
	
	[TIBLELogger detail:@"TIBLEScatterPlotViewController - Style Axis called (%p)\n", self];
	
	//Create styles
    
    //Creates line styles for the axis title, axis lines, axis labels, tick lines, and grid lines.
    //In this case, your grid lines will be horizontal at a defined “major” increment.
    
    CPTMutableTextStyle *axisTitleStyle = [self getAxisTitleStyle];
    CPTMutableLineStyle *axisLineStyle = [self getAxisLineStyle];
    CPTMutableTextStyle *axisTextStyle = [self getAxisTextStyle];
    CPTMutableLineStyle *tickLineStyle = [self getAxisLineStyle];
    //CPTMutableLineStyle *gridLineStyle = [self getGridLineStyle];
    
    //Get axis set (The axis set contains information about the graph’s axes).
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    //Configure x-axis
    CPTXYAxis *x = axisSet.xAxis;
    x.title = @"";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 30.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    x.labelTextStyle = axisTextStyle;
    x.labelOffset = 8.0f;
	x.majorTickLineStyle = tickLineStyle;
	x.minorTickLineStyle = tickLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
	
	//make sure it is always floating.
	x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
	
    //Configure y-axis
    CPTXYAxis *y = axisSet.yAxis;
    y.title = @"";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = 30.0f;
    y.axisLineStyle = axisLineStyle;
    //y.majorGridLineStyle = gridLineStyle;
	y.labelingPolicy = CPTAxisLabelingPolicyLocationsProvided;
	y.labelTextStyle = axisTextStyle;
    y.labelOffset = 1.0f;
    y.majorTickLineStyle = tickLineStyle;
	y.minorTickLineStyle = tickLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignNegative;

	//make sure it is always floating.
	y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
}

#pragma mark - Helpers

- (TIBLESensorModel * ) sensor{
	
	return [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
}

@end
