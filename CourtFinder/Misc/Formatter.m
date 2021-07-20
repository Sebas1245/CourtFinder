//
//  Formatter.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 19/07/21.
//

#import "Formatter.h"

@implementation Formatter
+ (NSString *)formattedDistance:(float)distanceFromUser {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode: NSNumberFormatterRoundDown];
    if (distanceFromUser > 1000) {
        float roundedDistance = round(2.0f * distanceFromUser) / (2.0f * 1000.0f);
        NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithFloat:roundedDistance]];
        return [NSString stringWithFormat:@"%@ km",numberString];
    } else {
        float roundedDistance = round(2.0f * distanceFromUser) / 2.0f;
        NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithFloat:roundedDistance]];
        return [NSString stringWithFormat:@"%@ m",numberString];
    }
}

+ (NSString *)formattedRating:(NSNumber *)rating {
    if (rating == nil) {
        return @"No rating available";
    } else {
        return [NSString stringWithFormat:@"%@", rating];
    }
}
@end
