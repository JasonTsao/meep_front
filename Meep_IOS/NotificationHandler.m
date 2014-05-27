//
//  NotificationHandler.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/23/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "NotificationHandler.h"
#import "Notification.h"

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

+ (void)handleNotification:(NSDictionary*)userInfo forMainView:(MainViewController*)viewController
{
    if( [userInfo[@"notification_type"] isEqualToString:@"event_chat"]){
        NSMutableDictionary *eventNotifications = viewController.eventNotifications;
        Notification *new_notification = [[Notification alloc] init];
        
        //test alert to see if we can parse the dictionary in this fashion
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"in user handling data!"
                                                        message:userInfo[@"aps"][@"alert"]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        NSMutableArray *notifications_for_event;
        if( [eventNotifications objectForKey:userInfo[@"event_id"]]){
            notifications_for_event = eventNotifications[userInfo[@"event_id"]];
        }else{
            
            notifications_for_event = [[NSMutableArray alloc] init];
        }
        
        
        
        new_notification.type = userInfo[@"notification_type"];
        //new_notification.message = userInfo[@"aps"][@"alert"];
        
        [notifications_for_event addObject:new_notification];
        NSString *key = [NSString stringWithFormat:@"%i",userInfo[@"event_id"]];
        eventNotifications[key] = notifications_for_event;
        
        NSString *eventNotificationsString = [NSString stringWithFormat:@"%@",eventNotifications];
        UIAlertView *new_alert = [[UIAlertView alloc] initWithTitle:@"now event notifications is!"
                                                            message:eventNotificationsString
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [new_alert show];
        
        viewController.eventNotifications = eventNotifications;
    }
}


@end
