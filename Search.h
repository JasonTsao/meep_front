//
//  Search.h
//  Meep_IOS
//
//  Created by Ryan Sharp on 6/8/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Search : NSObject
+ (BOOL) string:(NSString *)string
      hasPrefix:(NSString *)prefix
caseInsensitive:(BOOL)caseInsensitive;

@end
