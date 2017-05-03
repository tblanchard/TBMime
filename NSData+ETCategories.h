// NSData+ETCategories.h
//
// Author: ab
//
// CVS Info: $Id: NSData+ETCategories.h,v 1.3 2000/07/13 00:24:07 abrouwer Exp $ 
//
// Copyright (c) 1996-1999 Annard Brouwer. All rights reserved.
// Read the "License" file included in the distribution to find out what you can do with this code.

#import <Foundation/Foundation.h>

#import "ETStringEncodingProtocol.h"

@interface NSData (ETCategories) <ETStringEncodingProtocol>

+ (id)dataWithBase64String:(NSString *)base64String;

- (id)initWithBase64String:(NSString *)base64String;

- (NSString *)base64EncodedDataString;

- (NSData *)decodedURIFormData;

- (NSData *)dataByReversingByteEncodingWithDelimiter:(char)character
                        reverseEncodedSpaceCharacter:(BOOL)decodeSpaceChar;

@end
