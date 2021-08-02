//
//  AppDelegate.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 12/07/21.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
@import GooglePlaces;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupLocationMonitor:launchOptions];
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *keysDictionary = [NSDictionary dictionaryWithContentsOfFile: path];
    ParseClientConfiguration *parseConfig = [ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration>  _Nonnull configuration) {
        configuration.applicationId = [keysDictionary objectForKey:@"parseApplicationId"];
        configuration.clientKey =[keysDictionary objectForKey:@"parseClientKey"];
        configuration.server = @"https://parseapi.back4app.com";
    }];
    [Parse initializeWithConfiguration:parseConfig];
    [GMSPlacesClient provideAPIKey:[keysDictionary objectForKey:@"googleMapsAPIKey"]];
    return YES;
}

- (void)setupLocationMonitor:(NSDictionary *)launchOptions {
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    CLAuthorizationStatus locationAuthStatus = [self.locationManager authorizationStatus];
    if ([launchOptions valueForKey:UIApplicationLaunchOptionsLocationKey] != nil) {
        NSLog(@"relaunching becuase of significant location change");
        [self.locationManager startMonitoringSignificantLocationChanges];
    } else {
        if (locationAuthStatus == kCLAuthorizationStatusAuthorizedAlways) {
            NSLog(@"launching with authorization to always use location");
            [self.locationManager startMonitoringSignificantLocationChanges];
        } else {
            NSLog(@"launching with no authorization to always use location - requesting authorization");
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
            [self.locationManager startMonitoringSignificantLocationChanges];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"Location manager picked up a change");
    self.currentUserLocation = locations.lastObject;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationUpdated" object:nil];
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
