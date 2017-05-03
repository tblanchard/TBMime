/* TBContentType.m created by todd on Mon 12-Jun-2000 */

#import "TBContentType.h"
#import "TBContentId.h"

@implementation TBContentType

-(NSString *)majorType { return _majorType; }
-(NSString *)minorType { return _minorType; }

+ (id)contentTypeWithType:(NSString *)mimeType
// returns an autoreleased TBContentType object with the given mimeType
{
    return [[[TBContentType alloc] initWithString:mimeType] autorelease];
}

+ (id)contentTypeWithType:(NSString *)mimeType startCID:(TBContentId *)start
// returns an autoreleased TBContentType object with the given mimeType
// and start content id.
{
    TBContentType *ct = [[[TBContentType alloc] initWithString:mimeType] autorelease];
    [ct setStart:start];
    return ct;
}


-(id)initWithString:(NSString *)str
{
    NSArray *pair;
    [super initWithString: str];
    pair = [_primaryValue componentsSeparatedByString: @"/"];
    if ([pair count] !=2) {
        [NSException raise:@"TBMimeException" format:@"TBContentType: The mimetype \"%@\" is not formatted correctly.",str];
    }
    _majorType = [[pair objectAtIndex: 0] retain];
    _minorType = [[pair objectAtIndex: 1] retain];
    return self;
}

-(void)dealloc
{
    [_majorType release];
    [_minorType release];
    [super dealloc];
}

-(NSString *)charset { return [_additionalValues objectForKey: @"charset"]; }
-(void)setCharset:(NSString *)chars
{
    [_additionalValues setObject: chars forKey: @"charset"];
}

-(NSString *)boundary { return [_additionalValues objectForKey: @"boundary"]; }
-(void)setBoundary:(NSString *)bnd
{
    [_additionalValues setObject: bnd forKey: @"boundary"];
}

-(TBContentId *)start
{
    return [TBContentId headerWithString:[_additionalValues objectForKey: @"start"]];
}
-(void)setStart:(TBContentId *)start
// sets the start content part value, used in multipart messages to point to
// the logical first body part. 
{
    [_additionalValues setObject:[start idString] forKey: @"start"];
}


@end
