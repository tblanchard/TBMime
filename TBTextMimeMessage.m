/* TBTextMimeMessage.m created by todd on Tue 13-Jun-2000 */

#import "TBTextMimeMessage.h"
#import "TBContentType.h"
#import "TBContentDisposition.h"
#import "TBCharacterEncoder.h"

static const char crlf[] = { 13, 10, 0 };

@implementation TBTextMimeMessage

+(id)messageWithSubtype: subType filename: filename
{
    id msg = [self messageWithSubtype: subType];
    [msg setContentDisposition: [TBContentDisposition attachmentWithFilename: filename]];
    [msg setContentLocation: filename];
    [msg setContentTransferEncoding: @"8bit"];
    [msg setBody: [NSData dataWithContentsOfMappedFile: filename]];
    [[msg contentType] setCharset: @"utf-8"];
    return msg;
}


+(NSString *)majorType
{
    return @"text";
}

-(NSString *)text
{
    if(!_text)
    {
        TBCharacterEncoder *encoder = [TBCharacterEncoder encoderForName: [[self contentType] charset]];
        [self setText: [encoder decodeData: _body]];
    }
    return _text;
}

-(void) setText:(NSString *)str
{
    [str retain];
    [_text release];
    _text = str;
}

-(void)dealloc
{
    [_text release];
    [super dealloc];
}

-(NSString *)description
{
    return [[super description] stringByAppendingFormat: @"\n\"%@\"",[self text]];
}

-(NSData *)messageData
{
    NSData *body;
    NSMutableData *header;
    NSString *charset = [[self contentType] charset];
    TBCharacterEncoder *encoder;
    
    if(!charset)
    {
        [[self contentType] setCharset: @"utf-8"];
    }

    encoder = [TBCharacterEncoder encoderForName: charset];
    body = [encoder encodeString: [self text]];
    header = [[super messageData] mutableCopy];
    [header appendData: [[NSString stringWithFormat:@"Content-Length: %d%s%s",[body length],crlf,crlf] dataUsingEncoding: NSASCIIStringEncoding]];
    [header appendData: body];
    return [header autorelease];
}

@end
