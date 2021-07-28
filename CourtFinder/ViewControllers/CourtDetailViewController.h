//
//  CourtDetailViewController.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 16/07/21.
//

#import "ViewController.h"
#import "Court.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CourtDetailViewControllerDelegate <NSObject>
-(void)tappedOptInOnCourtNumber:(NSIndexPath *)courtIndexPath;
@end

@interface CourtDetailViewController : ViewController
@property (strong, nonatomic) Court *court;
@property (strong, nonatomic) NSIndexPath *courtIndexPath;
@property (weak, nonatomic) id<CourtDetailViewControllerDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
