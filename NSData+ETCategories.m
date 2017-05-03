// NSData+ETCategories.m
//
// Author: ab
//
// CVS Info: $Id: NSData+ETCategories.m,v 1.3 2000/07/13 00:24:07 abrouwer Exp $ 
//
// Copyright (c) 1996-1999 Annard Brouwer. All rights reserved.
// Read the "License" file included in the distribution to find out what you can do with this code.

#import "NSString+ETCategories.h"
#import "NSData+ETCategories.h"

// Encoding table for base64 algorithm
static unsigned char six2pr[64] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
    'a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','o','p','q','r','s','t','u','v','w','x','y','z',
    '0','1','2','3','4','5','6','7','8','9','+','/'
};
// ENC is the basic 1 character encoding function to make a char printing
#define ENC(c) six2pr[c]

static int base64Encode(const unsigned char *inBuf,
                        unsigned int nbytes,
                        unsigned char *outBuf)
// Uses the base64 algorithm to encode nbytes of inBuf into outBuf.
// Returns the length of outBuf.
{
    // Courtesy to Greg Titus of OmniGroup to post this code to the net.
    register unsigned char *outBufPtr;
    unsigned int i;

    outBufPtr = outBuf;
    for (i = 0; i < nbytes; i += 3)
    {
        *(outBufPtr++) = ENC(*inBuf >> 2);
        *(outBufPtr++) = ENC(((*inBuf << 4) & 060) | ((inBuf[1] >> 4) & 017));
        *(outBufPtr++) = ENC(((inBuf[1] << 2) & 074) | ((inBuf[2] >> 6) & 03));
        *(outBufPtr++) = ENC(inBuf[2] & 077);

        inBuf += 3;
    }

    // If nbytes was not a multiple of 3, then we have encoded too many
    // characters. Adjust appropriately.
    if (i == nbytes + 1)
    {
        // There were only 2 bytes in that last group.
        outBufPtr[-1] = '=';
    }
    else if (i == nbytes + 2)
    {
        // There was only 1 byte in that last group.
        outBufPtr[-1] = '=';
        outBufPtr[-2] = '=';
    }
    *outBufPtr = '\0';
    return outBufPtr - outBuf;
}

//
// Base-64 (RFC-1521) support.  The following is based on mpack-1.5
// (ftp://ftp.andrew.cmu.edu/pub/mpack/)
//
#define XX 127
static char index_64[256] = {
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,62, XX,XX,XX,63,
    52,53,54,55, 56,57,58,59, 60,61,XX,XX, XX,XX,XX,XX,
    XX, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,
    15,16,17,18, 19,20,21,22, 23,24,25,XX, XX,XX,XX,XX,
    XX,26,27,28, 29,30,31,32, 33,34,35,36, 37,38,39,40,
    41,42,43,44, 45,46,47,48, 49,50,51,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
};
#define CHAR64(c) (index_64[(unsigned char)(c)])

@implementation NSData (ETCategories)
//
// These categories enhance the NSData class cluster which extra functionality.
//

#define BASE64_GETC (length > 0 ? (length--, bytes++, bytes[-1]) : (unsigned int)EOF)
#define BASE64_PUTC(c) ([decodedData appendBytes: &c length: sizeof(c)])

+ (id)dataWithBase64String:(NSString *)base64String
{
    return [[[self alloc] initWithBase64String:base64String] autorelease];
}

- (id)initWithBase64String:(NSString *)base64String
{
    NSData *base64Data;
    const char *bytes;
    unsigned int length;
    NSMutableData *decodedData;

    BOOL suppressCR = NO;
    int c1, c2, c3, c4;
    BOOL DataDone = 0;
    char buf[3];


    base64Data = [base64String dataUsingEncoding:NSASCIIStringEncoding];
    bytes = [base64Data bytes];
    length = [base64Data length];
    decodedData = [NSMutableData dataWithCapacity: length];

    while ((c1 = BASE64_GETC) != (unsigned int)EOF)
    {
        if (c1 != '=' && CHAR64(c1) == XX)
            continue;
        if (DataDone)
            continue;

        do
        {
            c2 = BASE64_GETC;
        }
        while (c2 != (unsigned int)EOF && c2 != '=' && CHAR64(c2) == XX);
        do
        {
            c3 = BASE64_GETC;
        } while (c3 != (unsigned int)EOF && c3 != '=' && CHAR64(c3) == XX);
        do
        {
            c4 = BASE64_GETC;
        }
        while (c4 != (unsigned int)EOF && c4 != '=' && CHAR64(c4) == XX);
        if (c2 == (unsigned int)EOF
            || c3 == (unsigned int)EOF
            || c4 == (unsigned int)EOF)
        {
            [NSException raise: NSInvalidArgumentException
                        format: @"Premature end of Base64 string"];
            break;
        }
        if (c1 == '=' || c2 == '=')
        {
            DataDone = YES;
            continue;
        }
        c1 = CHAR64(c1);
        c2 = CHAR64(c2);
        buf[0] = ((c1<<2) | ((c2&0x30)>>4));
        if (!suppressCR || buf[0] != '\r')
            BASE64_PUTC(buf[0]);
        if (c3 == '=')
        {
            DataDone = YES;
        }
        else
        {
            c3 = CHAR64(c3);
            buf[1] = (((c2&0x0F) << 4) | ((c3&0x3C) >> 2));
            if (!suppressCR || buf[1] != '\r')
                BASE64_PUTC(buf[1]);
            if (c4 == '=')
            {
                DataDone = YES;
            }
            else
            {
                c4 = CHAR64(c4);
                buf[2] = (((c3&0x03) << 6) | c4);
                if (!suppressCR || buf[2] != '\r')
                    BASE64_PUTC(buf[2]);
            }
        }
    }
    self = [self initWithData:decodedData];

    return self;
}

- (NSString *)base64EncodedDataString
  // Returns a base64 encoded string of the contents of this instance.
{
    unsigned int len, base64Len;
    unsigned char *base64Buffer;
    NSString *base64String;

    len = [self length];
    base64Buffer = NSZoneMalloc ([self zone], 1 + 4 * len / 3);
    base64Len = base64Encode ([self bytes], len, base64Buffer);
    base64String = [NSString stringWithCString: base64Buffer length: base64Len];
    NSZoneFree ([self zone], base64Buffer);

    return base64String;
}

- (NSData *)decodedURIFormData
    // Given a block of bytes which are retrieved from an HTTP request, it will
    // remove all the escaped characters and return those to the original data.
{
    return [self dataByReversingByteEncodingWithDelimiter: '%'
                             reverseEncodedSpaceCharacter: YES];
}

- (NSData *)dataByReversingByteEncodingWithDelimiter:(char)character
                        reverseEncodedSpaceCharacter:(BOOL)decodeSpaceChar
    // Decodes all hexadecimal character pairs escaped with character to their byte
    // value. Converts `+` to ` ' of decodeSpaceChar equals YES. 
{
    unsigned char *bptr = (unsigned char *) [self bytes];
    unsigned char *end = bptr + [self length];
    NSMutableData *d = [NSMutableData dataWithCapacity: [self length]];

    while (bptr < end)
    {
        if (*bptr == character)
        {
            unsigned int tmp = 0;
            char uch = 0;
            char next[4] = { 0 };

            ++bptr;
            next[0] = *bptr++;
            next[1] = *bptr++;

            if (sscanf(next,"%2x",&tmp))
            {
                uch = (char) tmp;
                [d appendBytes: &uch length: sizeof(char)];
            }
        }
        else if (decodeSpaceChar && *bptr=='+')
        {
            static const char space = ' ';
            [d appendBytes: &space length: sizeof(space)];
            bptr++;
        }
        else
        {
            [d appendBytes: bptr++ length: sizeof(*bptr)];
        }
    }
    return d;
}

// ***** ETStringEncodingProtocol implementation *****

- (NSString *)stringEncoding
  // Returns a description of this string in ppl list format. All
  // spaces are stripped.
{
    return [[self description] stringWithStrippedWhiteSpace];
}

@end
