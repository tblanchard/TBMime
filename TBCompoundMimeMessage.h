/* TBCompoundMimeMessage.h created by todd on Mon 12-Jun-2000 */

#import <Foundation/Foundation.h>
#import <TBMime/TBMimeMessage.h>

@interface TBCompoundMimeMessage : TBMimeMessage
{
    NSMutableArray *_parts;
}

-initWithHeaders:(NSDictionary *)headers body: (NSData *) body;
-init;

-(id)body;

-(void)addPart:(TBMimeMessage *)message;

-(id)messageForContentId:(TBContentId *) cid;
-(id)messageForContentLocation:(NSURL *) loc;
-(id)messageForFilename:(NSString *)filename;

@end
