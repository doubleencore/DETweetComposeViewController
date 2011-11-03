//
//  DETweetSheetCardView.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DETweetSheetCardView.h"
#import <QuartzCore/QuartzCore.h>


@interface DETweetSheetCardView ()

@property (nonatomic, retain) UIView *backgroundView;

- (void)tweetSheetCardViewInit;

@end


@implementation DETweetSheetCardView

@synthesize backgroundView = _backgroundView;


#pragma mark - Setup & Teardown

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self tweetSheetCardViewInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self tweetSheetCardViewInit];
    }
    return self;
}


- (void)tweetSheetCardViewInit
{
    self.backgroundColor = [UIColor clearColor];  // So we can use any color in IB.
    
        // Add a border and a shadow.
    self.layer.cornerRadius = 12.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor colorWithWhite:0.17f alpha:1.0f].CGColor;
    self.layer.shadowOpacity = 1.0f;
    self.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.layer.shadowRadius = 5.0f;
    
        // Add the background image.
        // We can't put the image on the root view because we need to clip the
        // edges, which we can't do if we want the shadow.
    self.backgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
    self.backgroundView.layer.masksToBounds = YES;
    self.backgroundView.layer.cornerRadius = self.layer.cornerRadius + 1.0f;
    self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"DETweetCardBackground"]];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:self.backgroundView atIndex:0];
}


- (void)dealloc
{
    [_backgroundView release], _backgroundView = nil;
    
    [super dealloc];
}


#pragma mark - Superclass Overrides

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.backgroundView.frame = self.bounds;    
}


@end
