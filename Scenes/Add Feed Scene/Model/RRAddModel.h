//
//  RRAddModel.h
//  rework-reader
//
//  Created by 张超 on 2019/2/16.
//  Copyright © 2019 orzer. All rights reserved.
//

@import mvc_base;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    RRAddModelTypeInput,
    RRAddModelTypeSwitch,
    RRAddModelTypeInfo,
    RRAddModelTypeBtn,
    RRAddModelTypeTitle,
} RRAddModelType;

typedef enum : NSUInteger {
    RRAddModelInputTypeText,
    RRAddModelInputTypeURL,
    RRAddModelInputTypePasscode,
    RRAddModelInputTypeNumber,
} RRAddModelInputType;

@interface RRAddModel : MVPModel

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSString* key;
@property (nonatomic, assign) RRAddModelType type;
@property (nonatomic, strong) id switchValue;
@property (nonatomic, strong) NSString* placeholder;
@property (nonatomic, assign) RRAddModelInputType inputType;

@property (nonatomic, readonly, class) RRAddModel* (^model)(NSString* title,id value,NSString* key,RRAddModelType type);


@end

NS_ASSUME_NONNULL_END
