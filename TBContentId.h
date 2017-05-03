/* TBContentId.h created by todd on Fri 16-Jun-2000 */

#import <Foundation/Foundation.h>

@interface TBContentId : NSObject
{
    NSString *_id;
}

+(id)headerWithString:(NSString *)str;

-initWithString:(NSString *)str;
-init;

-(NSData *)messageData;
-(NSString *)idString;
-(NSString *)description;

-(BOOL)isEqual:(id)object;

@end
