//
//  Courts.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 13/07/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Courts : NSObject
@property (nonatomic, strong) NSString *placeID;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) float rating;
@property (nonatomic) float distanceFromUser;
@property (nonatomic) int players;
@property (nonatomic, strong) NSArray *photos;
@end

NS_ASSUME_NONNULL_END
