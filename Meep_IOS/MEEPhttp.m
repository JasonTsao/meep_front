//
//  MEEPhttp.m
//  Meep
//
//  Created by Ryan Sharp on 4/12/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "MEEPhttp.h"

@implementation MEEPhttp

+(NSMutableURLRequest*) makePOSTRequestWithString:(NSString*) urlString
                                   postDictionary:(NSDictionary*) postDict {
    NSString * boundary = @"0xKhTmLbOuNdArY";
    NSString * kNewLine = @"\r\n";
    
    NSMutableData * body = [NSMutableData data];
    for(NSString * key in postDict.allKeys) {
        NSData * value = [[NSData alloc] init];
        if([postDict[key] isKindOfClass:[NSString class]]) {
            value = [[NSString stringWithFormat:@"%@",postDict[key]] dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if ([postDict[key] isKindOfClass:[NSMutableArray class]]){
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postDict[key]
                                                               options:0
                                                                 error:&error];
            
            if (!jsonData) {
                NSLog(@"No json mutable array data: %@", error);
            } else {
                
                NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
                value = [[NSString stringWithFormat:@"%@",JSONString] dataUsingEncoding:NSUTF8StringEncoding];
            }
        }
        else{
            value = [[NSString stringWithFormat:@"%@",postDict[key]] dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"Error: no member postdict key: %@",postDict[key]);
        }
        [body appendData:[[NSString stringWithFormat:@"--%@%@", boundary, kNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", key] dataUsingEncoding:NSUTF8StringEncoding]];
        // For simple data types, such as text or numbers, there's no need to set the content type
        [body appendData:[[NSString stringWithFormat:@"%@%@", kNewLine, kNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:value];
        [body appendData:[kNewLine dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"multipart/form-data; boundary=0xKhTmLbOuNdArY" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:body];
    return request;
}

+(NSString*) applicationURL {
    return @"http://50.112.180.63:8000/";
}

+(NSString*) eventURL {
    return [NSString stringWithFormat:@"%@%@/",[self applicationURL],@"events"];
}

+(NSString*) accountURL {
    return [NSString stringWithFormat:@"%@%@/",[self applicationURL],@"acct"];
}

+(NSString*) iosNotificationsURL {
    return [NSString stringWithFormat:@"%@%@/",[self applicationURL],@"ios-notifications"];
}

+(NSString*) notificationsURL {
    return [NSString stringWithFormat:@"%@%@/",[self applicationURL],@"notifications"];
}



@end
