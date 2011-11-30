//
//  DEViewController.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DEViewController.h"
#import "DETweetComposeViewController.h"
#import "OAuth.h"
#import "OAuth+DEExtensions.h"
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
@synthesize backgroundView = _backgroundView;
@synthesize buttonView = _buttonView;

    // Private
@synthesize oAuth = _oAuth;


#pragma mark - Setup & Teardown

- (void)dealloc
{
        // IBOutlets
    [_deTweetButton release], _deTweetButton = nil;
    [_twTweetButton release], _twTweetButton = nil;
    [_backgroundView release], _backgroundView = nil;
    [_buttonView release], _buttonView = nil;
    
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
    UIImage *buttonImage = [[UIImage imageNamed:@"DETweetSendButtonPortrait.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    [self.twTweetButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.deTweetButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.backgroundView.image = nil;
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


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect buttonFrame = self.buttonView.frame;

    if (interfaceOrientation == UIInterfaceOrientationPortrait ||
        interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        
            // self.backgroundView.image = [UIImage imageNamed:@"Default"];
        buttonFrame.origin.y = 222.0f;
    }
    else {
            // self.backgroundView.image = [UIImage imageNamed:@"Default-Landscape"];
        buttonFrame.origin.y = 185.0f;
    }

    self.buttonView.frame = buttonFrame;
}


- (void)viewDidUnload
{
        // IBOutlets
    self.deTweetButton = nil;
    self.twTweetButton = nil;
    self.backgroundView = nil;
    self.buttonView = nil;
    
        // Private
    self.oAuth = nil;
    
    [super viewDidUnload];
}


#pragma mark - Private

- (void)tweetUs
{
    DETweetComposeViewController *tcvc = [[[DETweetComposeViewController alloc] init] autorelease];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self addTweetContent:tcvc];
    [self presentModalViewController:tcvc animated:YES];
}


- (void)tweetThem
{
    TWTweetComposeViewControllerCompletionHandler 
    completionHandler = ^(TWTweetComposeViewControllerResult result) {
        switch (result) {
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
    BOOL accepted;  // Just interesting to watch in the debugger.
    accepted = [tcvc addImage:[UIImage imageNamed:@"Buzz.jpeg"]];
    accepted = [tcvc addImage:[UIImage imageNamed:@"Woody.jpeg"]];  // This one won't actually work. Only one image per tweet allowed currently by Twitter.
    accepted = [tcvc addURL:[NSURL URLWithString:@"http://www.DoubleEncore.com/"]];
    accepted = [tcvc addURL:[NSURL URLWithString:@"http://www.apple.com/ios/features.html#twitter"]];
    accepted = [tcvc addURL:[NSURL URLWithString:@"http://www.twitter.com/"]];  // This won't work either. Only three URLs allowed, just like Apple's implementation.
    accepted = [tcvc setInitialText:@"This is a test of the emergency broadcast system. Don't panic."];
}


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


#pragma mark - TwitterLoginDialogDelegate

- (void)twitterDidLogin
{
    [self.oAuth saveOAuthContext];
    [self tweetUs:nil];
}


- (void)twitterDidNotLogin:(BOOL)cancelled
{
//    Show Error UIAlertView
}


@end
