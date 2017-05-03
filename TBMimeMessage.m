/* TBMimeMessage.m created by todd on Tue 06-Jun-2000 */

#import "TBMimeMessage.h"

#import "TBContentType.h"
#import "TBContentDisposition.h"
#import "TBContentId.h"

#import "TBTextMimeMessage.h"
#import "TBAudioMimeMessage.h"
#import "TBVideoMimeMessage.h"
#import "TBApplicationMimeMessage.h"
#import "TBImageMimeMessage.h"
#import "TBMultipartMimeMessage.h"
#import "TBMessageMimeMessage.h"
#import "TBCharacterEncoder.h"
#import "TBLocale.h"
#import "TBPrivateUtilities.h"

const char* hd_strscan(const char* s1, const char* s2, const char* end);
static const char crlf[] = { 13, 10, 0 };
static const char crlfcrlf[] = { 13, 10, 13, 10, 0 };
static const char continuation[] = { 13, 10, ' ', 0};

@interface NSString (TBMimeExtensions)

-(NSString *)stripHeaderComments;
-(NSData *)messageData;
-(NSString *)decodeQuotedPrintable;
-(NSString *)decodeAllQuotedPrintables;

@end

@implementation NSString (TBMimeExtensions)

-(NSString *)stripHeaderComments
{
    int startComment;
    int endComment;

    if((startComment = [self indexOfString: @"("]) < (endComment = [self indexOfString: @")"]))
    {
        NSMutableString *stripped = [[self mutableCopy] autorelease];
        do
        {
            NSRange rm = { startComment, endComment-startComment+1 };
            [stripped deleteCharactersInRange: rm];
        } while((startComment = [stripped indexOfString: @"("]) < (endComment = [stripped indexOfString:@")"]));
        return stripped;
    }
    return self;
}

-(NSData *)messageData
{
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    NSString *tmp = self;
    NSRange range = [self rangeOfCharacterFromSet: set];

    if([tmp canBeConvertedToEncoding: NSASCIIStringEncoding])
    {
        // cool - just see if we need to quote it
        if(range.length)
        {
            tmp = [NSString stringWithFormat:@"\"%@\"",tmp];
        }
    }
    else
    {
        tmp = [[tmp dataUsingEncoding: NSUTF8StringEncoding] base64EncodedDataString];
        tmp = [NSString stringWithFormat:@"=?utf-8?b?%@?=",tmp];
    }
    return [tmp dataUsingEncoding: NSASCIIStringEncoding];
}

-(NSString *)decodeQuotedPrintable
{
    NSString *tmp = [self trimmedString];
    if([tmp hasPrefix: @"=?"] && [tmp hasSuffix: @"?="])
    {
        NSArray *parts = [tmp componentsSeparatedByString: @"?"];
        NSString *encodingPart = [parts objectAtIndex: 1];
        NSString *encodingType = [[parts objectAtIndex: 2] lowercaseString];
        NSString *string = [parts objectAtIndex: 3];
        TBCharacterEncoder *coder = [TBCharacterEncoder encoderForName: [[encodingPart componentsSeparatedByString: @"*"] objectAtIndex: 0]];
        NSData *header;

        if([encodingType isEqualToString: @"q"])
        {
            // Make sure we don't convert `+' characters to spaces!
            header = [[string dataUsingEncoding: NSASCIIStringEncoding]
                      dataByReversingByteEncodingWithDelimiter: '='
                      reverseEncodedSpaceCharacter: NO];
        }
        else if ([encodingType isEqualToString: @"b"])
        {
            header = [string base64DecodedStringData];
        }
        else
        {
            return string;
        }
        return [coder decodeData: header];
    }
    return self;
}

-(NSString *)decodeAllQuotedPrintables
{
    NSRange start = [self rangeOfString: @"=?"];

    if(start.length)
    {
        NSMutableString *mc = [[self mutableCopy] autorelease];
        while(start.length)
        {
            NSRange end = [mc rangeOfString: @"?="];
            if(end.length)
            {
                start.length = end.location + 2;
                [mc replaceCharactersInRange: start withString: [[mc substringWithRange: start] decodeQuotedPrintable]];
            }
            else
            {
                return mc;
            }
            start = [mc rangeOfString: @"=?"];
        }
        return mc;
    }
    return self;
}

@end

static NSMutableDictionary *_headerClassesDictionary = nil;
static NSMutableDictionary *_messageClassesDictionary = nil;

@interface TBLocale (TBMimeExtensions)

+(id)headerWithString:(NSString*)string;
-(NSData *)messageData;

@end

@implementation TBLocale (TBMimeExtensions)

+(id)headerWithString:(NSString*)string
{
    return [self localeForName: string];
}

-(NSData *)messageData
{
    return [[self isoCode] dataUsingEncoding: NSASCIIStringEncoding];
}

@end


@interface NSURL (TBMimeExtensions)

+(id)headerWithString:(NSString*)string;
-(NSData *)messageData;

@end

@implementation NSURL (TBMimeExtensions)

+(id)headerWithString:(NSString*)string
{
    return [self URLWithString: string];
}

-(NSData *)messageData
{
    return [[self relativeString] messageData];
}


@end

static NSDictionary *__mimeTypesDict          = nil;
static NSDictionary *__mimeTypesExtensionDict = nil;

@implementation TBMimeMessage

+ (void)initialize
{
    if (!_headerClassesDictionary && !_messageClassesDictionary)
    {
        _headerClassesDictionary = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
            [TBContentType class], @"content-type",
            [TBContentDisposition class], @"content-disposition",
            [TBContentId class], @"content-id",
            [NSURL class], @"content-location",
            [TBLocale class], @"content-language",
            nil, nil] retain];
        _messageClassesDictionary = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
            [TBTextMimeMessage class], [TBTextMimeMessage majorType],
            [TBAudioMimeMessage class], [TBAudioMimeMessage majorType],
            [TBVideoMimeMessage class], [TBVideoMimeMessage majorType],
            [TBApplicationMimeMessage class], [TBApplicationMimeMessage majorType],
            [TBImageMimeMessage class], [TBImageMimeMessage majorType],
            [TBMultipartMimeMessage class], [TBMultipartMimeMessage majorType],
            [TBMessageMimeMessage class], [TBMessageMimeMessage majorType],
            nil, nil] retain];
    }
}

+ (Class)headerClassForKey:(NSString *)aKey
{
    return [_headerClassesDictionary objectForKey: aKey];
}

+ (void)registerHeaderClass:(Class)aClass
                     forKey:(NSString *)aKey
{
    [_headerClassesDictionary setObject: aClass forKey: aKey];
}

+ (Class)messageClassForMajorType:(NSString *)aType
{
    return [_messageClassesDictionary objectForKey: aType];
}

+ (void)registerMessageClass:(Class)aClass
                forMajorType:(NSString *)aType
{
    [_messageClassesDictionary setObject: aClass forKey: aType];
}

+ ( NSString * ) mimeTypeForExtension: ( NSString * ) anExtension
{
    NSString *mimeType;
    NSString *fileName;

    if( __mimeTypesDict == nil ){
        fileName = [[ NSBundle bundleForClass: self]
                       pathForResource:@"MimeTypes" ofType:@"plist" ];

        __mimeTypesDict = [[ NSDictionary alloc ] initWithContentsOfPropertyListFile: fileName ];
        NSAssert(__mimeTypesDict,@"+[TBMimeMessage mimeTypeForExtension:] Could not read MimeTypes.plist");
    }

    mimeType = [ __mimeTypesDict objectForKey: anExtension ];
    if( mimeType == nil )
        return [ NSString stringWithFormat: @"application/%@", anExtension ];
    return mimeType;
}

+ ( NSString * ) extensionForMimeType: ( NSString *) mimeType
{
    NSString *extension;
    NSString *fileName;

    extension = nil;
    if( __mimeTypesExtensionDict == nil ){
        fileName = [[ NSBundle bundleForClass: self ]
                       pathForResource:@"MimeTypesExtension" ofType:@"plist" ];

        __mimeTypesExtensionDict = [[ NSDictionary alloc ] initWithContentsOfPropertyListFile: fileName ];
        NSAssert(__mimeTypesExtensionDict,@"+[TBMimeMessage extensionForMimeType] Could not read MimeTypesExtension.plist");
    }

    extension = [ __mimeTypesExtensionDict objectForKey: mimeType ];
    if( extension == nil ){
        return @"txt";
    }
    return extension;
}


+(NSString *)majorType
{
    [[NSException exceptionWithName: @"TBMimeException" reason: [NSString stringWithFormat: @"%@ is an abstract class!",self] userInfo: nil] raise];
    return nil;
}

+(id)messageWithSubtype:(NSString *)subtype
{
    TBContentType *type = [TBContentType headerWithString: [NSString stringWithFormat: @"%@/%@",[self majorType],[subtype lowercaseString]]];
    TBMimeMessage *msg = [[[self alloc] initWithHeaders: [NSDictionary dictionaryWithObjectsAndKeys: type, @"content-type",nil,nil]] autorelease];
    return msg;
}

+(id)messageWithFilePath:(NSString *)filename
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = 0;
    TBMimeMessage *msg = nil;
    
    if([fm fileExistsAtPath:filename isDirectory:&isDir])
    {
        if(isDir) // create a multipart related
        {
            msg = [TBMultipartMimeMessage messageWithSubtype: @"mixed" filename: filename];
        }
        else
        {
            NSString *extension = [[filename componentsSeparatedByString: @"."] lastObject];
            NSArray *types = [[self mimeTypeForExtension: extension] componentsSeparatedByString: @"/"];
            NSString *majorType = [types objectAtIndex: 0];
            NSString *subType = [types lastObject];
            id messageClass = [self messageClassForMajorType: majorType];
            msg = [messageClass messageWithSubtype: subType filename: filename];
            if(!msg)
            {
                [NSException raise: @"TBMimeException" format: @"can't determine message type for file %@",filename];
            }
        }
    }
    return msg;
}

+(id)mimeMessageFromData:(NSData *)data
{
    // split the headers from the body, parse the headers, then construct the
    // correct mime subclass.  Headers are separated by crlfcrlf [rfc2045]
    const char* bytes = [data bytes];
    int length = [data length];
    char *divider = (char*) hd_strscan(bytes, crlfcrlf, bytes+length);
    NSString *headerString = nil;
    NSData *body = nil;
    NSArray *headerLines = nil;
    NSMutableDictionary *headers = nil;
    id messageClass;
    TBContentType *type;
    int i;
    
    if(!divider) // no body
    {
        // use utf8 because headers may have been decoded once already by WORequest and then reconstructed
        // by a direct action.  When reconstructed, we use utf8 to be save.  For ascii, this also still
        // works.
        headerString = [[[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding] autorelease];
    }
    else
    {
        NSRange headerRange = { 0, divider-bytes };
        // Get rid of the crlf at the end of the body!
        NSRange bodyRange = { headerRange.length+4, length-(headerRange.length+4)-2 };
        headerString = [[[NSString alloc] initWithData: [data subdataWithRange: headerRange]
                                              encoding: NSUTF8StringEncoding] autorelease];
        headerString = [headerString stringByReplacingAllOccurrencesOfString: [NSString stringWithCString: continuation] withString:@" "];
        body = [data subdataWithRange: bodyRange];
    }

    headerLines = [headerString componentsSeparatedByString: [NSString stringWithCString: crlf]];
    headers = [NSMutableDictionary dictionaryWithCapacity: [headerLines count]];

    // parse up the headers and see what we've got
    for(i = 0; i < [headerLines count]; ++i)
    {
        NSRange valueSeparatorRange;
        NSString *line, *key, *value;

        line = [headerLines objectAtIndex: i];
        if (![line length])
            continue;
        valueSeparatorRange = [line rangeOfString: @":" options: NSLiteralSearch];
        key = [[[line substringToIndex: valueSeparatorRange.location] trimmedString]
               lowercaseString];
        value = [[[[[line substringFromIndex: valueSeparatorRange.location + 1]
                    trimmedString] decodeAllQuotedPrintables] stripHeaderComments]
                 unquotedString];
        if ([key length] && [value length])
        {
            id cls = [self headerClassForKey: key];

            if([key isEqualToString: @"content-length"]) continue;
            
            if(cls != nil)
            {
                [headers setObject: [cls headerWithString: value] forKey: key];
            }
            else
            {
                [headers setObject: value forKey: key];
            }
        }
    }

    // construct the right kind of mime message
    type = [headers objectForKey: @"content-type"];

    // go with the recommended default
    if(!type)
    {
        type = [TBContentType headerWithString: @"text/plain; charset=us-ascii"];
        [headers setObject: type forKey: @"content-type"];
    }

    messageClass = [self messageClassForMajorType: [type majorType]];

    return [[[messageClass alloc] initWithHeaders: headers body: body] autorelease];
        
}

+(id)mimeMessageWithType:(NSString *)mimeType
// create a new mime message with mimeType.
{
    TBContentType *type = [TBContentType headerWithString: mimeType];
    id messageClass = [[self class] messageClassForMajorType:[type majorType]];
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: type,@"content-type",nil,nil];
    return [[[messageClass alloc] initWithHeaders: headers] autorelease];    
}

+(id)mimeMessageWithType:(NSString *)mimeType startCID:(TBContentId *)start
// create a new mime message with a content-type header that includes
// a 'start' component. Only makes sense with a major type of multipart.
{
    TBContentType *type = [TBContentType contentTypeWithType:mimeType startCID:start];
    id messageClass = [[self class] messageClassForMajorType:[type majorType]];
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: type,@"content-type",nil,nil];
    return [[[messageClass alloc] initWithHeaders: headers] autorelease];
}

/* Maybe later
+(id)mimeMessageWithType:(NSString *)mimeType filename:(NSString *)filename
{
    TBMimeMessage
}
*/

-(id)initWithHeaders:(NSDictionary *)headers
{
    [self init];
    [_headers addEntriesFromDictionary: headers];
    return self;
}

-(id)init
{
    [super init];
    _headers = [[NSMutableDictionary dictionary] retain];
    [_headers setObject: @"1.0" forKey: @"mime-version"];
    [_headers setObject: [[TBContentId new] autorelease] forKey: @"content-id"];
    return self;
}

- (void)dealloc
{
    [_headers release];
    [super dealloc];
}

-(TBContentType *) contentType
{
    return [_headers objectForKey: @"content-type"];
}

-(void)setContentDescription:(NSString *)desc
{
    [_headers setObject: desc forKey: @"content-description"];
}

-(NSString *) contentDescription
{
    return [_headers objectForKey: @"content-description"];
}

-(TBContentId *) contentId
{
    return [_headers objectForKey: @"content-id"];
}

-(void)setContentId:(TBContentId *)cid
{
    [_headers setObject: cid forKey: @"content-id"];
}

-(NSURL *) contentLocation
{
    return [_headers objectForKey: @"content-location"];
}

-(void)setContentLocation:(NSURL *)location
{
    [_headers setObject: location forKey: @"content-location"];    
}

-(TBContentDisposition *)contentDisposition
{
    return [_headers objectForKey: @"content-disposition"];
}

-(void)setContentDisposition: (TBContentDisposition *)disp
{
    [_headers setObject: disp forKey: @"content-disposition"];
}

-(NSString *)contentTransferEncoding
{
    return [_headers objectForKey: @"content-transfer-encoding"];
}

-(void)setContentTransferEncoding: (NSString *)enc
{
    [_headers setObject: enc forKey: @"content-transfer-encoding"];
}

-(TBLocale *)contentLanguage
{
    return [_headers objectForKey: @"content-language"];
}

-(void)setContentLanguage:(TBLocale *)loc
{
    [_headers setObject: loc forKey: @"content-language"];
}

-(id)headerForKey:(NSString *)key
{
    return [_headers objectForKey: key];
}

-(void)setHeader:(id) header forKey: (NSString *)key
{
    [_headers setObject: header forKey: key];
}

-(id)body { return nil; }

-(NSString *)description
{
    return [NSString stringWithFormat: @"%@\n%@",[self class],_headers];
}

-(NSData*)messageData
{
    NSArray *keys = [_headers allKeys];
    NSMutableData *message = [[NSMutableData new] autorelease];
    int i;
    
    for(i = 0; i < [keys count]; ++i)
    {
        NSString *key = [keys objectAtIndex: i];
        id value = [_headers objectForKey: key];
        NSArray *bits = [key componentsSeparatedByString: @"-"];
        int j;

        [message appendData: [[[bits objectAtIndex: 0] capitalizedString] dataUsingEncoding: NSASCIIStringEncoding]];

        for(j = 1; j < [bits count]; ++j)
        {
            [message appendBytes: "-" length: 1];
            [message appendData: [[[bits objectAtIndex: j] capitalizedString] dataUsingEncoding: NSASCIIStringEncoding]];
        }
        [message appendBytes: ": " length: 2];
        [message appendData: [value messageData]];
        [message appendBytes: crlf length: 2];
    }
    
    return message;
}

-(id)messageForContentId:(TBContentId *) cid
{
    return [[self contentId] isEqual: cid] ? self : nil;
}

-(id)messageForContentLocation:(NSURL *) loc
{
    return [[self contentLocation] isEqual: loc] ? self : nil;
}

-(id)messageForFilename:(NSString *)filename
{
    return [[[self contentDisposition] filename] isEqualToString: filename] ? self : nil;
}

@end
