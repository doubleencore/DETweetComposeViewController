//
//  OAuth+DEUserDefaults.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "OAuth.h"
#import "OAuth+DEUserDefaults.h"
#import "OAuthConsumerCredentials.h"

@implementation OAuth (OAuth_DEUserDefaults)

// The following tasks should really be done using keychain in a real app. But we will use userDefaults
// for the sake of clarity and brevity of this example app. Do think about security for your own real use.
- (void) loadOAuthContextFromUserDefaults 
{
	self.oauth_token = [[NSUserDefaults standardUserDefaults] stringForKey:@"detwitter_oauth_token"];
	self.oauth_token_secret = [[NSUserDefaults standardUserDefaults] stringForKey:@"detwitter_oauth_token_secret"];
	self.oauth_token_authorized = [[NSUserDefaults standardUserDefaults] integerForKey:@"detwitter_oauth_token_authorized"];
}


- (void) saveOAuthContextToUserDefaults 
{
	[self saveOAuthContextToUserDefaults:self];
}


- (void) saveOAuthContextToUserDefaults:(OAuth *)_oAuth 
{
	[[NSUserDefaults standardUserDefaults] setObject:_oAuth.oauth_token forKey:@"detwitter_oauth_token"];
	[[NSUserDefaults standardUserDefaults] setObject:_oAuth.oauth_token_secret forKey:@"detwitter_oauth_token_secret"];
	[[NSUserDefaults standardUserDefaults] setInteger:_oAuth.oauth_token_authorized forKey:@"detwitter_oauth_token_authorized"];
}


+ (BOOL) isTwitterAuthorizedFromUserDefaults
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"detwitter_oauth_token"] &&
        [[NSUserDefaults standardUserDefaults] objectForKey:@"detwitter_oauth_token_secret"] &&
        [[NSUserDefaults standardUserDefaults] boolForKey:@"detwitter_oauth_token_authorized"]) {
        
        return YES;
    } else {
        return NO;
    }
}


+ (void) clearCrendentialsFromUserDefaults 
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"detwitter_oauth_token"];
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"detwitter_oauth_token_secret"];
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"detwitter_oauth_token_authorized"];
    
    OAuth *oAuth = [[[OAuth alloc] initWithConsumerKey:kDEConsumerKey andConsumerSecret:kDEConsumerSecret] autorelease];
    [oAuth forget];
}


@end
