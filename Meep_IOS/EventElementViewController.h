//
//  EventElementViewController.h
//  Meep_IOS
//
//  Created by Ryan Sharp on 4/23/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EventElementViewControllerDelegate <NSObject>

@optional

@required
- (void)updateEventWithDateTime:(NSDate *)	selectedDate;

@end

@interface EventElementViewController : UIViewController

@property (nonatomic, assign) id<EventElementViewControllerDelegate> delegate;

@end
