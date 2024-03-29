//
//  EventCreatorViewController.h
//  MeepIOS
//
//  Created by Ryan Sharp on 4/17/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventElementViewController.h"

@protocol EventCreatorViewControllerDelegate <NSObject>

@optional

@required
- (void)closeCreatorModal;

@end

@interface EventCreatorViewController : UIViewController <UITableViewDelegate, UITextInputDelegate>

@property (nonatomic, assign) id<EventCreatorViewControllerDelegate> delegate;

@end
