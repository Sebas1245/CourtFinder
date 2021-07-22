//
//  CourtUsersUpdates.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 22/07/21.
//

#import <Foundation/Foundation.h>
#import "Court.h"

NS_ASSUME_NONNULL_BEGIN

@interface CourtUsersUpdates : NSObject
+(void)headedToParkCleanupWithCompletion:(void(^)(NSError *error, BOOL success))completion;
+(void)getUserCountForCourt:(Court *)court completion:(void(^)(NSError *error, int count))completion;
@end

NS_ASSUME_NONNULL_END
