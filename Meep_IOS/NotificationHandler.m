//
//  NotificationHandler.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/23/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "NotificationHandler.h"
#import "Notification.h"
#import "EventChatViewController.h"
#import "MEPAppDelegate.h"

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

    //EVENT CREATION
    if([userInfo[@"notification_type"] isEqualToString:@"event_create"]){
        NSMutableDictionary *eventNotifications = viewController.eventNotifications;
        Notification *new_notification = [[Notification alloc] init];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"handling an event creation notification!"
                                                        message:[NSString stringWithFormat:@"%@", userInfo[@"aps"][@"alert"]]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        NSMutableArray *notifications_for_event;
        NSString *key = [NSString stringWithFormat:@"%@",userInfo[@"event_id"]];
        if( [eventNotifications objectForKey:key]){
            notifications_for_event = eventNotifications[key];
        }else{
            
            notifications_for_event = [[NSMutableArray alloc] init];
        }
        
        new_notification.type = userInfo[@"notification_type"];
        
        [notifications_for_event addObject:new_notification];
        eventNotifications[key] = notifications_for_event;
        
        viewController.eventNotifications = eventNotifications;
    }
    //EVENT UPDATE
    else if( [userInfo[@"notification_type"] isEqualToString:@"event_update"]){
        NSMutableDictionary *eventNotifications = viewController.eventNotifications;
        Notification *new_notification = [[Notification alloc] init];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"handling an event update notification!"
                                                        message:[NSString stringWithFormat:@"%@", userInfo[@"aps"][@"alert"]]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        NSMutableArray *notifications_for_event;
        NSString *key = [NSString stringWithFormat:@"%@",userInfo[@"event_id"]];
        if( [eventNotifications objectForKey:key]){
            notifications_for_event = eventNotifications[key];
        }else{
            
            notifications_for_event = [[NSMutableArray alloc] init];
        }
        
        new_notification.type = userInfo[@"notification_type"];
        
        [notifications_for_event addObject:new_notification];
        eventNotifications[key] = notifications_for_event;
        
        viewController.eventNotifications = eventNotifications;
    }
    //EVENT CHAT
    else if( [userInfo[@"notification_type"] isEqualToString:@"event_chat"]){
        NSMutableDictionary *eventNotifications = viewController.eventNotifications;
        Notification *new_notification = [[Notification alloc] init];
        
        //Code for updating chat table if person is looking at it
        MEPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        UINavigationController *navigation = appDelegate.viewController.presentedViewController;
        EventChatViewController *eventchat = navigation.topViewController;
        
        NSString *classString = [NSString stringWithFormat:@"%@",[eventchat class]];
        if( [classString isEqualToString:@"EventChatViewController"]){
            NSInteger event_id = [userInfo[@"event_id"] integerValue];
            if(event_id == eventchat.currentEvent.event_id){
                NSLog(@"the class is an event chat view controller!!");
                NSString *message = userInfo[@"message"];
                NSString *account_id = userInfo[@"creator_id"];
                NSString *user_name = userInfo[@"user_name"];
                [eventchat putPushNotificationMessageOnTable:message withAccount:account_id withName:user_name];
            }
            
        }
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"handling a chat notification!"
                                                        message:[NSString stringWithFormat:@"%@", userInfo[@"aps"][@"alert"]]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];*/
        
        NSMutableArray *notifications_for_event;
        NSString *key = [NSString stringWithFormat:@"%@",userInfo[@"event_id"]];
        if( [eventNotifications objectForKey:key]){
            notifications_for_event = eventNotifications[key];
        }else{
            
            notifications_for_event = [[NSMutableArray alloc] init];
        }
        
        new_notification.type = userInfo[@"notification_type"];
        
        [notifications_for_event addObject:new_notification];
        eventNotifications[key] = notifications_for_event;
        
        viewController.eventNotifications = eventNotifications;
    }
    // USER ADDED TO GROUP
    else if( [userInfo[@"notification_type"] isEqualToString:@"group_added"]){
        // TODO FILL OUT
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"handling being added to a group notification!"
                                                        message:userInfo[@"aps"][@"alert"]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    // GROUP CHAT
    else if( [userInfo[@"notification_type"] isEqualToString:@"group_chat"]){
        // TODO FILL OUT
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"handling being added to a group notification!"
                                                        message:userInfo[@"aps"][@"alert"]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    // USER REQUESTED YOU AS A FRIEND
    else if( [userInfo[@"notification_type"] isEqualToString:@"friend_request"]){
        // TODO FILL OUT
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"handling being added to a group notification!"
                                                        message:userInfo[@"aps"][@"alert"]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    // USER ADDED YOU AS A FRIEND
    else if( [userInfo[@"notification_type"] isEqualToString:@"friend_added"]){
        // TODO FILL OUT
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"handling being added to a group notification!"
                                                        message:userInfo[@"aps"][@"alert"]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


@end
