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
            completion(nil, results);
        }
    }];
    [task resume];
}
@end
