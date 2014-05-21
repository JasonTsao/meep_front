//
//  jsonParser.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/21/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "jsonParser.h"
#import "Friend.h"
#import "InvitedFriend.h"
#import "Event.h"
#import "Group.h"

@implementation jsonParser
+(NSArray*)friendsArray:(NSArray*)friends
{
    NSError* error;
    NSMutableArray *friends_list = [[NSMutableArray alloc] init];
    for( int i = 0; i< [friends count]; i++){
        Friend *new_friend = [[Friend alloc]init];
        
        NSDictionary * new_friend_dict = [NSJSONSerialization JSONObjectWithData: [friends[i] dataUsingEncoding:NSUTF8StringEncoding]
                                                                         options: NSJSONReadingMutableContainers
                                                                           error: &error];
        
        
        new_friend.name = new_friend_dict[@"name"];
        new_friend.numTimesInvitedByMe = new_friend_dict[@"invited_count"];
        new_friend.phoneNumber= new_friend_dict[@"phone_number"];
        new_friend.imageFileName = new_friend_dict[@"pf_pic"];
        new_friend.bio = new_friend_dict[@"bio"];
        new_friend.account_id = [new_friend_dict[@"account_id"] intValue];
        
        if ([new_friend_dict[@"pf_pic"] length] == 0){
            UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
            img.image = [UIImage imageNamed:@"ManSilhouette"];
            new_friend.profilePic = img.image;
        }
        else{
            NSURL *url = [[NSURL alloc] initWithString:new_friend_dict[@"fb_pfpic_url"]];
            //NSURL *url = [[NSURL alloc] initWithString:@"https://graph.facebook.com/jason.s.tsao/picture"];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
            //NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:nil];
            NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            new_friend.profilePic = image;
        }
        
        [friends_list addObject:new_friend];
    }
    return friends_list;
}

+(NSArray*)eventsArray:(NSArray*)events_list
{
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for(NSDictionary *eventObj in events_list) {
        NSString *startTime;
        if ([eventObj[@"start_time"]  isEqual:[NSNull null]]){
            startTime = eventObj[@"created"];
        }
        else {
            startTime = eventObj[@"start_time"];
        }
        Event * event = [[Event alloc] initWithDescription:eventObj[@"description"] withName:eventObj[@"name"] startTime:startTime eventId:[eventObj[@"id"] integerValue]] ;
        event.locationName = eventObj[@"location_name"];
        event.locationAddress = eventObj[@"location_address"];
        event.end_time = eventObj[@"end_time"];
        event.yelpLink = eventObj[@"yelp_url"];
        event.locationLatitude = eventObj[@"location_latitude"];
        event.locationLongitude = eventObj[@"location_longitude"];
        event.yelpImageLink = eventObj[@"yelp_img_url"];
        [events addObject:event];
    }

    return events;
}

@end
