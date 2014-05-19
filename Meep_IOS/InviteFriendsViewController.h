//
//  InviteFriendsViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/1/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateMessageViewController.h"

@class InviteFriendsViewController;

@protocol InviteFriendsViewControllerDelegate
- (void) backToCenterFromCreateEvent:(InviteFriendsViewController *)controller;
@end

@interface InviteFriendsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property(nonatomic, strong) id <InviteFriendsViewControllerDelegate> delegate;
@property(nonatomic, strong) NSMutableData * data;

- (IBAction) backToMain:(id)sender;

+(UITableViewCell*) createCustomFriendCell:(Friend*)friend
                                  forTable:(UITableView*)tableView
                                  selected:(BOOL)sel;
@end
