//
//  Courts.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 13/07/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Court : NSObject
@property (nonatomic, strong) NSString *placeID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic) float distanceFromUser;
@property (nonatomic) int players;
@property (nonatomic, strong) UIImage *mainPhoto;
@property (nonatomic, strong) NSArray<UIImage *> *otherPhotos;
@property (nonatomic, strong) CLLocation *location;
-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
@end

NS_ASSUME_NONNULL_END
