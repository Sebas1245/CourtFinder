//
//  CourtsViewController.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 12/07/21.
//

#import "CourtsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CourtCell.h"

@interface CourtsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *courtsTableView;
@end

@implementation CourtsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
    self.courtsTableView.delegate = self;
    self.courtsTableView.dataSource = self;
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    if([manager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"User still thinking about it");
    } else if ([manager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"User opted out of location tracking");
    } else {
        [manager startUpdatingLocation];
    }
   
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *lastLocation = [locations lastObject];
    NSLog(@"lat %f - long %f", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CourtCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CourtCell"];
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
