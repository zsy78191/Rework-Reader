//
//  FMFeedParserOperation+ext.h
//  Fork-MWFeedParser
//
//  Created by 张超 on 2019/1/15.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "FMFeedParserOperation.h"
#import "FMParser.h"

NS_ASSUME_NONNULL_BEGIN

@interface FMFeedParserOperation () <MWFeedParserDelegate>
{
    
}
@property (nonatomic, strong) FMParser* parser;


@end

NS_ASSUME_NONNULL_END
