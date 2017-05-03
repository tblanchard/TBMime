/* TBTextMimeMessage.h created by todd on Tue 13-Jun-2000 */

#import <Foundation/Foundation.h>
#import <TBMime/TBSimpleMimeMessage.h>

@interface TBTextMimeMessage : TBSimpleMimeMessage
{
    NSString *_text;
}

+(NSString *)majorType;

-(NSString *)text;
-(void) setText:(NSString *)str;

@end
