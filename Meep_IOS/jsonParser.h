//
//  jsonParser.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/21/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Group.h"

@interface jsonParser : NSObject
+(NSArray*)friendsArray:(NSArray*)friends_list;
+(NSArray*)friendsArrayNoEncoding:(NSArray*)friends;
+(NSArray*)invitedFriendsArray:(NSArray*)invited_friends_list;
+(Event*)eventObject:(NSDictionary*)eventObj;
+(NSArray*)eventsArray:(NSArray*)events_list;
+(Group*)groupObject:(NSDictionary*)groupDict;
+(NSArray*)groupsArray:(NSArray*)groups_list;
+(NSArray*)notificationsArray:(NSArray*)notifications_list;
@end
