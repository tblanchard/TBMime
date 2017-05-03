/* TBLocale.m created by todd on Fri 11-Feb-2000 */

#import "TBLocale.h"
//#import <unicode/uloc.h>
//#import <unicode/ustring.h>
#import "TBCharacterEncoder.h"

static NSDictionary *_availableLocales; // Note that the keys are all lowercase!
static NSArray *_availableLanguages;
static NSArray *_availableCountries;
static NSDictionary *_localeEncoders;

@implementation TBLocale

- (id)copyWithZone:(NSZone *)zone
{
    return [[TBLocale allocWithZone: zone] initWithISOCode: [self isoCode]];
}

+(TBLocale *)localeForLanguageCode: (NSString*) lang countryCode: (NSString *) cntry variant: (NSString *)var
{
    NSString *str = [[lang stringByAppendingString: @"-"] stringByAppendingString: cntry];
    str = [[str stringByAppendingString: @"-"] stringByAppendingString: var];
    return [TBLocale localeForISOCode: str];
}

+(TBLocale *)localeForLanguageCode: (NSString*) lang countryCode: (NSString *) cntry
{
    NSString *str = [[lang stringByAppendingString: @"-"] stringByAppendingString: cntry];
    return [TBLocale localeForName: str];
}

+(TBLocale *)localeForLanguageCode: (NSString*) lang 
{
    return [TBLocale localeForName: lang];
}


+(TBLocale *)localeForName: (NSString *)nm
{
    return [TBLocale localeForISOCode: nm];
}

+(BOOL)isValidISOCode:(NSString *)str
{
    if(!_availableLocales) [self availableLocales];
    return [_availableLocales objectForKey: [[TBLocale isoConformingCodeForString:str] lowercaseString]] != nil;
}

+(NSArray *)availableLocales
{
   if (!_availableLocales)
    {
        int available = uloc_countAvailable();
        int i;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: available];
        _availableLocales = [dict retain];

        for(i = 0; i < available; ++i)
        {
            NSString *nm = [[NSString alloc] initWithCString: uloc_getAvailable(i)];
            NSString *iso = [self isoConformingCodeForString: nm];
            TBLocale *loc = [[TBLocale alloc] initWithISOCode: iso];
            [dict setObject: loc forKey: [iso lowercaseString]];
        }
    }
    return [_availableLocales allValues];
}

+(NSArray *)availableLanguageCodes
{
    if (!_availableLanguages)
    {
        const char* const* a = uloc_getISOLanguages();
        NSMutableArray *arr = [[NSMutableArray array] retain];
        _availableLanguages = arr;
        while(*a)
        {
            const char* code = *a++;
            NSString *lang = [NSString stringWithCString: code];
            [arr addObject: lang];
        }
    }
    return _availableLanguages;
}

+(NSArray *)availableCountryCodes
{
    if (!_availableCountries)
    {
        const char* const* a = uloc_getISOCountries();
        NSMutableArray *arr = [[NSMutableArray array] retain];
        _availableCountries = arr;
        while(*a)
        {
            const char* code = *a++;
            NSString *lang = [NSString stringWithCString: code];
            [arr addObject: lang];
        }
    }
    return _availableCountries;
}


+(TBLocale *)defaultLocale
{
    return [TBLocale localeForISOCode: [NSString stringWithCString:uloc_getDefault()]];
}

+(void)setDefaultLocale:(TBLocale *)locale
{
    int err = 0;
    uloc_setDefault([[locale icuCode] cString], &err);
}

-(NSString *)isoCode
{
    return [TBLocale isoConformingCodeForString: _implementation];
}

-(NSString *)icuCode
{
    return [TBLocale icuConformingCodeForString: _implementation];    
}

+(TBLocale *)localeForISOCode:(NSString *)code
    // Returns an TBLocale object for code, if no such object can be found returns nil.
{
    NSString *standardized;

    if(!_availableLocales) [self availableLocales];

    standardized = [self isoConformingCodeForString: code];
    return [_availableLocales objectForKey: [standardized lowercaseString]];
}

-initWithISOCode:(NSString *)code
{
    [super init];
    _implementation = [[TBLocale icuConformingCodeForString: code] retain];
    return self;
}

-(void)dealloc
{
    [_implementation release];
    [super dealloc];
}

+(NSString *)icuConformingCodeForString:(NSString *)s
{
    NSMutableString *str = [s mutableCopy];
    NSRange range = [str rangeOfString:@"-"];

    while(range.length)
    {
        [str replaceCharactersInRange: range withString: @"_"];
        range = [str rangeOfString:@"-"];
    }
    return str;
}

+(NSString *)isoConformingCodeForString:(NSString *)s
{
    NSMutableString *str = [s mutableCopy];
    NSRange range = [str rangeOfString:@"_"];

    while(range.length)
    {
        [str replaceCharactersInRange: range withString: @"-"];
        range = [str rangeOfString:@"_"];
    }
    return str;
}

-(NSString *)languageCode
{
    int err = 0;
    char buffer[6] = { 0 };
    int len = uloc_getLanguage([[self icuCode] cString],
         buffer,
         5,
         &err);
    if(len > 5) NSLog(@"TBLocale language wants buffer of size %d",len);
    return [NSString stringWithCString: buffer];
}

-(NSString *)countryCode
{
    int err = 0;
    char buffer[6] = { 0 };
    int len = uloc_getCountry([[self icuCode] cString],
         buffer,
         5,
         &err);
    if(len > 5) NSLog(@"TBLocale country wants buffer of size %d",len);
    return [NSString stringWithCString: buffer];
}

-(NSString *)variantCode
{
    int err = 0;
    char buffer[10] = { 0 };
    int len = uloc_getVariant([[self icuCode] cString],
         buffer,
         9,
         &err);
    if(len > 9) NSLog(@"TBLocale variant wants buffer of size %d",len);
    return [NSString stringWithCString: buffer];
}

-(NSString *)name
{
    return [self isoCode];
}

-(NSString *)iso3LanguageCode
{
    return [NSString stringWithCString: uloc_getISO3Language([[self icuCode] cString])];
}

-(NSString *)iso3CountryCode
{
    return [NSString stringWithCString: uloc_getISO3Country([[self icuCode] cString])];
}

-(NSString *)languageNameLocalizedForLocale:(TBLocale *)otherLocale
{
    int err = 0;
    unichar buffer[64] = { 0 };
    int len = uloc_getDisplayLanguage([[self icuCode]cString],
            [[otherLocale icuCode]cString],
            buffer,
            63,
            &err);
    if(len > 63) NSLog(@"TBLocale languageNameLocalizedForLocale wants buffer of size %d",len);
    return [NSString stringWithCharacters: buffer length: u_strlen(buffer)];
}

-(NSString *)countryNameLocalizedForLocale:(TBLocale *)otherLocale
{
    int err = 0;
    unichar buffer[64] = { 0 };
    int len = uloc_getDisplayCountry([[self icuCode]cString],
            [[otherLocale icuCode]cString],
            buffer,
            63,
            &err);
    if(len > 63) NSLog(@"TBLocale countryNameLocalizedForLocale wants buffer of size %d",len);
    return [NSString stringWithCharacters: buffer length: u_strlen(buffer)];
}

-(NSString *)variantNameLocalizedForLocale:(TBLocale *)otherLocale
{
    int err = 0;
    unichar buffer[64] = { 0 };
    int len = uloc_getDisplayVariant([[self icuCode]cString],
            [[otherLocale icuCode]cString],
            buffer,
            63,
            &err);
    if(len > 63) NSLog(@"TBLocale variantNameLocalizedForLocale wants buffer of size %d",len);
    return [NSString stringWithCharacters: buffer length: u_strlen(buffer)];
}

-(NSString *)nameLocalizedForLocale:(TBLocale *)otherLocale
{
    int err = 0;
    unichar buffer[64] = { 0 };
    int len = uloc_getDisplayName([[self icuCode]cString],
            [[otherLocale icuCode]cString],
            buffer,
            63,
            &err);
    if(len > 63) NSLog(@"TBLocale nameLocalizedForLocale wants buffer of size %d",len);
    return [NSString stringWithCharacters: buffer length: u_strlen(buffer)];
}

-(NSString *)localizedLanguageName { return [self languageNameLocalizedForLocale: [TBLocale defaultLocale]]; }
-(NSString *)localizedCountryName { return [self countryNameLocalizedForLocale: [TBLocale defaultLocale]]; }
-(NSString *)localizedVariantName { return [self variantNameLocalizedForLocale: [TBLocale defaultLocale]]; }
-(NSString *)localizedLocaleName { return [self nameLocalizedForLocale: [TBLocale defaultLocale]]; }

-(NSString *)description { return [self isoCode]; }

-(TBCharacterEncoder *)defaultCharacterEncoder
{
    NSString *encodingName = nil;
    if(!_localeEncoders)
    {
        NSBundle *bundle = [NSBundle bundleForClass: [self class]];
        NSString *path = [bundle pathForResource:@"LocaleDefaultEncodings" ofType:@"plist"];
        if(path)
        {
            NSString *fileData = [NSString stringWithContentsOfFile: path];
            _localeEncoders = [[fileData propertyList] retain];
        }
    }
    // try the iso version
    encodingName = [_localeEncoders objectForKey: [self isoCode]];
    // if not found try the ibm version
    if(!encodingName) encodingName = [_localeEncoders objectForKey: [self icuCode]];
    // if not found fall back the locale and return what it finds
    if(!encodingName) return [[self fallbackLocale] defaultCharacterEncoder];
    // otherwise we found one - return an encoder for it
    return [TBCharacterEncoder encoderForName: encodingName];
}

-(TBLocale *)fallbackLocale
{
    if([[self variantCode] length])
        return [TBLocale localeForLanguageCode: [self languageCode] countryCode: [self countryCode]];
    if([[self countryCode] length])
        return [TBLocale localeForLanguageCode: [self languageCode]];
    return [TBLocale localeForLanguageCode: @"en"];
}

- (BOOL)isEqual:(id)object
{
    if([object class] == [self class])
    {
        return [[object isoCode] isEqualToString: [self isoCode]];
    }
    return NO;
}


@end
