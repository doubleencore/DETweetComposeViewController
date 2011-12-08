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

- (void)tweetSucceeded:(DETweetPoster *)tweetPoster;
- (void)tweetFailed:(DETweetPoster *)tweetPoster;
- (void)tweetFailedAuthentication:(DETweetPoster *)tweetPoster;

@end
