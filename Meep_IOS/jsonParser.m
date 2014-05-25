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
#import "Notification.h"

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

+(NSArray*)friendsArrayNoEncoding:(NSArray*)friends
{
    NSError* error;
    NSMutableArray *friends_list = [[NSMutableArray alloc] init];
    for( int i = 0; i< [friends count]; i++){
        Friend *new_friend = [[Friend alloc]init];
        
        NSDictionary * new_friend_dict = friends[i];
        
        new_friend.name = new_friend_dict[@"user_name"];
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

+(NSArray*)invitedFriendsArray:(NSArray*)invited_friends_list
{
    NSError* error;
    NSMutableArray *invitedFriends = [[NSMutableArray alloc] init];
    for( int i = 0; i< [invited_friends_list count]; i++){
        InvitedFriend *new_friend = [[InvitedFriend alloc]init];
        
        NSDictionary * new_friend_dict = [NSJSONSerialization JSONObjectWithData: [invited_friends_list[i] dataUsingEncoding:NSUTF8StringEncoding]
                                                                         options: NSJSONReadingMutableContainers
                                                                           error: &error];
        new_friend.name = new_friend_dict[@"name"];
        new_friend.account_id = [new_friend_dict[@"friend_id"] intValue];

        new_friend.has_viewed_event = [new_friend_dict[@"has_viewed_event"] boolValue];
        
        if ([new_friend_dict[@"pf_pic"] length] == 0 || ![new_friend_dict objectForKey:@"pf_pic"] == nil){
            UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
            img.image = [UIImage imageNamed:@"ManSilhouette"];
            //new_friend.profilePic = img;
            new_friend.profilePic = img.image;
        }
        else{
            NSURL *url = [[NSURL alloc] initWithString:new_friend_dict[@"pf_pic"]];
            //NSURL *url = [[NSURL alloc] initWithString:@"https://graph.facebook.com/jason.s.tsao/picture"];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
            //NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:nil];
            NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            new_friend.profilePic = image;
        }
        [invitedFriends addObject:new_friend];
    }
    return invitedFriends;
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

+(NSArray*)groupsArray:(NSArray*)groups_list
{
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    for( int i = 0; i< [groups_list count]; i++){
        Group *new_group = [[Group alloc]init];
        
        NSDictionary * new_group_dict = groups_list[i];
        new_group.name = new_group_dict[@"name"];
        new_group.group_id = [new_group_dict[@"id"] integerValue];
        
        if ([new_group_dict[@"group_pic_url"] length] == 0){
            UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
            img.image = [UIImage imageNamed:@"ManSilhouette"];
            //new_friend.profilePic = img;
            new_group.groupProfilePic = img.image;
        }
        else{
            NSURL *url = [[NSURL alloc] initWithString:new_group_dict[@"group_pic_url"]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
            NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            new_group.groupProfilePic = image;
        }
        [groups addObject:new_group];
    }
    return groups;
}

+(NSArray*)notificationsArray:(NSArray*)notifications_list{
    NSMutableArray *notifications = [[NSMutableArray alloc] init];
    for( int i = 0; i< [notifications_list count]; i++){
        Notification *new_notification = [[Notification alloc]init];
        
        NSDictionary * new_notification_dict = notifications_list[i];
        new_notification.message = new_notification_dict[@"message"];
        new_notification.time_stamp = new_notification_dict[@"created_at"];
        new_notification.notification_id = [new_notification_dict[@"id"] integerValue];
        
        /*if ([new_group_dict[@"group_pic_url"] length] == 0){
            UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
            img.image = [UIImage imageNamed:@"ManSilhouette"];
            //new_friend.profilePic = img;
            new_group.groupProfilePic = img.image;
        }
        else{
            NSURL *url = [[NSURL alloc] initWithString:new_group_dict[@"group_pic_url"]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
            NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            new_group.groupProfilePic = image;
        }*/
        [notifications addObject:new_notification];
    }
    return notifications;
}
    

@end
