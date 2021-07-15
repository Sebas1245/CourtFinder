//
//  CourtCell.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 13/07/21.
//

#import <UIKit/UIKit.h>
#import "Court.h"

NS_ASSUME_NONNULL_BEGIN

@interface CourtCell : UITableViewCell
@property (weak, nonatomic) Court *court;
@property (weak, nonatomic) IBOutlet UILabel *cellNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *cellAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellUserCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellDistanceLabel;
@end

NS_ASSUME_NONNULL_END
