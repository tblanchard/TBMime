/* TBCharacterEncoder.h created by todd on Fri 11-Feb-2000 */

#import <Foundation/Foundation.h>

@class TBLocale;

@interface TBCharacterEncoder : NSObject <NSCopying>
{
    // the ugly C implmentation handle
    void* _icuEncoder;
    // name used to create the encoder
    // for the "official" name - use canonicalName
    NSString *_name;
}

// what can I get and how do I get one?
+(NSArray *)availableEncodings;
+(TBCharacterEncoder *)encoderForName: (NSString *)nm;

// default encoder stuff
+(TBCharacterEncoder *)defaultEncoder;
+(NSString *)defaultEncoderName;
+(void)setDefaultEncoderName: (NSString *)nm;
+(void)setDefaultEncoder:(TBCharacterEncoder *)enc;

// whats it called?
-(NSString *)name;
-(NSString *)canonicalName;
-(NSString *)displayName:(TBLocale*)loc;

-(NSData *)encodeString:(NSString *)str;
-(NSString *)decodeData:(NSData *)data;

// reset state
-(void)reset;

// what size are the characters?
-(int)maxCharSize;
-(int)minCharSize;

// quiet housekeeping routines you don't need to call

-(void)dealloc;
- initWithName:(NSString *)nm icuEncoder:(void *)impl;
-(void*)icuEncoder;

-(NSString *)description;
- (BOOL)isEqual:(id)object;

@end
