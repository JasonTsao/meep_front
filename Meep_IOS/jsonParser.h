//
//  jsonParser.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/21/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface jsonParser : NSObject
+(NSArray*)friendsArray:(NSArray*)friends_list;
+(NSArray*)friendsArrayNoEncoding:(NSArray*)friends;
+(NSArray*)invitedFriendsArray:(NSArray*)invited_friends_list;
+(NSArray*)eventsArray:(NSArray*)events_list;
+(NSArray*)groupsArray:(NSArray*)groups_list;
@end
