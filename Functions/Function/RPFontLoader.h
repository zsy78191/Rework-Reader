//
//  RPFontLoader.h
//  rework-reader
//
//  Created by 张超 on 2019/2/11.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPFontLoader : NSObject

+ (BOOL)registerFontsAtPath:(NSString *)fontFilePath;
+ (void)testShowAllFonts;
+ (NSNumber*)fontSizeWithTextStyle:(UIFontTextStyle)style;

@end

NS_ASSUME_NONNULL_END
