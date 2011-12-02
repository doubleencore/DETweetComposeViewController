//
//  UIApplication+DETweetComposeViewController.m
//  DETweeter
//
//  Created by James Graves on 12/1/11.
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "UIApplication+DETweetComposeViewController.h"

@implementation UIApplication (DETweetComposeViewController)

+ (BOOL)isIOS5
{
    return (NSClassFromString(@"NSJSONSerialization") != nil);
}

@end
