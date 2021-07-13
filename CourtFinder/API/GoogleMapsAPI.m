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
+(void)searchNearbyCourts:(CLLocation*) location searchRadius:(int) radius completion:(void(^)(NSError* error, NSArray *foundCourts))completion {
    NSString *requestParams = [NSString stringWithFormat:@"location=%f,%f&keyword=basketball&rankby=distance&key=%@",
                               location.coordinate.latitude, location.coordinate.longitude, APIKey];
    NSString *requestURLString = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?";
    NSString *fullRequestURLString = [NSString stringWithFormat:@"%@%@", requestURLString, requestParams];
    NSURL *fullRequestURL = [NSURL URLWithString:fullRequestURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:fullRequestURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil
                            delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            completion(error,nil);
        } else {
            NSDictionary *requestJSONResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *results = requestJSONResults[@"results"];
            for (int i = 0; i < results.count; i++) {
                NSLog(@"Index %d", i);
                NSLog(@"Name: %@", results[i][@"name"]);
                NSLog(@"rating: %@", results[i][@"rating"]);
                NSString *placeId = results[i][@"place_id"];
                NSLog(@"placeID: %@", placeId);
                GMSPlaceField fields = (GMSPlaceFieldPhotos | GMSPlaceFieldFormattedAddress);
                [[GMSPlacesClient sharedClient] fetchPlaceFromPlaceID:placeId placeFields:fields sessionToken:nil
                callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
                                    if(error != nil) {
                                        NSLog(@"An error ocurred: %@", error.localizedDescription);
                                        completion(error,nil);
                                    } else {
                                        NSLog(@"Formatted address: %@", [place formattedAddress]);
                                        unsigned long numberOfPlacePhotos = [[place photos] count];
                                        if(numberOfPlacePhotos != 0) {
                                            for (int photoIndex = 0; photoIndex < numberOfPlacePhotos; photoIndex++) {
                                                GMSPlacePhotoMetadata *photoMetadata = [place photos][photoIndex];
                                                [[GMSPlacesClient sharedClient] loadPlacePhoto:photoMetadata
                                                callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
                                                    if (error != nil) {
                                                        completion(error,nil);
                                                    } else {
                                                        NSLog(@"photo %d %@", photoIndex, photo);
                                                    }
                                                }];
                                            }
                                        }
                                    }
                }];
            }
            completion(nil, results);
        }
    }];
    [task resume];
}

@end
