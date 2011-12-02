//
//  DETweetTextView.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DETweetTextView.h"
#import "DETweetRuledView.h"


@interface DETweetTextView ()

@property (nonatomic, retain) DETweetRuledView *ruledView;

- (void)textViewInit;
- (CGRect)ruledViewFrame;

@end


@implementation DETweetTextView

    // Private
@synthesize ruledView = _ruledView;


#pragma mark - Setup & Teardown

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self textViewInit];
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self textViewInit];
    }
    
    return self;
}


- (void)textViewInit
{   
    self.clipsToBounds = NO;  // So the rules can extend outside of the view.

    self.ruledView = [[DETweetRuledView alloc] initWithFrame:[self ruledViewFrame]];
    self.ruledView.lineColor = [[UIColor colorWithWhite:0.5f alpha:0.15f] retain];
    self.ruledView.lineWidth = 1.0f;
    self.ruledView.rowHeight = self.font.lineHeight;
    [self insertSubview:self.ruledView atIndex:0];
}


- (void)dealloc
{    
        // Private
    [_ruledView release], _ruledView = nil;
    
    [super dealloc];
}


#pragma mark - Superclass Overrides

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    self.ruledView.frame = [self ruledViewFrame];
}


- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    self.ruledView.rowHeight = self.font.lineHeight;
}


#pragma mark - Private

- (CGRect)ruledViewFrame
{
    CGFloat extraForBounce = 200.0f;
    CGFloat textAlignmentOffset = -2.0f;  // To center the text between the lines. May want to find a way to determine this procedurally eventually.
    return CGRectMake(0.0f, -extraForBounce + textAlignmentOffset, 500.0f, self.contentSize.height + (2 * extraForBounce));
}


@end
