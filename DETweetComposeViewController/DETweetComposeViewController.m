//
//  DETweetComposeViewController.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DETweetComposeViewController.h"
#import "DETweetPoster.h"
#import "DETweetSheetCardView.h"
#import "OAuth.h"
#import "OAuth+DEExtensions.h"
#import <QuartzCore/QuartzCore.h>

@interface DETweetComposeViewController ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *urls;
@property (nonatomic, retain) NSArray *attachmentFrameViews;
@property (nonatomic, retain) NSArray *attachmentImageViews;
@property (nonatomic) UIStatusBarStyle previousStatusBarStyle;

- (void)tweetComposeViewControllerInit;
- (BOOL)isPresented;
- (BOOL)isIOS5;
- (NSInteger)charactersAvailable;
- (void)updateCharacterCount;
- (NSInteger)attachmentsCount;
- (void)updateAttachments;

@end


@implementation DETweetComposeViewController

    // IBOutlets
@synthesize cardView = _cardView;
@synthesize titleLabel = _titleLabel;
@synthesize cancelButton = _cancelButton;
@synthesize sendButton = _sendButton;
@synthesize cardHeaderLineView = _cardHeaderLineView;
@synthesize textView = _textView;
@synthesize paperClipView = _paperClipView;
@synthesize attachment1FrameView = _attachment1FrameView;
@synthesize attachment2FrameView = _attachment2FrameView;
@synthesize attachment3FrameView = _attachment3FrameView;
@synthesize attachment1ImageView = _attachment1ImageView;
@synthesize attachment2ImageView = _attachment2ImageView;
@synthesize attachment3ImageView = _attachment3ImageView;
@synthesize characterCountLabel = _characterCountLabel;
@synthesize previousStatusBarStyle = _previousStatusBarStyle;

    // Public
@synthesize completionHandler = _completionHandler;

    // Private
@synthesize text = _text;
@synthesize images = _images;
@synthesize urls = _urls;
@synthesize attachmentFrameViews = _attachmentFrameViews;
@synthesize attachmentImageViews = _attachmentImageViews;


NSInteger const DETweetMaxLength = 140;
NSInteger const DETweetURLLength = 21;  // https://dev.twitter.com/docs/tco-url-wrapper
NSInteger const DETweetMaxImages = 1;  // We'll get this dynamically later, but not today.

#define degreesToRadians(x) (M_PI * x / 180.0f)


#pragma mark - Class Methods

+ (BOOL)canSendTweet
{
    return [OAuth isTwitterAuthorized];
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
    [_cardView release], _cardView = nil;
    [_titleLabel release], _titleLabel = nil;
    [_cancelButton release], _cancelButton = nil;
    [_sendButton release], _sendButton = nil;
    [_cardHeaderLineView release], _cardHeaderLineView = nil;
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

        // Now add some angle to attachments 2 and 3.
    self.attachment2FrameView.transform = CGAffineTransformMakeRotation(degreesToRadians(-6.0f));
    self.attachment2ImageView.transform = CGAffineTransformMakeRotation(degreesToRadians(-6.0f));
    self.attachment3FrameView.transform = CGAffineTransformMakeRotation(degreesToRadians(-12.0f));
    self.attachment3ImageView.transform = CGAffineTransformMakeRotation(degreesToRadians(-12.0f));
    
        // Mask the corners on the image views so they don't stick out of the frame.
    [self.self.attachmentImageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        ((UIImageView *)obj).layer.cornerRadius = 3.0f;
        ((UIImageView *)obj).layer.masksToBounds = YES;
    }];
    
    if ([self isIOS5]) {
        self.textView.keyboardType = UIKeyboardTypeTwitter;
    }
    
    self.textView.text = self.text;
    [self.textView becomeFirstResponder];
    
    [self updateCharacterCount];
    [self updateAttachments];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES]; 
    
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0.0f];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:self.previousStatusBarStyle animated:YES];
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
    CGFloat buttonHorizontalMargin = 8.0f;
    CGFloat cardWidth, cardTop, cardHeight, cardHeaderLineTop, buttonTop;
    UIImage *cancelButtonImage, *sendButtonImage;
    CGFloat titleLabelFontSize, titleLabelTop;
    CGFloat characterCountLeft, characterCountTop;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        cardWidth = CGRectGetWidth(self.view.bounds) - 8.0f;
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            cardTop = 25.0f;
            cardHeight = 189.0f;
            buttonTop = 7.0f;
            cancelButtonImage = [[UIImage imageNamed:@"DETweetCancelButtonPortrait"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            sendButtonImage = [[UIImage imageNamed:@"DETweetSendButtonPortrait"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            cardHeaderLineTop = 41.0f;
            titleLabelFontSize = 20.0f;
            titleLabelTop = 9.0f;
        }
        else {
            cardTop = -1.0f;
            cardHeight = 150.0f;
            buttonTop = 6.0f;
            cancelButtonImage = [[UIImage imageNamed:@"DETweetCancelButtonLandscape"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            sendButtonImage = [[UIImage imageNamed:@"DETweetSendButtonLandscape"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            cardHeaderLineTop = 32.0f;
            titleLabelFontSize = 17.0f;
            titleLabelTop = 5.0f;
        }
    }
    else {  // iPad. Similar to iPhone portrait.
        cardWidth = 550.0f;
        cardHeight = 189.0f;
        buttonTop = 7.0f;
        cancelButtonImage = [[UIImage imageNamed:@"DETweetCancelButtonPortrait"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
        sendButtonImage = [[UIImage imageNamed:@"DETweetSendButtonPortrait"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
        cardHeaderLineTop = 41.0f;
        titleLabelFontSize = 20.0f;
        titleLabelTop = 9.0f;
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            cardTop = 280.0f;
        }
        else {
            cardTop = 110.0f;
        }
    }

    CGFloat cardLeft = trunc((CGRectGetWidth(self.view.bounds) - cardWidth) / 2);
    self.cardView.frame = CGRectMake(cardLeft, cardTop, cardWidth, cardHeight);

    self.titleLabel.font = [UIFont boldSystemFontOfSize:titleLabelFontSize];
    self.titleLabel.frame = CGRectMake(0.0f, titleLabelTop, cardWidth, self.titleLabel.frame.size.height);
    
    [self.cancelButton setBackgroundImage:cancelButtonImage forState:UIControlStateNormal];
    self.cancelButton.frame = CGRectMake(buttonHorizontalMargin, buttonTop, self.cancelButton.frame.size.width, cancelButtonImage.size.height);

    [self.sendButton setBackgroundImage:sendButtonImage forState:UIControlStateNormal];
    self.sendButton.frame = CGRectMake(self.cardView.bounds.size.width - buttonHorizontalMargin - self.sendButton.frame.size.width, buttonTop, self.sendButton.frame.size.width, sendButtonImage.size.height);

    self.cardHeaderLineView.frame = CGRectMake(0.0f, cardHeaderLineTop, self.cardView.bounds.size.width, self.cardHeaderLineView.frame.size.height);
    
    CGSize size = self.textView.contentSize;
    
    CGFloat textWidth = CGRectGetWidth(self.cardView.bounds);
    if ([self attachmentsCount] > 0) {
        textWidth -= CGRectGetWidth(self.attachment1FrameView.frame);  // Got to measure frame 1, because it's not rotated. Other frames are funky.
    }
    CGFloat textTop = CGRectGetMaxY(self.cardHeaderLineView.frame) - 2.0f;
    CGFloat textHeight = self.cardView.bounds.size.height - textTop - 30.0f;
    self.textView.frame = CGRectMake(0.0f, textTop, textWidth, textHeight);
    
    size = self.textView.contentSize;
    
    self.paperClipView.frame = CGRectMake(CGRectGetMaxX(self.cardView.frame) - self.paperClipView.frame.size.width + 5.0f,
                                          CGRectGetMinY(self.cardView.frame) + CGRectGetMaxY(self.cardHeaderLineView.frame) - 1.0f,
                                          self.paperClipView.frame.size.width,
                                          self.paperClipView.frame.size.height);
    
        // We need to position the rotated views by their center, not their frame.
        // This isn't elegant, but it is correct. Half-points are required because
        // some frame sizes aren't evenly divisible by 2.
    self.attachment1FrameView.center = CGPointMake(self.cardView.bounds.size.width - 45.0f, CGRectGetMaxY(self.paperClipView.frame) - cardTop + 18.0f);
    self.attachment1ImageView.center = CGPointMake(self.cardView.bounds.size.width - 45.5, self.attachment1FrameView.center.y - 2.0f);
    
    self.attachment2FrameView.center = CGPointMake(self.attachment1FrameView.center.x - 4.0f, self.attachment1FrameView.center.y + 5.0f);
    self.attachment2ImageView.center = CGPointMake(self.attachment1ImageView.center.x - 4.0f, self.attachment1ImageView.center.y + 5.0f);

    self.attachment3FrameView.center = CGPointMake(self.attachment2FrameView.center.x - 4.0f, self.attachment2FrameView.center.y + 5.0f);
    self.attachment3ImageView.center = CGPointMake(self.attachment2ImageView.center.x - 4.0f, self.attachment2ImageView.center.y + 5.0f);
    
    characterCountLeft = CGRectGetWidth(self.cardView.frame) - CGRectGetWidth(self.characterCountLabel.frame) - 12.0f;
    characterCountTop = CGRectGetHeight(self.cardView.frame) - CGRectGetHeight(self.characterCountLabel.frame) - 8.0f;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            characterCountTop -= 5.0f;
            if ([self attachmentsCount] > 0) {
                characterCountLeft -= CGRectGetWidth(self.attachment3FrameView.frame) - 15.0f;
            }
        }
    }
    self.characterCountLabel.frame = CGRectMake(characterCountLeft, characterCountTop, self.characterCountLabel.frame.size.width, self.characterCountLabel.frame.size.height);
}


- (void)viewDidUnload
{
        // Keep:
        //  _completionHandler
        //  _text
        //  _images
        //  _urls

        // Save the text.
    self.text = self.textView.text;
    
        // IBOutlets
    self.cardView = nil;
    self.titleLabel = nil;
    self.cancelButton = nil;
    self.sendButton = nil;
    self.cardHeaderLineView = nil;
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
        
    self.text = initialText;  // Keep a copy in case the view isn't loaded yet.
    self.textView.text = self.text;

    return YES;
}


- (BOOL)addImage:(UIImage *)image
{
    if (image == nil) {
        return NO;
    }
    
    if ([self isPresented]) {
        return NO;
    }
    
    if ([self.images count] >= DETweetMaxImages) {
        return NO;
    }
    
    if ([self attachmentsCount] >= 3) {
        return NO;  // Only three allowed.
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
    if (url == nil) {
        return NO;
    }
    
    if ([self isPresented]) {
        return NO;
    }
    
    if ([self attachmentsCount] >= 3) {
        return NO;  // Only three allowed.
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
         
- (BOOL)isIOS5
 {
     return (NSClassFromString(@"NSJSONSerialization") != nil);
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
        self.sendButton.enabled = (available != DETweetMaxLength);  // At least one character is required.
    }
    else {
        self.characterCountLabel.textColor = [UIColor colorWithRed:0.64f green:0.32f blue:0.32f alpha:1.0f];
        self.sendButton.enabled = NO;
    }
}


- (NSInteger)attachmentsCount
{
    return [self.images count] + [self.urls count];
}


- (void)updateAttachments
{
    CGRect frame = self.textView.frame;
    if ([self attachmentsCount] > 0) {
        frame.size.width = self.cardView.frame.size.width - self.attachment1FrameView.frame.size.width;
    }
    else {
        frame.size.width = self.cardView.frame.size.width;
    }
    self.textView.frame = frame;
    
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


- (void)tweetFailedAuthentication
{
    // Clear existing credentials
    [OAuth clearCrendentials];
    [self dismissModalViewControllerAnimated:YES];

    [[[[UIAlertView alloc] initWithTitle:@"Cannot Send Tweet"
                                 message:[NSString stringWithFormat:@"Unable to login to Twitter with existing credentials.  Try again with new credentials", self.textView.text]
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK", nil] autorelease] show];
}


- (void)tweetSucceeded
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Actions

- (IBAction)send
{
    self.sendButton.enabled = NO;
    [self.textView resignFirstResponder];
    
    NSString *tweet = self.textView.text;
    
    for (NSURL *url in self.urls) {
        NSString *urlString = [url absoluteString];
        if ([tweet length] > 0) {
            tweet = [tweet stringByAppendingString:@" "];
        }
        tweet = [tweet stringByAppendingString:urlString];
    }
    
    DETweetPoster *tweetPoster = [[[DETweetPoster alloc] init] autorelease];
    tweetPoster.delegate = self;
    [tweetPoster postTweet:tweet withImages:self.images];
}


- (IBAction)cancel
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - UIAlertViewDelegate

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    // Notice this is a class method since we're displaying the alert from a class method.
    // This is not the real code. Put real code here.
{
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs://Twitter"]];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    // This gets called if there's an error sending the tweet.
{
    if (buttonIndex == 1) {
            // The user wants to try again.
        [self send];
    }
}


@end
