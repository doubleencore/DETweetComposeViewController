//
//  DETweetTextView.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
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

    _ruledView = [[DETweetRuledView alloc] initWithFrame:[self ruledViewFrame]];
    _ruledView.lineColor = [UIColor colorWithWhite:0.5f alpha:0.15f];
    _ruledView.lineWidth = 1.0f;
    _ruledView.rowHeight = self.font.lineHeight;
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
