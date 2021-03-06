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
    PFQuery *query = [PFQuery queryWithClassName:@"OptIn"];
    [query whereKey:@"expiresAt" lessThan:[NSDate date]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable expiredOptIns, NSError * _Nullable error) {
        if (error != nil) {
            completion(error, false);
        } else {
            for (PFObject *expiredOptIn in expiredOptIns) {
                NSLog(@"%@", expiredOptIn[@"expiresAt"]);
            }
            [PFObject deleteAllInBackground:expiredOptIns block:^(BOOL succeeded, NSError * _Nullable error) {
                completion(error, succeeded);
            }];
        }
    }];
}

+ (void)getUserCountForCourt:(Court *)court completion:(void(^)(NSError *error, int count))completion {
    PFQuery *soloOptIns = [PFUser query];
    [soloOptIns whereKey:@"playingSolo" equalTo:@YES];
    PFQuery *optInQuery = [PFQuery queryWithClassName:@"OptIn"];
    [optInQuery whereKey:@"headedToPark" equalTo:court.placeID];
    [optInQuery whereKey:@"user" doesNotMatchQuery:soloOptIns];
    [optInQuery includeKey:@"user"];
    [optInQuery findObjectsInBackgroundWithBlock:^(NSArray* _Nullable optInUsers, NSError * _Nullable error) {
        if (error != nil) {
            completion(error, 0);
        } else {
            NSMutableArray *optInUserUsernames = [NSMutableArray new];
            for (PFObject *optInUser in optInUsers) {
                [optInUserUsernames addObject:optInUser[@"user"][@"username"]];
            }
            PFQuery *locationQuery = [PFUser query];
            PFGeoPoint *courtLocation = [PFGeoPoint new];
            courtLocation.latitude = court.location.coordinate.latitude;
            courtLocation.longitude = court.location.coordinate.longitude;
            [locationQuery whereKey:@"lastLocation" nearGeoPoint:courtLocation withinKilometers:0.1];
            [locationQuery whereKey:@"playingSolo" notEqualTo:@YES];
            [locationQuery whereKey:@"username" notContainedIn:optInUserUsernames];
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
