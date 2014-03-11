//
//  TFClockView.m
//  TwoFace
/*
 Two Face - a two factor authenticator for mac
 Copyright (C) 2014  Sandeep Chayapathi
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 */



#import "TFClockView.h"

#define DEFAULT_BACKGROUND_COLOR [NSColor colorWithRed:(float)0.0 green:(float)0x3D/0xFF blue:(float)0xAF/0xFF alpha:1.0];
#define DEFAULT_FACE_COLOR [NSColor colorWithRed:(float)0x33/0xFF green:(float)0x55/0xFF blue:(float)0x99/0xFF alpha:1.0];

@interface TFClockView (PrivateMethods)

- (void) startTimer;

@end

@implementation TFClockView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.period = 30.0;
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        self.faceColor = DEFAULT_FACE_COLOR;
        
        // Initialization code here.
        [self startTimer];
    }
    return self;
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
    // Drawing code here.
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    CGFloat mod =  fmod(seconds, self.period);
    CGFloat percent = mod / self.period;
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetLineWidth(context, 1.0);
    CGRect bounds = self.bounds;
    [[NSColor clearColor] setFill];
    CGContextFillRect(context, rect);
    CGFloat midX = CGRectGetMidX(bounds);
    CGFloat midY = CGRectGetMidY(bounds);
    CGFloat radius = midY - 4;
    CGContextMoveToPoint(context, midX, midY);
    CGFloat start = M_PI_2;
    CGFloat end = -2 * M_PI;
    CGFloat sweep = end * percent + start;
    CGContextAddArc(context, midX, midY, radius, start, sweep, 1);
    [[self.backgroundColor colorWithAlphaComponent:0.7] setFill];
    CGContextFillPath(context);
    if (percent > .875) {
        CGContextMoveToPoint(context, midX, midY);
        CGContextAddArc(context, midX, midY, radius, start, sweep, 1);
        [[[NSColor redColor] colorWithAlphaComponent: 0.8] setFill];
        CGContextFillPath(context);
    }

    if (percent > .875) {
        [[[NSColor redColor] colorWithAlphaComponent:0.9] setStroke];
        CGContextStrokePath(context);
    }else{
        [[[NSColor blackColor] colorWithAlphaComponent:0.5] setStroke];
    }
    

    // Draw a stroke around the circle
    CGContextAddArc(context,
                    midX, midY, radius, 0, 2 * M_PI, 1);
    CGContextStrokePath(context);

    
    // Draw face
    [self.faceColor setStroke];
    CGContextMoveToPoint(context, midX + radius , midY);
    CGContextAddArc(context, midX, midY, radius, 0, 2.0 * M_PI, 1);
    CGContextStrokePath(context);

    CGFloat x, y;
    // Hand
    x = midX + radius * cos(sweep);
    y = midY + radius * sin(sweep);
    CGContextMoveToPoint(context, midX, midY);
    CGContextAddLineToPoint(context, x, y);
    CGContextStrokePath(context);

}

- (void)redrawTimer:(NSTimer *)timer {
    [self setNeedsDisplay:YES];
}

- (void)invalidate {
    [self.theTimer invalidate];
    self.theTimer = nil;
}

#pragma mark - Private Methods
- (void) startTimer {
    self.theTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                     target: self
                                                   selector: @selector(redrawTimer:)
                                                   userInfo: nil
                                                    repeats: YES];
}

@end
