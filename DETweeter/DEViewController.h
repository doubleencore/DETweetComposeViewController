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
@property (retain, nonatomic) IBOutlet UIImageView *backgroundView;
@property (retain, nonatomic) IBOutlet UIView *buttonView;

- (IBAction)tweetUs:(id)sender;
- (IBAction)tweetThem:(id)sender;

@end
