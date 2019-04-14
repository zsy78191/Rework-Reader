//
//  RRReadMode.h
//  rework-reader
//
//  Created by 张超 on 2019/3/19.
//  Copyright © 2019 orzer. All rights reserved.
//

#ifndef RRReadMode_h
#define RRReadMode_h

typedef enum : NSUInteger {
    RRReadModeLight,
    RRReadModeDark,
} RRReadMode;

typedef enum : NSUInteger {
    RRReadLightSubModeDefalut,
    RRReadLightSubModeMice,
    RRReadLightSubModeSafariMice,
} RRReadLightSubMode;

typedef enum : NSUInteger {
    RRReadDarkSubModeDefalut,
    RRReadDarkSubModeGray
} RRReadDarkSubMode;

#endif /* RRReadMode_h */
