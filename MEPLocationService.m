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
#import <MapKit/MapKit.h>

@interface MEPLocationService() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) NSMutableData * data;
@property (nonatomic, strong) CLLocation * currentLocation;

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
        _currentLocation = location;
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

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    _data = [[NSMutableData alloc] init]; // _data being an ivar
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_data appendData:data];
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Handle the error properly
    NSLog(@"Call Failed");
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [self handleData]; // Deal with the data
}

-(void)handleData{
    NSDictionary * recievedData = [NSJSONSerialization JSONObjectWithData:_data options:0 error:nil];
}

+(NSString*) distanceBetweenCoordinatesWithLatitudeOne:(float)lat1
                                      longitudeOne:(float)lng1
                                       latitudeTwo:(float)lat2
                                      longitudeTwo:(float)lng2 {
    CLLocation * loc1 = [[CLLocation alloc] initWithLatitude:lat1 longitude:lng1];
    CLLocation * loc2 = [[CLLocation alloc] initWithLatitude:lat2 longitude:lng2];
    CLLocationDistance distance = [loc1 distanceFromLocation:loc2];
    float dist = (distance * 3.28084)/5280;
    if (dist >= 10) {
        return [NSString stringWithFormat:@"%.0Lf miles",roundl(dist*100.0)/100.0];
    }
    return [NSString stringWithFormat:@"%.1Lf miles",roundl(dist*100.0)/100.0];
}
@end
