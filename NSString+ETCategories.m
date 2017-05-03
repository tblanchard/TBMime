// NSString+ETCategories.m
//
// Author: ab
//
// CVS Info: $Id: NSString+ETCategories.m,v 1.11 2000/10/30 17:55:52 cmp Exp $
//
// Copyright (c) 1996-1999 Annard Brouwer. All rights reserved.
// Read the "License" file included in the distribution to find out what you can do with this code.

//#import "ETFoundationMessages.h"
//#import "ETFoundationExceptions.h"
//#import "ETDefaults.h"
//#import "NSCharacterSet+ETCategories.h"
#import "NSData+ETCategories.h"
#import "NSString+ETCategories.h"

#define CF_CLEAN_STR_MAP_KEY  @"cleansedStringMapping"
#define CF_URL_STR_MAP_KEY    @"urlStringMapping"

#define KBYTES_BASE  (unsigned long long)1024
#define MBYTES_BASE  (unsigned long long)(1000 * KBYTES_BASE)
#define GBYTES_BASE  (unsigned long long)(1000 * MBYTES_BASE)
#define TBYTES_BASE  (unsigned long long)(1000 * GBYTES_BASE)
#define PBYTES_BASE  (unsigned long long)(1000 * TBYTES_BASE)

// Boundaries of Unicode character ranges not to escape for URIs
#define ASCII_NUMERIC_START   0x0030
#define ASCII_NUMERIC_END     0x0039
#define ASCII_UPPERCASE_START 0x0041
#define ASCII_UPPERCASE_END   0x005a
#define ASCII_LOWERCASE_START 0x0061
#define ASCII_LOWERCASE_END   0x007a

@interface NSString (ETStringEncodingPrivate)

static NSCharacterSet *_escapedCharacterSet;
static NSCharacterSet *_quotedCharacterSet;

+ (NSCharacterSet *)escapedCharacterSet;

+ (NSCharacterSet *)quotedCharacterSet;

@end

@implementation NSString (ETCategories)
//
// These categories enhance the NSString class cluster which extra functionality.
//
// Defines key/values:
//  * "cleansedStringMapping" (dictionary): key is a string which will be replaced
//    by its value
//  * "urlStringMapping" (dictionary): key is a character string which will be
//    replaced by an encoded sequence for url GET method key/value encoding
//

+ (NSString *)stringWithData:(NSData *)someData
                    encoding:(NSStringEncoding)anEncoding
{
    return [[[self alloc] initWithData: someData
                              encoding: anEncoding] autorelease];
}

+ (NSString *)emptyString
  // Returns the empty string.
{
	return @"";
}

+ (id)readPropertyListFromFile:(NSString *)aPath
				  mustBeOfType:(Class)targetClass
					 logErrors:(BOOL)showErrors
  // Invokes 'readPropertyListFromFile:encoding:mustBeOfType:logErrors:'
  // with the NSISOLatin1StringEncoding.
{
	return [self readPropertyListFromFile: aPath
			encoding: NSISOLatin1StringEncoding
			mustBeOfType: targetClass
			logErrors: showErrors];
}
  
+ (id)readPropertyListFromFile:(NSString *)aPath
					  encoding:(NSStringEncoding)anEncoding
				  mustBeOfType:(Class)targetClass
					 logErrors:(BOOL)showErrors
// Reads a property file from aPath with the given encoding and returns the
// property list decoding of it.  If showErrors equals YES the errors will
// be logged using NSLog(), if it equals NO it will raise.
// ETFilePplParseErrorException is raised if an error occurs while parsing
// the file or when the returned class is not equal to targetClass.
{
	NSString *string;
	id plist;

	plist = nil;
	string = [[NSString allocWithZone: NULL]
			  initWithData: [NSData dataWithContentsOfFile: aPath]
			  encoding: anEncoding];
	if (showErrors && nil == string)
	{
		NSLog(@"%@: string could not be read from '%@'",
			  NSStringFromSelector (_cmd), aPath);
	}
	NS_DURING
	  plist = [string propertyList];
      [string release];
	NS_HANDLER
	  [string release];
      plist = nil;
	  if (showErrors)
		  NSLog(@"%@: exception was raised while parsing: %@",
				NSStringFromSelector (_cmd), localException);
	  else
		  [NSException raise: ETFilePplParseErrorException
		   format: ET_PPL_FILE_PARSE_ERROR, aPath, [localException reason]];
	NS_ENDHANDLER
	if (Nil != targetClass && ![plist isKindOfClass: targetClass])
	{
		if (showErrors)
			NSLog(@"%@: property list is not of desired type '%@'. It's an '%@'.",
				  NSStringFromSelector (_cmd), NSStringFromClass (targetClass),
				  NSStringFromClass ([plist class]));
		else
			[NSException raise: ETFilePplParseErrorException
			 format: ET_PPL_FILE_PARSE_ERROR, aPath,
			 [NSString stringWithFormat: @"Wrong class: %@",
			  NSStringFromClass ([plist class])]];
		plist = nil;
	}
	return plist;
}

+ (NSString *)formattedStringForNumberOfBytes:(NSNumber *)bytesNumber;
// Convenience for WebScript to pretty print a number of bytes.
//
// See also: -formattedStringForBytes:
{
    return [self formattedStringForBytes: (unsigned long long)[bytesNumber intValue]];
}

+ (NSString *)formattedStringForBytes:(unsigned long long)bytes
//  Takes a number of bytes and returns a nice, user-friendly string describing
//  how many bytes there are. For example: passing in 1100000 bytes returns "1.07 MB".
{
    if (bytes > 0)
    {
        // Return as bytes (under 1K)
        if (bytes < KBYTES_BASE)
        {
            // under 1 K, display as some number of bytes
            return [NSString stringWithFormat: ET_STRING_BYTES_FORMAT_STRING, bytes];
        }
        else if (bytes < MBYTES_BASE)
        {
            return [NSString stringWithFormat: ET_STRING_KBYTES_FORMAT_STRING, (float)bytes / KBYTES_BASE];
        }
        else if (bytes < GBYTES_BASE)
        {
            // Return as MegaBytes
            return [NSString stringWithFormat: ET_STRING_MBYTES_FORMAT_STRING, (float)bytes / MBYTES_BASE];
        }
        else if (bytes < TBYTES_BASE)
        {
            // Return as GigaBytes
            return [NSString stringWithFormat: ET_STRING_GBYTES_FORMAT_STRING, (float)bytes / GBYTES_BASE];
        }
        else if (bytes < PBYTES_BASE)
        {
            // Return as TeraBytes
            return [NSString stringWithFormat: ET_STRING_TBYTES_FORMAT_STRING, (float)bytes / TBYTES_BASE];
        }
        else if (bytes >= PBYTES_BASE)
        {
            // Return as PetaBytes
            return [NSString stringWithFormat: ET_STRING_PBYTES_FORMAT_STRING, (float)bytes / PBYTES_BASE];
        }
    }
    else
    {
        // Return 0 Bytes.
        return [NSString stringWithFormat: ET_STRING_BYTES_FORMAT_STRING, 0];
    }

    return self;
}

+ (NSString *)formattedStringForNumberOfSeconds:(NSNumber *)secondsNumber;
//  By taking in an NSNumber consisting of seconds, this method will
//  use this information to return a user-friendly string displaying
//  time as hours, minutes and seconds.
{
    int seconds;
    NSString *formattedString;

    seconds = [secondsNumber intValue];
    formattedString = [NSString emptyString];
   	// Return empty string if supplied interval is nil
    if (!seconds)
        return formattedString;

    if (seconds  < 60)
    {
        // under 1 minute: display as xx seconds
        formattedString = [NSString stringWithFormat: ET_STRING_SEC_FORMAT_STRING, seconds];
    }
    else
    {
        int minutesInHour;
        int secondsInMinute;

        if (seconds > 60 && seconds < 3600)
        {
            // less than 1 hour: display as xx minutes xx seconds
            minutesInHour = seconds / 60;
            secondsInMinute = seconds - (minutesInHour * 60);
            formattedString = [NSString stringWithFormat: ET_STRING_MIN_SEC_FORMAT_STRING,
                minutesInHour, secondsInMinute];
        }
        else if (seconds > 3600)
        {
            int hours;

            // more than 1 hour: display as xx hours xx minutes xx seconds
            hours = seconds / 3600;
            minutesInHour = (seconds - (hours * 3600)) / 60;
            secondsInMinute = (seconds - (hours * 3600) - (minutesInHour * 60));
            formattedString = [NSString stringWithFormat: ET_STRING_HR_MIN_SEC_FORMAT_STRING,
                hours, minutesInHour, secondsInMinute];
        }
    }
    return formattedString;
}

- (NSString *)stringWithCharactersFromSet:(NSCharacterSet *)aSet
  // Find the substring of the receiver composed of members of the given
  // aSet.
{
    unsigned int len;
    NSScanner *scanner;
    NSMutableString *newStr;

	len = [self length];
	scanner = [NSScanner localizedScannerWithString: self];
	newStr = [NSMutableString stringWithCapacity: len];
    while ([scanner scanLocation] < len)
	{
        NSString *str;
		
        if ([scanner scanCharactersFromSet: aSet intoString: &str])
                [newStr appendString: str];
        else
			break;
    }
    return newStr;
}

- (NSString *)stringWithStrippedWhiteSpace
  // Cover method for `stringWithCharactersFromSet:' which removes the
  // members of [NSCharacterSet
  // nonWhitespaceOrCarriageReturnOrNewlineCharacterSet].
{
    return [self stringWithCharactersFromSet:
			[NSCharacterSet nonWhitespaceOrCarriageReturnOrNewlineCharacterSet]];
}

- (NSString *)stringByTruncatingWhiteSpace
  // Returns an autoreleased string with contents equal to that of the receiver
  // minus any trailing whitespace.
{
	int charPtr;

	charPtr = [self length];
	while (--charPtr >= 0)
	{
		if (![[NSCharacterSet whitespaceAndNewlineCharacterSet]
			  characterIsMember: [self characterAtIndex: charPtr]])
			return [self substringToIndex: charPtr + 1];
	}
	return [NSString emptyString];
}

- (NSString *)stringWithTrimmedWhitespace
    // Removes whitespace from the beginning and the end of the string.
{
    NSString *truncStr;
    int charPtr;

    truncStr = [self stringByTruncatingWhiteSpace];
    if ([truncStr length] > 0)
    {
        charPtr = 0;
        while ([[NSCharacterSet whitespaceAndNewlineCharacterSet]
                characterIsMember: [truncStr characterAtIndex: charPtr]])
        {
            charPtr++;
        }
        if (charPtr > 0)
            return [truncStr substringFromIndex: charPtr];
    }
    return truncStr;
}

- (BOOL)containsOnlyDigits
//Checks to see if all of the character in the given string are digits.
{
    int i;
    for (i = [self length]-1; i>=0; i--)
    {
        char currentChar = [self characterAtIndex:i];
        if (isdigit(currentChar))
        {
            continue;
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)stringConsistsOfWhitespace
  // Returns YES if string consists of whitespace only, otherwise returns NO.
{
    NSCharacterSet *whiteSpaceSet;
    unsigned len;
    unsigned index;

	whiteSpaceSet = [NSCharacterSet whitespaceAndCarriageReturnAndNewlineCharacterSet];
	len = [self length];
    for (index=0; index < len; index++)
	{
        if (![whiteSpaceSet characterIsMember: [self characterAtIndex: index]])
            return NO;
	}
    return YES;
}

- (NSData *)base64DecodedStringData
{
    return [NSData dataWithBase64String: self];
}

- (NSString *)uriEncodedString
  // Convert the receiver into an http-safe string for passing key/value pairs
  // when using the GET method to transfer information using an URI.
{
    const char *utf8DataPtr;
    NSMutableData *tempData;
    NSMutableString *escString;
    NSString *retStr;

    utf8DataPtr = [self UTF8String];
    tempData = [[NSMutableData alloc] initWithCapacity: [self length]];
    escString = [[NSMutableString alloc] initWithCapacity: 4];
    while (*utf8DataPtr)
    {
        unsigned char testChar;

        testChar = *utf8DataPtr++;
        if ((testChar >= ASCII_NUMERIC_START && testChar <= ASCII_NUMERIC_END)
            || (testChar >= ASCII_UPPERCASE_START && testChar <= ASCII_UPPERCASE_END)
            || (testChar >= ASCII_LOWERCASE_START && testChar <= ASCII_LOWERCASE_END))
        {
            char c;

            c = (char)testChar; // This is safe now
            [tempData appendBytes: &c length: sizeof (char)];
        }
        else
        {
            // Escape it using the value in (uppercased) hex with a `%' in front of it.
            [escString appendFormat: @"%%%02X", testChar];
            [tempData appendData: [escString dataUsingEncoding: NSASCIIStringEncoding]];
            [escString setString: @""];
        }
    }
    retStr = [NSString stringWithData: tempData encoding: NSASCIIStringEncoding];
    [tempData release];
    [escString release];

    return retStr;
}

- (NSString *)cleansedString
  // This method converts strings with "illegal" characters in strings to
  // more "usable" strings. The mapping is done according to the dictionary
  // which can be found in the defaults under the `cleansedStringMapping'
  // key.
{
    NSDictionary *mappingDictionary;

    mappingDictionary = [[ETDefaults standardDefaults]
						 dictionaryForKey: CF_CLEAN_STR_MAP_KEY];
    if (!mappingDictionary || ![mappingDictionary count])
		[NSException raise: ETDefaultValueNotFoundException
		 format: ET_DEFAULT_MISSING_KEY_VALUE, CF_CLEAN_STR_MAP_KEY, @"<none>"];

    // Make this string "windows safe"
#if defined(WIN32)
    return [[self encodedStringUsingDictionary: mappingDictionary] winSafePathComponent];
#endif
    return [self encodedStringUsingDictionary: mappingDictionary];
}

- (NSString *)encodedStringUsingDictionary:(NSDictionary *)encodingDictionary
  // General method for converting a string using encodingDictionary. Each
  // key in encodingDictionary found in the receiver will be replaced by
  // the corresponding value. Returns the newly encoded string.
{
    NSEnumerator *encodingEnumerator;
    NSString *mapKey;
    NSString *tmpString;

    tmpString = [NSString stringWithString: self];
    encodingEnumerator = [encodingDictionary keyEnumerator];
    while ((mapKey = [encodingEnumerator nextObject]))
    {
        tmpString = [[tmpString componentsSeparatedByString: mapKey]
                     componentsJoinedByString: [encodingDictionary objectForKey: mapKey]];
    }
    return tmpString;
}

/* NOTE: It is a bad idea to have an "isEmpty" method because of the tendancy for
         a developer to write code such as "if ([aString isEmpty]) then", because
         if aString is nil, this will evaluate to NO (FALSE), which is not what
         any sane person would want to occur.  The opposite "isNotEmpty" method
         is OK because it will behave logically if aString is nil.

- (BOOL)isEmpty
// is the string an empty string (eg, length 0)
{
    if ( [self length] > 0 )
        return NO;
    return YES;
}
*/

- (BOOL)isNotEmpty
// does the string contain at least 1 character?
{
    if ([self length] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)containsNonWhitespaceCharacter
// does the string contain at least 1 non-whitespace character?
{
    if ([self length] > 0) {
        return (! [self stringConsistsOfWhitespace]);
    } else {
        return NO;
    }
}

- (BOOL)containsString: (NSString *)aString
// does this string contain the aString argument?
{
    if (([self length] == 0) || ([aString length] == 0)) {
        return NO;
    } else {
        NSRange range = [self rangeOfString:aString];
        return (range.length > 0) ? YES : NO;
    }
}

- (SEL)selectorValue
{
    return NSSelectorFromString(self);
}

- (NSString *)asAccessor
// automagically generate accessor name
// assumes accessor name is lower case for first character
{
    if ( [self isNotEmpty] )
     {
     return [NSString stringWithFormat:@"%@%@",
             [[self substringToIndex:1] lowercaseString], [self substringFromIndex:1]];
     }
     return self;
}

- (NSString *)asSetter
// autmagically generate setter name
{
    if ([self isNotEmpty]) {
    return [NSString stringWithFormat:@"set%@%@:", [[self substringToIndex:1] uppercaseString], [self substringFromIndex:1]];
    }

    return self;
}

// ***** ETStringEncodingProtocol implementation *****

- (NSString *)stringEncoding
  // Returns a description of this string in ppl list format. The string
  // will be quoted if it contains characters other than letters. If the
  // characters '"' and '\' are present, they will be escaped with a
  // backslash character.
{
    NSMutableString *escapedString;
    NSRange escapedCharRange, quoteStringRange;

    if ([self length] == 0)
        return @"\"\"";

    escapedString = nil;
    // If the string contains '"' or '\' we have to escape those with a \.
    escapedCharRange = [self rangeOfCharacterFromSet: [NSString escapedCharacterSet]];
    while (NSNotFound != escapedCharRange.location)
    {
        NSString *replacementString;
        NSRange newSearchRange;

        if (!escapedString)
            escapedString = [NSMutableString stringWithString: self];
        replacementString = [NSString stringWithFormat: @"\\%@",
                             [escapedString substringWithRange: escapedCharRange]];
        [escapedString replaceCharactersInRange: escapedCharRange
         withString: replacementString];

        // Set the new search range.
        newSearchRange.location = escapedCharRange.location + 2;
        newSearchRange.length = [escapedString length] - newSearchRange.location;
        // Test if the end of the string has been reached.
        if (newSearchRange.length <= 0)
            break;
        // Find new character to escape...
        escapedCharRange = [escapedString rangeOfCharacterFromSet: [NSString escapedCharacterSet]
                            options: NSLiteralSearch
                            range: newSearchRange];
    }

    if (!escapedString)
        escapedString = (NSMutableString *)self;
    quoteStringRange = [escapedString rangeOfCharacterFromSet: [NSString quotedCharacterSet]];
    if (NSNotFound == quoteStringRange.location)
        return escapedString;
    else
        return [NSString stringWithFormat: @"\"%@\"", escapedString];
}

- (BOOL)caseInsensitiveIsEqual:(NSString *)otherString
// Return YES if the two strings are equal, ignoring case.
// Really just a cover method for caseInsensitiveCompare:,
// but returns a BOOL, so you can use it any place you might
// otherwise use isEqual:
{
    return ([self caseInsensitiveCompare:otherString] == NSOrderedSame);
}

@end

@implementation NSString (ETStringEncodingPrivate)

+ (NSCharacterSet *)escapedCharacterSet
  // Returns a set of characters to escape for ETStringEncodingProtocol,
  // these are: '"' and '\'.
{
    if (!_escapedCharacterSet)
    {
        _escapedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:
                                @"\"\\"] retain];
    }
    return _escapedCharacterSet;
}

+ (NSCharacterSet *)quotedCharacterSet
    // Returns a set of characters which are not alphanumeric or `_'.
{
    if (!_quotedCharacterSet)
    {
        NSMutableCharacterSet *tempSet;

        tempSet = [[NSCharacterSet ASCIIAlphanumericCharacterSet] mutableCopy];
        [tempSet addCharactersInString: @"_"];
        _quotedCharacterSet = [tempSet invertedSet];
        [tempSet release];
        [_quotedCharacterSet retain];
    }
    return _quotedCharacterSet;
}

@end
