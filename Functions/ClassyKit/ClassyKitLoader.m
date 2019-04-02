//
//  ClassyKitLoader.m
//  rework-reader
//
//  Created by 张超 on 2019/1/26.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "ClassyKitLoader.h"
@import Classy;
@import ui_base;
@import oc_string;
#import "RRReadMode.h"
#import "RPFontLoader.h"

@implementation ClassyKitLoader

+ (void)cleanStyleFiles
{
    NSURL* u = UIApplication.sharedApplication.doucumentDictionary();
    NSError* e;
    NSArray* all = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[u path] error:&e];
    if (e) {
        DDLogError(@"%@",e);
    }
    else {
        [all.filter(^BOOL(id  _Nonnull x) {
            return [x hasSuffix:@"cas"];
        }) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            //NSLog(@"%@",obj);
            BOOL x = [[NSFileManager defaultManager] removeItemAtURL:[u URLByAppendingPathComponent:obj] error:nil];
            if (x) {
                DDLogVerbose(@"删除成功%@",obj);
            }
            else {
                DDLogWarn(@"删除失败%@",obj);
            }
        }];
    }
}

+ (void)copyStyleFile
{
    NSArray* a = [[NSBundle mainBundle] pathsForResourcesOfType:@"cas" inDirectory:nil];
    [a enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL* u = [UIApplication.sharedApplication.doucumentDictionary() URLByAppendingPathComponent:[obj lastPathComponent]];
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[u path]];
        if (!exist) {
            NSError* e;
            [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:obj] toURL:u error:&e];
            if (e) {
                DDLogError(@"%@",e);
            }
            else {
                DDLogVerbose(@"拷贝Cas文件成功");
            }
        }
    }];
}

+ (void)loadWithStyle:(NSString*)style variables:(NSString*)variablesFileName;
{
    NSURL* u = [UIApplication.sharedApplication.doucumentDictionary() URLByAppendingPathComponent:[style stringByAppendingString:@".cas"]];
    
    NSString* mainColorKey = @"mainTintColor";
    RRReadMode mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"kRRReadMode"];
    if (mode == RRReadModeDark) {
        mainColorKey = @"mainTintColorDark";
    }
 
    NSString* mainTintColor = [[NSUserDefaults standardUserDefaults] valueForKey:mainColorKey];
    NSString* mainFont = [[NSUserDefaults standardUserDefaults] stringForKey:@"mainFont"];
    
    NSMutableDictionary* styleVariables = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:variablesFileName ofType:@"plist"]];
    
    if (mainTintColor) {
        [styleVariables setObject:mainTintColor forKey:@"$main-tint-color"];
    }
    if (mainFont) {
        [styleVariables setObject:mainFont forKey:@"$main-font"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:styleVariables forKey:@"style"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

    if(1){
        [styleVariables setValue:[RPFontLoader fontSizeWithTextStyle:UIFontTextStyleLargeTitle] forKey:@"$large-title-font-size"];
        
        NSNumber* n = [RPFontLoader fontSizeWithTextStyle:UIFontTextStyleHeadline];
        [styleVariables setValue:n forKey:@"$main-font-size"];
        
        [styleVariables setValue:[RPFontLoader fontSizeWithTextStyle:UIFontTextStyleSubheadline] forKey:@"$sub-font-size"];
    }
    
    DDLogInfo(@"%@",styleVariables);
    
    [[CASStyler defaultStyler] setVariables:styleVariables];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         [CASStyler bootstrapClassyWithTargetWindows:UIApplication.sharedApplication.windows];
    });
    [[CASStyler defaultStyler] setTargetWindows:UIApplication.sharedApplication.windows];
//    [CASStyler defaultStyler].filePath = [[NSBundle mainBundle] pathForResource:[style stringByAppendingString:@".cas"] ofType:nil];
   
#if TARGET_IPHONE_SIMULATOR
    NSString *absoluteFilePath = CASAbsoluteFilePath([@"../ClassyKit/" stringByAppendingString:[style stringByAppendingString:@".cas"]]);
    [CASStyler defaultStyler].watchFilePath = absoluteFilePath;
#else
    [CASStyler defaultStyler].filePath = u.path;
//    [CASStyler defaultStyler].watchFilePath = u.path;
    
//    NSLog(@"%@",[CASStyler defaultStyler].targetWindows);
#endif
}

+ (NSDictionary *)values
{
    return [CASStyler defaultStyler].variables;
}


/**
 修改参数，重新加载样式

 @param style 样式名称
 */
+ (void)test:(NSString*)style
{
    NSURL* u = [UIApplication.sharedApplication.doucumentDictionary() URLByAppendingPathComponent:[style stringByAppendingString:@".cas"]];
    
    NSDictionary* styleVariables = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"style2" ofType:@"plist"]];
    [[CASStyler defaultStyler] setVariables:styleVariables];
    [CASStyler defaultStyler].watchFilePath = u.path;
}


+ (void)needReload
{
        [[CASStyler defaultStyler] setTargetWindows:UIApplication.sharedApplication.windows];
//    [CASStyler]
//    [[UIApplication.sharedApplication keyWindow].rootViewController cas_updateStyling];
//    [[UIApplication.sharedApplication keyWindow].rootViewController cas_setNeedsUpdateStyling];
//    [[UIApplication.sharedApplication keyWindow].rootViewController cas_updateStylingIfNeeded];
    [[CASStyler defaultStyler].targetWindows enumerateObjectsUsingBlock:^(UIWindow*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.rootViewController cas_updateStyling];
    }];
}

@end
