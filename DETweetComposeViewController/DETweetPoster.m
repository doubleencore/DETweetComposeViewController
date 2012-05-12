//
//  DETweetPoster.m
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

#import "DETweetPoster.h"
#import "OAuth.h"
#import "OAuth+DEExtensions.h"
#import "OAuthConsumerCredentials.h"
#import "NSString+URLEncoding.h"
#import "UIDevice+DETweetComposeViewController.h"
#import <Accounts/Accounts.h>
#import <Twitter/TWRequest.h>


@interface DETweetPoster ()

@property (nonatomic, retain) NSURLConnection *postConnection;

- (NSURLRequest *)NSURLRequestForTweet:(NSString *)tweetText withImages:(NSArray *)images;
- (void)sendFailedToDelegate;
- (void)sendFailedAuthenticationToDelegate;
- (void)sendSuccessToDelegate;

@end


@implementation DETweetPoster

NSString * const twitterPostURLString = @"https://api.twitter.com/1/statuses/update.json";
NSString * const twitterPostWithImagesURLString = @"https://upload.twitter.com/1/statuses/update_with_media.json";
NSString * const twitterStatusKey = @"status";

@synthesize delegate = _delegate;
@synthesize postConnection = _postConnection;


#pragma mark - Class Methods

+ (NSArray *)accounts
{
    if (![UIDevice de_isIOS5]) {
        return nil;
    }
    ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
    return twitterAccounts;
}


#pragma mark - Setup & Teardown

- (void)dealloc
{
    _delegate = nil;
    [_postConnection cancel];
    [_postConnection release], _postConnection = nil;
  
    [super dealloc];
}


#pragma mark - Public

- (void)postTweet:(NSString *)tweetText withImages:(NSArray *)images
    // Posts the tweet with the first available account on iOS 5.
{
    id account = nil;  // An ACAccount. But that didn't exist on iOS 4.
    if ([UIDevice de_isIOS5]) {
        NSArray *twitterAccounts = [[self class] accounts];
        if ([twitterAccounts count] > 0) {
            account = [twitterAccounts objectAtIndex:0];
            [self postTweet:tweetText withImages:images fromAccount:account];
        }
        else {
            [self sendFailedToDelegate];
        }
    }
    else {
        [self postTweet:tweetText withImages:images fromAccount:account];
    }
}


- (void)postTweet:(NSString *)tweetText withImages:(NSArray *)images fromAccount:(id)account
{
    NSURLRequest *postRequest = nil;
    if ([UIDevice de_isIOS5] && account != nil) {        
        TWRequest *twRequest = nil;
        if ([images count] > 0) {
            twRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:twitterPostWithImagesURLString]
                                            parameters:nil requestMethod:TWRequestMethodPOST] autorelease];
            
            [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIImage *image = (UIImage *)obj;
                [twRequest addMultiPartData:UIImagePNGRepresentation(image) withName:@"media[]" type:@"multipart/form-data"];
            }];
            
            [twRequest addMultiPartData:[tweetText dataUsingEncoding:NSUTF8StringEncoding] 
                             withName:twitterStatusKey type:@"multipart/form-data"];
        }
        else {
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:tweetText, twitterStatusKey, nil];
            twRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:twitterPostURLString]
                                            parameters:parameters requestMethod:TWRequestMethodPOST] autorelease];
        }
            // There appears to be a bug in iOS 5.0 that gives us trouble if we used our retained account.
            // If we get it again using the identifier then everything works fine.
        ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
        twRequest.account = [accountStore accountWithIdentifier:((ACAccount *)account).identifier];
        postRequest = [twRequest signedURLRequest];
    }
    else {
        postRequest = [self NSURLRequestForTweet:tweetText withImages:images];
    }
    
    if ([NSURLConnection canHandleRequest:postRequest]) {
        self.postConnection = [NSURLConnection connectionWithRequest:postRequest delegate:self];
        [self.postConnection start];
    }
    else {
        [self sendFailedToDelegate];
    }
}


- (NSURLRequest *)NSURLRequestForTweet:(NSString *)tweetText withImages:(NSArray *)images
{
    NSMutableData *postData = nil;
    NSMutableDictionary *tweetParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            tweetText, twitterStatusKey,
                                            @"t", @"trim_user",
                                            nil];
    
    NSMutableArray *postKeysAndValues = [NSMutableArray array];
    
    for (NSString *key in [tweetParameters allKeys]) {		
        [postKeysAndValues addObject:[NSString stringWithFormat:@"%@=%@", key, [(NSString *)[tweetParameters objectForKey:key] encodedURLParameterString]]];
    }
    
    NSString *postString = [NSString stringWithFormat:@"%@", [postKeysAndValues componentsJoinedByString:@"&"]];
    
    NSURL *postURL = [NSURL URLWithString:twitterPostURLString];
    if ([images count] > 0) {
        postURL = [NSURL URLWithString:twitterPostWithImagesURLString];
    }
    
    OAuth *oAuth = [[[OAuth alloc] initWithConsumerKey:kDEConsumerKey andConsumerSecret:kDEConsumerSecret] autorelease];
    [oAuth loadOAuthContext];

    NSString *header = nil;
    
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:postURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60 * 2];
    [postRequest setHTTPMethod:@"POST"];
    
    if ([images count] > 0) {
        header = [oAuth oAuthHeaderForMethod:@"POST" andUrl:[postURL absoluteString] andParams:nil];
        NSString *stringBoundary = @"dOuBlEeNcOrEbOuNdArY";
        [postRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary] forHTTPHeaderField:@"Content-Type"];
        
        postData = [NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        for (NSString *key in [tweetParameters allKeys]) {
            [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[[NSString stringWithFormat:@"%@", [tweetParameters objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        for (UIImage *image in images) {
            [postData appendData:[@"Content-Disposition: form-data; name=\"media[]\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];            
            [postData appendData:UIImagePNGRepresentation(image)];
            [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    else {
        header = [oAuth oAuthHeaderForMethod:@"POST" andUrl:[postURL absoluteString] andParams:tweetParameters];
        [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        postData = [[[postString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy] autorelease];
        [postRequest setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    }
    
    [postRequest setHTTPBody:postData];
    [postRequest addValue:header forHTTPHeaderField:@"Authorization"];
    
    return postRequest;
}


#pragma mark - Private methods

- (void)sendFailedToDelegate
{
    if ([self.delegate respondsToSelector:@selector(tweetFailed:)]) {
        [self.delegate tweetFailed:self];
    }
}


- (void)sendFailedAuthenticationToDelegate
{
    if ([self.delegate respondsToSelector:@selector(tweetFailedAuthentication:)]) {
        [self.delegate tweetFailedAuthentication:self];
    }
}


- (void)sendSuccessToDelegate
{
    if ([self.delegate respondsToSelector:@selector(tweetSucceeded:)]) {
        [self.delegate tweetSucceeded:self];
    }
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self sendFailedToDelegate];
    [_postConnection release];
    _postConnection = nil;
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    NSInteger statusCode = [response statusCode];
    
    NSRange successRange = NSMakeRange(200, 5);
    if (NSLocationInRange(statusCode, successRange)) {
        [self sendSuccessToDelegate];
    }
    else if (statusCode == 401) {
        // Failed authentication
        [self sendFailedAuthenticationToDelegate];
    }
    else {
        [self sendFailedToDelegate];
    }
    [_postConnection release];
    _postConnection = nil;
}


@end
