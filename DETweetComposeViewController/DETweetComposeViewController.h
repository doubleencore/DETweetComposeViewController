//
//  DETweetComposeViewController.h
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

@interface DETweetComposeViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *sendButton;
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) IBOutlet UIImageView *paperClipView;
@property (retain, nonatomic) IBOutlet UIImageView *attachmentFrameView;
@property (retain, nonatomic) IBOutlet UIImageView *attachmentImageView;

    // Public
+ (void)displayNoTwitterAccountsAlert;
+ (void)displayNoTwitterAccountsAlertWithTarget:(id)target action:(SEL)selector;

- (IBAction)send;
- (IBAction)cancel;




enum DETweetComposeViewControllerResult {
    DETweetComposeViewControllerResultCancelled,
    DETweetComposeViewControllerResultDone
};
typedef enum DETweetComposeViewControllerResult DETweetComposeViewControllerResult;

    // Completion handler for DETweetComposeViewController
typedef void (^DETweetComposeViewControllerCompletionHandler)(DETweetComposeViewControllerResult result); 

    // Returns if Twitter is accessible and at least one account has been setup.
+ (BOOL)canSendTweet;

    // Sets the initial text to be tweeted. Returns NO if the specified text will
    // not fit within the character space currently available, or if the sheet
    // has already been presented to the user.
- (BOOL)setInitialText:(NSString *)text;

    // Adds an image to the tweet. Returns NO if the additional image will not fit
    // within the character space currently available, or if the sheet has already
    // been presented to the user.
- (BOOL)addImage:(UIImage *)image;

    // Adds a URL to the tweet. Returns NO if the additional URL will not fit
    // within the character space currently available, or if the sheet has already
    // been presented to the user.
- (BOOL)addImageWithURL:(NSURL *)url;

    // Removes all images from the tweet. Returns NO and does not perform an operation
    // if the sheet has already been presented to the user. 
- (BOOL)removeAllImages;

    // Adds a URL to the tweet. Returns NO if the additional URL will not fit
    // within the character space currently available, or if the sheet has already
    // been presented to the user.
- (BOOL)addURL:(NSURL *)url;

    // Removes all URLs from the tweet. Returns NO and does not perform an operation
    // if the sheet has already been presented to the user.
- (BOOL)removeAllURLs;

    // Specify a block to be called when the user is finished. This block is not guaranteed
    // to be called on any particular thread.
@property (nonatomic, copy) DETweetComposeViewControllerCompletionHandler completionHandler;

@end
