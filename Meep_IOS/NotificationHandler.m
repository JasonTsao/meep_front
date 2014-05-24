//
//  NotificationHandler.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/23/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "NotificationHandler.h"

//localNotif.alertAction = NSLocalizedString(@"View Details", nil); localized string example
@implementation NotificationHandler

// LOCAL NOTIFICATIONS FOR IN SYSTEM THINGS THAT HAPPEN
+ (void)createAndSendLocalNotificationForEvent:(Event*)event
{
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:@"%@ event time!.",event.description];
    localNotif.alertAction = @"View Details";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:event.description forKey:@"event"];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];

}

- (void)presentLocalNotificationNow:(UILocalNotification *)notification
{
    NSLog(@"presenting local notificaiton now!");
}

@end
