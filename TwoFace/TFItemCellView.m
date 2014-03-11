//
//  TFItemCellView.m
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


#import "TFItemCellView.h"

#define TFCellStrokeColor [NSColor colorWithRed: 200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0]
#define TFCellStrokeEndColor [NSColor colorWithRed: 224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0]
#define TFCellStrokeStartColor [NSColor colorWithRed: 250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]

#define TFSiteLabelColor  [NSColor colorWithRed:(float)0.0 green:(float)0x3D/0xFF blue:(float)0xAF/0xFF alpha:1.0]

@interface TFItemCellView (PrivateMethods)


- (void) updateUIForNewOTP: (NSNotification *)notification;
- (void) secondsBeforeNewOTP: (NSNotification *) notification;
- (void) resetFieldColors;
- (void) setFieldColor: (NSColor *) newColor;
@end

@implementation TFItemCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) setHexSecret: (NSString *) hexSecret andName: (NSString *) aName {
    self.theToken = [Token createEmpty];
    NSString *errhdr = nil;
    NSString *errmsg = nil;
    
    [self.theToken applyChangesName: aName
                                key: [TFHelper base32ToHexString: hexSecret]
                          timeBased: YES
                            counter: @"0"
                           interval: kOTPDefaultInterval
                          numDigits: kOTPDefaultLength
                         displayHex: NO
                            errhdrp: &errhdr
                            errmsgp: &errmsg];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(updateUIForNewOTP:)
               name:kOTPDidGenerateNewOTPNotification
             object:nil];
    
    [nc  addObserver: self
            selector: @selector(secondsBeforeNewOTP:)
                name: kOTPWillGenerateNewOTPWarningNotification
              object: nil];
    
    self.SiteLabel.stringValue = aName;
    self.OTPLabel.stringValue = [self.theToken generatePassword];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
	
    NSRect gradientRect = NSMakeRect(0.f, 0.f, [self bounds].size.width, 1.f);
    
    NSGradient *gradient = [[NSGradient alloc] initWithColors:@[TFCellStrokeColor]];
    [gradient drawInRect:gradientRect angle:90.f];
    
    //NSGradient *backgroundGradient = [[NSGradient alloc] initWithStartingColor: TFCellStrokeStartColor endingColor:TFCellStrokeEndColor];
    //[backgroundGradient drawInRect: self.bounds angle: 90.0f];
}

- (void) setBackgroundStyle:(NSBackgroundStyle)backgroundStyle{
        NSTableRowView *row = (NSTableRowView*)self.superview;
        if (row.isSelected) {
            self.OTPLabel.textColor = [NSColor whiteColor];
            self.SiteLabel.textColor = [NSColor whiteColor];
        } else {
            self.OTPLabel.textColor = [NSColor blackColor];
            self.SiteLabel.textColor = TFSiteLabelColor;
        }
}

#pragma mark - Private Method
- (void) updateUIForNewOTP:(NSNotification *)notification {
    self.OTPLabel.stringValue = [self.theToken generatePassword];
    [self resetFieldColors];
}

- (void) secondsBeforeNewOTP:(NSNotification *)notification {
    [self setFieldColor: [NSColor redColor]];
}

- (void) resetFieldColors; {
    self.OTPLabel.textColor = [NSColor blackColor];
    self.SiteLabel.textColor = TFSiteLabelColor;
}


- (void) setFieldColor: (NSColor *) newColor; {
    self.OTPLabel.textColor = newColor;
    self.SiteLabel.textColor = newColor;
}

@end
