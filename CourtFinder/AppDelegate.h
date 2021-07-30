//
//  AppDelegate.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 12/07/21.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentUserLocation;
@end

