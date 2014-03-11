//
//  TwoFaceTests.m

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

#import <XCTest/XCTest.h>
#import "Token.h"
#import "TFHelper.h"
#import "TFWindowController.h"

@interface TwoFaceTests : XCTestCase

@end

@implementation TwoFaceTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (Token *) testHOTPToken {
    NSString *hexSecret = @"d642b988f6ac534a3dc6960a0432dc6626a75a7b";
    
    NSString *errhdr = nil;
    NSString *errmsg = nil;
    
    Token *theToken = [Token createEmpty];
    [theToken applyChangesName: @"Test"
                                key: hexSecret
                          timeBased: NO
                            counter: @"1"
                           interval: @"30"
                          numDigits: @"6"
                         displayHex: NO
                            errhdrp: &errhdr
                            errmsgp: &errmsg];
    
    
    NSString *password = [theToken generatePassword];
    XCTAssertEqualObjects(password, @"184575", @"totp password match");
    
    return theToken;
}

- (void) testStringEncoding {
    NSString *encodedSecret = @"kwywthw4q3cakej5zsvkomplohbc5cxk";
    NSString *hexSecret = @"55B1699EDC86C405113DCCAAA731EB71C22E8AEA";

    XCTAssertEqualObjects(hexSecret, [TFHelper base32ToHexString: encodedSecret], @"base32 to Hex");
}

@end
