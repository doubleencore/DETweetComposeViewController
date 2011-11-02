//
//  DEViewController.h
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "TwitterDialog.h"

@interface DEViewController : UIViewController <TwitterDialogDelegate, TwitterLoginDialogDelegate>

@property (retain, nonatomic) IBOutlet UIButton *deTweetButton;
@property (retain, nonatomic) IBOutlet UIButton *twTweetButton;

- (IBAction)tweetUs:(id)sender;
- (IBAction)tweetThem:(id)sender;

@end
