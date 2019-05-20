//
//  RRCanEditProtocol.h
//  rework-reader
//
//  Created by 张超 on 2019/2/28.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    RRCEEditTypeDefault,
    RRCEEditTypeInsert,
    RRCEEditTypeDelete,
 
} RRCEEditType;

@protocol RRCanEditProtocol <NSObject>
 
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, assign) BOOL canMove;
@property (nonatomic, assign) NSInteger idx;
@property (nonatomic, assign) RRCEEditType editType;

@end

NS_ASSUME_NONNULL_END
