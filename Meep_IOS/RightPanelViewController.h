//
//  RightPanelViewController.h
//  SlideoutNavigation
//
//  Created by Tammy Coron on 1/10/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RightPanelViewControllerDelegate <NSObject>

@optional

@required

@end

@interface RightPanelViewController : UIViewController

@property (nonatomic, assign) id<RightPanelViewControllerDelegate> delegate;

@end
