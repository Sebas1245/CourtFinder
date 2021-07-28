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
#import "CourtDetailViewController.h"
#import <Parse/Parse.h>
#import "CourtUsersUpdates.h"

@interface CourtsViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, CourtDetailViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *courtsTableView;
@property (strong, nonatomic) NSMutableArray<Court*> *courts;
@end

@implementation CourtsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startMonitoringSignificantLocationChanges];
    self.courtsTableView.delegate = self;
    self.courtsTableView.dataSource = self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *lastLocation = [locations lastObject];
    self.courts = [NSMutableArray new];
    NSLog(@"Location changed lat %f - long %f", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude);
    [self updateUserLocationWithCompletion:^(NSError * _Nonnull error, BOOL success) {
        if (error != nil) {
            NSString *errorMsg = [NSString stringWithFormat:@"Error updating location in database: %@", error.localizedDescription];
            [[Alert new] showErrAlertOnView:self message:errorMsg title:@"Internal server error"];
        } else {
            NSLog(@"Updated user location successfully");
            [CourtUsersUpdates headedToParkCleanupWithCompletion:^(NSError *error, BOOL success) {
                if (error != nil) {
                    NSString *errorMsg = [NSString stringWithFormat:@"Error updating database: %@", error.localizedDescription];
                    [[Alert new] showErrAlertOnView:self message:errorMsg title:@"Internal server error"];
                } else {
                    [self loadAPIDataWithCompletion:^(NSError *error, BOOL success) {
                        if (success) {
                            NSLog(@"Successfully reloaded API data");
                            [self.courtsTableView reloadData];
                        } else {
                            NSString *errorMsg =  [NSString stringWithFormat:@"Error fetching Google Maps Data: %@",error.localizedDescription];
                            [[Alert new] showErrAlertOnView:self message:errorMsg title:@"Google Maps Error"];
                        }
                    }];
                }
            }];
        }
    }];
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

- (void)loadAPIDataWithCompletion:(void(^)(NSError *error, BOOL success))completion {
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

- (void)loadAPIDetails:(NSArray<Court*> *)searchResults completion:(void(^)(NSError *error, BOOL success))completion {
    [GoogleMapsAPI getDetailsForEachCourt:searchResults userLocation:self.locationManager.location completion:^(NSError * _Nonnull error, NSArray<Court *> * _Nonnull foundCourts) {
            dispatch_group_t addressRequestGroup = dispatch_group_create();
            dispatch_group_t photoRequestGroup = dispatch_group_create();
            dispatch_group_t courtUserCountRequestGroup = dispatch_group_create();
            for (Court *foundCourt in foundCourts) {
                dispatch_group_enter(addressRequestGroup);
                [GoogleMapsAPI getAddressForCourt:foundCourt.placeID completion:^(NSError * _Nonnull error, NSString * _Nonnull address) {
                    if (error != nil) {
                        completion(error, false);
                    } else {
                        [foundCourt setAddress:address];
                        dispatch_group_leave(addressRequestGroup);
                    }
                }];
                dispatch_group_enter(photoRequestGroup);
                [GoogleMapsAPI getAllPhotosForCourt:foundCourt.placeID completion:^(NSError * _Nonnull error, NSArray<UIImage *> * _Nonnull photos) {
                    if (error != nil) {
                        completion(error, false);
                    } else {
                        foundCourt.otherPhotos = photos;
                        [foundCourt setMainPhoto:foundCourt.otherPhotos[0]];
                        dispatch_group_leave(photoRequestGroup);
                    }
                }];
                dispatch_group_enter(courtUserCountRequestGroup);
                [CourtUsersUpdates getUserCountForCourt:foundCourt completion:^(NSError * _Nonnull error, int count) {
                    if (error != nil) {
                        completion(error, false);
                    } else {
                        [foundCourt setPlayers:count];
                        dispatch_group_leave(courtUserCountRequestGroup);
                    }
                }];
                [self.courts addObject:foundCourt];
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_group_wait(addressRequestGroup, DISPATCH_TIME_FOREVER);
                dispatch_group_wait(photoRequestGroup, DISPATCH_TIME_FOREVER);
                dispatch_group_wait(courtUserCountRequestGroup, DISPATCH_TIME_FOREVER);
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil,true);
                });
            });
    }];
}

- (void)updateUserLocationWithCompletion:(void(^)(NSError *error, BOOL success))completion {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        PFGeoPoint *lastLocation = [PFGeoPoint new];
        lastLocation.latitude = self.locationManager.location.coordinate.latitude;
        lastLocation.longitude = self.locationManager.location.coordinate.longitude;
        currentUser[@"lastLocation"] = lastLocation;
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            completion(error, succeeded);
        }];
    }
}

- (void)tappedOptInOnCourtNumber:(NSIndexPath *)courtIndexPath{
    [self.courtsTableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.courtsTableView indexPathForCell:tappedCell];
    Court *selectedCourt = self.courts[indexPath.row];
    CourtDetailViewController *courtDetailVC = [segue destinationViewController];
    courtDetailVC.court = selectedCourt;
    courtDetailVC.courtIndexPath = indexPath;
    courtDetailVC.delegate = self;
}
@end
