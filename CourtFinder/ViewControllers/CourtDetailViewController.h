//
//  CourtDetailViewController.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 16/07/21.
//

#import "ViewController.h"
#import "Court.h"

NS_ASSUME_NONNULL_BEGIN

@interface CourtDetailViewController : ViewController
@property (weak, nonatomic) Court *court;
@end

NS_ASSUME_NONNULL_END
