//
//  DETweetPoster.h
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DETweetPosterDelegate <NSObject>

@optional
- (void)tweetSucceeded;
- (void)tweetFailed;

@end

@interface DETweetPoster : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, assign) id<DETweetPosterDelegate> delegate;

- (void)postTweet:(NSString *)tweetText withImages:(NSArray *)images;

@end
