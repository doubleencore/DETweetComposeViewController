//
//  DETweetPoster.h
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DETweetPoster : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

- (void)postTweet:(NSString *)tweetText withImages:(NSArray *)images;

@end
