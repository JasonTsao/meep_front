//
//  InviteFriendsViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/1/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateMessageViewController.h"

@interface InviteFriendsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) NSMutableData * data;
@end
