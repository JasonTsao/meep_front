//
//  Notification.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/25/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject<NSCoding>{
    NSInteger notification_id;
    NSInteger event_id;
    NSInteger group_id;
    NSString *message;
    NSString *type;
    NSString *time_stamp;
    NSDictionary *custom_payload;
}
@property (nonatomic) NSInteger notification_id;
@property (nonatomic) NSInteger event_id;
@property (nonatomic) NSInteger group_id;
@property (nonatomic) NSString *message;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *time_stamp;
@property (nonatomic) NSDictionary *custom_payload;
@end
