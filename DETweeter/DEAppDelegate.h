//
//  DEAppDelegate.h
//  DETweeter
//
//  Created by Dave Batton on 10/25/11.
//  Copyright (c) 2011 Mere Mortal Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DEViewController;

@interface DEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DEViewController *viewController;

@end
