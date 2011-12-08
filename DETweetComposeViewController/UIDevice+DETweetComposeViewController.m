//
//  UIDevice+DETweetComposeViewController.m
//  DETweeter
//
//  Created by James Graves on 12/7/11.
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "UIDevice+DETweetComposeViewController.h"

@implementation UIDevice (DETweetComposeViewController)

+ (BOOL)isPad
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? YES : NO;
}

+ (BOOL)isPhone
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? YES : NO;
}

@end
