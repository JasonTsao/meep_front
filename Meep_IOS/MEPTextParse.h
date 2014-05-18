//
//  MEPTextParse.h
//  Meep_IOS
//
//  Created by Ryan Sharp on 5/1/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEPTextParse : NSObject
-(NSDictionary*)parseText:(NSString*)text;
+(NSString*)identifyCategory:(NSString*)text;
+(NSString*)getTimeUntilDateTime:(NSDate*)date;
@end
