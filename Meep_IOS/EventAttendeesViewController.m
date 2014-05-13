//
//  EventAttendeesViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/12/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EventAttendeesViewController.h"

@interface EventAttendeesViewController ()

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


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_invitedFriends count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
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
    return cell;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Invited";
    NSLog(@"event invited friends page loaded!");
    NSLog(@"invited friends: %@", _invitedFriends);
    NSLog(@"current event: %@", _currentEvent);
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
