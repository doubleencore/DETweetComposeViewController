//
//  DEViewController.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DEViewController.h"
#import "DETweetComposeViewController.h"
#import "OAuth.h"
#import "OAuth+UserDefaults.h"
#import "OAuthConsumerCredentials.h"
#import <Twitter/Twitter.h>
#import <QuartzCore/QuartzCore.h>  // Just for testing


@interface DEViewController ()

@property (nonatomic, retain) OAuth *oAuth;

- (void)addTweetContent:(id)tcvc;

@end


@implementation DEViewController

    // IBOutlets
@synthesize deTweetButton = _deTweetButton;
@synthesize twTweetButton = _twTweetButton;

    // Private
@synthesize oAuth = _oAuth;


#pragma mark - Setup & Teardown

- (void)dealloc
{
        // IBOutlets
    [_deTweetButton release], _deTweetButton = nil;
    [_twTweetButton release], _twTweetButton = nil;
    
        // Private
    [_oAuth release], _oAuth = nil;

    [super dealloc];
}


#pragma mark - Superclass Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([TWTweetComposeViewController class] == nil) {
        self.twTweetButton.enabled = NO;
        [self.twTweetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else {
        return YES;
    }
}


- (void)viewDidUnload
{
        // IBOutlets
    self.deTweetButton = nil;
    self.twTweetButton = nil;
    
        // Private
    self.oAuth = nil;
    
    [super viewDidUnload];
}


#pragma mark - Public


#pragma mark - Private

- (void)tweetUs
{
    DETweetComposeViewController *tcvc = [[[DETweetComposeViewController alloc] init] autorelease];
    [self addTweetContent:tcvc];
    [self presentModalViewController:tcvc animated:YES];
}


- (void)tweetThem
{
    TWTweetComposeViewControllerCompletionHandler 
    completionHandler = ^(TWTweetComposeViewControllerResult result) {
        switch (result)
        {
            case TWTweetComposeViewControllerResultCancelled:
                NSLog(@"Twitter Result: canceled");
                break;
            case TWTweetComposeViewControllerResultDone:
                NSLog(@"Twitter Result: sent");
                break;
            default:
                NSLog(@"Twitter Result: default");
                break;
        }
        [self dismissModalViewControllerAnimated:YES];
    };

    TWTweetComposeViewController *tcvc = [[[TWTweetComposeViewController alloc] init] autorelease];
    if (tcvc) {
        [self addTweetContent:tcvc];
        [tcvc setCompletionHandler:completionHandler];
        [self presentModalViewController:tcvc animated:YES];
    }
}


- (void)addTweetContent:(id)tcvc
{
//    [tcvc addImage:[UIImage imageNamed:@"Buzz.jpeg"]];
//    [tcvc addImage:[UIImage imageNamed:@"Woody.jpeg"]];  // This one won't actually work. Only one image per tweet allowed.
//    [tcvc addURL:[NSURL URLWithString:@"http://www.DoubleEncore.com/"]];
//    [tcvc addURL:[NSURL URLWithString:@"http://www.Apple.com/"]];
    [tcvc setInitialText:@"This is a test of the emergency broadcast system. Don't panic."];
}


#pragma mark - Notifications


#pragma mark - Actions

- (IBAction)tweetUs:(id)sender
{    
    // check for saved credentials
    if ([DETweetComposeViewController canSendTweet]) {
        [self tweetUs];
    }
    else {
        self.oAuth = [[[OAuth alloc] initWithConsumerKey:kDEConsumerKey andConsumerSecret:kDEConsumerSecret] autorelease];
        TwitterDialog *td = [[[TwitterDialog alloc] init] autorelease];
        td.twitterOAuth = self.oAuth;
        td.delegate = self;
        td.logindelegate = self;
        [td show];
    }
}


- (IBAction)tweetThem:(id)sender
{    
    [self tweetThem];
}


#pragma mark - Accessors


#pragma mark - TwitterDialogDelegate


#pragma mark - TwitterLoginDialogDelegate

- (void)twitterDidLogin
{
    [self.oAuth saveOAuthContextToUserDefaults];
}

- (void)twitterDidNotLogin:(BOOL)cancelled
{
//    Show Error UIAlertView
}


@end
