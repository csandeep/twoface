//
//  TFWindowController.m
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

#import "TFWindowController.h"

@interface TFWindowController ()

@property (nonatomic, retain) NSTimer *theTimer;

- (void) startTimer;
- (void) updateOTP: (NSTimer *) timer;
- (void) reloadData;

@end

@implementation TFWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        self.theSource = [NSMutableArray new];
        self.generationAdvanceWarning = kOTPDefaultSecondsBeforeChange;
        [self startTimer];
    }
    return self;
}

- (void) windowWillLoad {

}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewSelectionDidChange:)
                                                 name:NSTableViewSelectionDidChangeNotification
                                               object:self.theTableView];

    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self reloadData];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [self.theSource count];
}

#pragma mark - NSTableViewDelegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *rowData = (NSDictionary *)self.theSource[row];
    
    TFItemCellView *theCell = [tableView makeViewWithIdentifier: @"MainCell" owner: self];
    [theCell setHexSecret: [rowData objectForKey:@"key"]
                  andName: [rowData objectForKey:@"name"]];
    
    return theCell;
}

#pragma mark - Notifications
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSTableView *tableView = (NSTableView *)aNotification.object;
    
    if ( [tableView selectedRow] == -1 ) {
        // no selection
        return;
    }
    
    TFItemCellView *theCell =  (TFItemCellView *)[tableView viewAtColumn: 0
                                                                     row: [tableView selectedRow]
                                                         makeIfNecessary: YES];
    [tableView deselectRow: [tableView selectedRow]];
    
    [self copyOTPToPasteboard: theCell.OTPLabel.stringValue];
}

#pragma mark - Helper Methods

- (void)copyOTPToPasteboard: (NSString *) otp; {
    //TODO: use a org.nspasteboard.TransientType marker on this item, refer: http://nspasteboard.org
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    
    NSArray *copiedObjects = [NSArray arrayWithObject:otp];
    [pasteboard writeObjects:copiedObjects];
}

#pragma mark - Private Methods

- (void) reloadData; {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        [self.theSource removeAllObjects];
        
        // get keychain data
        SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
        query.service = kKeyChainServiceName;
        query.account = kKeyChainServiceName;
        [query fetch: nil];
        
        self.theSource = [[NSMutableArray alloc] initWithArray: (NSArray *)query.passwordObject];
        
        // reload table view
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.theTableView reloadData];
        });
    });
}

- (void) startTimer; {
    self.theTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                     target: self
                                                   selector: @selector(updateOTP:)
                                                   userInfo: nil
                                                    repeats: YES];
}


- (void) updateOTP: (NSTimer *) timer; {
    NSTimeInterval delta = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval period = kTimePeriod;
    uint64_t progress = (uint64_t)delta % (uint64_t)period;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (progress == 0 || progress > self.lastProgress) {
        [nc postNotificationName:kOTPDidGenerateNewOTPNotification object:nil];
        self.lastProgress = period;
        self.warningSent = NO;
    } else if (progress > period - self.generationAdvanceWarning
               && !self.warningSent) {        
        [nc postNotificationName:kOTPWillGenerateNewOTPWarningNotification
                          object:nil];
        self.warningSent = YES;
    }

}

#pragma mark - Add Account Sheet Methods

- (IBAction)closeAddAccountSheet:(id)sender {
    [self.window endSheet: self.addAccountSheet
               returnCode: NSCancelButton];
}

- (IBAction)openAddAccountSheet:(id)sender; {
    if ( !self.addAccountSheet ) {
        
        [[NSBundle mainBundle] loadNibNamed: @"AddAccount"
                                      owner: self
                            topLevelObjects: nil];
    }

    [self.window beginSheet: self.addAccountSheet
          completionHandler:^(NSModalResponse returnCode) {
              [self.addAccountSheet orderOut:self];
              
              if ( returnCode == NSOKButton ) {
                  // refresh the table view
                  // reload table view
                  [self reloadData];
              }else if ( returnCode == NSCancelButton) {
                  // do nothing
              }
          }];

}

- (IBAction)addNewAccount:(id)sender {
    
    //TODO: fail nicely if any of the field values are invalid
    
    NSString *aName = self.accountName.stringValue;
    NSString *aKey  = self.accountKey.stringValue;
    
    if ( !(aName && [aName length]) ) {
        // highlight the problem field
        return;
    }
    
    if ( !(aKey && [aKey length]) ) {
        // highlight the field
        return;
    }
    
    // is this a valid key ?
    NSString *base32String = [TFHelper base32ToHexString: aKey];
    Token *theToken = [Token createEmpty];
    
    NSString *errhdr = nil;
    NSString *errmsg = nil;
    
    BOOL didApply = [theToken applyChangesName: aName
                                           key: base32String
                                     timeBased: YES
                                       counter: @"0"
                                      interval: kOTPDefaultInterval
                                     numDigits: kOTPDefaultLength
                                    displayHex: NO
                                       errhdrp: &errhdr
                                       errmsgp: &errmsg];
    
    if ( !didApply ) {
        //display error message
        return;
    }

    //TODO: handle keychain save errors
    [self.theSource addObject: @{@"name":aName , @"key":aKey}];
    
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = kKeyChainServiceName;
    query.account = kKeyChainServiceName;
    [query setPasswordObject: self.theSource];
    [query save: nil];
    
    
    // everything looks good, close the sheet
    [self.window endSheet: self.addAccountSheet
               returnCode: NSOKButton];

}

@end
