//
//  EventAttendeesDistanceViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/12/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EventAttendeesDistanceViewController.h"
#import "CenterViewController.h"
#import "MEEPhttp.h"
#import "MEPLocationService.h"

@interface EventAttendeesDistanceViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *friendsDistanceCollectionView;
@property (nonatomic, strong) NSArray * attendeeList;
// @property (nonatomic, strong) NSMutableData * data;
@end

@implementation EventAttendeesDistanceViewController

- (void)getInvitedFriendsWithDistance {
    _data = [[NSMutableData alloc] init];
    NSInteger eventId = self.currentEvent.event_id;
    NSString * requestUrl = [NSString stringWithFormat:@"%@invited_friends_location/%d",[MEEPhttp eventURL],eventId];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestUrl postDictionary:nil];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void)handleData {
    _attendeeList = [[NSArray alloc] init];
    NSError * error = nil;
    NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
    NSArray * invitees = jsonResponse[@"invited"];
    NSMutableArray * unsortedFriendArray = [[NSMutableArray alloc] init];
    for (NSDictionary * invitedUser in invitees) {
        NSMutableDictionary * inviteeData = [[NSMutableDictionary alloc] init];
        [inviteeData setObject:invitedUser[@"name"] forKey:@"name"];
        if ([invitedUser objectForKey:@"lat"] && [invitedUser objectForKey:@"lng"]) {
            [inviteeData setObject:invitedUser[@"lng"] forKey:@"lng"];
            [inviteeData setObject:invitedUser[@"lat"] forKey:@"lat"];
        }
        if ([invitedUser objectForKey:@"picture"] && [[invitedUser objectForKey:@"picture"] length] > 1) {
            [inviteeData setObject:invitedUser[@"picture"] forKey:@"imageUrl"];
        }
        [unsortedFriendArray addObject:inviteeData];
    }
    NSSortDescriptor * nameSort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    _attendeeList = [unsortedFriendArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:nameSort, nil]];
    [self.friendsDistanceCollectionView reloadData];
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.attendeeList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // UICollectionViewCell *cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(3, 3, collectionView.frame.size.height - 6, collectionView.frame.size.height - 6)];
    UICollectionViewCell *cell = [self.friendsDistanceCollectionView dequeueReusableCellWithReuseIdentifier:@"invitedFriendDistanceCell" forIndexPath:indexPath];
    for (UIView * subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    NSDictionary * guest = _attendeeList[indexPath.row];
    UIImageView * profilePicture = [[UIImageView alloc] initWithFrame:CGRectMake(2, 4, cell.frame.size.width - 4, cell.frame.size.width - 4)];
    if ([guest objectForKey:@"picture"]) {
        profilePicture.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:guest[@"picture"]]]];
    }
    else {
        profilePicture.image = [UIImage imageNamed:@"ManSilhouette"];
    }
    profilePicture.layer.cornerRadius = profilePicture.frame.size.height/2;
    profilePicture.layer.masksToBounds = YES;
    [cell addSubview:profilePicture];
    UILabel * name = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.width - 4, cell.frame.size.width - 8, 10)];
    name.text = guest[@"name"];
    name.textAlignment = NSTextAlignmentCenter;
    name.backgroundColor = [CenterViewController colorWithHexString:@"FFFFFF"];
    [name setFont:[UIFont systemFontOfSize:9]];
    [cell addSubview:name];
    
    UILabel * distance = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.width + 8, cell.frame.size.width, 10)];
    if (![self.currentEvent.locationLatitude isEqual:[NSNull null]] &&
        ![self.currentEvent.locationLongitude isEqual:[NSNull null]] &&
        [guest objectForKey:@"lng"] &&
        [guest objectForKey:@"lat"]) {
        NSString * dist = [MEPLocationService distanceBetweenCoordinatesWithLatitudeOne:[self.currentEvent.locationLatitude floatValue] longitudeOne:[self.currentEvent.locationLongitude floatValue] latitudeTwo:[guest[@"lat"] floatValue] longitudeTwo:[guest[@"lng"] floatValue]];
        distance.text = dist;
    }
    else {
        distance.text = @"Unavailable";
    }
    [distance setFont:[UIFont systemFontOfSize:9]];
    distance.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:distance];
    
    return cell;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"HI");
    [super viewDidLoad];
    self.friendsDistanceCollectionView.dataSource = self;
    self.friendsDistanceCollectionView.delegate = self;
    self.friendsDistanceCollectionView.backgroundColor = [UIColor whiteColor];
    [self getInvitedFriendsWithDistance];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    NSLog(@"%@",error);
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [self handleData]; // Deal with the data
}

@end
