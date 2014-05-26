//
//  EventElementViewController.m
//  Meep_IOS
//
//  Created by Ryan Sharp on 4/23/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EventElementViewController.h"
#import "MEEPhttp.h"

@interface EventElementViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIDatePicker *timeSelect;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *returnToEventPage;
@property (weak, nonatomic) IBOutlet UISearchBar *locationSearchBar;

@property (strong, nonatomic) NSMutableData * data;

@end

@implementation EventElementViewController

- (IBAction)returnToEventCreator:(id)sender {
    
}

- (IBAction)selectTime:(id)sender {
    NSDate * selectedDay = [self.timeSelect date];
    [_delegate updateEventWithDateTime:selectedDay];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString * query = _locationSearchBar.text;
    NSString * requestUrl = [NSString stringWithFormat:@"%@searchlocations?query=%@",[MEEPhttp eventURL],query];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestUrl postDictionary:nil];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
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
-(void)handleData {
    NSDictionary * response = [NSJSONSerialization JSONObjectWithData:_data options:0 error:nil];
    NSLog(@"%@",response);
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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _locationSearchBar.delegate = self;
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
