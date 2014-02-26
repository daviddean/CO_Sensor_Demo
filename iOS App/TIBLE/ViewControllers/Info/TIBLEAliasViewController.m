/*
 *  TIBLEAliasViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEAliasViewController.h"
#import "TIBLEUIConstants.h"

@implementation TIBLEAliasViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
        self.activityIndicator.hidesWhenStopped = YES;
        self.navigationItem.rightBarButtonItem = barButton;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.refreshButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIFont fontWithName:TIBLE_APP_FONT_NAME size:TIBLE_APP_FONT_H3_HEADER_SIZE], UITextAttributeFont,nil] forState:UIControlStateNormal];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    
    if ([self.aliasWebView canGoBack]) {
        self.backButton.enabled = YES;
    }
    else {
        self.backButton.enabled = NO;
    }
    
    if ([self.aliasWebView canGoForward]) {
        self.forwardButton.enabled = YES;
    }
    else {
        self.forwardButton.enabled = NO;
    }
    
    self.refreshButton.title = NSLocalizedString(@"InfoScreen.Refresh", nil);
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    self.refreshButton.title = NSLocalizedString(@"InfoScreen.Stop", nil);
    
    [self.noConnectionLabel setHidden:YES];
    [self.activityIndicator startAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{

    [self.activityIndicator stopAnimating];

    if ([error code] == NSURLErrorNotConnectedToInternet) {
        [self.noConnectionLabel setText:NSLocalizedString(@"InfoScreen.NoConnection", @"No connection")];
        [self.noConnectionLabel setHidden:NO];
    }
    
    else if ([error code] == NSURLErrorCancelled) {
        self.refreshButton.title = NSLocalizedString(@"InfoScreen.Refresh", nil);
    }
}

- (void)viewDidUnload {
    [self setNoConnectionLabel:nil];
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [self setBackButton:nil];
    [self setRefreshButton:nil];
    [super viewDidUnload];
}

- (void)loadPageWithURL:(NSString *)url pageTitle:(NSString *)title {
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:@""]];
    [self.aliasWebView loadRequest:requestObj];
    
    NSURL *address = [NSURL URLWithString:url];
    requestObj = [NSURLRequest requestWithURL:address];
    [self.aliasWebView loadRequest:requestObj];
    
	self.navigationController.title = title;
    self.title = title;
}

- (IBAction)back:(id)sender {
    [self.aliasWebView goBack];
}

- (IBAction)stop:(id)sender {

	if (self.aliasWebView.isLoading) {
        [self.aliasWebView stopLoading];
    }
}

- (IBAction)refresh:(id)sender {
    
    if (self.aliasWebView.isLoading) {
        [self.aliasWebView stopLoading];
    }
    
    else {
        [self.aliasWebView reload];
    }
}

- (IBAction)forward:(id)sender {
    [self.aliasWebView goForward];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
