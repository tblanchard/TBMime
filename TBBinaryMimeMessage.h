/* TBBinaryMimeMessage.h created by todd on Fri 16-Jun-2000 */

#import <Foundation/Foundation.h>
#import <TBMime/TBSimpleMimeMessage.h>

@interface TBBinaryMimeMessage : TBSimpleMimeMessage
{
    NSString *_base64String;
}

+(id)messageWithSubtype: subType filename: filename;

-initWithHeaders:(NSDictionary *)headers body: (NSData *) body;
-initWithContentsOfFile:(NSString *)filename;

-(void)setBody:(NSData *)data;
-(NSString*)bodyString;


@end
