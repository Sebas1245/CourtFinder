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
    NSLog(@"Name: %@", self.court.name);
    NSLog(@"Address: %@", self.court.address);
}
@end
