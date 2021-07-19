//
//  Alert.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 12/07/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Alert : NSObject
-(void)showErrAlertOnView:(UIViewController*)viewController  message:(NSString*)message title:(NSString*)title;
@end

NS_ASSUME_NONNULL_END
