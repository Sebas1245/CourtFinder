//
//  GoogleMapsAPI.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 13/07/21.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoogleMapsAPI : NSObject
+(void)searchNearbyCourts:(CLLocation*) location searchRadius:(int) radius completion:(void(^)(NSError* error, NSArray *foundCourts))completion;
@end

NS_ASSUME_NONNULL_END
