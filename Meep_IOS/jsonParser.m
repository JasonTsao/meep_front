//
//  jsonParser.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/21/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "jsonParser.h"
#import "InvitedFriend.h"
#import "Notification.h"
#import "ImageCache.h"

@implementation jsonParser

+(Friend*)friendObject:(NSDictionary*)friendDict
{
    NSError* error;
        Friend *friend = [[Friend alloc]init];
        
        /*NSDictionary * new_friend_dict = [NSJSONSerialization JSONObjectWithData: [friendDict dataUsingEncoding:NSUTF8StringEncoding]
                                                                         options: NSJSONReadingMutableContainers
                                                                           error: &error];*/
        
        
        friend.name = friendDict[@"name"];
        friend.numTimesInvitedByMe = friendDict[@"invited_count"];
        friend.phoneNumber= friendDict[@"phone_number"];
        friend.imageFileName = friendDict[@"pf_pic"];
        friend.bio = friendDict[@"bio"];
        friend.account_id = [friendDict[@"account_id"] intValue];
        
        if ([friendDict[@"pf_pic"] length] == 0){
            UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
            img.image = [UIImage imageNamed:@"ManSilhouette"];
            friend.profilePic = img.image;
        }
        else{
            // Set up a background task to get set the users profile from cache or if cache is empty pull from online
            dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
            dispatch_async(downloadQueue, ^{
                NSString *imgUrl = friendDict[@"fb_pfpic_url"];
                float imageHeight = 40;
                float imageXCoord = 8;
                float imageYCoord = (60/2) - (imageHeight/2);
                UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(imageXCoord-0.75, imageYCoord-0.75, imageHeight+1.5, imageHeight+1.5)];
                UIImage* image;
                
                if ([[ImageCache sharedImageCache] DoesExist:imgUrl] == true)
                {
                    image = [[ImageCache sharedImageCache] GetImage:imgUrl];
                }
                else
                {
                    // Create new image data to be cached
                    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imgUrl]];
                    image = [[UIImage alloc] initWithData:imageData];
                    
                    // Create a rounded image from the square ones we would get from online
                    UIImageView* tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageXCoord-0.75, imageYCoord-0.75, imageHeight+1.5, imageHeight+1.5)];
                    tmpImageView.image = image;
                    tmpImageView.layer.cornerRadius = imageHeight/2;
                    tmpImageView.layer.masksToBounds = YES;
                    UIImage* roundedImage = [ImageCache screenshotOfView: tmpImageView];
                    
                    image = roundedImage;
                    
                    // Add the image to the cache
                    [[ImageCache sharedImageCache] AddImage:imgUrl :roundedImage];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    img.image = image;
                    friend.profilePic = image;
                    
                });
            });
        }
    
    return friend;
}
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
            // Set up a background task to get set the users profile from cache or if cache is empty pull from online
            dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
            dispatch_async(downloadQueue, ^{
                NSString *imgUrl = new_friend_dict[@"fb_pfpic_url"];
                float imageHeight = 40;
                float imageXCoord = 8;
                float imageYCoord = (60/2) - (imageHeight/2);
                UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(imageXCoord-0.75, imageYCoord-0.75, imageHeight+1.5, imageHeight+1.5)];
                UIImage* image;

                if ([[ImageCache sharedImageCache] DoesExist:imgUrl] == true)
                {
                    image = [[ImageCache sharedImageCache] GetImage:imgUrl];
                }
                else
                {
                    // Create new image data to be cached
                    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imgUrl]];
                    image = [[UIImage alloc] initWithData:imageData];
                    
                    // Create a rounded image from the square ones we would get from online
                    UIImageView* tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageXCoord-0.75, imageYCoord-0.75, imageHeight+1.5, imageHeight+1.5)];
                    tmpImageView.image = image;
                    tmpImageView.layer.cornerRadius = imageHeight/2;
                    tmpImageView.layer.masksToBounds = YES;
                    UIImage* roundedImage = [ImageCache screenshotOfView: tmpImageView];
                    
                    image = roundedImage;
                    
                    // Add the image to the cache
                    [[ImageCache sharedImageCache] AddImage:imgUrl :roundedImage];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    img.image = image;
                    new_friend.profilePic = image;
                    
                });
            });
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

+(Event*)eventObject:(NSDictionary*)eventDict
{

    NSString *startTime;
    if ([eventDict[@"start_time"]  isEqual:[NSNull null]]){
        startTime = eventDict[@"created"];
    }
    else {
        startTime = eventDict[@"start_time"];
    }
    Event * event = [[Event alloc] initWithDescription:eventDict[@"description"] withName:eventDict[@"name"] startTime:startTime eventId:[eventDict[@"id"] integerValue]] ;
    event.locationName = eventDict[@"location_name"];
    event.locationAddress = eventDict[@"location_address"];
    event.end_time = eventDict[@"end_time"];
    event.yelpLink = eventDict[@"yelp_url"];
    event.locationLatitude = eventDict[@"location_latitude"];
    event.locationLongitude = eventDict[@"location_longitude"];
    event.yelpImageLink = eventDict[@"yelp_img_url"];
    
    return event;
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

+(Group*)groupObject:(NSDictionary*)groupDict
{

    Group *group = [[Group alloc]init];
    
    group.name = groupDict[@"name"];
    group.group_id = [groupDict[@"id"] integerValue];
        
    if ([groupDict[@"group_pic_url"] length] == 0){
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
        img.image = [UIImage imageNamed:@"ManSilhouette"];
        //new_friend.profilePic = img;
        group.groupProfilePic = img.image;
    }
    else{
        NSURL *url = [[NSURL alloc] initWithString:groupDict[@"group_pic_url"]];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        group.groupProfilePic = image;
    }

    return group;
}

+(NSArray*)notificationsArray:(NSArray*)notifications_list{
    NSMutableArray *notifications = [[NSMutableArray alloc] init];
    NSError* error;
    for( int i = 0; i< [notifications_list count]; i++){
        Notification *new_notification = [[Notification alloc]init];
        
        NSDictionary * new_notification_dict = notifications_list[i];
        new_notification.message = new_notification_dict[@"message"];
        new_notification.time_stamp = new_notification_dict[@"created_at"];
        new_notification.notification_id = [new_notification_dict[@"id"] integerValue];
        new_notification.type = new_notification_dict[@"notification_type"];
        
        
        
        new_notification.custom_payload = [NSJSONSerialization JSONObjectWithData: [new_notification_dict[@"extra"] dataUsingEncoding:NSUTF8StringEncoding]
                                        options: NSJSONReadingMutableContainers
                                          error: &error];
        

        [notifications addObject:new_notification];
    }
    return notifications;
}
    

@end
