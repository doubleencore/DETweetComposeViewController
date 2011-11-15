//
//  DETweetPoster.h
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

@protocol DETweetPosterDelegate;

@interface DETweetPoster : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, assign) id<DETweetPosterDelegate> delegate;

- (void)postTweet:(NSString *)tweetText withImages:(NSArray *)images;

@end


@protocol DETweetPosterDelegate <NSObject>

@optional
- (void)tweetSucceeded;
- (void)tweetFailed;
- (void)tweetFailedAuthentication;

@end
