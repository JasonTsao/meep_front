//
//  MEPLocationService.m
//  Meep_IOS
//
//  Created by Ryan Sharp on 5/12/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "MEPLocationService.h"
#import "MEEPhttp.h"
#import <CoreLocation/CoreLocation.h>

@interface MEPLocationService() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager * locationManager;

@end

@implementation MEPLocationService

- (id) init {
    if (self = [super init]) {
        [self startSignificantChangeUpdates];
    }
    return self;
}

- (void) startSignificantChangeUpdates {
    if (nil == _locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    _locationManager.delegate = self;
    [_locationManager startMonitoringSignificantLocationChanges];
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
    NSString *latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:latitude,@"latitude",
                               longitude,@"longitude", nil];
    NSString * requestUrl = [NSString stringWithFormat:@"%@updateLocation",[MEEPhttp accountURL]];
    NSURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestUrl postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // do something
    NSLog(@"Location Services Failed with error :: %@",[error localizedDescription]);
}

@end
