//
//  Event.m
//  MeepIOS
//
//  Created by Ryan Sharp on 4/14/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "Event.h"

@implementation Event

@synthesize event_id;
@synthesize name;
@synthesize description;
@synthesize locationName;
@synthesize locationAddress;
@synthesize locationLatitude;
@synthesize locationLongitude;
@synthesize meetUpSpot;
@synthesize start_time;
@synthesize end_time;
@synthesize yelpLink;
@synthesize uberLink;
@synthesize yelpImageLink;
@synthesize eventGroup;
@synthesize createdUTC;

-(id) initWithDescription:(NSString*) evdescription
                 withName:(NSString*) evname
                startTime:(NSString*) evstarttime
                  eventId:(NSInteger)evId{
    if((self = [super init])) {
        event_id = evId;
        name = evname;
        description = evdescription;
        start_time = evstarttime;
        /*
        _event_id = evId;
        _name = evname;
        _description = evdescription;
        _start_time = evstarttime;*/
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.event_id = [decoder decodeIntegerForKey:@"event_id"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.description = [decoder decodeObjectForKey:@"description"];
        self.locationName = [decoder decodeObjectForKey:@"locationName"];
        self.locationAddress = [decoder decodeObjectForKey:@"locationAddress"];
        self.meetUpSpot = [decoder decodeObjectForKey:@"meetUpSpot"];
        self.start_time = [decoder decodeObjectForKey:@"start_time"];
        self.end_time = [decoder decodeObjectForKey:@"end_time"];
        self.yelpLink = [decoder decodeObjectForKey:@"yelpLink"];
        self.uberLink = [decoder decodeObjectForKey:@"uberLink"];
        self.yelpImageLink = [decoder decodeObjectForKey:@"yelpImageLink"];
        
        self.eventGroup = [decoder decodeObjectForKey:@"eventGroup"];
        self.createdUTC = [decoder decodeDoubleForKey:@"createdUTC"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:event_id forKey:@"event_id"];

    [encoder encodeObject: name forKey:@"name"];
    [encoder encodeObject: description forKey:@"description"];
    [encoder encodeObject: locationName forKey:@"locationName"];
    [encoder encodeObject: locationAddress forKey:@"locationAddress"];
    [encoder encodeObject: meetUpSpot forKey:@"meetUpSpot"];
    [encoder encodeObject: start_time forKey:@"start_time"];
    [encoder encodeObject: end_time forKey:@"end_time"];
    [encoder encodeObject: yelpLink forKey:@"yelpLink"];
    [encoder encodeObject: uberLink forKey:@"uberLink"];
    [encoder encodeObject: yelpImageLink forKey:@"yelpImageLink"];
    [encoder encodeObject: eventGroup forKey:@"eventGroup"];
    [encoder encodeDouble: createdUTC forKey:@"createdUTC"];
}
@end
