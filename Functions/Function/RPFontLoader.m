
//
//  RPFontLoader.m
//  rework-reader
//
//  Created by 张超 on 2019/2/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RPFontLoader.h"
@import CoreText;
@implementation RPFontLoader

+ (BOOL)registerFontsAtPath:(NSString *)fontFilePath
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:fontFilePath] == YES)
    {
        [UIFont familyNames];//This is here for a bug where font registration API hangs for forever.
        
        //In case of TTF file update : Fonts are already registered, first de-register them from Font Manager
        CFErrorRef cfDe_RegisterError;
        CTFontManagerUnregisterFontsForURL((__bridge CFURLRef)[NSURL fileURLWithPath:fontFilePath], kCTFontManagerScopeNone, &cfDe_RegisterError);
        
        
        //finally register the fonts with Font Manager,
        CFErrorRef cfRegisterError;
        bool fontsRegistered = CTFontManagerRegisterFontsForURL((__bridge CFURLRef)[NSURL fileURLWithPath:fontFilePath], kCTFontManagerScopeNone, &cfRegisterError);
        
        return fontsRegistered;
    }
    return NO;
}

+ (void)testShowAllFonts
{
    [[UIFont familyNames] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //NSLog(@"[family] %@ ----",obj);
        NSArray* a = [UIFont fontNamesForFamilyName:obj];
        //NSLog(@"%@",a);
    }];
}

+ (NSNumber*)fontSizeWithTextStyle:(UIFontTextStyle)style
{
    UIFont *font = [UIFont preferredFontForTextStyle:style];
    UIFontDescriptor *ctFont = font.fontDescriptor;
    NSNumber *fontString = [ctFont objectForKey:@"NSFontSizeAttribute"];
    return fontString;
}

@end
