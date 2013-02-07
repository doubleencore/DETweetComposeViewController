//
//  OAuth+DEUserDefaults.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer 
//  in the documentation and/or other materials provided with the distribution. Neither the name of the Double Encore Inc. nor the names of its 
//  contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
//  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "OAuth.h"
#import "OAuth+DEUserDefaults.h"
#import "OAuthConsumerCredentials.h"

@implementation OAuth (OAuth_DEUserDefaults)

// The following tasks should really be done using keychain in a real app. But we will use userDefaults
// for the sake of clarity and brevity of this example app. Do think about security for your own real use.

- (void)loadOAuthContextFromUserDefaults 
{
	self.oauth_token = [[NSUserDefaults standardUserDefaults] stringForKey:@"detwitter_oauth_token"];
	self.oauth_token_secret = [[NSUserDefaults standardUserDefaults] stringForKey:@"detwitter_oauth_token_secret"];
	self.oauth_token_authorized = [[NSUserDefaults standardUserDefaults] integerForKey:@"detwitter_oauth_token_authorized"];
}


- (void)saveOAuthContextToUserDefaults 
{
	[self saveOAuthContextToUserDefaults:self];
}


- (void)saveOAuthContextToUserDefaults:(OAuth *)_oAuth 
{
	[[NSUserDefaults standardUserDefaults] setObject:_oAuth.oauth_token forKey:@"detwitter_oauth_token"];
	[[NSUserDefaults standardUserDefaults] setObject:_oAuth.oauth_token_secret forKey:@"detwitter_oauth_token_secret"];
	[[NSUserDefaults standardUserDefaults] setInteger:_oAuth.oauth_token_authorized forKey:@"detwitter_oauth_token_authorized"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (BOOL)isTwitterAuthorizedFromUserDefaults
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"detwitter_oauth_token"] &&
        [[NSUserDefaults standardUserDefaults] objectForKey:@"detwitter_oauth_token_secret"] &&
        [[NSUserDefaults standardUserDefaults] boolForKey:@"detwitter_oauth_token_authorized"]) {
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    } else {
        return NO;
    }
}


+ (void)clearCrendentialsFromUserDefaults 
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"detwitter_oauth_token"];
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"detwitter_oauth_token_secret"];
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"detwitter_oauth_token_authorized"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    OAuth *oAuth = [[[OAuth alloc] initWithConsumerKey:kDEConsumerKey andConsumerSecret:kDEConsumerSecret] autorelease];
    [oAuth forget];
}


@end
