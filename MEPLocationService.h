//
//  MEPLocationService.h
//  Meep_IOS
//
//  Created by Ryan Sharp on 5/12/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEPLocationService : NSObject
+(float) distanceBetweenCoordinatesWithLatitudeOne:(float)lat1
                                      longitudeOne:(float)lng1
                                       latitudeTwo:(float)lat2
                                      longitudeTwo:(float)lng2;
@end
