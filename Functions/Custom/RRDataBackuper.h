//
//  RRDataBackuper.h
//  rework-reader
//
//  Created by 张超 on 2019/3/21.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RRDataBackuper : NSObject


- (NSURL*)iCloudURL;
- (NSArray*)showiCloudFiles;
- (void)recoverFromiCloud:(void (^)(BOOL))finish;
- (void)backupToiCloud:(void (^)(BOOL))finish;
- (void)downloadFromiCloud:(void (^)(BOOL))finish;

- (NSURL*)localURL;
- (BOOL)ensureFileDownloaded;

@end

NS_ASSUME_NONNULL_END
