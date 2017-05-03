/* TBContentId.m created by todd on Fri 16-Jun-2000 */

#import "TBContentId.h"
#import "TBPrivateUtilities.h"

@interface TBContentId (PrivateAccessor)
-(NSString *)__cid;
@end

@implementation TBContentId (PrivateAccessor)
-(NSString *)__cid { return _id; }
@end


@implementation TBContentId

+(id)headerWithString:(NSString *)str
{
    return [[[self alloc] initWithString: str] autorelease]; 
}

-initWithString:(NSString *)str
{
    // remove < and >
    NSString *s = [str trimmedString];
    NSRange r = { 0, [s length] };

    if(([s characterAtIndex: 0] == '<') && ([s characterAtIndex: [s length]-1] == '>'))
    {
        r.length -= 2;
        r.location += 1;
        s = [s substringWithRange: r];
    }
    _id = [s retain];
    return self;
}

-init
{
    [super init];
    _id = [[[NSProcessInfo processInfo] globallyUniqueString] retain];
    return self;
}

-(NSData *)messageData
{
    return [[NSString stringWithFormat:@"%@",_id] dataUsingEncoding: NSASCIIStringEncoding];
}

-(NSString *)idString
// returns the contentId value as a string, e.g. khawk1_234_5678_3.
{
    return [NSString stringWithFormat:@"%@", _id];
}

-(NSString *)description
{
    return [[[self class] description] stringByAppendingFormat: @": <%@>",_id];
}


-(BOOL)isEqual:(id)object
{
    return ([self class] == [object class]) && [_id isEqualToString: [object __cid]];
}

-(void)dealloc
{
    [_id release];
    [super dealloc];
}

@end
