//
//  DBUpdateActions.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 22/07/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBUpdateActions : NSObject
+(void)headedToParkCleanupWithCompletion:(void(^)(NSError *error, BOOL success))completion;
@end

NS_ASSUME_NONNULL_END
