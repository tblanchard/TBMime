/* TBLocale.h created by todd on Fri 11-Feb-2000 */

#import <Foundation/Foundation.h>

@class TBCharacterEncoder;

@interface TBLocale : NSObject <NSCopying>
{
    NSString *_implementation;
}
+(BOOL)isValidISOCode:(NSString *)str;
+(NSArray *)availableLocales;
+(NSArray *)availableLanguageCodes;
+(NSArray *)availableCountryCodes;

+(TBLocale *)localeForLanguageCode: (NSString*) lang countryCode: (NSString *) cntry variant: (NSString *)var;
+(TBLocale *)localeForLanguageCode: (NSString*) lang countryCode: (NSString *) cntry;
+(TBLocale *)localeForLanguageCode: (NSString*) lang;

+(TBLocale *)localeForName: (NSString *)nm;
+(TBLocale *)localeForISOCode:(NSString *)code;
+(TBLocale *)defaultLocale;
+(void)setDefaultLocale:(TBLocale *)locale;

-initWithISOCode:(NSString *)code;

-(NSString *)isoCode;
-(NSString *)icuCode;

-(NSString *)languageCode;
-(NSString *)countryCode;
-(NSString *)variantCode;
-(NSString *)name;
-(NSString *)iso3LanguageCode;
-(NSString *)iso3CountryCode;

-(NSString *)languageNameLocalizedForLocale:(TBLocale *)otherLocale;
-(NSString *)countryNameLocalizedForLocale:(TBLocale *)otherLocale;
-(NSString *)variantNameLocalizedForLocale:(TBLocale *)otherLocale;
-(NSString *)nameLocalizedForLocale:(TBLocale *)otherLocale;

-(NSString *)localizedLanguageName;
-(NSString *)localizedCountryName;
-(NSString *)localizedVariantName;
-(NSString *)localizedLocaleName;

-(void)dealloc;

+(NSString *)icuConformingCodeForString:(NSString *)s;
+(NSString *)isoConformingCodeForString:(NSString *)s;

-(NSString *)description;

// how do we usually encode this language?
-(TBCharacterEncoder *)defaultCharacterEncoder;

// fallback works like this: de-LU-EURO -> de-LU -> de -> en
-(TBLocale *)fallbackLocale;

-(BOOL)isEqual:(id)object;
-(NSString *)description;


@end
