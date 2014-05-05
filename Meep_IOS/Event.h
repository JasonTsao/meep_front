//
//  Event.h
//  MeepIOS
//
//  Created by Ryan Sharp on 4/14/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject
@property NSInteger * event_id;
@property NSString * name;
@property NSString * description;
@property NSString * locationName;
@property NSString * locationAddress;
@property NSString * locationCoord;
@property NSString * meetUpSpot;
@property NSString * start_time;

-(id) initWithDescription:(NSString*) evdescription
                 withName:(NSString*) evname
               startTime:(NSString*) evstarttime
                  eventId:(NSInteger)evId;

@end
