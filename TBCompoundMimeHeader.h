/* TBCompoundMimeHeader.h created by todd on Mon 12-Jun-2000 */

#import <Foundation/Foundation.h>

@interface TBCompoundMimeHeader : NSObject
{
    NSString 			*_primaryValue;
    NSMutableDictionary	*_additionalValues;
}

+(id)headerWithString:(NSString*)string;

-(id)initWithString:(NSString *)string;

-(NSString *)primaryValue;
-(void)setPrimaryValue:(NSString *)value;

-(NSString *)description;
-(NSData *)messageData;


@end
