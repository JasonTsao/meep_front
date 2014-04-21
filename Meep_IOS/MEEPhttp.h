//
//  MEEPhttp.h
//  Meep
//
//  Created by Ryan Sharp on 4/12/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEEPhttp : NSObject
+(NSString*) applicationURL;
+(NSString*) accountURL;
+(NSString*) eventURL;
+(NSMutableURLRequest*) makePOSTRequestWithString:(NSString*) urlString
                                   postDictionary:(NSDictionary*) postDict;

@end
