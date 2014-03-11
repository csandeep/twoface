//
//  TFWindowController.h
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

#import <Cocoa/Cocoa.h>
#import <SSKeychain.h>

#import "Token.h"
#import "TFItemCellView.h"
#import "TFHelper.h"
#import "TFClockView.h"

@interface TFWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>

@property IBOutlet NSTableView *theTableView;
@property IBOutlet TFClockView *theClockView;
@property IBOutlet NSWindow *addAccountSheet;
@property IBOutlet NSTextField *accountName;
@property IBOutlet NSTextField *accountKey;

@property NSTimeInterval generationAdvanceWarning;
@property NSTimeInterval lastProgress;
@property BOOL warningSent;

@property (nonatomic, retain) NSMutableArray *theSource;

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (void)copyOTPToPasteboard: (NSString *) otp;

- (IBAction)closeAddAccountSheet:(id)sender;
- (IBAction)openAddAccountSheet:(id)sender;
- (IBAction)addNewAccount:(id)sender;
@end
