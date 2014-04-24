//
//  AccountSettings.m
//  Meep_IOS
//
//  Created by Jason Tsao on 4/23/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "AccountSettings.h"

@implementation AccountSettings
@synthesize user_is_private;
@synthesize searchable;
@synthesize reminders;
@synthesize vibrate_on_notification;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.user_is_private = [decoder decodeBoolForKey:@"private"];
        self.searchable = [decoder decodeBoolForKey:@"searchable"];
        self.reminders = [decoder decodeBoolForKey:@"reminders"];
        self.vibrate_on_notification = [decoder decodeBoolForKey:@"vibrate_on_notification"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:user_is_private forKey:@"private"];
    [encoder encodeBool:searchable forKey:@"searchable"];
    [encoder encodeBool:reminders forKey:@"reminders"];
    [encoder encodeBool:vibrate_on_notification forKey:@"vibrate_on_notification"];
}

-(id) initWithPrivate:(BOOL) acctPrivate
       withSearchable:(BOOL) acctSearchable
        withReminders:(BOOL) acctReminders
        withVibrateOnNotification:(BOOL) acctVibrateOnNotification{
    if((self = [super init])) {
        user_is_private = acctPrivate;
        searchable = acctSearchable;
        reminders = acctReminders;
        vibrate_on_notification = acctVibrateOnNotification;
    }
    return self;
}
@end
