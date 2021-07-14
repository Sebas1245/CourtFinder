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
+(void)getDetailsForEachCourt:(NSArray*)results completion: (void(^)(NSError* error, NSArray<Court*> *foundCourts))completion;
+(void)getAddressForCourt:(NSString *)placeID completion:(void(^)(NSError* error, NSString *address))completion;
+(void)getCourtPhotos:(NSString*)placeID completion:(void(^)(NSError* error, NSArray *photos))completion;
+(UIImage * _Nullable)getOnePhotoWithMetadata:(GMSPlacePhotoMetadata *)photoMetadata;
@end

NS_ASSUME_NONNULL_END
