//
//  DETweetGradientView.m
//  DETweeter
//
//  Created by Dave Batton on 11/28/11.
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//

#import "DETweetGradientView.h"

@implementation DETweetGradientView

@synthesize centerOffset = _centerOffset;


#pragma mark - Setup & Teardown

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}


#pragma mark - Superclass Overrides

- (void)drawRect:(CGRect)rect 
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    if (CGSizeEqualToSize(self.centerOffset, CGSizeZero) == NO) {
        center.x += self.centerOffset.width;
        center.y += self.centerOffset.height;
    }
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 0.0, 0.0, 0.0, 0.5,   // Start color
                              0.0, 0.0, 0.0, 0.7 }; // End color
    
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    CGGradientDrawingOptions options = kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation;
    CGFloat endRadius = [UIApplication sharedApplication].keyWindow.bounds.size.height / 2;
    CGContextDrawRadialGradient(currentContext, gradient, center, 50.0f, center, endRadius, options);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgbColorspace); 
}


#pragma mark - Accessors

- (void)setCenterOffset:(CGSize)offset
{
    if (CGSizeEqualToSize(_centerOffset, offset) == NO) {
        _centerOffset = offset;
        [self setNeedsDisplay];
    }
}



@end
