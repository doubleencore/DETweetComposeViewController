//
//  DETweetComposeViewController.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DETweetComposeViewController.h"
#import "DETweetPoster.h"

@interface DETweetComposeViewController ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *urls;

- (void)tweetComposeViewControllerInit;
- (BOOL)isPresented;

@end


@implementation DETweetComposeViewController

    // IBOutlets
@synthesize cancelButton = _cancelButton;
@synthesize sendButton = _sendButton;
@synthesize textView = _textView;
@synthesize paperClipView = _paperClipView;
@synthesize attachmentFrameView = _attachmentFrameView;
@synthesize attachmentImageView = _attachmentImageView;

    // Private
@synthesize text = _text;
@synthesize images = _images;
@synthesize urls = _urls;


#pragma mark - Class Methods

+ (BOOL)canSendTweet
{
    return YES;  // Overly optimistic?
}


+ (void)displayNoTwitterAccountsAlert
{
    [[[[UIAlertView alloc] initWithTitle:@"No Twitter Account"
                                 message:@"There are no Twitter accounts configured."
                                delegate:nil
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil] autorelease] show];
}


+ (void)displayNoTwitterAccountsAlertWithTarget:(id)target action:(SEL)selector
    // Eventually this will trigger an action if the taps the Configure button.
{
    [[[[UIAlertView alloc] initWithTitle:@"No Twitter Account"
                                 message:@"There is no Twitter account configured. Would you like to add a Twitter account now?"
                                delegate:self
                       cancelButtonTitle:@"Configure"  // The iOS5 apps mix up cancel and the action, so we do it too.
                       otherButtonTitles:@"Cancel", nil] autorelease] show];
}


#pragma mark - Setup & Teardown


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self tweetComposeViewControllerInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self tweetComposeViewControllerInit];
    }
    return self;
}


- (void)tweetComposeViewControllerInit
{
    _images = [[NSMutableArray alloc] init];
    _urls = [[NSMutableArray alloc] init];
}


- (void)dealloc
{
        // IBOutlets
    [_cancelButton release], _cancelButton = nil;
    [_sendButton release], _sendButton = nil;
    
        // Private
    [_text release], _text = nil;
    [_images release], _images = nil;
    [_urls release], _urls = nil;
    
    [_textView release];
    [_attachmentFrameView release];
    [_paperClipView release];
    [_attachmentImageView release];
    [super dealloc];
}


#pragma mark - Superclass Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [self.sendButton backgroundImageForState:UIControlStateNormal];
    image = [image stretchableImageWithLeftCapWidth:trunc(image.size.width / 2) topCapHeight:0];
    [self.sendButton setBackgroundImage:image forState:UIControlStateNormal];

    image = [self.cancelButton backgroundImageForState:UIControlStateNormal];
    image = [image stretchableImageWithLeftCapWidth:trunc(image.size.width / 2) topCapHeight:0];
    [self.cancelButton setBackgroundImage:image forState:UIControlStateNormal];
    
    self.textView.text = self.text;
    
    self.attachmentImageView.image = [UIImage imageNamed:@"DETweetURLAttachment"];
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
    self.cancelButton = nil;
    self.sendButton = nil;
    
        // Private
    self.text = nil;
    self.images = nil;
    self.urls = nil;

    [self setTextView:nil];
    [self setAttachmentFrameView:nil];
    [self setPaperClipView:nil];
    [self setAttachmentImageView:nil];
    
    [super viewDidUnload];
}


#pragma mark - Public

- (BOOL)setInitialText:(NSString *)initialText
{
    if ([self isPresented]) {
        return NO;
    }
    
    if ([initialText length] > 140) {
        return NO;
    }
    
    self.text = initialText;
    self.textView.text = self.text;
    return YES;
}


- (BOOL)addImage:(UIImage *)image
{
    if ([self isPresented]) {
        return NO;
    }
    
    [self.images addObject:image];
    return YES;
}


- (BOOL)addImageWithURL:(NSURL *)url;
{
        // We should probably just start the download, rather than saving the URL.
        // Just save the image once we have it.
}


- (BOOL)removeAllImages
{
    if ([self isPresented]) {
        return NO;
    }
    
    [self.images removeAllObjects];
    return YES;
}


- (BOOL)addURL:(NSURL *)url
{
    if ([self isPresented]) {
        return NO;
    }
    
    [self.urls addObject:url];
    return YES;
}


- (BOOL)removeAllURLs
{
    if ([self isPresented]) {
        return NO;
    }
    
    [self.urls removeAllObjects];
    return YES;
}


#pragma mark - Private

- (BOOL)isPresented
{
    return [self isViewLoaded];
}


#pragma mark - Notifications


#pragma mark - Actions

- (IBAction)send
{
    DETweetPoster *tweetPoster = [[DETweetPoster alloc] init];
    [tweetPoster postTweet:self.textView.text withImages:[NSArray arrayWithObject:[UIImage imageNamed:@"Buzz.jpeg"]]];
//    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)cancel
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Accessors

#pragma mark - UIAlertViewDelegate

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    // Notice this is a class method since we're displaying the alert from a class method.
    // This is not the real code. Put real code here.
{
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs://Twitter"]];
    }
}


@end
