//
//  PMUIController.m
//  iProxy
//
//  Created by Jérôme Lebel on 18/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PMUIController.h"
#import "iProxyMacSetupAppDelegate.h"

@implementation PMUIController

@synthesize appDelegate;

- (void)awakeFromNib
{
    [self updateProxyPopUpButton];
    [self updateStartButton];
    [self updateProgressIndicator];
    [appDelegate addObserver:self forKeyPath:@"browsing" options:NSKeyValueObservingOptionNew context:nil];
    [appDelegate addObserver:self forKeyPath:@"resolvingServiceCount" options:NSKeyValueObservingOptionNew context:nil];
    [appDelegate addObserver:self forKeyPath:@"proxyServiceList" options:NSKeyValueObservingOptionNew context:nil];
    [appDelegate addObserver:self forKeyPath:@"interfaceList" options:NSKeyValueObservingOptionNew context:nil];
    [appDelegate addObserver:self forKeyPath:@"proxyEnabled" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"browsing"]) {
    	[self updateProgressIndicator];
    } else if ([keyPath isEqualToString:@"resolvingServiceCount"]) {
    	[self updateProgressIndicator];
    } else if ([keyPath isEqualToString:@"proxyServiceList"]) {
    	[self updateStartButton];
        [self updateProxyPopUpButton];
    } else if ([keyPath isEqualToString:@"interfaceList"]) {
    	[self updateStartButton];
        [self updateInterfacePopUpButton];
    } else if ([keyPath isEqualToString:@"proxyEnabled"]) {
    	[self updateStartButton];
        [proxyPopUpButton setEnabled:!appDelegate.proxyEnabled];
        [interfacePopUpButton setEnabled:!appDelegate.proxyEnabled];
    }
}

- (void)updateProgressIndicator
{
	if (appDelegate.browsing || appDelegate.resolvingServiceCount > 0) {
    	[progressIndicator startAnimation:nil];
    } else {
        [progressIndicator stopAnimation:nil];
    }
}

- (void)updateStartButton
{
	if ([appDelegate.proxyServiceList count] > 0 && [appDelegate.interfaceList count] > 0) {
    	[startButton setEnabled:YES];
        if (appDelegate.proxyEnabled) {
        	[startButton setTitle:@"Stop"];
        } else {
        	[startButton setTitle:@"Start"];
        }
    } else {
    	[startButton setEnabled:NO];
    }
}

- (void)updateProxyPopUpButton
{
	NSString *defaultProxy = appDelegate.defaultProxy;
    
	[proxyPopUpButton removeAllItems];
    for (NSNetService *service in appDelegate.proxyServiceList) {
    	NSString *title;
        
        title = [[NSString alloc] initWithFormat:@"%@.%@", [service name], [service domain]];
    	if ([service port] != -1) {
            [proxyPopUpButton addItemWithTitle:title];
        } else {
            [proxyPopUpButton addItemWithTitle:[NSString stringWithFormat:@"%@ (disabled)", title]];
        }
        if ([defaultProxy isEqualToString:title]) {
        	[proxyPopUpButton selectItem:[proxyPopUpButton lastItem]];
        }
        [title release];
    }
    [self updateStartButton];
}

- (void)updateInterfacePopUpButton
{
	NSString *defaultInterface = appDelegate.defaultInterface;
    
	[interfacePopUpButton removeAllItems];
    for (NSDictionary *service in appDelegate.interfaceList) {
    	if ([[service objectForKey:INTERFACE_ENABLED] boolValue]) {
            [interfacePopUpButton addItemWithTitle:[service objectForKey:INTERFACE_NAME]];
        } else {
            [interfacePopUpButton addItemWithTitle:[NSString stringWithFormat:@"%@ (disabled)", [service objectForKey:INTERFACE_NAME]]];
        }
        if ([defaultInterface isEqualToString:[service objectForKey:INTERFACE_NAME]]) {
        	[interfacePopUpButton selectItem:[interfacePopUpButton lastItem]];
        }
    }
    [self updateStartButton];
}

- (IBAction)startButtonAction:(id)sender
{
    NSDictionary *interfaceInfo;
    NSNetService *proxy;
	
    [self updateProxyPopUpButton];
    [self updateInterfacePopUpButton];
    interfaceInfo = [appDelegate.interfaceList objectAtIndex:[interfacePopUpButton indexOfSelectedItem]];
    proxy = [appDelegate.proxyServiceList objectAtIndex:[proxyPopUpButton indexOfSelectedItem]];
	if (appDelegate.proxyEnabled) {
    	[appDelegate disableProxyForInterface:[interfaceInfo objectForKey:INTERFACE_NAME]];
    } else {
    	[appDelegate enableForInterface:[interfaceInfo objectForKey:INTERFACE_NAME] withProxy:proxy];
    }
}

- (IBAction)interfacePopUpButtonAction:(id)sender
{
	appDelegate.defaultInterface = [[appDelegate.interfaceList objectAtIndex:[interfacePopUpButton indexOfSelectedItem]] objectForKey:INTERFACE_NAME];
}

- (IBAction)proxyPopUpButtonAction:(id)sender
{
	appDelegate.defaultProxy = [appDelegate.proxyServiceList objectAtIndex:[proxyPopUpButton indexOfSelectedItem]];
}

@end
