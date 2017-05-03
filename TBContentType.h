/* TBContentType.h created by todd on Mon 12-Jun-2000 */

#import <Foundation/Foundation.h>
#import <TBMime/TBCompoundMimeHeader.h>

@class TBContentId;

@interface TBContentType : TBCompoundMimeHeader
{

    NSString *_majorType;
    NSString *_minorType;
    
}

+ (id)contentTypeWithType:(NSString *)mimeType;
+ (id)contentTypeWithType:(NSString *)mimeType startCID:(TBContentId *)start;


-(id)initWithString:(NSString *)str;

-(NSString *)majorType;
-(NSString *)minorType;

-(NSString *)charset;
-(void)setCharset:(NSString *)chars;

-(NSString *)boundary;
-(void)setBoundary:(NSString *)bndry;

-(TBContentId *)start;
-(void)setStart:(TBContentId *)start;

@end
