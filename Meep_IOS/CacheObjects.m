//
//  CacheObjects.m
//  Meep_IOS
//
//  Created by Ryan Sharp on 6/15/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "CacheObjects.h"

@implementation CacheObjects

+(BOOL)cacheEvent:(Event*)event
{
    NSString *event_key = [NSString stringWithFormat:@"event.%i", event.event_id];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:event];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:event_key];
    [NSUserDefaults resetStandardUserDefaults];
    
    return YES;
}

+(BOOL)cacheGroup:(Group*)group
{
    NSString *group_key = [NSString stringWithFormat:@"group.%i", group.group_id];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:group];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:group_key];
    [NSUserDefaults resetStandardUserDefaults];
    
    return YES;
}

+(BOOL)cacheFriend:(Friend*)friend
{
    NSString *friend_key = [NSString stringWithFormat:@"friend.%i", friend.account_id];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:friend];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:friend_key];
    [NSUserDefaults resetStandardUserDefaults];
    
    return YES;
}

+(BOOL)cacheNotification:(Notification*)notification
{
    NSString *notification_key = [NSString stringWithFormat:@"notification.%i", notification.notification_id];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:notification];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:notification_key];
    [NSUserDefaults resetStandardUserDefaults];
    
    return YES;
}

+(BOOL)cacheUpcomingEvents:(NSArray*)upcomingEvents
{
    NSString *upcoming_events_key = @"upcoming_events";
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:upcomingEvents];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:upcoming_events_key];
    [NSUserDefaults resetStandardUserDefaults];
    
    return YES;
}

+(BOOL)cacheGroupUpcomingEvents:(NSArray*)upcomingEvents
{
    NSString *group_upcoming_events_key = @"group_upcoming_events";
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:upcomingEvents];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:group_upcoming_events_key];
    [NSUserDefaults resetStandardUserDefaults];
    
    return YES;
}

+(BOOL)cacheGroups:(NSArray*)groups
{
    NSString *groups_key = @"groups_list";
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:groups];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:groups_key];
    [NSUserDefaults resetStandardUserDefaults];
    
    return YES;
}

+(BOOL)cacheFriends:(NSArray*)friends
{
    NSString *friends_key = @"friends_list";
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:friends];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:friends_key];
    [NSUserDefaults resetStandardUserDefaults];
    
    return YES;
}

+(BOOL)cacheNotifications:(NSArray*)notifications
{
    NSString *notifications_key = @"notificaitons_list";
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:notifications];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:notifications_key];
    [NSUserDefaults resetStandardUserDefaults];
    
    return YES;
}

+(Event*)getCachedEvent:(NSString*)event_id
{
    NSString *event_key = [NSString stringWithFormat:@"event.%@", event_id];
    
    NSData *event_data = [[NSUserDefaults standardUserDefaults] objectForKey:event_key];
    Event *event = [NSKeyedUnarchiver unarchiveObjectWithData:event_data];
  
    return event;
}

+(Group*)getCachedGroup:(NSString*)group_id
{
    NSString *group_key = [NSString stringWithFormat:@"group.%@", group_id];
    
    NSData *group_data = [[NSUserDefaults standardUserDefaults] objectForKey:group_key];
    Group *group = [NSKeyedUnarchiver unarchiveObjectWithData:group_data];
    
    return group;
}

+(Friend*)getCachedFriend:(NSString*)friend_id
{
    NSString *friend_key = [NSString stringWithFormat:@"friend.%@", friend_id];
    
    NSData *friend_data = [[NSUserDefaults standardUserDefaults] objectForKey:friend_key];
    Friend *friend = [NSKeyedUnarchiver unarchiveObjectWithData:friend_data];
    
    return friend;
}

+(Notification*)getCachedNotification:(NSString*)notification_id
{
    NSString *notification_key = [NSString stringWithFormat:@"notification.%@", notification_id];
    
    NSData *notification_data = [[NSUserDefaults standardUserDefaults] objectForKey:notification_key];
    Notification *notification = [NSKeyedUnarchiver unarchiveObjectWithData:notification_data];
    
    return notification;
}

+(NSArray*)getCachedList:(NSString*)cache_key
{
    NSData *list_data = [[NSUserDefaults standardUserDefaults] objectForKey:cache_key];
    NSArray *list = [NSKeyedUnarchiver unarchiveObjectWithData:list_data];
    
    return list;
}


@end
