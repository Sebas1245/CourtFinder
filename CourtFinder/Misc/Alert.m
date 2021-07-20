//
//  Alert.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 12/07/21.
//

#import "Alert.h"

@implementation Alert
-(void)showErrAlertOnView:(UIViewController*)viewController  message:(NSString*)message title:(NSString*)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [viewController presentViewController:alert animated:true completion:nil];
}

-(void)showSuccessAlertOnView:(UIViewController*)viewController  message:(NSString*)message title:(NSString*)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [viewController presentViewController:alert animated:true completion:nil];
}

@end
