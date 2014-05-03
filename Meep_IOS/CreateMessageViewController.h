//
//  CreateMessageViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/1/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"

@interface CreateMessageViewController : UIViewController<UITableViewDataSource>
@property (nonatomic) NSMutableArray *invited_friends_list;

-(void)textFieldDidChange;
@end
