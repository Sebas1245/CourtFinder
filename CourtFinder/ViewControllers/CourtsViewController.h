//
//  CourtsViewController.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 12/07/21.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CourtsViewController : ViewController <CLLocationManagerDelegate>
@property (strong,nonatomic) CLLocationManager *locationManager;
@end

NS_ASSUME_NONNULL_END
