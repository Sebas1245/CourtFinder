//
//  CourtsViewController.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 12/07/21.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Court.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CourtViewControllerDelegate <NSObject>

- (void)updatedCourt:(Court *)updatedCourt;

@end

@interface CourtsViewController : ViewController
@property (weak, nonatomic) id<CourtViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
