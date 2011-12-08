//
//  DETweetPoster.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DETweetPoster.h"
#import "OAuth.h"
#import "OAuth+DEExtensions.h"
#import "OAuthConsumerCredentials.h"
#import "NSString+URLEncoding.h"


@interface DETweetPoster ()

- (void)sendFailedToDelegate;
- (void)sendFailedAuthenticationToDelegate;
- (void)sendSuccessToDelegate;

@end


@implementation DETweetPoster

@synthesize delegate = _delegate;


#pragma mark - Setup & Teardown

- (void)dealloc
{
    _delegate = nil;
    
    [super dealloc];
}


#pragma mark - Public

- (void)postTweet:(NSString *)tweetText withImages:(NSArray *)images
{
    NSMutableData *postData = nil;
    NSMutableDictionary *tweetParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            tweetText, @"status",
                                            @"t", @"trim_user",
                                            nil];
    
    NSMutableArray *postKeysAndValues = [NSMutableArray array];
    
    for (NSString *key in [tweetParameters allKeys]) {		
        [postKeysAndValues addObject:[NSString stringWithFormat:@"%@=%@", key, [(NSString *)[tweetParameters objectForKey:key] encodedURLParameterString]]];
    }
    
    NSString *postString = [NSString stringWithFormat:@"%@", [postKeysAndValues componentsJoinedByString:@"&"]];
    
    NSURL *postURL = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
    if ([images count] > 0) {
        postURL = [NSURL URLWithString:@"https://upload.twitter.com/1/statuses/update_with_media.json"];
    }
    
    OAuth *oAuth = [[[OAuth alloc] initWithConsumerKey:kDEConsumerKey andConsumerSecret:kDEConsumerSecret] autorelease];
    [oAuth loadOAuthContext];

    NSString *header = nil;
    
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:postURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60 * 2];
    [postRequest setHTTPMethod:@"POST"];
    
    if ([images count] > 0) {
        header = [oAuth oAuthHeaderForMethod:@"POST" andUrl:[postURL absoluteString] andParams:nil];
        NSString *stringBoundary = [NSString stringWithString:@"dOuBlEeNcOrEbOuNdArY"];
        [postRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary] forHTTPHeaderField:@"Content-Type"];
        
        postData = [NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        for (NSString *key in [tweetParameters allKeys]) {
            [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[[NSString stringWithFormat:@"%@", [tweetParameters objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        for (UIImage *image in images) {
            [postData appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"media[]\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];            
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
    
    if ([NSURLConnection canHandleRequest:postRequest]) {
        NSURLConnection *postConnection = [NSURLConnection connectionWithRequest:postRequest delegate:self];
        [postConnection start];
    }
    else {
        [self sendFailedToDelegate];
    }
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
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    NSInteger statusCode = [response statusCode];
    
    NSRange successRange = NSMakeRange(200, 5);
    if (NSLocationInRange(statusCode, successRange)) {
        [self sendSuccessToDelegate];
    } else if (statusCode == 401) {
        // Failed authentication
        [self sendFailedAuthenticationToDelegate];
    } else {
        [self sendFailedToDelegate];
    }
}


@end
