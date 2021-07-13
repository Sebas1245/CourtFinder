//
//  CourtsViewController.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 12/07/21.
//

#import "CourtsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CourtCell.h"
#import "GoogleMapsAPI.h"

@interface CourtsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *courtsTableView;
@end

@implementation CourtsViewController
CLLocation *previousLastLocation;

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
        [manager startMonitoringSignificantLocationChanges];
    }
   
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *lastLocation = [locations lastObject];
    if(![locations isEqual:previousLastLocation]) {
        NSLog(@"Location changed lat %f - long %f", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude);
        [self loadAPIData];
    } else {
        previousLastLocation = lastLocation;
        NSLog(@"Location still at lat %f - long %f", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CourtCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CourtCell"];
    return cell;
}

-(void) loadAPIData {
    [GoogleMapsAPI searchNearbyCourts:self.locationManager.location searchRadius:5000 completion:^(NSError * _Nonnull error, NSArray * _Nonnull foundCourts) {
        if (error != nil) {
            // show an alert
            NSLog(@"Error fetching data from Google Maps API: @%@", error.localizedDescription);
        } else {
            // load data into table view
            NSLog(@"Found courts: %@", foundCourts);
        }
    }];
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
