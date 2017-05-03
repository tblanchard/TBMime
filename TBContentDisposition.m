/* TBContentDisposition.m created by todd on Thu 15-Jun-2000 */

#import "TBContentDisposition.h"

@implementation TBContentDisposition

+attachmentWithFilename:(NSString *)filename
{
    return [self contentDispositionWithType: @"attachment" filename: filename];
}

+inlineWithFilename:(NSString *)filename
{
    return [self contentDispositionWithType: @"inline" filename: filename];
}

+contentDispositionWithType: (NSString *)str filename: filename
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *file = [[filename pathComponents] lastObject];
    NSDictionary *dict;
    NSString *string = [str stringByAppendingString: @"; filename="];
    string = [string stringByAppendingString: file];
    
    if ([fm fileExistsAtPath: filename])
    {
        NSString *val = nil;
        dict = [fm fileAttributesAtPath:filename traverseLink: YES];

        if(val = [dict objectForKey: NSFileModificationDate])
        {
            string = [string stringByAppendingFormat: @"; modification-date=\"%@\"",val];
        }
        if(val = [dict objectForKey: NSFileSize])
        {
            string = [string stringByAppendingFormat: @"; size=",val];
        }
    }
    
    return [self headerWithString: string];   
}

-(NSString *)filename
{
    return [_additionalValues objectForKey: @"filename"];
}

-(void)setFilename:(NSString *)file
{
    [_additionalValues setObject: file forKey: @"filename"];
}


-(NSCalendarDate *)creationDate
{
    NSString *dt = [_additionalValues objectForKey: @"creation-date"];
    return dt ? [NSCalendarDate dateWithNaturalLanguageString: dt] : nil;
}

-(void)setCreationDate:(NSCalendarDate *)date
{
    [_additionalValues setObject: [date description] forKey: @"creation-date"];
}

-(NSCalendarDate *)modificationDate
{
    NSString *dt = [_additionalValues objectForKey: @"modification-date"];
    return dt ? [NSCalendarDate dateWithNaturalLanguageString: dt] : nil;
}

-(void)setModificationDate:(NSCalendarDate *)date
{
    [_additionalValues setObject: [date description] forKey: @"modification-date"];
}

-(NSCalendarDate *)readDate
{
    NSString *dt = [_additionalValues objectForKey: @"read-date"];
    return dt ? [NSCalendarDate dateWithNaturalLanguageString: dt] : nil;
}

-(void)setReadDate:(NSCalendarDate *)date
{
    [_additionalValues setObject: [date description] forKey: @"read-date"];
}

-(NSNumber *)size
{
    NSString *sz = [_additionalValues objectForKey: @"size"];
    return sz ? [NSNumber numberWithInt: [sz intValue]] : nil;
}

-(void)setSize:(NSNumber *)size
{
    [_additionalValues setObject: [size description] forKey: @"size"];
}

- (NSString *)name
{
    return [_additionalValues objectForKey: @"name"];
}

- (void)setName:(NSString *)aName
{
    [_additionalValues setObject: aName forKey: @"name"];
}

@end
