//
//  CourtCell.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 13/07/21.
//

#import "CourtCell.h"
#import "Formatter.h"

@implementation CourtCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setCourt:(Court *)court{
    _court = court;
    self.cellNameLabel.text = self.court.name;
    self.cellAddressLabel.text = self.court.address;
    self.cellDistanceLabel.text = [Formatter formattedDistance:self.court.distanceFromUser];
    self.cellUserCountLabel.text = [NSString stringWithFormat:@"%d",self.court.players];
    [self.cellImageView setImage:self.court.mainPhoto];
}
@end
