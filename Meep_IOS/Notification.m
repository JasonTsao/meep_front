//
//  Notification.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/25/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "Notification.h"

@implementation Notification

@synthesize notification_id;
@synthesize event_id;
@synthesize group_id;
@synthesize message;
@synthesize type;
@synthesize time_stamp;



- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.time_stamp = [decoder decodeObjectForKey:time_stamp];
        self.type = [decoder decodeObjectForKey:@"type"];
        self.message = [decoder decodeObjectForKey:@"message"];
        self.notification_id = [decoder decodeIntegerForKey:@"notification_id"];
        self.event_id = [decoder decodeIntegerForKey:@"event_id"];
        self.group_id = [decoder decodeIntegerForKey:@"group_id"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:notification_id forKey:@"notification_id"];
    [encoder encodeInteger:event_id forKey:@"event_id"];
    [encoder encodeInteger:group_id forKey:@"group_id"];
    [encoder encodeObject: time_stamp forKey:@"time_stamp"];
    [encoder encodeObject: type forKey:@"type"];
    [encoder encodeObject: message forKey:@"message"];
}
@end
