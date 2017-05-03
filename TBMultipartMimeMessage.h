/* TBMultipartMimeMessage.h created by todd on Tue 13-Jun-2000 */

#import <Foundation/Foundation.h>
#import <TBMime/TBCompoundMimeMessage.h>

@interface TBMultipartMimeMessage : TBCompoundMimeMessage
{
}

+(NSString *)majorType;

+(id)messageWithSubtype: (NSString *)subtype filename: (NSString *) filename;


@end
