//
//  OAuth+DEExtensions.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "OAuth.h"
#import "OAuth+DEExtensions.h"
#import "OAuth+DEUserDefaults.h"

@implementation OAuth (OAuth_DEExtensions)

// The following tasks should really be done using keychain in a real app. But we will use userDefaults
// for the sake of clarity and brevity of this example app. Do think about security for your own real use.
- (void) loadOAuthContext 
{
    [self loadOAuthContextFromUserDefaults];
}


- (void) saveOAuthContext 
{
	[self saveOAuthContextToUserDefaults:self];
}


- (void) saveOAuthContext:(OAuth *)_oAuth 
{
    [self saveOAuthContextToUserDefaults:_oAuth];
}


+ (BOOL) isTwitterAuthorized 
{
    return [OAuth isTwitterAuthorizedFromUserDefaults];
}


+ (void) clearCrendentials 
{
    [OAuth clearCrendentialsFromUserDefaults];
}


@end
