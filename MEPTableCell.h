//
//  MEPTableCell.h
//  Meep_IOS
//
//  Created by Ryan Sharp on 5/21/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "Event.h"
#import <Foundation/Foundation.h>

@interface MEPTableCell : NSObject

+(UITableViewCell*)eventCell:(Event*)event userLatitude:(float)lat userLongitude:(float)lng;

@end
