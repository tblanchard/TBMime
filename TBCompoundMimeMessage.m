/* TBCompoundMimeMessage.m created by todd on Mon 12-Jun-2000 */

#import "TBCompoundMimeMessage.h"
#import "TBContentType.h"

static const char crlf[] = { 13, 10, 0 };

// replacement for strstr - ignores embedded null characters and scans until end
const char* hd_strscan(const char* s1, const char* s2, const char* end)
{
    const char* p = s1;
    const char* pp;
    const char* sp;
    
    while(p < end)
    {
        while(p < end && *p != *s2) { ++p; }
        pp = p++;
        sp = s2;
        while(*sp && pp < end && *pp == *sp) 
        { 
            ++sp; 
            ++pp; 
        }
        if(!*sp && pp <= end) { return p-1; }
    }
    return 0;
}


@implementation TBCompoundMimeMessage

-initWithHeaders:(NSDictionary *)headers body: (NSData *) data
{
    const char* bytes = [data bytes];
    const char* endBytes = bytes + [data length];
    char startbound[1024];
    char endbound[1024];
    int boundlen;
    NSString* bndry;
    
    [super initWithHeaders: headers];
    bndry = [[self contentType] boundary];

    if(bndry)
    {
        const char *startptr, *nextptr, *endptr;

        strcpy(startbound,"--");
        strncat(startbound,[bndry cString],1024);
        strcpy(endbound,startbound);
        strncat(endbound,"--",1024);
        boundlen = strlen(startbound);
        
        endptr = hd_strscan(bytes, endbound, endBytes);
        if(endptr)
        {
            NSRange range;

            startptr = hd_strscan(bytes, startbound, endBytes);
            while(startptr && startptr != endptr)
            {
                NSData *d;
                //NSString *s;

                startptr += boundlen;
                nextptr = hd_strscan(startptr,startbound,endBytes);
                range.location = startptr-bytes;
                range.length = nextptr-startptr;
                d = [data subdataWithRange: range];
                //s = [[[NSString alloc] initWithData: d encoding: NSASCIIStringEncoding] autorelease];
                [self addPart: [TBMimeMessage mimeMessageFromData: [data subdataWithRange: range]]];
                startptr = nextptr;
            }
        }
    }    
    return self;
}

-initWithHeaders:(NSDictionary *)headers
{
    TBContentType *ct = [headers objectForKey: @"content-type"];
    if(![ct boundary])
    {
        [ct setBoundary: [[NSProcessInfo processInfo] globallyUniqueString]];
    }
    return [super initWithHeaders: headers]; 
}

-init
{
    [super init];
    _parts = [[NSMutableArray array] retain];
    return self;
}

-(void)addPart:(TBMimeMessage *)msg
{
    [_parts addObject: msg];
}

-(id)body
{
    return _parts;
}

-(void)dealloc
{
    [_parts release];
    [super dealloc];
}

-(NSString *)description
{
    return [[super description] stringByAppendingFormat:@"\n%@",_parts];
}

-(NSData *)messageData
{
    NSData *bndry = [[[self contentType] boundary] dataUsingEncoding: NSASCIIStringEncoding];
    int i;
    NSMutableData *body = [NSMutableData data];
    NSMutableData *header;
    
    if([_parts count])
    {
        [body appendBytes: "--" length: 2];
        [body appendData: bndry];
        for(i = 0; i < [_parts count]; ++i)
        {
            [body appendBytes: crlf length: 2];
            [body appendData: [[_parts objectAtIndex: i] messageData]];
            [body appendBytes: crlf length: 2];
            [body appendBytes: "--" length: 2];
            [body appendData: bndry];
        }
        [body appendBytes: "--" length: 2];
        [body appendBytes: crlf length: 2];
    }
    header = [[super messageData] mutableCopy];
    [header appendData: [[NSString stringWithFormat:@"Content-Length: %d%s%s",[body length],crlf,crlf] dataUsingEncoding: NSASCIIStringEncoding]];
    [header appendData: body];
    return [header autorelease];
}

-(id)messageForContentId:(TBContentId *) cid
{
    id msg = [super messageForContentId: cid];
    if(!msg)
    {
        int i;
        for(i = 0; i < [_parts count]; ++i)
        {
            msg = [[_parts objectAtIndex: i] messageForContentId: cid];
            if(msg) break;
        }
    }
    return msg;
}

-(id)messageForContentLocation:(NSURL *) loc
{
    id msg = [super messageForContentLocation: loc];
    if(!msg)
    {
        int i;
        for(i = 0; i < [_parts count]; ++i)
        {
            msg = [[_parts objectAtIndex: i] messageForContentLocation: loc];
            if(msg) break;
        }
    }
    return msg;
}

-(id)messageForFilename:(NSString *)filename
{
    id msg = [super messageForFilename: filename];
    if(!msg)
    {
        int i;
        for(i = 0; i < [_parts count]; ++i)
        {
            msg = [[_parts objectAtIndex: i] messageForFilename: filename];
            if(msg) break;
        }
    }
    return msg;
}


@end
