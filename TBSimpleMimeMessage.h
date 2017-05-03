/* TBSimpleMimeMessage.h created by todd on Mon 12-Jun-2000 */

#import <Foundation/Foundation.h>
#import <TBMime/TBMimeMessage.h>

@interface TBSimpleMimeMessage : TBMimeMessage
{
    NSData *_body;
}

-(id)body;
-(void)setBody:(NSData *)data;

-(NSString*)bodyString;

-initWithHeaders:(NSDictionary *)headers body: (NSData *) body;

@end
