//
//  AccountSettings.m
//  Meep_IOS
//
//  Created by Jason Tsao on 4/23/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "AccountSettings.h"

@implementation AccountSettings

-(id) initWithPrivate:(BOOL) acctPrivate
       withSearchable:(BOOL) acctSearchable
        withReminders:(BOOL) acctReminders
        withVibrateOnNotification:(BOOL) acctVibrateOnNotification{
    if((self = [super init])) {
        _user_is_private = acctPrivate;
        _searchable = acctSearchable;
        _reminders = acctReminders;
        _vibrate_on_notification = acctVibrateOnNotification;
    }
    return self;
}
@end
