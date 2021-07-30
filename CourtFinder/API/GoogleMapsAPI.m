//
//  GoogleMapsAPI.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 13/07/21.
//

#import "GoogleMapsAPI.h"
#import "AFNetworking.h"



@implementation GoogleMapsAPI
+ (void)searchNearbyCourts:(CLLocation*) location completion:(void(^)(NSError* error, NSArray *searchResults))completion {
        NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
        NSDictionary *keysDictionary = [NSDictionary dictionaryWithContentsOfFile: path];
        NSString *APIKey = [keysDictionary objectForKey:@"googleMapsAPIKey"];
        NSString *requestParams = [NSString stringWithFormat:@"location=%f,%f&keyword=basketball&rankby=distance&key=%@",
                                   location.coordinate.latitude, location.coordinate.longitude, APIKey];
        NSString *requestURLString = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?";
        NSString *fullRequestURLString = [NSString stringWithFormat:@"%@%@", requestURLString, requestParams];
        NSURL *fullRequestURL = [NSURL URLWithString:fullRequestURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:fullRequestURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                              delegate:nil
                                                         delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil) {
                completion(error,nil);
            } else {
                NSDictionary *requestJSONResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSArray *results = requestJSONResults[@"results"];
                completion(nil, results);
            }
        }];
        [task resume];
}

+ (void)getDetailsForEachCourt:(NSArray*)results userLocation:(CLLocation *)userLocation completion:(void(^)(NSError* error, NSArray<Court*> *foundCourts))completion {
        NSMutableArray *foundCourts = [NSMutableArray new];
        for (int i = 0; i < results.count; i++) {
            NSMutableDictionary *courtDetails = [[NSMutableDictionary alloc] init];
            NSString *placeId = results[i][@"place_id"];
            NSNumber *totalRatings = results[i][@"user_ratings_total"];
            NSNumber *placeLat = results[i][@"geometry"][@"location"][@"lat"];
            NSNumber *placeLng = results[i][@"geometry"][@"location"][@"lng"];
            CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:placeLat.doubleValue
                                                                   longitude:placeLng.doubleValue];
            if ([totalRatings isEqual:@0]) {
                [courtDetails setValue:@"No rating" forKey:@"rating"];
            } else {
                [courtDetails setValue:results[i][@"rating"] forKey:@"rating"];
            }
            [courtDetails setValue:placeId forKey:@"placeID"];
            [courtDetails setValue:results[i][@"name"] forKey:@"name"];
            [courtDetails setValue:placeLocation forKey:@"location"];
            [courtDetails setValue:userLocation forKey:@"userLocation"];
            Court *newCourt = [[Court alloc] initWithDictionary:courtDetails];
            [foundCourts addObject:newCourt];
        }
        completion(nil, foundCourts);
}

+(void)getAddressForCourt:(NSString *)placeID completion:(void(^)(NSError* error, NSString *address))completion {
    GMSPlaceField fields = (GMSPlaceFieldFormattedAddress);
    [[GMSPlacesClient sharedClient] fetchPlaceFromPlaceID:placeID placeFields:fields sessionToken:nil
        callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"An error fetching more details ocurred: %@", error.localizedDescription);
                completion(error, nil);
            } else {
                completion(nil, [place formattedAddress]);
            }
    }];
}

+(void)getAllPhotosForCourt:(NSString*)placeID completion:(void(^)(NSError *error, NSArray<UIImage *> *photos))completion {
    GMSPlaceField fields = (GMSPlaceFieldPhotos);
    [[GMSPlacesClient sharedClient] fetchPlaceFromPlaceID:placeID placeFields:fields sessionToken:nil
        callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
        if (error != nil) {
            completion(error, nil);
        } else {
            unsigned long numberOfPlacePhotos = [[place photos] count];
            NSMutableArray *fetchedPhotos = [NSMutableArray new];
            if (numberOfPlacePhotos == 0) {
                [fetchedPhotos addObject:[UIImage imageNamed:@"no_image_available"]];
                completion(nil, fetchedPhotos);
            } else {
                dispatch_group_t photoRequestGroup = dispatch_group_create();
                NSArray *placePhotosMetadata = [place photos];
                for (GMSPlacePhotoMetadata *photoMetadata in placePhotosMetadata) {
                    dispatch_group_enter(photoRequestGroup);
                    [self getOnePhotoWithMetadata:photoMetadata completion:^(NSError * _Nonnull error, UIImage * _Nonnull photo) {
                        if (error != nil) {
                            completion(error, nil);
                        } else {
                            [fetchedPhotos addObject:photo];
                            dispatch_group_leave(photoRequestGroup);
                        }
                    }];
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_group_wait(photoRequestGroup, DISPATCH_TIME_FOREVER);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil,fetchedPhotos);
                    });
                });
            }
        }
    }];
}

+(void)getOnePhotoWithMetadata:(GMSPlacePhotoMetadata *)photoMetadata completion:(void(^)(NSError *error, UIImage *photo))completion {
    [[GMSPlacesClient sharedClient] loadPlacePhoto:photoMetadata callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error getting photo with metadata %@", error.localizedDescription);
            completion(error, nil);
        } else {
            completion(nil, photo);
        }
    }];
}

@end
