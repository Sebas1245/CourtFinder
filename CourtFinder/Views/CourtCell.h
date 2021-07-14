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
@end

NS_ASSUME_NONNULL_END
