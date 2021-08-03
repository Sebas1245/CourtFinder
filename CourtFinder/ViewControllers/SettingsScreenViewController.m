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
#import "AppDelegate.h"

@interface SettingsScreenViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *soloOptionSwitch;
@end

@implementation SettingsScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameLabel.text = PFUser.currentUser.username;
    [self.soloOptionSwitch setOn:[PFUser.currentUser[@"playingSolo"] boolValue]];
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

- (IBAction)switchTapped:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        currentUser[@"playingSolo"] = self.soloOptionSwitch.on ? @YES : @NO;
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"An error updating playing solo field ocurred: %@", error.localizedDescription);
            } else {
                NSLog(@"Successfully updated playing solo field");
            }
        }];
    }
}
@end
