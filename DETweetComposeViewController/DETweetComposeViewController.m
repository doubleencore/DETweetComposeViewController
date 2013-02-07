    //
    //  DETweetComposeViewController.m
    //  DETweeter
    //
    //  Copyright (c) 2011-2012 Double Encore, Inc. All rights reserved.
    //
    //  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    //  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    //  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer 
    //  in the documentation and/or other materials provided with the distribution. Neither the name of the Double Encore Inc. nor the names of its 
    //  contributors may be used to endorse or promote products derived from this software without specific prior written permission.
    //  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
    //  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
    //  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
    //  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    //  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    //

#import "DETweetComposeViewController.h"
#import "DETweetPoster.h"
#import "DETweetSheetCardView.h"
#import "DETweetTextView.h"
#import "DETweetGradientView.h"
#import "OAuth.h"
#import "OAuth+DEExtensions.h"
#import "OAuthConsumerCredentials.h"
#import "UIDevice+DETweetComposeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Accounts/Accounts.h>
#import <Twitter/TWRequest.h>


static BOOL waitingForAccess = NO;


@interface DETweetComposeViewController ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *urls;
@property (nonatomic, retain) NSArray *attachmentFrameViews;
@property (nonatomic, retain) NSArray *attachmentImageViews;
@property (nonatomic) UIStatusBarStyle previousStatusBarStyle;
@property (nonatomic, assign) UIViewController *fromViewController;
@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) DETweetGradientView *gradientView;
@property (nonatomic, retain) UIPickerView *accountPickerView;
@property (nonatomic, retain) UIPopoverController *accountPickerPopoverController;
@property (nonatomic, retain) id twitterAccount;  // iOS 5 use only.
@property (nonatomic, retain) OAuth *oAuth;

- (void)tweetComposeViewControllerInit;
- (void)updateFramesForOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)isPresented;
- (NSInteger)charactersAvailable;
- (void)updateCharacterCount;
- (NSInteger)attachmentsCount;
- (void)updateAttachments;
- (void)selectTwitterAccount;
- (void)displayNoTwitterAccountsAlert;
- (void)presentAccountPicker;
- (void)checkTwitterCredentials;
- (UIImage*)captureScreen;

@end


@implementation DETweetComposeViewController

    // IBOutlets
@synthesize cardView = _cardView;
@synthesize titleLabel = _titleLabel;
@synthesize cancelButton = _cancelButton;
@synthesize sendButton = _sendButton;
@synthesize cardHeaderLineView = _cardHeaderLineView;
@synthesize textView = _textView;
@synthesize textViewContainer = _textViewContainer;
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
@synthesize alwaysUseDETwitterCredentials = _alwaysUseDETwitterCredentials;

    // Private
@synthesize text = _text;
@synthesize images = _images;
@synthesize urls = _urls;
@synthesize attachmentFrameViews = _attachmentFrameViews;
@synthesize attachmentImageViews = _attachmentImageViews;
@synthesize previousStatusBarStyle = _previousStatusBarStyle;
@synthesize fromViewController = _fromViewController;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize gradientView = _gradientView;
@synthesize accountPickerView = _accountPickerView;
@synthesize accountPickerPopoverController = _accountPickerPopoverController;
@synthesize twitterAccount = _twitterAccount;
@synthesize oAuth = _oAuth;

enum {
    DETweetComposeViewControllerNoAccountsAlert = 1,
    DETweetComposeViewControllerCannotSendAlert
};

NSInteger const DETweetMaxLength = 140;
NSInteger const DETweetURLLength = 20;  // https://dev.twitter.com/docs/tco-url-wrapper
NSInteger const DETweetMaxImages = 1;  // We'll get this dynamically later, but not today.
static NSString * const DETweetLastAccountIdentifier = @"DETweetLastAccountIdentifier";

#define degreesToRadians(x) (M_PI * x / 180.0f)


#pragma mark - Class Methods

+ (BOOL)canAccessTwitterAccounts
{
    if ([UIDevice de_isIOS5]) {
        ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
        ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        __block BOOL accessGranted = NO;
        [accountStore requestAccessToAccountsWithType:twitterAccountType
                                withCompletionHandler:^(BOOL granted, NSError *error) {
                                    accessGranted = granted;
                                    waitingForAccess = NO;
                                }];
        waitingForAccess = YES;
        while (waitingForAccess) {
            sleep(1);
        }
        
        return accessGranted;
    }
    
    return YES;
}


+ (BOOL)canSendTweet
{
    BOOL canSendTweet = NO;
    
    if ([UIDevice de_isIOS5] && [[self class] canAccessTwitterAccounts]) {
        ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
        ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
        if ([twitterAccounts count] > 0) {
            canSendTweet = YES;
        }
    }
    
    if ([OAuth isTwitterAuthorized]) {
        canSendTweet = YES;
    }
    
    return canSendTweet;
}


+ (void)displayNoTwitterAccountsAlert
    // We have an instance method that's identical to this. Make sure it stays identical.
    // This duplicates the message and buttons displayed in Apple's TWTweetComposeViewController alert message.
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Twitter Accounts", @"")
                                                         message:NSLocalizedString(@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings.", @"")
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles:nil] autorelease];
    alertView.tag = DETweetComposeViewControllerNoAccountsAlert;
    [alertView show];
}


+ (NSArray *)systemTwitterAccounts
{
    ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    return [accountStore accountsWithAccountType:twitterAccountType];
}

- (UIImage *) captureScreen {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        CGFloat statusBarOffset = -20.0f;
        if ( UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation]))
        {
            CGContextTranslateCTM(context,statusBarOffset, 0.0f);

        }else
        {
            CGContextTranslateCTM(context, 0.0f, statusBarOffset);
        }
    }
    
    [keyWindow.layer renderInContext:context];   
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageOrientation imageOrientation;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationRight;
            break;
        case UIInterfaceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationLeft;
            break;
        case UIInterfaceOrientationPortrait:
            imageOrientation = UIImageOrientationUp;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        default:
            break;
    }
    
    UIImage *outputImage = [[[UIImage alloc] initWithCGImage: image.CGImage
                                                      scale: 1.0
                                                orientation: imageOrientation] autorelease];
    return outputImage;
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
    [_textViewContainer release], _textViewContainer = nil;
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
    [_backgroundImageView release], _backgroundImageView = nil;
    [_gradientView release], _gradientView = nil;
    [_accountPickerView release], _accountPickerView = nil;
    [_accountPickerPopoverController release], _accountPickerPopoverController = nil;
    [_twitterAccount release], _twitterAccount = nil;
    [_oAuth release], _oAuth = nil;
    
    [super dealloc];
}


#pragma mark - Superclass Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.textViewContainer.backgroundColor = [UIColor clearColor];
    self.textView.backgroundColor = [UIColor clearColor];
    
    if ([UIDevice de_isIOS5]) {
        self.fromViewController = self.presentingViewController;
        self.textView.keyboardType = UIKeyboardTypeTwitter;
    }
    else {
        self.fromViewController = self.parentViewController;
    }
    
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
    [self.attachmentImageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        ((UIImageView *)obj).layer.cornerRadius = 3.0f;
        ((UIImageView *)obj).layer.masksToBounds = YES;
    }];
    
    self.textView.text = self.text;
    [self.textView becomeFirstResponder];
    
    [self updateCharacterCount];
    [self updateAttachments];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

        // Take a snapshot of the current view, and make that our background after our view animates into place.
        // This only works if our orientation is the same as the presenting view.
        // If they don't match, just display the gray background.
    if (self.interfaceOrientation == self.fromViewController.interfaceOrientation) {
        UIImage *backgroundImage = [self captureScreen];
        self.backgroundImageView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
    }
    else {
        self.backgroundImageView = [[[UIImageView alloc] initWithFrame:self.fromViewController.view.bounds] autorelease];
    }
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingNone;
    self.backgroundImageView.alpha = 0.0f;
    self.backgroundImageView.backgroundColor = [UIColor lightGrayColor];
    [self.view insertSubview:self.backgroundImageView atIndex:0];
    
        // Now let's fade in a gradient view over the presenting view.
    self.gradientView = [[[DETweetGradientView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds] autorelease];
    self.gradientView.autoresizingMask = UIViewAutoresizingNone;
    self.gradientView.transform = self.fromViewController.view.transform;
    self.gradientView.alpha = 0.0f;
    self.gradientView.center = [UIApplication sharedApplication].keyWindow.center;
    [self.fromViewController.view addSubview:self.gradientView];
    [UIView animateWithDuration:0.3f
                     animations:^ {
                         self.gradientView.alpha = 1.0f;
                     }];    
    
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES]; 
    
    [self updateFramesForOrientation:self.interfaceOrientation];
    
    [self checkTwitterCredentials];
    
    [self selectTwitterAccount];  // Set or verify our default account.
    
        // Like TWTweetComposeViewController, we'll let the user change the account only if
        // we're in portrait orientation on iPhone. iPad can do it in any orientation.
    if ([[DETweetPoster accounts] count] > 1
        && ([UIDevice de_isPad] || UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ) {
        self.textView.accountName = ((ACAccount *)self.twitterAccount).accountDescription;
    }
    else {
        self.textView.accountName = nil;
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.backgroundImageView.alpha = 1.0f;
    //self.backgroundImageView.frame = [self.view convertRect:self.backgroundImageView.frame fromView:[UIApplication sharedApplication].keyWindow];
    [self.view insertSubview:self.gradientView aboveSubview:self.backgroundImageView];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIView *presentingView = [UIDevice de_isIOS5] ? self.fromViewController.view : self.parentViewController.view;
    [presentingView addSubview:self.gradientView];
    
    [self.backgroundImageView removeFromSuperview];
    self.backgroundImageView = nil;
    
    [UIView animateWithDuration:0.3f
                     animations:^ {
                         self.gradientView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [self.gradientView removeFromSuperview];
                     }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:self.previousStatusBarStyle animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self.parentViewController respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)]) {
        return [self.parentViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    
    if ([UIDevice de_isPhone]) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }

    return YES;  // Default for iPad.
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateFramesForOrientation:interfaceOrientation];
    self.accountPickerView.alpha = 0.0f;
    
        // Our fake background won't rotate properly. Just hide it.
    if (interfaceOrientation == self.presentedViewController.interfaceOrientation) {
        self.backgroundImageView.alpha = 1.0f;
    }
    else {
        self.backgroundImageView.alpha = 0.0f;
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.accountPickerView removeFromSuperview];
    self.accountPickerView = nil;  // Easier to recreate it next time rather than resize it.
    
    if (self.accountPickerPopoverController) {
        [self presentAccountPicker];
    }
}


- (void)viewDidUnload
{
        // Keep:
        //  _completionHandler
        //  _text
        //  _images
        //  _urls
        //  _twitterAccount
    
        // Save the text.
    self.text = self.textView.text;
    
        // IBOutlets
    self.cardView = nil;
    self.titleLabel = nil;
    self.cancelButton = nil;
    self.sendButton = nil;
    self.cardHeaderLineView = nil;
    self.textView = nil;
    self.textViewContainer = nil;
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
    self.gradientView = nil;
    self.accountPickerView = nil;
    self.accountPickerPopoverController = nil;
    self.oAuth = nil;
    
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
    
    if (([self charactersAvailable] - (DETweetURLLength + 1)) < 0) {  // Add one for the space character.
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
    
    if (([self charactersAvailable] - (DETweetURLLength + 1)) < 0) {  // Add one for the space character.
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

- (void)updateFramesForOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    CGFloat buttonHorizontalMargin = 8.0f;
    CGFloat cardWidth, cardTop, cardHeight, cardHeaderLineTop, buttonTop;
    UIImage *cancelButtonImage, *sendButtonImage;
    CGFloat titleLabelFontSize, titleLabelTop;
    CGFloat characterCountLeft, characterCountTop;
    
    if ([UIDevice de_isPhone]) {
        cardWidth = CGRectGetWidth(self.view.bounds) - 10.0f;
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
        cardWidth = 543.0f;
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
    
    CGFloat textWidth = CGRectGetWidth(self.cardView.bounds);
    if ([self attachmentsCount] > 0) {
        textWidth -= CGRectGetWidth(self.attachment1FrameView.frame) + 10.0f;  // Got to measure frame 1, because it's not rotated. Other frames are funky.
    }
    CGFloat textTop = CGRectGetMaxY(self.cardHeaderLineView.frame) - 1.0f;
    CGFloat textHeight = self.cardView.bounds.size.height - textTop - 30.0f;
    self.textViewContainer.frame = CGRectMake(0.0f, textTop, self.cardView.bounds.size.width, textHeight);
    self.textView.frame = CGRectMake(0.0f, 0.0f, textWidth, self.textViewContainer.frame.size.height);
    self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, -(self.cardView.bounds.size.width - textWidth - 1.0f));
    
    self.paperClipView.frame = CGRectMake(CGRectGetMaxX(self.cardView.frame) - self.paperClipView.frame.size.width + 6.0f,
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
    if ([UIDevice de_isPhone]) {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            characterCountTop -= 5.0f;
            if ([self attachmentsCount] > 0) {
                characterCountLeft -= CGRectGetWidth(self.attachment3FrameView.frame) - 15.0f;
            }
        }
    }
    self.characterCountLabel.frame = CGRectMake(characterCountLeft, characterCountTop, self.characterCountLabel.frame.size.width, self.characterCountLabel.frame.size.height);
    
    self.gradientView.frame = self.gradientView.superview.bounds;
}


- (BOOL)isPresented
{
    return [self isViewLoaded];
}


- (NSInteger)charactersAvailable
{
    NSInteger available = DETweetMaxLength;
    available -= (DETweetURLLength + 1) * [self.images count];
    available -= (DETweetURLLength + 1) * [self.urls count];
    available -= [self.textView.text length];
    
    if ( (available < DETweetMaxLength) && ([self.textView.text length] == 0) ) {
        available += 1;  // The space we added for the first URL isn't needed.
    }
    
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


- (void)selectTwitterAccount
    // Picks the iOS 5 Twitter account to use.
    // If one is already selected, makes sure it's still valid.
    // If not, another is picked.
{
    if ([UIDevice de_isIOS5] == NO || self.alwaysUseDETwitterCredentials == YES) {
        return;
    }
    
    NSArray *accounts = [DETweetPoster accounts];
    
    if ([accounts count] == 0) {
        self.twitterAccount = nil;
        return;
    }
    
    NSString *accountIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:DETweetLastAccountIdentifier];
    if (self.twitterAccount) {
        accountIdentifier = ((ACAccount *)self.twitterAccount).identifier;
    }
    
    if ([accountIdentifier length] > 0) {
        NSUInteger index = [accounts indexOfObjectPassingTest:^BOOL(ACAccount *account, NSUInteger idx, BOOL *stop) {
            *stop = [account.identifier isEqualToString:accountIdentifier];
            return *stop;
        }];
        if (index != NSNotFound) {
            self.twitterAccount = [accounts objectAtIndex:index];
        }
        else {
            self.twitterAccount = nil;  // Clear out the invalid account.
        }
    }
    
    if (self.twitterAccount == nil) {
        self.twitterAccount = [accounts objectAtIndex:0];  // Safe, since we tested for [accounts count] == 0 above.
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:((ACAccount *)self.twitterAccount).identifier forKey:DETweetLastAccountIdentifier];
}


- (void)displayNoTwitterAccountsAlert
    // A private instance version of the class method with the same name.
    // This duplicates the message and buttons displayed in Apple's TWTweetComposeViewController alert message.
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Twitter Accounts", @"")
                                                         message:NSLocalizedString(@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings.", @"")
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                               otherButtonTitles:nil] autorelease];
    alertView.tag = DETweetComposeViewControllerNoAccountsAlert;
    [alertView show];
}


- (void)presentAccountPicker
{
    if ([UIDevice de_isPhone]) {
        if (self.accountPickerView == nil) {
            self.accountPickerView = [[[UIPickerView alloc] init] autorelease];
            CGRect frame = self.accountPickerView.frame;
            frame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.accountPickerView.frame);
            self.accountPickerView.frame = frame;
            self.accountPickerView.dataSource = self;
            self.accountPickerView.delegate = self;
            self.accountPickerView.showsSelectionIndicator = YES;
            [self.view addSubview:self.accountPickerView];
        }
        self.accountPickerView.alpha = 1.0f;
        [self.textView resignFirstResponder];
    }
    
    else {  // iPad
        if (self.accountPickerPopoverController == nil) {
            DETweetAccountSelectorViewController *contentViewController = [[[DETweetAccountSelectorViewController alloc] init] autorelease];
            contentViewController.delegate = self;
            contentViewController.selectedAccount = self.twitterAccount;
            self.accountPickerPopoverController = [[[UIPopoverController alloc] initWithContentViewController:contentViewController] autorelease];
            self.accountPickerPopoverController.delegate = self;
        }
        CGRect presentFromRect = [self.view convertRect:self.textView.fromButtonFrame fromView:self.textView];
        [self.accountPickerPopoverController presentPopoverFromRect:presentFromRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown animated:YES];
    }
}


- (void)checkTwitterCredentials
{
    if (self.alwaysUseDETwitterCredentials == NO && [UIDevice de_isIOS5]) {
            // Try using iOS5 Twitter credentials
        if ([[self class] canAccessTwitterAccounts]) {
            ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
            ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
            if ([twitterAccounts count] < 1) {
                [self displayNoTwitterAccountsAlert];
            }
        }
        else {
            [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:self afterDelay:1.0f];
        }
    }
    else {
            // Present Twitter OAuth login if necessary
        if (![OAuth isTwitterAuthorized]) {
            self.oAuth = [[[OAuth alloc] initWithConsumerKey:kDEConsumerKey andConsumerSecret:kDEConsumerSecret] autorelease];
            TwitterDialog *td = [[[TwitterDialog alloc] init] autorelease];
            td.twitterOAuth = self.oAuth;
            td.delegate = self;
            td.logindelegate = self;
            [self.textView resignFirstResponder];
            [td show];
        }
    }
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateCharacterCount];
}


#pragma mark - DETweetTextViewDelegate

- (void)tweetTextViewAccountButtonWasTouched:(DETweetTextView *)tweetTextView
{
    [self presentAccountPicker];
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *accounts = [DETweetPoster accounts];
    return [accounts count];
}


#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    ACAccount *account = [[DETweetPoster accounts] objectAtIndex:row];
    
    if ([account.accountDescription isEqualToString:@"Primary Account"]) {
        [self.accountPickerView selectRow:row inComponent:0 animated:NO];
    }
    
    return account.accountDescription;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.twitterAccount = [[DETweetPoster accounts] objectAtIndex:row];
    self.textView.accountName = ((ACAccount *)self.twitterAccount).accountDescription;
}



#pragma mark - DETweetAccountSelectorViewControllerDelegate

- (void)tweetAccountSelectorViewController:(DETweetAccountSelectorViewController *)viewController didSelectAccount:(ACAccount *)account
{
    self.twitterAccount = account;
    self.textView.accountName = ((ACAccount *)self.twitterAccount).accountDescription;
    [self.accountPickerPopoverController dismissPopoverAnimated:YES];
}


#pragma mark - DETweetPosterDelegate

- (void)tweetFailed:(DETweetPoster *)tweetPoster
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Send Tweet", @"")
                                                         message:[NSString stringWithFormat:NSLocalizedString(@"The tweet, \"%@\" cannot be sent because the connection to Twitter failed.", @""), self.textView.text]
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                               otherButtonTitles:NSLocalizedString(@"Try Again", @""), nil] autorelease];
    alertView.tag = DETweetComposeViewControllerCannotSendAlert;
    [alertView show];
    
    self.sendButton.enabled = YES;
}


- (void)tweetFailedAuthentication:(DETweetPoster *)tweetPoster
{
    [OAuth clearCrendentials];
    [self dismissModalViewControllerAnimated:YES];
    
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Send Tweet", @"")
                                 message:NSLocalizedString(@"Unable to login to Twitter with existing credentials. Try again with new credentials.", @"")
                                delegate:nil
                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                       otherButtonTitles:nil] autorelease] show];
}


- (void)tweetSucceeded:(DETweetPoster *)tweetPoster
{
    CGFloat yOffset = -(self.view.bounds.size.height + CGRectGetMaxY(self.cardView.frame) + 10.0f);
    
    [UIView animateWithDuration:0.35f
                     animations:^ {
                         self.cardView.frame = CGRectOffset(self.cardView.frame, 0.0f, yOffset);
                         self.paperClipView.frame = CGRectOffset(self.paperClipView.frame, 0.0f, yOffset);
                     }];
    
    
    if (self.completionHandler) {
        self.completionHandler(DETweetComposeViewControllerResultDone);
    }
    else {
        [self dismissModalViewControllerAnimated:YES];
    }
}


#pragma mark - Actions

- (IBAction)send
{
    self.sendButton.enabled = NO;
    
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
    [tweetPoster postTweet:tweet withImages:self.images fromAccount:self.twitterAccount];
}


- (IBAction)cancel
{
    if (self.completionHandler) {
        self.completionHandler(DETweetComposeViewControllerResultCancelled);
    }
    else {
        [self dismissModalViewControllerAnimated:YES];
    }
}


#pragma mark - UIAlertViewDelegate

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    // Notice this is a class method since we're displaying the alert from a class method.
{
    // no op
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    // This gets called if there's an error sending the tweet.
{
    if (alertView.tag == DETweetComposeViewControllerNoAccountsAlert) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else if (alertView.tag == DETweetComposeViewControllerCannotSendAlert) {
        if (buttonIndex == 1) {
                // The user wants to try again.
            [self send];
        }
    }
}


#pragma mark - TwitterLoginDialogDelegate

- (void)twitterDidLogin
{
    [self.oAuth saveOAuthContext];
    [self.textView becomeFirstResponder];
}


- (void)twitterDidNotLogin:(BOOL)cancelled
{
        // Oddly this is not an optional method in the protocol.
    [self dismissModalViewControllerAnimated:YES];
}

@end
