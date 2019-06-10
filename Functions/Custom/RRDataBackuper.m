//
//  RRDataBackuper.m
//  rework-reader
//
//  Created by 张超 on 2019/3/21.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRDataBackuper.h"
@import ui_base;
@import MagicalRecord;

@implementation RRDataBackuper

- (NSURL*)iCloudURL
{
    NSString* s = [NSString stringWithFormat:@"iCloud.%@",[UIApplication sharedApplication].bundleID()];
//    NSLog(@"%s %@",__func__,s);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    return [[filemgr URLForUbiquityContainerIdentifier:s] URLByAppendingPathComponent:@"Documents"];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURL* u = [self iCloudURL];
        if (u) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:[u path]]) {
                NSError* e;
                [[NSFileManager defaultManager] createDirectoryAtURL:u withIntermediateDirectories:YES attributes:nil error:&e];
                if (e) {
                    NSLog(@"%s %@",__func__,e);
                }
            }
        }
    }
    return self;
}

- (NSArray*)showiCloudFiles
{
    NSURL* icloud_url = [self iCloudURL];
    NSArray* b = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[icloud_url path] error:nil];
    [b enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"%@",obj);
    }];
    return b;
}

- (BOOL)ensureFileDownloaded
{
    NSURL* icloud_url = [self iCloudURL];
    NSArray* a = [self showiCloudFiles];
    __block BOOL result = YES;
    [a enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSError* e;
        result = result &&  [[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:[icloud_url URLByAppendingPathComponent:obj] error:&e];
        if (e) {
            NSLog(@"%@",e);
        }
    }];
    return result;
}

- (void)recoverFromiCloud:(void (^)(BOOL))finish
{
    [self recoverFromiCloud:finish time:0];
}

- (void)recoverFromiCloud:(void (^)(BOOL))finish time:(NSUInteger)time
{
    NSURL* icloud_url = [self iCloudURL];
    if (icloud_url) {
        NSURL* local_url = [[NSPersistentStore MR_defaultPersistentStore] URL];
        __block BOOL ss = YES;
        if (local_url) {
            if (time == 0) {
                [MagicalRecord cleanUp];
            }
            
            NSString* database_path = [[local_url path] stringByDeletingLastPathComponent];
            NSArray* b = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:database_path error:nil];
            [b enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSURL* url1 = [NSURL fileURLWithPath:[database_path stringByAppendingPathComponent:obj]];
                NSURL* url2 = [icloud_url URLByAppendingPathComponent:obj];
//                NSURL* url1b = [url1 URLByAppendingPathExtension:@"bak"];
                NSError* error;
                if ([[NSFileManager defaultManager] fileExistsAtPath:[url1 path]]) {
                    NSError* del_error;
                    [[NSFileManager defaultManager] removeItemAtURL:url1 error:&del_error];
//                    [[NSFileManager defaultManager] removeItemAtURL:url1b error:nil];
//                    [[NSFileManager defaultManager] moveItemAtURL:url1 toURL:url1b error:&del_error];
                    if (del_error) {
                        NSLog(@"备份失败");
                    }
                }
                BOOL copy = [[NSFileManager defaultManager] copyItemAtURL:url2 toURL:url1 error:&error];
                ss = ss && copy;
                if (!copy) {
                    [[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:url2 error:nil];
//                    NSLog(@"失败2");
//                    [[NSFileManager defaultManager] removeItemAtURL:url1 error:nil];
//                    BOOL recover = [[NSFileManager defaultManager] moveItemAtURL:url1b toURL:url1 error:nil];
//                    NSLog(@"恢复 %@",@(recover));
                }
                else
                {
                }
            }];
            
            [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Model"];
            if (finish) {
                finish(ss);
            }
            return;
        }
    }
    if (finish) {
        finish(NO);
    }
}


- (void)backupToiCloud:(void (^)(BOOL))finish
{
    NSURL* icloud_url = [self iCloudURL];
    if (icloud_url) {
        NSURL* local_url = [[NSPersistentStore MR_defaultPersistentStore] URL];
        if (local_url) {
            NSString* database_path = [[local_url path] stringByDeletingLastPathComponent];
            NSArray* b = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:database_path error:nil];
            NSArray* array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[icloud_url path] error:nil];
            __block NSDate* lastDate = [NSDate dateWithTimeIntervalSince1970:0];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary* d = [[NSFileManager defaultManager] attributesOfItemAtPath:[[icloud_url URLByAppendingPathComponent:obj] path] error:nil];
                if ([lastDate timeIntervalSinceDate:[d fileModificationDate]] < 0) {
                    lastDate = [d fileModificationDate];
                }
            }];
            
            __block BOOL s = YES;
            [b enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                NSURL* url1 = [NSURL fileURLWithPath:[database_path stringByAppendingPathComponent:obj]];
                NSURL* url2 = [icloud_url URLByAppendingPathComponent:obj];
                NSError* error;
                if ([[NSFileManager defaultManager] fileExistsAtPath:[url2 path]]) {
                    NSError* del_error;
                    [[NSFileManager defaultManager] removeItemAtURL:url2 error:&del_error];
//                    [[NSFileManager defaultManager] moveItemAtURL:url2 toURL:[url2 URLByAppendingPathExtension:@"bak"] error:&del_error];
                    if (del_error) {
                        NSLog(@"备份失败");
                    }
                }
                BOOL copy = [[NSFileManager defaultManager] copyItemAtURL:url1 toURL:url2 error:&error];
                s = s && copy;
                if (copy) {
                    NSLog(@"COPY {%@} TO {%@}",url1,url2);
                }
                else
                {
                    NSError* del_error;
//                    [[NSFileManager defaultManager] moveItemAtURL:[url2 URLByAppendingPathExtension:@"bak"] toURL:url2 error:&del_error];
                    if (del_error) {
                        NSLog(@"恢复失败");
                    }
                }
            }];
            
            if (finish) {
                finish(s);
            }
        }
    }
}


- (BOOL)checkFileExistFromiCloud
{
    NSFileManager *filemgr = [NSFileManager defaultManager];
//    NSError* error = nil;
    NSURL* url = [self iCloudURL];
    if (![filemgr fileExistsAtPath:[url path]]) {
        return NO;
    }
    NSString* database_path = [url path];
    NSArray* b = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:database_path error:nil];
    __block BOOL _needDownload = NO;
    [b enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSString* fp = [database_path stringByAppendingPathComponent:obj];
        _needDownload = _needDownload || [[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:[url URLByAppendingPathComponent:obj] error:nil];
        
    }];
    if (b.count < 3) {
        return NO;
    }
    return YES;
}

- (void)downloadFromiCloud:(void (^)(BOOL))finish
{
    @try {
        NSFileManager *filemgr = [NSFileManager defaultManager];
        NSError* error = nil;
        NSURL* url = [self iCloudURL];
        if (!url) {
            if (finish) {
                finish(NO);
            }
            return;
        }
        BOOL hasDic = NO;
        if (![filemgr fileExistsAtPath:[url path]]) {
            hasDic = [filemgr createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
        }
        else{
            hasDic = YES;
        }
        if (url && hasDic) {
            NSError*e2;
            [filemgr evictUbiquitousItemAtURL:url error:&e2];
            if (e2) {
                NSLog(@"%@",e2);
            }
            BOOL s =  [filemgr startDownloadingUbiquitousItemAtURL:url error:&error];
            if (error) {
                NSLog(@"startDownloadingiCloud error %@",error);
            }
            else
            {
                NSLog(@"startDownloadingiCloud %@",@(s));
            }
            if (finish) {
                finish(s);
            }
        }
    } @catch (NSException *exception) {
        if (finish) {
            finish(NO);
        }
    } @finally {
       
    }
}

- (NSURL*)localURL
{
    return [[NSPersistentStore MR_defaultLocalStoreUrl] URLByDeletingLastPathComponent];
}


@end
