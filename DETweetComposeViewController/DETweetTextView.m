//
//  DETweetTextView.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DETweetTextView.h"


@interface DETweetTextView ()

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, retain) UIColor *lineColor;

- (void)textViewInit;

@end


@implementation DETweetTextView

@synthesize lineWidth = _lineWidth;
@synthesize lineColor = _lineColor;


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
    self.contentMode = UIViewContentModeRedraw;
    
    _lineWidth = 1.0f;
    _lineColor = [[UIColor colorWithWhite:0.5f alpha:0.15f] retain];
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
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    CGFloat strokeOffset = (self.lineWidth / 2);  // Because lines are drawn between pixels. This moves it back onto the pixel.

    CGFloat rowHeight = self.font.lineHeight;
    if (rowHeight > 0) {
        CGRect rowRect = CGRectMake(self.contentOffset.x, - 97.0f, self.contentSize.width, rowHeight);  // Note we start drawing with the second (index=1) row.
        NSInteger rowNumber = 1;
        while (rowRect.origin.y < self.frame.size.height + 100.0f) {            
            CGContextMoveToPoint(context, rowRect.origin.x + strokeOffset, rowRect.origin.y + strokeOffset);
            CGContextAddLineToPoint(context, rowRect.origin.x + rowRect.size.width + strokeOffset, rowRect.origin.y + strokeOffset);
            CGContextDrawPath(context, kCGPathStroke);
            
            rowRect.origin.y += rowHeight;
            rowNumber++;
        }
    }
}


@end
