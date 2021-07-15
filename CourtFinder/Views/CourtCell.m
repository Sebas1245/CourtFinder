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
    [self.cellImageView setImage:self.court.mainPhoto];
}
@end
