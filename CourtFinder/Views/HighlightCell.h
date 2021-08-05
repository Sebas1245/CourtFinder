//
//  HighlightCell.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 04/08/21.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "Highlight.h"

NS_ASSUME_NONNULL_BEGIN

@interface HighlightCell : UITableViewCell
@property (strong, nonatomic) Highlight *highlight;
@property (strong, nonatomic) AVPlayer *highlightPlayer;
@end

NS_ASSUME_NONNULL_END
