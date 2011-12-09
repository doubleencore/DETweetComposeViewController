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
#import "UIDevice+DETweetComposeViewController.h"
#import "UIApplication+DETweetComposeViewController.h"

@interface DEViewController ()

@property (nonatomic, retain) OAuth *oAuth;
@property (nonatomic, retain) NSArray *tweets;

- (void)addTweetContent:(id)tcvc;

@end


@implementation DEViewController

    // IBOutlets
@synthesize deTweetButton = _deTweetButton;
@synthesize twTweetButton = _twTweetButton;
@synthesize backgroundView = _backgroundView;
@synthesize buttonView = _buttonView;
@synthesize tweets = _tweets;

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
    [_tweets release], _tweets = nil;

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
    
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0.0f];
    
    self.tweets = [NSArray arrayWithObjects:
                   @"Step into my office.",
                   @"Please take a seat, I suppose you're wondering why I called you all here…",
                   @"You eyeballin' me son!",
                   @"I'm going to make him an offer he can't refuse.",
                   @"You talkin' to me?",
                   @"who's in charge here?",
                   @"I swear, the cat was alive when I left.",
                   @"I will never get into the trash ever again.  I swear.",
                   @"Somebody throw me a bone here!",
                   @"really? another meeting?",
                   @"Type faster.",
                   @"How was I supposed to know you didn't leave the trash out for me?",
                   @"It's been a ruff day for all of us.",
                   @"The maple kind, yeah?",
                   @"Unless you brought enough biscuits for everyone I suggest you leave.",
                   @"@Would you file a new TPS report for 1 Scooby Snack? How about 2?",
                   @"", nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice isPhone]) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else {
        return YES;
    }
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect frame = self.buttonView.frame;
    frame.origin.x = trunc((self.view.bounds.size.width - frame.size.width) / 2);
    if ([UIDevice isPhone]) {
        frame.origin.y = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? 306.0f : 210.0f;
    }
    else {
        frame.origin.y = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? 722.0f : 535.0f;
    }
    self.buttonView.frame = frame;
        
    frame = self.backgroundView.frame;
    frame.origin.x = trunc((self.view.bounds.size.width - frame.size.width) / 2);
    frame.origin.y = trunc((self.view.bounds.size.height - frame.size.height) / 2) - 10.0f;
    self.backgroundView.frame = frame;
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
    self.tweets = nil;
    
    [super viewDidUnload];
}


#pragma mark - Private

- (void)tweetUs
{    
    DETweetComposeViewControllerCompletionHandler completionHandler = ^(DETweetComposeViewControllerResult result) {
        switch (result) {
            case DETweetComposeViewControllerResultCancelled:
                NSLog(@"Twitter Result: canceled");
                break;
            case DETweetComposeViewControllerResultDone:
                NSLog(@"Twitter Result: sent");
                break;
            default:
                NSLog(@"Twitter Result: default");
                break;
        }
        [self dismissModalViewControllerAnimated:YES];
    };

    DETweetComposeViewController *tcvc = [[[DETweetComposeViewController alloc] init] autorelease];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self addTweetContent:tcvc];
    tcvc.completionHandler = completionHandler;
    [self presentModalViewController:tcvc animated:YES];
}


- (void)tweetThem
{
    TWTweetComposeViewControllerCompletionHandler completionHandler = ^(TWTweetComposeViewControllerResult result) {
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
        tcvc.completionHandler = completionHandler;
        [self presentModalViewController:tcvc animated:YES];
    }
}


- (void)addTweetContent:(id)tcvc
{
    BOOL accepted;  // Just interesting to watch in the debugger.
    accepted = [tcvc addImage:[UIImage imageNamed:@"YawkeyBusinessDog.jpg"]];
    accepted = [tcvc addImage:[UIImage imageNamed:@"YawkeyCleanTeeth.jpg"]];  // This one won't actually work. Only one image per tweet allowed currently by Twitter.
    accepted = [tcvc addURL:[NSURL URLWithString:@"http://www.DoubleEncore.com/"]];
    accepted = [tcvc addURL:[NSURL URLWithString:@"http://www.apple.com/ios/features.html#twitter"]];
    accepted = [tcvc addURL:[NSURL URLWithString:@"http://www.twitter.com/"]];  // This won't work either. Only three URLs allowed, just like Apple's implementation.
    NSString *tweetText = [self.tweets objectAtIndex:arc4random() % [self.tweets count]];
    accepted = [tcvc setInitialText:tweetText];
}


#pragma mark - Actions

- (IBAction)tweetUs:(id)sender
{    
    if ([UIApplication isIOS5]) {
        [self tweetUs];
    }
    else {
        // check for saved credentials
        if ([DETweetComposeViewController canSendTweet]) {
            [self tweetUs];
        }
        else {
            if ([UIApplication isIOS5]) {
                [self tweetUs];
                [DETweetComposeViewController displayNoTwitterAccountsAlert];
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
