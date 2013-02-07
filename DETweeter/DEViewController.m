//
//  DEViewController.m
//  DETweeter
//
//  Copyright (c) 2011-2012 Double Encore, Inc. All rights reserved.
//

#import "DEViewController.h"
#import "DETweetComposeViewController.h"
#import "UIDevice+DETweetComposeViewController.h"
#import <Twitter/Twitter.h>


@interface DEViewController ()

@property (nonatomic, retain) NSArray *tweets;

- (void)updateFramesForOrientation:(UIInterfaceOrientation)interfaceOrientation;
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


#pragma mark - Setup & Teardown

- (void)dealloc
{
        // IBOutlets
    [_deTweetButton release], _deTweetButton = nil;
    [_twTweetButton release], _twTweetButton = nil;
    [_backgroundView release], _backgroundView = nil;
    [_buttonView release], _buttonView = nil;
    
        // Private
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
    
    [self updateFramesForOrientation:self.interfaceOrientation];
    
    self.tweets = [NSArray arrayWithObjects:
                   @"Step into my office.",
                   @"Please take a seat. I suppose you're wondering why I called you all here…",
                   @"You eyeballin' me son?!",
                   @"I'm going to make him an offer he can't refuse.",
                   @"You talkin' to me?",
                   @"Who's in charge here?",
                   @"I swear, the cat was alive when I left.",
                   @"I will never get into the trash ever again. I swear.",
                   @"Somebody throw me a bone here!",
                   @"Really? Another meeting?",
                   @"Type faster!",
                   @"How was I supposed to know you didn't leave the trash out for me?",
                   @"It's been a ruff day for all of us.",
                   @"The maple kind, yeah?",
                   @"Unless you brought enough biscuits for everyone I suggest you leave.",
                   @"Would you file a new TPS report for 1 Scooby Snack? How about 2?",
                   nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice de_isPhone]) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else {
        return YES;
    }
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateFramesForOrientation:interfaceOrientation];
}


- (void)viewDidUnload
{
        // IBOutlets
    self.deTweetButton = nil;
    self.twTweetButton = nil;
    self.backgroundView = nil;
    self.buttonView = nil;
    
        // Private
    self.tweets = nil;
    
    [super viewDidUnload];
}


#pragma mark - Private

- (void)updateFramesForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGRect frame = self.buttonView.frame;
    frame.origin.x = trunc((self.view.bounds.size.width - frame.size.width) / 2);
    if ([UIDevice de_isPhone]) {
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


- (void)tweetUs
{    
    DETweetComposeViewControllerCompletionHandler completionHandler = ^(DETweetComposeViewControllerResult result) {
        switch (result) {
            case DETweetComposeViewControllerResultCancelled:
                NSLog(@"Twitter Result: Cancelled");
                break;
            case DETweetComposeViewControllerResultDone:
                NSLog(@"Twitter Result: Sent");
                break;
        }
        [self dismissModalViewControllerAnimated:YES];
    };

    DETweetComposeViewController *tcvc = [[[DETweetComposeViewController alloc] init] autorelease];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self addTweetContent:tcvc];
    tcvc.completionHandler = completionHandler;
    
    // Optionally, set alwaysUseDETwitterCredentials to YES to prevent using
    //  iOS5 Twitter credentials.
//    tcvc.alwaysUseDETwitterCredentials = YES;
    [self presentModalViewController:tcvc animated:YES];
}


- (void)tweetThem
{
    TWTweetComposeViewControllerCompletionHandler completionHandler = ^(TWTweetComposeViewControllerResult result) {
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled:
                NSLog(@"Twitter Result: Cancelled");
                break;
            case TWTweetComposeViewControllerResultDone:
                NSLog(@"Twitter Result: Sent");
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
    [tcvc addImage:[UIImage imageNamed:@"YawkeyBusinessDog.jpg"]];
    [tcvc addImage:[UIImage imageNamed:@"YawkeyCleanTeeth.jpg"]];  // This one won't actually work. Only one image per tweet allowed currently by Twitter.
    [tcvc addURL:[NSURL URLWithString:@"http://www.DoubleEncore.com/"]];
    [tcvc addURL:[NSURL URLWithString:@"http://www.apple.com/ios/features.html#twitter"]];
    [tcvc addURL:[NSURL URLWithString:@"http://www.twitter.com/"]];  // This won't work either. Only three URLs allowed, just like Apple's implementation.
    NSString *tweetText = [self.tweets objectAtIndex:arc4random() % [self.tweets count]];
    [tcvc setInitialText:tweetText];
}


#pragma mark - Actions

- (IBAction)tweetUs:(id)sender
{    
    [self tweetUs];
}


- (IBAction)tweetThem:(id)sender
{    
    [self tweetThem];
}


@end
