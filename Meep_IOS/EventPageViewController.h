//
//  EventPageViewController.h
//  MeepIOS
//
//  Created by Ryan Sharp on 4/15/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Event.h"
#import "Friend.h"
#import "InvitedFriend.h"
#import "MEEPhttp.h"
@class EventPageViewController;

@protocol EventPageViewControllerDelegate <NSObject>

@optional

@required
- (void)closeEventModal;
- (void) backToCenterFromEventPage:(EventPageViewController *)controller;

@end

@interface EventPageViewController : UIViewController<UIActionSheetDelegate, UITableViewDataSource,UITableViewDelegate, MKMapViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic) Event *currentEvent;
@property (nonatomic) NSArray *notifications;
@property (nonatomic) NSArray *invitedFriends;
@property(nonatomic, strong) NSMutableData * data;
//@property(nonatomic, weak) NSMutableData * data;
@property (nonatomic, assign) id<EventPageViewControllerDelegate> delegate;

@end
