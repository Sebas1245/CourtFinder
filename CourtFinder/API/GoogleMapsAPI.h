//
//  GoogleMapsAPI.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 13/07/21.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Court.h"
@import GooglePlaces;

NS_ASSUME_NONNULL_BEGIN

@interface GoogleMapsAPI : NSObject
+(void)searchNearbyCourts:(CLLocation*) location searchRadius:(int) radius completion:(void(^)(NSError* error, NSArray *searchResults))completion;
+(void)getDetailsForEachCourt:(NSArray*)results userLocation:(CLLocation *)userLocation completion: (void(^)(NSError* error, NSArray<Court*> *foundCourts))completion;
+(void)getAddressForCourt:(NSString *)placeID completion:(void(^)(NSError* error, NSString *address))completion;
+(void)getMainCourtPhoto:(NSString*)placeID completion:(void(^)(NSError* error, UIImage *photo))completion;
+(void)getOnePhotoWithMetadata:(GMSPlacePhotoMetadata *)photoMetadata completion:(void(^)(NSError *error, UIImage *photo))completion;
@end

NS_ASSUME_NONNULL_END
