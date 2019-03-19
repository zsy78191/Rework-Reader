//
//  ClassyKitLoader.h
//  rework-reader
//
//  Created by 张超 on 2019/1/26.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClassyKitLoader : NSObject

+ (void)cleanStyleFiles;

+ (void)copyStyleFile;

+ (void)loadWithStyle:(NSString*)style variables:(NSString*)variablesFileName;

+ (NSDictionary*)values;

+ (void)needReload;

@end

NS_ASSUME_NONNULL_END
