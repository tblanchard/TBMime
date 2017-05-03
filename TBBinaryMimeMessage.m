/* TBBinaryMimeMessage.m created by todd on Fri 16-Jun-2000 */

#import "TBBinaryMimeMessage.h"
#import "TBContentDisposition.h"
#import "TBPrivateUtilities.h"

static const char crlf[] = { 13, 10, 0 };

@implementation TBBinaryMimeMessage

+(id)messageWithSubtype: subType filename: filename
{
    id msg = [self messageWithSubtype: subType];
    [msg setContentDisposition: [TBContentDisposition attachmentWithFilename: filename]];
    [msg setContentLocation: filename];
    [msg setContentTransferEncoding: @"base64"];
    [msg setBody: [NSData dataWithContentsOfMappedFile: filename]];
    return msg;
}

-initWithHeaders:(NSDictionary *)headers body: (NSData *) body
{
    NSData *decodedData = body;
    if([@"base64" isEqualToString: [[headers objectForKey:@"content-transfer-encoding"] lowercaseString]])
    {
        _base64String = [[NSString alloc] initWithData: body encoding: NSASCIIStringEncoding];
        decodedData = [[_base64String base64DecodedStringData] retain];
    }
    return [super initWithHeaders: headers body: decodedData];
}

-initWithContentsOfFile:(NSString *)filename
{
    [self init];
    [self setBody: [NSData dataWithContentsOfMappedFile: filename]];
    return self;
}

-(void)setBody:(NSData *)data
{
    [super setBody: data];
    [_base64String release];
    _base64String = [[_body base64EncodedDataString] retain];
}

-(NSString*)bodyString
{
    return _base64String;
}

-(void)dealloc
{
    [_base64String release];
    [super dealloc];
}

-(NSData *)messageData
{
    NSData *body = [[self bodyString] dataUsingEncoding: NSASCIIStringEncoding];
    NSMutableData *header;
    header = [[super messageData] mutableCopy];
    [header appendData: [[NSString stringWithFormat:@"Content-Length: %d%s%s",[body length],crlf,crlf] dataUsingEncoding: NSASCIIStringEncoding]];
    [header appendData: body];
    return [header autorelease];
}


@end
