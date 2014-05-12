//
//  MEPLocationService.m
//  Meep_IOS
//
//  Created by Ryan Sharp on 5/12/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "MEPLocationService.h"
#import <CoreLocation/CoreLocation.h>

@interface MEPLocationService() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager * locationManager;

@end

@implementation MEPLocationService

- (void) startSignificantChangeUpdates {
    
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    
    // This code is using the general location manager...
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    _locationManager.distanceFilter = 500; // meters
    [_locationManager startUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *) manager didUpdateLocations:(NSArray *)locations {
    CLLocation * location = [locations lastObject];
    NSDate * eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent < 15.0)) {
        NSLog(@"latitude %+.6f, longitutde %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // do something
    NSLog(@"Location services failed with an error");
}

@end
