//
//  TFHelper.h
//  TwoFace
//
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

#import <Foundation/Foundation.h>
#import "GTMStringEncoding.h"
#import "NSData+Hex.h"

FOUNDATION_EXPORT NSString *const kBase32Charset;
FOUNDATION_EXPORT NSString *const kBase32Synonyms;
FOUNDATION_EXPORT NSString *const kBase32Sep;
FOUNDATION_EXPORT NSString *const kKeychainServName;
FOUNDATION_EXPORT NSTimeInterval const kTimePeriod;
FOUNDATION_EXPORT NSString *const kOTPWillGenerateNewOTPWarningNotification;
FOUNDATION_EXPORT NSString *const kOTPDidGenerateNewOTPNotification;
FOUNDATION_EXPORT NSString *const kOTPSecondsBeforeNewOTPKey;
FOUNDATION_EXPORT NSTimeInterval const kOTPDefaultSecondsBeforeChange;

FOUNDATION_EXPORT NSString *const kOTPDefaultInterval;
FOUNDATION_EXPORT NSString *const kOTPDefaultLength;

FOUNDATION_EXPORT NSString *const kKeyChainServiceName;

@interface TFHelper : NSObject

/*
 base32ToHexString: - decode a base32 encoded string and convert to hexadecimal (as string value)
 */
+ (NSString *) base32ToHexString: (NSString *) encodedString;
@end
