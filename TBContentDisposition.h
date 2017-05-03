/* TBContentDisposition.h created by todd on Thu 15-Jun-2000 */

#import <Foundation/Foundation.h>
#import <TBMime/TBCompoundMimeHeader.h>

@interface TBContentDisposition : TBCompoundMimeHeader
{

}

+attachmentWithFilename:(NSString *)filename;
+inlineWithFilename:(NSString *)filename;
+contentDispositionWithType: (NSString *)str filename: filename;

-(NSString *)filename;
-(void)setFilename:(NSString *)file;

-(NSCalendarDate *)creationDate;
-(void)setCreationDate:(NSCalendarDate *)date;

-(NSCalendarDate *)modificationDate;
-(void)setModificationDate:(NSCalendarDate *)date;

-(NSCalendarDate *)readDate;
-(void)setReadDate:(NSCalendarDate *)date;

-(NSNumber *)size;
-(void)setSize:(NSNumber *)size;

- (NSString *)name;
- (void)setName:(NSString *)aName;

@end
