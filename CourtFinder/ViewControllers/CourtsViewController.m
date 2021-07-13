//
//  CourtsViewController.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 12/07/21.
//

#import "CourtsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CourtCell.h"

@interface CourtsViewController () <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITableView *courtsTableView;
@end

@implementation CourtsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    self.courtsTableView.delegate = self;
    self.courtsTableView.dataSource = self;
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    NSLog(@"Accepted always use location permission");
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
