//
//  DEViewController.h
//  DETweeter
//
//  Copyright (c) 2011-2012 Double Encore, Inc. All rights reserved.
//

@interface DEViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIButton *deTweetButton;
@property (retain, nonatomic) IBOutlet UIButton *twTweetButton;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundView;
@property (retain, nonatomic) IBOutlet UIView *buttonView;

- (IBAction)tweetUs:(id)sender;
- (IBAction)tweetThem:(id)sender;

@end
