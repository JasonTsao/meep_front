//
//  FriendProfileViewController.m
//  Friends
//
//  Created by Jason Tsao on 4/24/14.
//  Copyright (c) 2014 Jason Tsao. All rights reserved.
//

#import "FriendProfileViewController.h"

@interface FriendProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *currentProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *numRowsLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (strong, nonatomic) Photo *profilePicture;

@end

@implementation FriendProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)callFriend:(id)sender {
    NSLog(@"Phone number of friend %@", _currentFriend.phoneNumber);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.currentFriend.name;
    [_nameLabel setText:_currentFriend.name];
    [_bioLabel setText:_currentFriend.bio];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    FriendFullSizeProfileImageViewController *pvc = [segue destinationViewController];
    pvc.currentFriend = self.currentFriend;
    //pvc.fullProfilePicture = self.profilePicture;
}


@end
