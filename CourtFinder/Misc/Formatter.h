//
//  Formatter.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 19/07/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Formatter : NSObject
+(NSString *)formattedDistance:(float)distanceFromUser;
+(NSString *)formattedRating:(NSNumber *)rating;
@end

NS_ASSUME_NONNULL_END
