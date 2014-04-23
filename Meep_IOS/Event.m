//
//  Event.m
//  MeepIOS
//
//  Created by Ryan Sharp on 4/14/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "Event.h"

@implementation Event

-(id) initWithDescription:(NSString*) evdescription
                 withName:(NSString*) evname
                startTime:(NSString*) evstarttime {
    if((self = [super init])) {
        _name = evname;
        _description = evdescription;
        _start_time = evstarttime;
    }
    return self;
}

@end