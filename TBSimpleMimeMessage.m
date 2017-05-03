/* TBSimpleMimeMessage.m created by todd on Mon 12-Jun-2000 */

#import "TBSimpleMimeMessage.h"

@implementation TBSimpleMimeMessage


-initWithHeaders:(NSDictionary *)headers body: (NSData *) body
{
    [super initWithHeaders: headers];
    _body = [body retain];
    return self;
}

-(id)body
{
    return _body;
}

-(void)setBody:(NSData *)data
{
    [data retain];
    [_body release];
    _body = data;
}

-(NSString *)bodyString
{
    return [_body description];
}

-(void)dealloc
{
    [_body release];
    [super dealloc];
}

-(NSString *)description
{
    return [NSString stringWithFormat: @"%@\nbody=%@",[super description],_body];
}

@end
