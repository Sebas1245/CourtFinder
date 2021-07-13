//
//  SettingsScreenViewController.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 13/07/21.
//

#import "SettingsScreenViewController.h"
#import "SceneDelegate.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface SettingsScreenViewController ()

@end

@implementation SettingsScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)handleLogout:(id)sender {
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
    
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        [self dismissViewControllerAnimated:false completion:nil];
    }];
}


@end
