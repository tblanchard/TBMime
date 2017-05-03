/* TBMimeMessage.h created by todd on Tue 06-Jun-2000 */

#import <Foundation/Foundation.h>

@class TBContentType;
@class TBContentId;
@class TBContentDisposition;
@class TBLocale;

@interface TBMimeMessage : NSObject
// Abstract class - TBMimeMessage is a class cluster with leaves for the usual
// mime types specified in rfc 2046
// Subclasses are TBSimpleMimeMessage (messages with a single body) and
// TBCompoundMimeMessage - (multipart and message - contains several subparts)
// Beneath TBSimpleMimeMessage there is TBTextMimeMessage and TBBinaryMimeMessage.
// TBTextMimeMessage represents all the text/* messages
// TBBinaryMimeMessage implements most of image, video, audio etc...
{
    @private
    NSMutableDictionary 	*_headers;
}

+ (void)initialize;

+ (Class)headerClassForKey:(NSString *)aKey;
+ (void)registerHeaderClass:(Class)aClass
                     forKey:(NSString *)aKey;

+ (Class)messageClassForMajorType:(NSString *)aType;
+ (void)registerMessageClass:(Class)aClass
                forMajorType:(NSString *)aType;

// gets extension for type or vice versa from the plists 
+ (NSString *)mimeTypeForExtension:(NSString *)anExtension;
+ (NSString *)extensionForMimeType:(NSString *)mimeType;

// technically an abstract method - it will raise unless overridden
// subclasses override it to return text, multipart etc...
+(NSString *)majorType;

// create a message from scratch
+(id)mimeMessageWithType:(NSString *)mimeType;
+(id)mimeMessageWithType:(NSString *)mimeType startCID:(TBContentId *)start;

// parse up and construct a mime message from a buffer of bytes
// this is what you use when you get something over the wire
+(id)mimeMessageFromData:(NSData *)data;

// generally called at subclass levels - ie [TBTextMimeMessage messageWithSubtype: @"plain"]
+(id)messageWithSubtype:(NSString *)subtype;

// based on the file's extension - builds you a mime message of the right
// type.  If you pass it a directory it makes a multipart mixed message.
+(id)messageWithFilePath:(NSString *)filename;

// called by various subclasses
-(id)initWithHeaders:(NSDictionary *)headers;

// you can't change the content type but you can look at it and set subfields
-(TBContentType *) contentType;

-(void)setContentDescription:(NSString *)desc;
-(NSString *) contentDescription;

-(TBContentId *) contentId;
-(void)setContentId:(TBContentId *)cid;

-(NSURL *) contentLocation;
-(void)setContentLocation:(NSURL *)location;

-(TBContentDisposition *)contentDisposition;
-(void)setContentDisposition: (TBContentDisposition *)disp;

-(NSString *)contentTransferEncoding;
-(void)setContentTransferEncoding: (NSString *)enc;

-(TBLocale *)contentLanguage;
-(void)setContentLanguage:(TBLocale *)loc;

// access to headers I might not have thought of.
-(id)headerForKey:(NSString *)key;
-(void)setHeader:(id) header forKey: (NSString *)key;

// most mime messages have some kind of body - for compound messages
// body is an NSArray - simple mime messages have NSData bodies
-(id)body;
-(id)init;

// This gives you a data buffer for sending the message over a wire.
-(NSData *)messageData;

// Finding message parts by various criteria
-(id)messageForContentId:(TBContentId *) cid;
-(id)messageForContentLocation:(NSURL *) loc;
-(id)messageForFilename:(NSString *)filename;

@end
