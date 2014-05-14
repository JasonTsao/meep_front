//
//  EventAttendeesViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/12/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EventAttendeesViewController.h"
#import "FriendProfileViewController.h"

@interface EventAttendeesViewController ()
@property(nonatomic, strong) NSMutableArray *attendeeFriends;
@property (nonatomic, strong) FriendProfileViewController *friendProfileViewController;
@end

@implementation EventAttendeesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) backToEventAttendeesPage:(FriendProfileViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) openFriendPage:(id)sender
{
    UIButton *cellButton = sender;
    NSLog(@"button tag: %i", cellButton.tag);
    
    Friend *selectedFriend = [[Friend alloc] init];
    selectedFriend.name = [_invitedFriends[cellButton.tag] name];
    selectedFriend.account_id =[_invitedFriends[cellButton.tag] account_id];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _friendProfileViewController = (FriendProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"friendProfile"];
    _friendProfileViewController.currentFriend = selectedFriend;
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_friendProfileViewController];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Event" style:UIBarButtonItemStyleBordered target:self action:@selector(backToEventAttendeesPage:)];
    _friendProfileViewController.navigationItem.leftBarButtonItem = customBarItem;
    
    [_friendProfileViewController setDelegate:self];
    [self presentViewController:navigation animated:YES completion:nil];
}

// FUNCTION DOES NOT GET CALLED
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
            headerCellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *headerCell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"eventAttendeesHeader"
                                                                                                         forIndexPath:indexPath];
    UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
    if (indexPath.section == 0){
        NSLog(@"Attending");
        cellLabel.text = @"Attending";
    }
    else if (indexPath.section == 1){
        cellLabel.text = @"Not Attending";
    }
    [headerCell.contentView addSubview: cellLabel];
    return headerCell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0){
        //Attending friends
    }
    else if(section == 1){
        //Not attending friends
    }
        
    return [_invitedFriends count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"in collection view didselectitematindexpath: %@", [_invitedFriends[indexPath.row] name]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"invitedFriendCell" forIndexPath:indexPath];
    //UIImage *cellImage = [[UIImage alloc] init];
    UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *user_name;
    
    [_attendeeFriends addObject:_invitedFriends[indexPath.row]];
    if(indexPath.section == 1){
        if([[_invitedFriends[indexPath.row] name] length] >= 6){
            user_name = [[_invitedFriends[indexPath.row] name] substringToIndex:6];
        }
        else{
            user_name = [_invitedFriends[indexPath.row] name];
        }
        
        [cellButton addTarget:self
                       action:@selector(openFriendPage:)
             forControlEvents:UIControlEventTouchUpInside];
        [cellButton setTitle:user_name forState:UIControlStateNormal];
        cellButton.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
        [cell.contentView addSubview: cellButton];
        
        // later when separating between attending and not, tag will be numAttending + indexPath.row
        cellButton.tag = indexPath.row;
    }
    
    
    return cell;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    _attendeeFriends = [[NSMutableArray alloc] init];
    //self.collectionView.backgroundColor = [UIColor whiteColor];
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

@end
