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
#import "Alert.h"

@interface CourtsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *courtsTableView;
@property (strong, nonatomic) NSMutableArray<Court*> *courts;
@end

@implementation CourtsViewController
CLLocation *previousLastLocation;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.courts = [NSMutableArray new];
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
        [self loadAPIDataWithCompletion:^(NSError *error, BOOL success) {
            if (success) {
                NSLog(@"Reloaded table data");
                [self.courtsTableView reloadData];
            } else {
                // alert error
                NSString *errorMsg =  [NSString stringWithFormat:@"Error fetching Google Maps Data: %@",error.localizedDescription];
                [[Alert new] showErrAlertOnView:self message:errorMsg title:@"Google Maps Error"];
            }
        }];
    } else {
        previousLastLocation = lastLocation;
        NSLog(@"Location still at lat %f - long %f", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.courts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CourtCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CourtCell"];
    Court *court = self.courts[indexPath.row];
    cell.court = court;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)loadAPIDataWithCompletion:(void(^)(NSError *error, BOOL success))completion {
    [GoogleMapsAPI searchNearbyCourts:self.locationManager.location searchRadius:5000 completion:^(NSError * _Nonnull error, NSArray<Court*> * searchResults) {
        if (error != nil) {
            NSLog(@"Error fetching data from Google Maps API: @%@", error.localizedDescription);
            completion(error, false);
        } else {
            [self loadAPIDetails:searchResults completion:^(NSError *error, BOOL success) {
                if (error != nil) {
                    completion(error, false);
                } else {
                    completion(nil, true);
                }
            }];
        }
    }];
}

-(void)loadAPIDetails:(NSArray<Court*> *)searchResults completion:(void(^)(NSError *error, BOOL success))completion {
    [GoogleMapsAPI getDetailsForEachCourt:searchResults completion:^(NSError * _Nonnull error, NSArray<Court *> * _Nonnull foundCourts) {
        dispatch_group_t addressRequestGroup = dispatch_group_create();
        dispatch_group_t photoRequestGroup = dispatch_group_create();
        for (Court *foundCourt in foundCourts) {
            dispatch_group_enter(addressRequestGroup);
            [GoogleMapsAPI getAddressForCourt:foundCourt.placeID completion:^(NSError * _Nonnull error, NSString * _Nonnull address) {
                if (error != nil) {
                    completion(error, false);
                } else {
                    [foundCourt setAddress:address];
                    NSLog(@"Leaving addressRequestGroup");
                    dispatch_group_leave(addressRequestGroup);
                }
            }];
            dispatch_group_enter(photoRequestGroup);
            [GoogleMapsAPI getMainCourtPhoto:foundCourt.placeID completion:^(NSError * _Nonnull error, UIImage * _Nonnull photo) {
                if (error != nil) {
                    completion(error, false);
                } else {
                    [foundCourt setMainPhoto:photo];
                    dispatch_group_leave(photoRequestGroup);
                    NSLog(@"Leaving photoRequestGroup");
                }
            }];
            NSLog(@"Inserting aobject to self.courts");
            [self.courts addObject:foundCourt];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_group_wait(addressRequestGroup, DISPATCH_TIME_FOREVER);
            dispatch_group_wait(photoRequestGroup, DISPATCH_TIME_FOREVER);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil,true);
            });
        });
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
