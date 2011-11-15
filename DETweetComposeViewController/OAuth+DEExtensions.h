//
//  OAuth+DEExtensions.h
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OAuth;

@interface OAuth (OAuth_DEExtensions)

- (void) loadOAuthContext;
- (void) saveOAuthContext;
- (void) saveOAuthContext:(OAuth *)oAuthContext;

+ (BOOL) isTwitterAuthorized;
+ (void) clearCrendentials;

@end
