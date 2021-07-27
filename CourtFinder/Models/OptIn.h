//
//  Database.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 27/07/21.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface OptIn : NSObject
+(void)getOptInForUser:(PFUser *)user courtID:(NSString *)courtID completion:(void(^)(BOOL exists, PFObject *optIn, NSError  * _Nullable error))completion;
+(void)createOptInForUser:(PFUser *)user courtID:(NSString *)courtID completion:(void(^)(BOOL success,  PFObject *newOptIn, NSError *error))completion;
+(void)deleteOptIn:(PFObject *)optIn completion:(void(^)(BOOL success, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
