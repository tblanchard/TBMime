//
//  TBPrivateUtilities.h
//  TBMime
//
//  Created by todd on Mon Jun 11 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (TBPrivate) 

- (NSString *) trimmedString;
- (NSData *) base64DecodedStringData;
- (NSString *) unquotedString;
- (unsigned)indexOfString:(NSString *)aString;
- (unsigned)indexOfString:(NSString *)aString options:(unsigned)mask;
- (unsigned)indexOfString:(NSString *)aString options:(unsigned)mask range:(NSRange)searchRange;
-(NSString *)stringByReplacingAllOccurrencesOfString:(NSString *)fromString
                                          withString: (NSString *)toString;

@end

@interface NSData (TBPrivate)

+ (id)dataWithBase64String:(NSString *)base64String;

- (id)initWithBase64String:(NSString *)base64String;

- (NSString *)base64EncodedDataString;

- (NSData *)decodedURIFormData;

- (NSData *)dataByReversingByteEncodingWithDelimiter:(char)character
                        reverseEncodedSpaceCharacter:(BOOL)decodeSpaceChar;

@end

@interface NSDictionary (TBPrivate)

- (id)initWithContentsOfPropertyListFile:(NSString *)aPath;


@end