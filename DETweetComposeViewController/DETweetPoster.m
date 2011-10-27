//
//  DETweetPoster.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DETweetPoster.h"
#import "OAuth.h"
#import "OAuth+UserDefaults.h"
#import "OAuthConsumerCredentials.h"
#import "NSString+URLEncoding.h"

@implementation DETweetPoster

- (void)postTweet:(NSString *)tweetText withImages:(NSArray *)images;
{
    NSMutableDictionary *tweetParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:tweetText, @"status",
                                            @"t", @"trim_user", nil];
    
    NSMutableArray *postKeysAndValues = [NSMutableArray array];
    
    for (NSString *key in [tweetParameters allKeys]) {		
        [postKeysAndValues addObject:[NSString stringWithFormat:@"%@=%@", key, [(NSString *)[tweetParameters objectForKey:key] encodedURLParameterString]]];
    }
    
    NSString *postString = [NSString stringWithFormat:@"%@", [postKeysAndValues componentsJoinedByString:@"&"]];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *postURL = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
    if ([images count] > 0) {
        postURL = [NSURL URLWithString:@"https://upload.twitter.com/1/statuses/update_with_media.json"];
    }
    
    OAuth *oAuth = [[[OAuth alloc] initWithConsumerKey:kDEConsumerKey andConsumerSecret:kDEConsumerSecret] autorelease];
    [oAuth loadOAuthContextFromUserDefaults];

    NSString *header = [oAuth oAuthHeaderForMethod:@"POST" andUrl:[postURL absoluteString] andParams:tweetParameters];
    
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:postURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60 * 2];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest addValue:header forHTTPHeaderField:@"Authorization"];
    
    if ([images count] > 0) {
        
    } else {
        [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [postRequest setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
        [postRequest setHTTPBody:postData];
    }
    
    if ([NSURLConnection canHandleRequest:postRequest]) {
        NSURLConnection *postConnection = [NSURLConnection connectionWithRequest:postRequest delegate:self];
        [postConnection start];
    } else {
//        Return can't handle request error
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSUInteger statusCode = [response statusCode];
    
    NSRange successRange = NSMakeRange(200, 204);
    if (NSLocationInRange(statusCode, successRange)) {
//      Tell the delegate we had a success.
        NSLog(@"success");
    } else {
//      Tell the delegate we had a failuer.
        NSLog(@"failure");
    }
    
    NSLog(@"%d", statusCode);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"didFinishLoading: %@", connection);
}

@end
