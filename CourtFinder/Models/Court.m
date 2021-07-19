//
//  Courts.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 13/07/21.
//

#import "Court.h"
#import "GoogleMapsAPI.h"

@implementation Court
-(instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.placeID = dictionary[@"placeID"];
        self.name = dictionary[@"name"];
        self.rating = dictionary[@"rating"];
        self.location = dictionary[@"location"];
        CLLocation *currentUserLocation = dictionary[@"userLocation"];
        self.distanceFromUser = [self.location distanceFromLocation:currentUserLocation];
    }
    return self;
}

@end