//
//  TBPrivateUtilities.m
//  TBMime
//
//  Created by todd on Mon Jun 11 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import "TBPrivateUtilities.h"


@implementation NSString (TBPrivateUtilities)

- (NSString *) trimmedString
{
    NSCharacterSet 	*set 		= [NSCharacterSet whitespaceCharacterSet];
    NSRange			range 		= { 0, 0 };
    int i;

    for(i = 0; i < [self length]; ++i)
    {
        if (![set characterIsMember: [self characterAtIndex: i]])
            break;
    }
    range.location = i;
    if (range.location == [self length])
        range.length = 0;
    else
        for(i = [self length] - 1 ; i >= range.location; --i)
            if (![set characterIsMember: [self characterAtIndex:i]])
            {
                range.length = (i - range.location)+1;
                break;
            }

    return [self substringWithRange: range];
}

- (NSData *)base64DecodedStringData
{
    return [NSData dataWithBase64String: self];
}

-(NSString *)unquotedString
{
    NSRange range = {0,[self length]};
    if([self characterAtIndex: 0] == '"')
    {
        ++range.location;
        --range.length;
    }
    if([self characterAtIndex: [self length]-1] == '"')
    {
        --range.length;
    }
    if (range.length != [self length])
        return [self substringWithRange: range];
    return self;
}

- (unsigned)indexOfString:(NSString *)aString
{
    return [self rangeOfString: aString].location;
}

-(NSString *)stringByReplacingAllOccurrencesOfString:(NSString *)fromString
                                          withString: (NSString *)toString
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSArray *array; 
    NSString *str;
    int i;
        
    // This code handles huge strings: it prevents the creation of 1000's of obj's at a time.
    #define CHUNKSIZE 10000
    if ([self length] > CHUNKSIZE) {
        NSMutableString *srcString = [self mutableCopy];
        NSMutableString *strCollector = [NSMutableString new];
        int buffPtr, fsLen = [fromString length], srcLen = [srcString length];
        NSRange rng, subrng, bndrng;

        for (buffPtr = 0; buffPtr < srcLen; buffPtr+=CHUNKSIZE ) {
            // if search token is multi-char, we have to search for it on the boundries.
            if (fsLen > 1 && (buffPtr+CHUNKSIZE < srcLen)) {
                subrng.location = buffPtr+CHUNKSIZE-fsLen+1;
                subrng.length = (fsLen*2)-2;
                bndrng = [srcString rangeOfString:fromString options:0 range:subrng];
                if (bndrng.length) { // there is search token on the boundry
                    [srcString replaceCharactersInRange:bndrng withString:toString];
                    srcLen = [srcString length]; // length changed; update it.
                }
            }
            rng.location = buffPtr;
            rng.length =  (buffPtr+CHUNKSIZE < srcLen) ? CHUNKSIZE : (srcLen-buffPtr);
            str = [srcString substringWithRange:rng];
            [strCollector appendString:[str stringByReplacingAllOccurrencesOfString:fromString withString:toString]];
        }
        [strCollector retain];
        [pool release];
        return [strCollector autorelease];       
    }
    
    array = [self componentsSeparatedByString: fromString];
    str = [array objectAtIndex: 0];
    for(i = 1; i < [array count]; ++i)
    {
        str = [str stringByAppendingString: toString];
        str = [str stringByAppendingString: [array objectAtIndex: i]];
    }
    [str retain];
    [pool release];
    return [str autorelease];

    /*  // this is the short & sweet implementation, but it is 15x slower than immutable str's.
        int stringLength = [workString length];, destLen = [toString length];
        NSMutableString *workString = [self mutableCopy];
        NSRange rng = [workString rangeOfString:fromString options:0];

        while (rng.length) {
            [workString replaceCharactersInRange:rng withString:toString];
            stringLength = [workString length];
            rng.location = rng.location+destLen; // move past the replacement text
            rng.length = stringLength - rng.location; // now search from this point forward.
            rng = [workString rangeOfString:fromString options:0 range:rng];
        }
        [pool release];
        return [workString autorelease]; */
}


@end

@implementation NSData (TBPrivateUtilities)

@end