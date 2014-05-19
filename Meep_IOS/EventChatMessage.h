//
//  EventChatMessage.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/17/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"

@interface EventChatMessage : NSObject
@property NSInteger * event_id;
@property NSInteger * creator_id;
@property NSString * creator_name;
@property NSString * message;
@property NSString * locationName;
@property NSString * locationAddress;
@property NSString * locationLatitude;
@property NSString * locationLongitude;
@property NSString * time_stamp;
@property BOOL * new_message;
@property Group * eventGroup;
@end
