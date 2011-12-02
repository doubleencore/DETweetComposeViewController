//
//  DETweetRuledView.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DETweetRuledView.h"


@interface DETweetRuledView ()

- (void)tweetRuledViewInit;

@end


@implementation DETweetRuledView

@synthesize rowHeight = _rowHeight;
@synthesize lineWidth = _lineWidth;
@synthesize lineColor = _lineColor;


#pragma mark - Setup & Teardown

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self tweetRuledViewInit];
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self tweetRuledViewInit];
    }
    
    return self;
}


- (void)tweetRuledViewInit
{
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
    self.userInteractionEnabled = NO;
    
    _rowHeight = 20.0f;
    _lineWidth = 1.0f;
    _lineColor = [[UIColor colorWithWhite:0.5f alpha:0.15f] retain];
}


- (void)dealloc
{
    [_lineColor release], _lineColor = nil;
    
    [super dealloc];
}


#pragma mark - Superclass Overrides

- (void)drawRect:(CGRect)rect
{    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    CGFloat strokeOffset = (self.lineWidth / 2);  // Because lines are drawn between pixels. This moves it back onto the pixel.

    if (self.rowHeight > 0.0f) {
        CGRect rowRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, self.rowHeight);
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


@end
