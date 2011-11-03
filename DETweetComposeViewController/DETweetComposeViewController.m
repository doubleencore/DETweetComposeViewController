//
//  DETweetComposeViewController.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DETweetComposeViewController.h"
#import "DETweetPoster.h"
#import <QuartzCore/QuartzCore.h>


@interface DETweetComposeViewController ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *urls;
@property (nonatomic, retain) NSArray *attachmentFrameViews;
@property (nonatomic, retain) NSArray *attachmentImageViews;

- (void)tweetComposeViewControllerInit;
- (BOOL)isPresented;
- (NSInteger)charactersAvailable;
- (void)updateCharacterCount;
- (void)updateAttachments;

@end


@implementation DETweetComposeViewController

    // IBOutlets
@synthesize cancelButton = _cancelButton;
@synthesize sendButton = _sendButton;
@synthesize textView = _textView;
@synthesize paperClipView = _paperClipView;
@synthesize attachment1FrameView = _attachment1FrameView;
@synthesize attachment2FrameView = _attachment2FrameView;
@synthesize attachment3FrameView = _attachment3FrameView;
@synthesize attachment1ImageView = _attachment1ImageView;
@synthesize attachment2ImageView = _attachment2ImageView;
@synthesize attachment3ImageView = _attachment3ImageView;
@synthesize characterCountLabel = _characterCountLabel;

    // Public
@synthesize completionHandler = _completionHandler;

    // Private
@synthesize text = _text;
@synthesize images = _images;
@synthesize urls = _urls;
@synthesize attachmentFrameViews = _attachmentFrameViews;
@synthesize attachmentImageViews = _attachmentImageViews;


NSInteger const DETweetMaxLength = 140;
NSInteger const DETweetURLLength = 21;    // https://dev.twitter.com/docs/tco-url-wrapper
NSInteger const DETweetMaxImages = 1;  // We'll get this dynamically later, but not today.


#pragma mark - Class Methods

+ (BOOL)canSendTweet
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token"] &&
        [[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token_secret"] &&
        [[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token_authorized"]) {
        return YES;
    }
    
    return NO;
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
    [_textView release], _textView = nil;
    [_paperClipView release], _paperClipView = nil;
    [_attachment1FrameView release], _attachment1FrameView = nil;
    [_attachment2FrameView release], _attachment2FrameView = nil;
    [_attachment3FrameView release], _attachment3FrameView = nil;
    [_attachment1ImageView release], _attachment1ImageView = nil;
    [_attachment2ImageView release], _attachment2ImageView = nil;
    [_attachment3ImageView release], _attachment3ImageView = nil;
    [_characterCountLabel release], _characterCountLabel = nil;

        // Public
    [_completionHandler release], _completionHandler = nil;
    
        // Private
    [_text release], _text = nil;
    [_images release], _images = nil;
    [_urls release], _urls = nil;
    [_attachmentFrameViews release], _attachmentFrameViews = nil;
    [_attachmentImageViews release], _attachmentImageViews = nil;
    
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

        // Put the attachment frames and image views into arrays so they're easier to work with.
        // Order is important, so we can't use IB object arrays. Or at least this is easier.
    self.attachmentFrameViews = [NSArray arrayWithObjects:
                                 self.attachment1FrameView,
                                 self.attachment2FrameView,
                                 self.attachment3FrameView,
                                 nil];

    self.attachmentImageViews = [NSArray arrayWithObjects:
                                 self.attachment1ImageView,
                                 self.attachment2ImageView,
                                 self.attachment3ImageView,
                                 nil];
    
        // Mask the corners on the image views so they don't stick out of the frame.
    [self.self.attachmentImageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        ((UIImageView *)obj).layer.cornerRadius = 3.0f;
        ((UIImageView *)obj).layer.masksToBounds = YES;
    }];
    
    self.textView.text = self.text;
    [self.textView becomeFirstResponder];
    
    [self updateCharacterCount];
    [self updateAttachments];
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
        // Keep:
        //  _completionHandler
        //  _text
        //  _images
        //  _urls

    self.text = self.textView.text;
    
        // IBOutlets
    self.cancelButton = nil;
    self.sendButton = nil;
    self.textView = nil;
    self.paperClipView = nil;
    self.attachment1FrameView = nil;
    self.attachment2FrameView = nil;
    self.attachment3FrameView = nil;
    self.attachment1ImageView = nil;
    self.attachment2ImageView = nil;
    self.attachment3ImageView = nil;
    self.characterCountLabel = nil;

        // Private
    self.attachmentFrameViews = nil;
    self.attachmentImageViews = nil;

    [super viewDidUnload];
}


#pragma mark - Public

- (BOOL)setInitialText:(NSString *)initialText
{
    if ([self isPresented]) {
        return NO;
    }
    
    if (([self charactersAvailable] - (NSInteger)[initialText length]) < 0) {
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
    
    if ([self.images count] >= DETweetMaxImages) {
        return NO;
    }
    
    if (([self charactersAvailable] - DETweetURLLength) < 0) {
        return NO;
    }
    
    [self.images addObject:image];
    return YES;
}


- (BOOL)addImageWithURL:(NSURL *)url;
    // Not yet impelemented.
{
        // We should probably just start the download, rather than saving the URL.
        // Just save the image once we have it.
    return NO;
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
    
    if (([self charactersAvailable] - DETweetURLLength) < 0) {
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


- (NSInteger)charactersAvailable
{
    NSInteger available = DETweetMaxLength;
    available -= DETweetURLLength * [self.images count];
    available -= DETweetURLLength * [self.urls count];
    available -= [self.textView.text length];
    return available;
}


- (void)updateCharacterCount
{
    NSInteger available = [self charactersAvailable];
    
    self.characterCountLabel.text = [NSString stringWithFormat:@"%d", available];
    
    if (available >= 0) {
        self.characterCountLabel.textColor = [UIColor grayColor];
    }
    else {
        self.characterCountLabel.textColor = [UIColor colorWithRed:0.64f green:0.32f blue:0.32f alpha:1.0f];
    }
}


- (void)updateAttachments
{
        // Create a array of attachment images to display.
    NSMutableArray *attachmentImages = [NSMutableArray arrayWithArray:self.images];
    for (NSInteger index = 0; index < [self.urls count]; index++) {
        [attachmentImages addObject:[UIImage imageNamed:@"DETweetURLAttachment"]];
    }
    
    self.paperClipView.hidden = YES;
    self.attachment1FrameView.hidden = YES;
    self.attachment2FrameView.hidden = YES;
    self.attachment3FrameView.hidden = YES;

    if ([attachmentImages count] >= 1) {
        self.paperClipView.hidden = NO;
        self.attachment1FrameView.hidden = NO;
        self.attachment1ImageView.image = [attachmentImages objectAtIndex:0];

        if ([attachmentImages count] >= 2) {
            self.paperClipView.hidden = NO;
            self.attachment2FrameView.hidden = NO;
            self.attachment2ImageView.image = [attachmentImages objectAtIndex:1];
            
            if ([attachmentImages count] >= 3) {
                self.paperClipView.hidden = NO;
                self.attachment3FrameView.hidden = NO;
                self.attachment3ImageView.image = [attachmentImages objectAtIndex:2];
            }
        }
    }
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateCharacterCount];
}


#pragma mark - DETweetPosterDelegate

- (void)tweetFailed
{
    [[[[UIAlertView alloc] initWithTitle:@"Cannot Send Tweet"
                               message:[NSString stringWithFormat:@"The tweet, \"%@\" cannot be sent because the connection to Twitter failed.", self.textView.text]
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                       otherButtonTitles:@"Try Again", nil] autorelease] show];
}


- (void)tweetSucceeded
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self send];
    }
}

#pragma mark - Actions

- (IBAction)send
{
    self.sendButton.enabled = NO;
    
    DETweetPoster *tweetPoster = [[DETweetPoster alloc] init];
    tweetPoster.delegate = self;
    [tweetPoster postTweet:self.textView.text withImages:[NSArray arrayWithObject:[UIImage imageNamed:@"Buzz.jpeg"]]];
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
