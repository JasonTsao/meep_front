//
//  Search.m
//  Meep_IOS
//
//  Created by Ryan Sharp on 6/8/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "Search.h"

@implementation Search

+ (BOOL) string:(NSString *)string
      hasPrefix:(NSString *)prefix
caseInsensitive:(BOOL)caseInsensitive {
    
    if (!caseInsensitive)
        return [string hasPrefix:prefix];
    
    const NSStringCompareOptions options = NSAnchoredSearch|NSCaseInsensitiveSearch;
    NSRange prefixRange = [string rangeOfString:prefix
                                        options:options];
    return prefixRange.location == 0 && prefixRange.length > 0;
}


@end
