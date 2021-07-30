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
#import <Lottie/Lottie.h>
#import "AppDelegate.h"

@interface CourtsViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, CourtDetailViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *courtsTableView;
@property (strong, nonatomic) NSMutableArray<Court*> *courts;
@property (strong, nonatomic) LOTAnimationView *lottieAnimation;
@property (strong, nonatomic) NSIndexPath *selectedCourtIndexPath;
@end

@implementation CourtsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewData) name:@"locationUpdated" object:nil];
    [self updateViewData];
    self.courtsTableView.delegate = self;
    self.courtsTableView.dataSource = self;
}

- (void)updateViewData {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.courts = [NSMutableArray new];
    [self setupLottieAnimation];
    NSLog(@"Location changed lat %f - long %f",
          appDelegate.currentUserLocation.coordinate.latitude,
          appDelegate.currentUserLocation.coordinate.longitude);
    [self updateUserLocation:appDelegate.currentUserLocation completion:^(NSError * _Nonnull error, BOOL success) {
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
                    [self loadAPIDataFromLocation:appDelegate.currentUserLocation completion:^(NSError *error, BOOL success) {
                        if (success) {
                            NSLog(@"Successfully reloaded API data");
                            [self.delegate updatedCourt:self.courts[self.selectedCourtIndexPath.row]];
                            [self.courtsTableView reloadData];
                            [UIView animateWithDuration:0.4
                                             animations:^{
                                                self.lottieAnimation.layer.opacity = 0;
                                             }
                                             completion:^(BOOL finished) {
                                                if (finished) {
                                                    [self.lottieAnimation removeFromSuperview];
                                                }
                                             }
                            ];
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

- (void)loadAPIDataFromLocation:(CLLocation *)currentLocation completion:(void(^)(NSError *error, BOOL success))completion {
    [GoogleMapsAPI searchNearbyCourts:currentLocation completion:^(NSError * _Nonnull error, NSArray<Court*> * searchResults) {
        if (error != nil) {
            NSLog(@"Error fetching data from Google Maps API: @%@", error.localizedDescription);
            completion(error, false);
        } else {
            [self loadAPIDetails:searchResults currentLocation:currentLocation completion:^(NSError *error, BOOL success) {
                if (error != nil) {
                    completion(error, false);
                } else {
                    completion(nil, true);
                }
            }];
        }
    }];
}

- (void)loadAPIDetails:(NSArray<Court*> *)searchResults currentLocation:(CLLocation *)currentLocation completion:(void(^)(NSError *error, BOOL success))completion {
    [GoogleMapsAPI getDetailsForEachCourt:searchResults userLocation:currentLocation completion:^(NSError * _Nonnull error, NSArray<Court *> * _Nonnull foundCourts) {
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

- (void)updateUserLocation:(CLLocation *)currentLocation completion:(void(^)(NSError *error, BOOL success))completion {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        PFGeoPoint *lastLocation = [PFGeoPoint new];
        lastLocation.latitude = currentLocation.coordinate.latitude;
        lastLocation.longitude = currentLocation.coordinate.longitude;
        currentUser[@"lastLocation"] = lastLocation;
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            completion(error, succeeded);
        }];
    }
}

- (void)tappedOptInOnCourtNumber:(NSIndexPath *)courtIndexPath {
    [self.courtsTableView reloadData];
}

- (void)setupLottieAnimation {
    self.lottieAnimation = [LOTAnimationView animationNamed:@"lottie-baseketball"];
    self.lottieAnimation.loopAnimation = YES;
    self.lottieAnimation.backgroundColor = [UIColor systemBackgroundColor];
    self.lottieAnimation.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.lottieAnimation.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.lottieAnimation];
    [self.lottieAnimation play];
    NSLog(@"Finished setting up animation");
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.courtsTableView indexPathForCell:tappedCell];
    self.selectedCourtIndexPath = indexPath;
    Court *selectedCourt = self.courts[indexPath.row];
    CourtDetailViewController *courtDetailVC = [segue destinationViewController];
    courtDetailVC.court = selectedCourt;
    courtDetailVC.courtIndexPath = indexPath;
    courtDetailVC.delegate = self;
    self.delegate = courtDetailVC;
}
@end
