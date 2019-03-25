// To parse this JSON:
//
//   NSError *error;
//   RRModelItem *modelItem = [RRModelItem fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>
@import mvc_base;
@class RRModelItem;
@class RRSetting;

typedef enum : NSUInteger {
    RRSettingTypeBase = 0,
    RRSettingTypeOnlyTitle,
    RRSettingTypeTitle,
    RRSettingTypeSwitch,
    RRSettingTypeSubSetting,
    RRSettingTypeDymaticValue,
} RRSettingType;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Top-level marshaling functions

RRModelItem *_Nullable RRModelItemFromData(NSData *data, NSError **error);
RRModelItem *_Nullable RRModelItemFromJSON(NSString *json, NSStringEncoding encoding, NSError **error);
NSData      *_Nullable RRModelItemToData(RRModelItem *modelItem, NSError **error);
NSString    *_Nullable RRModelItemToJSON(RRModelItem *modelItem, NSStringEncoding encoding, NSError **error);

#pragma mark - Object interfaces

@interface RRModelItem : MVPModel
@property (nonatomic, nullable, copy) NSArray<RRSetting *> *setting;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
@end

@interface RRSetting : MVPModel
@property (nonatomic, nullable, copy)   NSString *title;
@property (nonatomic, nullable, copy)   NSString *value;
@property (nonatomic, nullable, copy)   NSString *action;
@property (nonatomic, nullable, copy)   id switchkey;
@property (nonatomic, nullable, copy)   id select;
@property (nonatomic, nullable, strong) NSNumber *type;
@property (nonatomic, nullable, strong) NSNumber *switchValue;

@end

NS_ASSUME_NONNULL_END
