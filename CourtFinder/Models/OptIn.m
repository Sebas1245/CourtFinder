//
//  Database.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 27/07/21.
//

#import "OptIn.h"

@implementation OptIn
+ (void)getOptInForUser:(PFUser *)user courtID:(NSString *)courtID completion:(void(^)(BOOL exists, PFObject *optIn, NSError  * _Nullable error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"OptIn"];
    [query whereKey:@"userID" equalTo:user.objectId];
    [query whereKey:@"headedToPark" equalTo:courtID];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error != nil) {
            completion(false, nil, error);
        } else {
            if (objects.count > 0) {
                completion(true, objects.firstObject, nil);
            } else {
                completion(false, nil, nil);
            }
        }
    }];
}

+ (void)createOptInForUser:(PFUser *)user courtID:(NSString *)courtID completion:(void(^)(BOOL success,  PFObject *newOptIn, NSError *error))completion {
    PFObject *newOptIn = [PFObject objectWithClassName:@"OptIn"];
    newOptIn[@"userID"] = user;
    newOptIn[@"headedToPark"] = courtID;
    newOptIn[@"expiresAt"] = [[NSDate new] dateByAddingTimeInterval:900];
    [newOptIn saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        completion(succeeded, newOptIn, error);
    }];
}

+ (void)deleteOptIn:(PFObject *)optIn completion:(void(^)(BOOL success, NSError *error))completion {
    PFQuery *deleteOptInQry = [PFQuery queryWithClassName:@"OptIn"];
    [deleteOptInQry getObjectInBackgroundWithId:optIn.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            completion(succeeded, error);
        }];
    }];
}
@end
