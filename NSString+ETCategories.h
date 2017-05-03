// NSString+ETCategories.h
//
//Author: ab
//
// CVS Info: $Id: NSString+ETCategories.h,v 1.9 2000/10/30 17:55:52 cmp Exp $
//
// Copyright (c) 1996-1999 Annard Brouwer. All rights reserved.
// Read the "License" file included in the distribution to find out what you can do with this code.

#import <Foundation/Foundation.h>

#import "ETStringEncodingProtocol.h"

@interface NSString (ETCategories) <ETStringEncodingProtocol>

+ (NSString *)stringWithData:(NSData *)someData
                    encoding:(NSStringEncoding)anEncoding;

+ (NSString *)emptyString;

+ (id)readPropertyListFromFile:(NSString *)aPath
                  mustBeOfType:(Class)targetClass
                     logErrors:(BOOL)showErrors;

+ (id)readPropertyListFromFile:(NSString *)path
                      encoding:(NSStringEncoding)anEncoding
				  mustBeOfType:(Class)targetClass
					 logErrors:(BOOL)showErrors;

+ (NSString *)formattedStringForBytes:(unsigned long long)bytes;

+ (NSString *)formattedStringForNumberOfBytes:(NSNumber *)bytesNumber;

+ (NSString *)formattedStringForNumberOfSeconds:(NSNumber *)secondsNumber;

- (NSString *)stringWithCharactersFromSet:(NSCharacterSet *)aSet;

- (NSString *)stringWithStrippedWhiteSpace;

- (NSString *)stringByTruncatingWhiteSpace;

- (NSString *)stringWithTrimmedWhitespace;

- (BOOL)containsOnlyDigits;
- (BOOL)stringConsistsOfWhitespace;

- (NSData *)base64DecodedStringData;

- (NSString *)uriEncodedString;

- (NSString *)cleansedString;
- (NSString *)encodedStringUsingDictionary:(NSDictionary *)encodingDictionary;

- (SEL)selectorValue;
- (NSString *)asAccessor;
- (NSString *)asSetter;
- (BOOL)isNotEmpty;
- (BOOL)containsNonWhitespaceCharacter;
- (BOOL)containsString:(NSString *)aString;

- (BOOL)caseInsensitiveIsEqual:(NSString *)otherString;

@end

