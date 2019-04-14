#import "RRModelItem.h"

// Shorthand for simple blocks
#define λ(decl, expr) (^(decl) { return (expr); })

// nil → NSNull conversion for JSON dictionaries
static id NSNullify(id _Nullable x) {
    return (x == nil || x == NSNull.null) ? NSNull.null : x;
}

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces

@interface RRModelItem (JSONConversion)


+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface RRSetting (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

static id map(id collection, id (^f)(id value)) {
    id result = nil;
    if ([collection isKindOfClass:NSArray.class]) {
        result = [NSMutableArray arrayWithCapacity:[collection count]];
        for (id x in collection) [result addObject:f(x)];
    } else if ([collection isKindOfClass:NSDictionary.class]) {
        result = [NSMutableDictionary dictionaryWithCapacity:[collection count]];
        for (id key in collection) [result setObject:f([collection objectForKey:key]) forKey:key];
    }
    return result;
}

#pragma mark - JSON serialization

RRModelItem *_Nullable RRModelItemFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : [RRModelItem fromJSONDictionary:json];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

RRModelItem *_Nullable RRModelItemFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    return RRModelItemFromData([json dataUsingEncoding:encoding], error);
}

NSData *_Nullable RRModelItemToData(RRModelItem *modelItem, NSError **error)
{
    @try {
        id json = [modelItem JSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSString *_Nullable RRModelItemToJSON(RRModelItem *modelItem, NSStringEncoding encoding, NSError **error)
{
    NSData *data = RRModelItemToData(modelItem, error);
    return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
}

@implementation RRModelItem


- (id)copyWithZone:(nullable NSZone *)zone;
{
    return [[RRModelItem allocWithZone:zone] initWithJSONDictionary:self.JSONDictionary];
}


+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
                                                    @"setting": @"setting",
                                                    };
}

+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error
{
    return RRModelItemFromData(data, error);
}

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    return RRModelItemFromJSON(json, encoding, error);
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[RRModelItem alloc] initWithJSONDictionary:dict] : nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        _setting = map(_setting, λ(id x, [RRSetting fromJSONDictionary:x]));
    }
    return self;
}

- (NSDictionary *)JSONDictionary
{
    id dict = [[self dictionaryWithValuesForKeys:RRModelItem.properties.allValues] mutableCopy];
    
    // Map values that need translation
    [dict addEntriesFromDictionary:@{
                                     @"setting": NSNullify(map(_setting, λ(id x, [x JSONDictionary]))),
                                     }];
    
    return dict;
}

- (NSData *_Nullable)toData:(NSError *_Nullable *)error
{
    return RRModelItemToData(self, error);
}

- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    return RRModelItemToJSON(self, encoding, error);
}
@end

@implementation RRSetting



- (id)copyWithZone:(nullable NSZone *)zone;
{
    return [[RRSetting allocWithZone:zone] initWithJSONDictionary:self.JSONDictionary];
}

+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
                                                    @"title": @"title",
                                                    @"value": @"value",
                                                    @"action": @"action",
                                                    @"switchkey": @"switchkey",
                                                    @"select": @"select",
                                                    @"type": @"type",
                                                    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[RRSetting alloc] initWithJSONDictionary:dict] : nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (NSDictionary *)JSONDictionary
{
    return [self dictionaryWithValuesForKeys:RRSetting.properties.allValues];
}

- (NSString *)icon
{
    return self.value;
}

- (NSString *)fontStyle
{
    return nil;
}

- (NSString*)subtitle
{
    return nil;
}
@end

NS_ASSUME_NONNULL_END
