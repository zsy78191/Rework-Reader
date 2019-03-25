//
//  RRImageRender.m
//  rework-reader
//
//  Created by 张超 on 2019/3/18.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "RRImageRender.h"

@interface RRImageRender ()
{
    
}
@property (nonatomic, strong) NSMutableDictionary* filters;
@end

@implementation RRImageRender

+ (instancetype)sharedRender
{
    static RRImageRender * _g_shared_image_render_rr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _g_shared_image_render_rr = [[RRImageRender alloc] init];
    });
    return _g_shared_image_render_rr;
}

- (NSMutableDictionary *)filters
{
    if (!_filters) {
        _filters = [[NSMutableDictionary alloc] init];
    }
    return _filters;
}

- (void)preloadFilters
{
    [self addFiltersWithName:@"CIColorControls" kv:@{@"inputSaturation":@(0.0)}];
}

- (void)addFiltersWithName:(NSString*)name kv:(NSDictionary*)kv;
{
    CIFilter* filter = [CIFilter filterWithName:name withInputParameters:kv];
    [self.filters setObject:filter forKey:name];
}

- (UIImage *)imageApplyFilters:(UIImage *)origin
{
    __block UIImage* temp = origin;
    [[self.filters allValues] enumerateObjectsUsingBlock:^(CIFilter*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CIImage* ci = [[CIImage alloc] initWithImage:temp];
        [obj setValue:ci forKey:kCIInputImageKey];
        temp = [UIImage imageWithCIImage:obj.outputImage];
    }];
    return temp;
}


@end
