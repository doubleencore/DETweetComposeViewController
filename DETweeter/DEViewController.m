//
//  DEViewController.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DEViewController.h"
#import "DETweetComposeViewController.h"
#import <Twitter/Twitter.h>
#import <QuartzCore/QuartzCore.h>  // Just for testing
#import "OAuth.h"
#import "OAuthConsumerCredentials.h"

@interface DEViewController ()

@property (nonatomic, retain) OAuth *oAuth;

- (void)tweet;
- (BOOL)hasTwiterCredentials;

@end


@implementation DEViewController


@synthesize oAuth = _oAuth;

#pragma mark - Class Methods


#pragma mark - Setup & Teardown

- (void)dealloc
{

    [_oAuth release], _oAuth = nil;
    [super dealloc];
}


- (void)viewDidUnload
{
    self.oAuth = nil;
    [super viewDidUnload];
}

#pragma mark - Superclass Overrides

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else {
        return YES;
    }
}


#pragma mark - Public


#pragma mark - Private

void dumpViews(UIView* view, NSString *text, NSString *indent)
    // Just test code.
{
    if ([view isKindOfClass:[UIImageView class]]) {
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *sDocumentsDir = [documentPaths objectAtIndex:0];
        NSString *filePath = [sDocumentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"Image %d.png", arc4random()]];
        NSData *data = UIImagePNGRepresentation(((UIImageView *)view).image);
        [data writeToFile:filePath atomically:YES];
    }
    
    Class cl = [view class];
    NSString *classDescription = [cl description];
    while ([cl superclass]) 
    {
        cl = [cl superclass];
        classDescription = [classDescription stringByAppendingFormat:@":%@", [cl description]];
    }
    
    if ([text compare:@""] == NSOrderedSame)
        NSLog(@"%@ %@", classDescription, NSStringFromCGRect(view.frame));
    else
        NSLog(@"%@ %@ %@", text, classDescription, NSStringFromCGRect(view.frame));
    
    for (NSUInteger i = 0; i < [view.subviews count]; i++)
    {
        UIView *subView = [view.subviews objectAtIndex:i];
        NSString *newIndent = [[NSString alloc] initWithFormat:@"  %@", indent];
        NSString *msg = [[NSString alloc] initWithFormat:@"%@%d:", newIndent, i];
        dumpViews(subView, msg, newIndent);
        [msg release];
        [newIndent release];
    }
}


- (void)xx:(id)tcvc
    // More test code.
{
    UIView *aView = [[[tcvc view] subviews] objectAtIndex:0];
    NSArray *subviews = aView.subviews;
    dumpViews(aView, @"", @"");

//    UIImageView *iv = [subviews lastObject];
//    UIImage *image = iv.image;
//    NSData *data = UIImagePNGRepresentation(image);
//
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *sDocumentsDir = [documentPaths objectAtIndex:0];
//    NSString *filePath = [sDocumentsDir stringByAppendingPathComponent:@"IMaGE.png"];
//    [data writeToFile:filePath atomically:YES];
    
}


- (void)tweetUs
{
    DETweetComposeViewController *tcvc = [[[DETweetComposeViewController alloc] init] autorelease];
    [tcvc addImage:[UIImage imageNamed:@"Buzz.jpeg"]];
    [tcvc addImage:[UIImage imageNamed:@"Woody.jpeg"]];
    [tcvc addURL:[NSURL URLWithString:@"http://www.DoubleEncore.com/"]];
    [tcvc addURL:[NSURL URLWithString:@"http://www.Apple.com/"]];
    [tcvc addURL:[NSURL URLWithString:@"http://www.Twitter.com/"]];
    [tcvc setInitialText:@"This is a test of the emergency broadcast system. Don't panic."];
    [self presentModalViewController:tcvc animated:YES];
}


- (void)tweetThem
{
    TWTweetComposeViewController *tcvc = [[[TWTweetComposeViewController alloc] init] autorelease];
    [tcvc addImage:[UIImage imageNamed:@"Buzz.jpeg"]];
    [tcvc addImage:[UIImage imageNamed:@"Woody.jpeg"]];
    [tcvc addURL:[NSURL URLWithString:@"http://www.DoubleEncore.com/"]];
    [tcvc addURL:[NSURL URLWithString:@"http://www.Apple.com/"]];
    [tcvc addURL:[NSURL URLWithString:@"http://www.Twitter.com/"]];
    [tcvc setInitialText:@"This is a test of the emergency broadcast system. Don't panic."];
    [self presentModalViewController:tcvc animated:YES];
//    [self performSelector:@selector(xx:) withObject:tcvc afterDelay:1.0f];
}


- (BOOL)hasTwiterCredentials
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kDEConsumerKey] &&
         [[NSUserDefaults standardUserDefaults] objectForKey:kDEConsumerSecret]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Notifications


#pragma mark - Actions

- (IBAction)tweetUs:(id)sender
{    
    // check for saved credentials
    if ([self hasTwiterCredentials]) {
        [self tweetUs];
    } else {
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
    [[NSUserDefaults standardUserDefaults] setObject:self.oAuth.oauth_token forKey:kDEConsumerKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.oAuth.oauth_token_secret forKey:kDEConsumerSecret];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)twitterDidNotLogin:(BOOL)cancelled
{
//    Show Error UIAlertView
}




@end
