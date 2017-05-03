/* TBMultipartMimeMessage.m created by todd on Tue 13-Jun-2000 */

#import "TBMultipartMimeMessage.h"


@implementation TBMultipartMimeMessage

+(NSString *)majorType
{
    return @"multipart";
}

+(id)messageWithSubtype: (NSString *)subtype filename: (NSString *) filename
{
    TBMultipartMimeMessage *msg = [self messageWithSubtype: subtype];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm directoryContentsAtPath: filename];
    int i;

    for(i = 0; i < [files count]; ++i)
    {
        NSString *file = [filename stringByAppendingPathComponent: [files objectAtIndex: i]];
        TBMimeMessage *part = [TBMimeMessage messageWithFilePath: file];
        if(part == nil)
        {
            part = [TBMimeMessage messageWithFilePath: file];
        }
        [msg addPart: part];
    }
    return msg;
}


@end
