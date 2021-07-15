//
//  CourtCell.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 13/07/21.
//

#import "CourtCell.h"

@implementation CourtCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setCourt:(Court *)court{
    _court = court;
    self.cellNameLabel.text = self.court.name;
    self.cellAddressLabel.text = self.court.address;
    self.cellDistanceLabel.text = [self formattedDistance:self.court.distanceFromUser];
    [self.cellImageView setImage:self.court.mainPhoto];
}

-(NSString *)formattedDistance:(float)distanceFromUser {
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

@end
