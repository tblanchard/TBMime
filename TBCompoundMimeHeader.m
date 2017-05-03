/* TBCompoundMimeHeader.m created by todd on Mon 12-Jun-2000 */

#import "TBCompoundMimeHeader.h"
#import "TBPrivateUtilities.h"

static const char ccrlf[] = { 13, 10, 0 };

@implementation TBCompoundMimeHeader

+(id)headerWithString:(NSString*)string
{
    return [[[self alloc] initWithString: string] autorelease];
}
    

-(id)initWithString:(NSString *)string
{
    NSArray *items = [string componentsSeparatedByString: @";"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: [items count]];
    int i;

    [super init];
    
    _primaryValue = [[[[items objectAtIndex: 0] trimmedString] lowercaseString] retain];
    _additionalValues = [dict retain];
    
    for(i = 1; i < [items count]; ++i)
    {
        NSArray *pair = [[items objectAtIndex: i] componentsSeparatedByString:@"="];
        if([pair count] == 2)
        {
            NSString *key = [[[pair objectAtIndex: 0] trimmedString] lowercaseString];
            NSString *value = [[[pair objectAtIndex: 1] trimmedString] unquotedString];
            [dict setObject: value forKey: key];
        }
    }
    
    return self;
}

-(NSString *)primaryValue
{
    return _primaryValue;
}

-(void)setPrimaryValue:(NSString *)value
{
    [value retain];
    [_primaryValue release];
    _primaryValue = value;
}

-(void)dealloc
{
    [_primaryValue release];
    [_additionalValues release];
    [super dealloc];
}

-(NSString *) description
{
    NSMutableString *desc = [[NSMutableString new] autorelease];
    [desc appendString: [[self class] description]];
    [desc appendString: @": "];
    [desc appendString: _primaryValue];
    [desc appendString: @"; "];
    [desc appendString: [_additionalValues description]];
    return desc;
}

-(NSData *)messageData
{
    NSMutableString *str = [[_primaryValue mutableCopy] autorelease];
    NSArray *keys = [_additionalValues allKeys];
    NSCharacterSet *wsp = [NSCharacterSet whitespaceCharacterSet];
    int i;

    // add in all the sub tags
    for(i = 0; i < [keys count]; ++i)
    {
        NSString *key = [keys objectAtIndex: i];
        NSString *value = [_additionalValues objectForKey: key];
        NSRange r = [value rangeOfCharacterFromSet: wsp];
        
        [str appendString: @"; "];
        [str appendString: key];
        [str appendString: @"="];
        if(r.length)
        {
            [str appendString: @"\""];
            [str appendString: value];
            [str appendString: @"\""];
        }
        else
        {
            [str appendString: value];
        }
    }
    return [str dataUsingEncoding: NSASCIIStringEncoding];
}


@end
