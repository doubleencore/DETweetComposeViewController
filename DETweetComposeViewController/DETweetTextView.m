//
//  DETweetTextView.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DETweetTextView.h"


@interface DETweetTextView ()

@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, retain) UIColor *lineColor;

- (void)textViewInit;
- (BOOL)isRetinaDisplay;

@end


@implementation DETweetTextView

@synthesize rowHeight = _rowHeight;
@synthesize lineWidth = _lineWidth;
@synthesize lineColor = _lineColor;


#pragma mark - Class Methods


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
    _rowHeight = self.font.lineHeight;
    _lineWidth = 1.0f;
    _lineColor = [[UIColor colorWithWhite:0.5f alpha:0.15f] retain];
    
    if ([self isRetinaDisplay]) {
        _lineWidth = 1.0f;  // Retina display.
    }
    else {
        _lineWidth = 1.0f;
    }
}


- (BOOL)isRetinaDisplay
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0));
}


- (void)dealloc
{
    [_lineColor release], _lineColor = nil;
    
    [super dealloc];
}


#pragma mark - Superclass Overrides

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    self.rowHeight = self.font.lineHeight;
}


- (void)drawRect:(CGRect)rect
{    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    CGFloat strokeOffset = (self.lineWidth / 2);  // Because lines are drawn between pixels. This moves it back onto the pixel.

    if (self.rowHeight > 0) {
        CGRect rowRect = CGRectMake(self.contentOffset.x, - 97.0f, self.contentSize.width, self.rowHeight);  // Note we start drawing with the second (index=1) row.
        NSInteger rowNumber = 1;
        while (rowRect.origin.y < self.frame.size.height + 100.0f) {            
            CGContextMoveToPoint(context, rowRect.origin.x + strokeOffset, rowRect.origin.y + strokeOffset);
            CGContextAddLineToPoint(context, rowRect.origin.x + rowRect.size.width + strokeOffset, rowRect.origin.y + strokeOffset);
            CGContextDrawPath(context, kCGPathStroke);
            
            rowRect.origin.y += self.rowHeight;
            rowNumber++;
        }
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}


#pragma mark - Public


#pragma mark - Private


#pragma mark - Notifications


#pragma mark - Actions


#pragma mark - Accessors




@end
