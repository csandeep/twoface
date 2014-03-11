//
//  TFHelper.m

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

#import "TFHelper.h"

NSString *const kBase32Charset = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
NSString *const kBase32Synonyms = @"AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz";
NSString *const kBase32Sep = @" -";
NSString *const kKeychainServName = @"TwoFaceService";
NSTimeInterval const kTimePeriod = 30;
NSString *const kOTPWillGenerateNewOTPWarningNotification = @"kOTPWillGenerateNewOTPWarningNotification";
NSString *const kOTPDidGenerateNewOTPNotification = @"kOTPDidGenerateNewOTPNotification";
NSString *const kOTPSecondsBeforeNewOTPKey = @"kOTPSecondsBeforeNewOTPKey";
NSTimeInterval const kOTPDefaultSecondsBeforeChange = 5;

NSString *const kOTPDefaultInterval = @"30";
NSString *const kOTPDefaultLength = @"6";

NSString *const kKeyChainServiceName = @"TwoFace";

@implementation TFHelper

+ (NSString *) base32ToHexString: (NSString *) encodedString {
    GTMStringEncoding *coder = [GTMStringEncoding stringEncodingWithString:kBase32Charset];
    [coder addDecodeSynonyms:kBase32Synonyms];
    [coder ignoreCharacters:kBase32Sep];
    
    NSData *hexData = [coder decode: encodedString];
    NSString *hexStr = [[hexData toHexString] uppercaseString];
    
    return hexStr;
}
@end
