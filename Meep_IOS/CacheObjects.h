//
//  CacheObjects.h
//  Meep_IOS
//
//  Created by Ryan Sharp on 6/15/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Friend.h"
#import "Group.h"
#import "Notification.h"
#import "InvitedFriend.h"

@interface CacheObjects : NSObject
+(BOOL)cacheEvent:(Event*)event;
+(BOOL)cacheGroup:(Group*)group;
+(BOOL)cacheFriend:(Friend*)friend;
+(BOOL)cacheNotification:(Notification*)notification;
+(BOOL)cacheUpcomingEvents:(NSArray*)upcomingEvents;
+(BOOL)cacheGroupUpcomingEvents:(NSArray*)upcomingEvents;
+(BOOL)cacheGroups:(NSArray*)groups;
+(BOOL)cacheFriends:(NSArray*)friends;
+(BOOL)cacheNotifications:(NSArray*)notifications;
+(Event*)getCachedEvent:(NSString*)event_id;
+(Group*)getCachedGroup:(NSString*)group_id;
+(Friend*)getCachedFriend:(NSString*)friend_id;
+(Notification*)getCachedNotification:(NSString*)notification_id;
+(NSArray*)getCachedList:(NSString*)cache_key;
@end
