//
//  OAuth+DEUserDefaults.h
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OAuth;

@interface OAuth (OAuth_DEUserDefaults)

- (void) loadOAuthContextFromUserDefaults;
- (void) saveOAuthContextToUserDefaults;
- (void) saveOAuthContextToUserDefaults:(OAuth *)oAuthContext;

+ (BOOL) isTwitterAuthorizedFromUserDefaults;
+ (void) clearCrendentialsFromUserDefaults;

@end
