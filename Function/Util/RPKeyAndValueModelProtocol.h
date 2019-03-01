//
//  RPKeyAndValueModelProtocol.h
//  rework-password
//
//  Created by 张超 on 2019/1/14.
//  Copyright © 2019 orzer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//@protocol MVPModelProtocol;
@protocol RPKeyAndValueModelProtocol <NSObject>

@property (nonatomic, readonly) id entityKey;
@property (nonatomic, readonly) id entityValue;
@property (nonatomic, readonly) id entityType;
@property (nonatomic, readonly) id entityUUID;

@end

NS_ASSUME_NONNULL_END
