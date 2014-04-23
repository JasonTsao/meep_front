//
//  EventCreatorViewController.m
//  MeepIOS
//
//  Created by Ryan Sharp on 4/17/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EventCreatorViewController.h"

@interface EventCreatorViewController () <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextView *eventText;
@property (weak, nonatomic) IBOutlet UITableViewCell *TagButtonsBar;
@property (weak, nonatomic) IBOutlet UITableView *NavBar;
@property (nonatomic, strong) NSMutableArray *displayCell;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;

@end

@implementation EventCreatorViewController
- (IBAction)backToMain:(id)sender {
    [self.eventText resignFirstResponder];
    [_delegate closeCreatorModal];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboard will show");
    NSDictionary * info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    NSLog(@"%f",height);
    _keyboardHeight.constant = height;
    NSLog(@"%f",self.keyboardHeight.constant);
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    CGRect frameRect = self.eventText.frame;
    frameRect.size.height = 100 * (frameRect.size.height - height);
    _eventText.frame = frameRect;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return [_displayCell count];
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"HI Again");
    static NSString *cellMainNibID = @"TagButtons";
    
    _TagButtonsBar = [_NavBar dequeueReusableCellWithIdentifier:cellMainNibID];
    NSLog(@"Tag buttons bar %@", _TagButtonsBar);
    if (_TagButtonsBar == nil) {
        [[NSBundle mainBundle] loadNibNamed:cellMainNibID owner:self options:nil];
    }

    [self.NavBar registerClass:[UITableViewCell class] forCellReuseIdentifier:cellMainNibID];
    return _TagButtonsBar;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Event *currentRecord = [self.eventArray objectAtIndex:indexPath.row];
    
    // Return Data to delegate: either way is fine, although passing back the object may be more efficient
    // [_delegate imageSelected:currentRecord.image withTitle:currentRecord.title withCreator:currentRecord.creator];
    // [_delegate animalSelected:currentRecord];
}

- (void) observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.NavBar.dataSource = self;
    self.NavBar.delegate = self;
    [self.NavBar reloadData];
    [self observeKeyboard];
    // [_eventText becomeFirstResponder];
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
