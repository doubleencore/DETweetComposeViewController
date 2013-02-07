//
//  DEAppDelegate.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DEAppDelegate.h"
#import "DEViewController.h"
#import "UIDevice+DETweetComposeViewController.h"

@implementation DEAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;



#pragma mark - Class Methods


#pragma mark - Setup & Teardown

- (void)dealloc
{
    [_window release], _window = nil;
    [_viewController release], _viewController = nil;
    
    [super dealloc];
}


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
        // Override point for customization after application launch.
    if ([UIDevice de_isPhone]) {
        self.viewController = [[[DEViewController alloc] initWithNibName:@"DEViewController_iPhone" bundle:nil] autorelease];
    }
    else {
        self.viewController = [[[DEViewController alloc] initWithNibName:@"DEViewController_iPad" bundle:nil] autorelease];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
