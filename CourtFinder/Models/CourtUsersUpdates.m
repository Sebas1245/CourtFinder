//
//  CourtUsersUpdates.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 22/07/21.
//

#import "CourtUsersUpdates.h"
#import <Parse/Parse.h>

@implementation CourtUsersUpdates
+ (void)headedToParkCleanupWithCompletion:(void(^)(NSError *error, BOOL success))completion {
    PFQuery *query = [PFUser query];
    [query whereKeyExists:@"headedToPark"];
    [query includeKeys:[NSArray arrayWithObjects:@"headedToPark", @"lastSetHeadedToPark", @"username", nil]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        NSMutableArray *updatedUsers = [NSMutableArray new];
        for (PFUser *user in users) {
            NSTimeInterval timeDifference = [[NSDate date] timeIntervalSinceDate:user[@"lastSetHeadedToPark"] ];
            NSLog(@"User=%@", user.username);
            NSLog(@"timeDifference in minutes = %f", timeDifference/60);
            // if the time difference is greater than 15 minutes, set user as we would set someone who has opted out
            if (timeDifference > 900) {
                user[@"headedToPark"] = [NSNull new];
                user[@"lastSetHeadedToPark"] = [NSDate date];
                NSLog(@"Adding updated user %@", user.username);
                [updatedUsers addObject:user];
            } else {
                NSLog(@"User not updated = %@", user.username);
            }
        }
        NSLog(@"Out of for loop");
        [PFUser saveAllInBackground:updatedUsers block:^(BOOL succeeded, NSError * _Nullable error) {
            NSLog(@"Done updating user opt ins");
            completion(error, succeeded);
        }];
    }];
    
}

+ (void)getUserCountForCourt:(Court *)court completion:(void(^)(NSError *error, int count))completion {
    PFQuery *optInQuery = [PFUser query];
    [optInQuery whereKey:@"headedToPark" equalTo:court.placeID];
    PFQuery *locationQuery = [PFUser query];
    PFGeoPoint *courtLocation = [PFGeoPoint new];
    courtLocation.latitude = court.location.coordinate.latitude;
    courtLocation.longitude = court.location.coordinate.longitude;
    [locationQuery whereKey:@"lastLocation" nearGeoPoint:courtLocation withinKilometers:0.1];
    [locationQuery whereKey:@"headedToPark" equalTo:[NSNull new]];
    [optInQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable optInUsers, NSError * _Nullable error) {
        if (error != nil) {
            completion(error, 0);
        } else {
            [locationQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable atLocationUsers, NSError * _Nullable error) {
                if (error != nil) {
                    completion(error, 0);
                } else {
                    completion(nil, (int)(optInUsers.count + atLocationUsers.count));
                }
            }];
        }
    }];
}
@end
