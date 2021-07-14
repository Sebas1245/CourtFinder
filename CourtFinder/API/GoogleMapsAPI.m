//
//  GoogleMapsAPI.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 13/07/21.
//

#import "GoogleMapsAPI.h"
#import "AFNetworking.h"

static NSString *const APIKey = @"AIzaSyDulKwf5yAA5noc_qcyoUA06MmF5OtPntQ";

@implementation GoogleMapsAPI
+(void)searchNearbyCourts:(CLLocation*) location searchRadius:(int) radius completion:(void(^)(NSError* error, NSArray *searchResults))completion {
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

+(void)getDetailsForEachCourt:(NSArray*)results completion: (void(^)(NSError* error, NSArray<Court*> *foundCourts))completion {
    NSMutableArray *foundCourts = [NSMutableArray new];
    for (int i = 0; i < results.count; i++) {
        NSMutableDictionary *courtDetails = [[NSMutableDictionary alloc] init];
        NSString *placeId = results[i][@"place_id"];
        [courtDetails setValue:placeId forKey:@"placeID"];
        [courtDetails setValue:results[i][@"name"] forKey:@"name"];
        [courtDetails setValue:results[i][@"rating"] forKey:@"rating"];
        Court *newCourt = [[Court alloc] initWithDictionary:courtDetails];
        [foundCourts addObject:newCourt];
    }
    completion(nil, foundCourts);
}

+(void)getAddressForCourt:(NSString *)placeID completion:(void(^)(NSError* error, NSString *address))completion{
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

+(void)getCourtPhotos:(NSString*)placeID completion:(void(^)(NSError* error, NSArray *photos))completion{
    GMSPlaceField fields = (GMSPlaceFieldPhotos);
    [[GMSPlacesClient sharedClient] fetchPlaceFromPlaceID:placeID placeFields:fields sessionToken:nil
        callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
            if (error != nil) {
                // do something else rather than just log the error
                NSLog(@"An error ocurred: %@", error.localizedDescription);
                completion(error, nil);
            } else {
                NSMutableArray *photos;
                unsigned long numberOfPlacePhotos = [[place photos] count];
                if (numberOfPlacePhotos == 0) {
                    [photos addObject:[UIImage imageNamed:@"no_image_available"]];
                    completion(nil, photos);
                } else {
                    for (int photoIndex = 0; photoIndex < numberOfPlacePhotos; photoIndex++) {
                        GMSPlacePhotoMetadata *photoMetadata = [place photos][photoIndex];
                        UIImage *photo = [self getOnePhotoWithMetadata:photoMetadata];
                        [photos addObject:photo];
                    }
                    completion(nil, photos);
                }
                
            }
    }];
}

+(UIImage * _Nullable)getOnePhotoWithMetadata:(GMSPlacePhotoMetadata *)photoMetadata {
    __block UIImage *returnedImage;
    [[GMSPlacesClient sharedClient] loadPlacePhoto:photoMetadata callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error getting photo with metadata %@", error.localizedDescription);
            returnedImage = nil;
        } else {
            returnedImage = photo;
        }
    }];
    return returnedImage;
}

@end
