//
//  DETweetSheetCardView.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DETweetSheetCardView.h"
#import <QuartzCore/QuartzCore.h>


@interface DETweetSheetCardView ()

- (void)tweetSheetCardViewInit;

@end


@implementation DETweetSheetCardView



#pragma mark - Class Methods


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
    UIView *backgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
    backgroundView.layer.masksToBounds = YES;
    backgroundView.layer.cornerRadius = self.layer.cornerRadius;
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"DETweetCardBackground"]];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:backgroundView atIndex:0];
}


#pragma mark - Superclass Overrides


#pragma mark - Public


#pragma mark - Private


#pragma mark - Notifications


#pragma mark - Actions


#pragma mark - Accessors




@end
