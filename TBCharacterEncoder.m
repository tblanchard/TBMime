/* TBCharacterEncoder.m created by todd on Fri 11-Feb-2000 */

#import "TBCharacterEncoder.h"
#import "TBLocale.h"
#import <unicode/ucnv.h>

static NSArray *_availableEncodings;

@interface TBCharacterEncoder (TBPrivate)

- (void)setName:(NSString *)aName;

@end


@implementation TBCharacterEncoder

- (id)copyWithZone:(NSZone *)zone
{
    int err = 0;
    void* impl = ucnv_open([[self name] cString],&err);

    return [[TBCharacterEncoder allocWithZone: zone] initWithName: [self name] icuEncoder: impl];
}

+(NSArray *)availableEncodings
{
   if (!_availableEncodings)
    {
        int available = ucnv_countAvailable();
        int i;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity: available];
        _availableEncodings = [array retain];
        
        for(i = 0; i < available; ++i)
        {
            NSString *nm = [[NSString alloc] initWithCString: ucnv_getAvailableName(i)];
            [array addObject: nm];
        }
    }
    return _availableEncodings;
}

+(TBCharacterEncoder *)encoderForName:(NSString *)nm
    // Returns nil if no encoder can be found.
{
    int err;
    void *impl;

    err = 0;
    impl = ucnv_open([nm cString],&err);
    if (!impl)
        return nil;
#if 0
    {
        [[NSException exceptionWithName: @"TBCharacterEncoder"
                                 reason: @"Encoder not found!"
                               userInfo: [NSDictionary dictionaryWithObjectsAndKeys: @"name",nm,nil,nil]]
                raise];
    }//initWithName:(NSString *) implementation:(void *)impl
#endif
    return [[[TBCharacterEncoder alloc] initWithName: nm icuEncoder: impl] autorelease];
}

+(TBCharacterEncoder *)defaultEncoder
{
    return [self encoderForName: [self defaultEncoderName]];
}

+(NSString *)defaultEncoderName
{
    return [[[NSString alloc] initWithCString: ucnv_getDefaultName()] autorelease];    
}

+(void)setDefaultEncoderName: (NSString *)nm
{
    ucnv_setDefaultName([nm cString]);
}

+(void)setDefaultEncoder:(TBCharacterEncoder *)enc
{
    ucnv_setDefaultName([[enc canonicalName] cString]);
}

-(id)initWithName:(NSString *)nm icuEncoder:(void*)impl
{
    [super init];
    _icuEncoder = impl;
    [self setName: (nm) ? nm : [self canonicalName]];
    return self;
}

-(void)dealloc
{
    [_name release];
    ucnv_close(_icuEncoder);
    [super dealloc];
}

-(void)reset
{
    ucnv_reset(_icuEncoder);
}

- (void)setName:(NSString *)aName
{
    [_name release];
    _name = [aName retain];
}

-(NSString *)name
{
    return _name;
}

-(int)maxCharSize
{
    return ucnv_getMaxCharSize(_icuEncoder);
}

-(int)minCharSize
{
    return ucnv_getMinCharSize(_icuEncoder);
}

-(NSString *)canonicalName
{
    int err = 0;
    const char* nm = ucnv_getName(_icuEncoder,&err);
    return [NSString stringWithCString: nm]; 
}

-(NSString *)displayName: (TBLocale *)locale
{
    int err = 0;
    UChar tmp[512];
    int len = ucnv_getDisplayName(_icuEncoder,
                                  [[locale icuCode] cString],
                                  tmp,
                                  512,
                                  &err);
    return [NSString stringWithCharacters: tmp length: len];
}

-(void*)icuEncoder
{
    return _icuEncoder;
}

#define TBMAXBUF 512

-(NSData *)encodeString:(NSString *)str
{
    int SRC_MAX = ([str length]+1) * sizeof(unichar); // bytes in source
    int DEST_MAX = [self maxCharSize] * ([str length] +1); // max bytes required for dest

    // couple of stack allocated buffers - stack is FAST
    char source[TBMAXBUF];
    char dest[TBMAXBUF];
    
    // try to get out of malloc for small strings if we can
    unichar *sourcePtr = (unichar*) ((SRC_MAX >= TBMAXBUF) ? malloc(SRC_MAX) : source);
    char *destPtr = (DEST_MAX >= TBMAXBUF) ? malloc(DEST_MAX) : dest;
    unichar *mutableSrcPtr = sourcePtr;
    char* mutableDestPtr = destPtr;
    NSData *data = nil;
    UErrorCode err = 0;

    [str getCharacters: sourcePtr];

    ucnv_fromUnicode (_icuEncoder,
                      &mutableDestPtr,
                      mutableDestPtr+DEST_MAX,
                      &mutableSrcPtr,
                      mutableSrcPtr+[str length],
                      0,
                      YES,
                      &err);
    
    data = [NSData dataWithBytes: destPtr length: (mutableDestPtr - destPtr)];

    if((char*)sourcePtr != source)
        free(sourcePtr);
    if(destPtr != dest)
        free(destPtr);
    return data;
}

-(NSString *)decodeData:(NSData *)data
{
    const char* sourcePtr = [data bytes];
    int UNICHARS_REQUIRED = [data length]/[self minCharSize];

    unichar dest[TBMAXBUF];
    unichar *destPtr = UNICHARS_REQUIRED >= TBMAXBUF ? malloc(sizeof(unichar) * ([data length]+1)) : dest;
    unichar *mutableDestPtr = destPtr;
    NSString *str = nil;
    UErrorCode err = 0;

    ucnv_toUnicode (_icuEncoder,
                 &mutableDestPtr,
                 mutableDestPtr+UNICHARS_REQUIRED,
                 &sourcePtr,
                 sourcePtr+[data length],
                 0,
                 YES,
                 &err);

    if(err)
    {
        NSLog(@"Bummer - decodeData returned %d",err);
    }
    str = [NSString stringWithCharacters: destPtr length: mutableDestPtr - destPtr];
    if(destPtr != dest)
        free(destPtr);
    return str;
}

-(NSString *)description
{
    return [NSString stringWithFormat: @"%@: %@",[self class],[self name]];
}

- (BOOL)isEqual:(id)object
{
    if([object class] == [self class])
    {
        return [[object canonicalName] isEqualToString: [self canonicalName]];
    }
    return NO;
}

@end
