//
//  LoginViewController.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 12/07/21.
//

#import "LoginViewController.h"
#import "Alert.h"
#import <Parse/Parse.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewStyling];
}

- (IBAction)handleLogin:(id)sender {
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (error != nil) {
            NSString *errorMsg = @"There was an error logging you in. Please verify your username and password and check that you have a good network connection";
            [[Alert new] showErrAlertOnView:self message:errorMsg title:@"Login In Error"];
        } else {
            [self performSegueWithIdentifier:@"SuccessfulAuth" sender:nil];
        }
    }];
}

-(void)viewStyling {
    self.loginButton.layer.cornerRadius = 15.0f;
    self.signupButton.layer.cornerRadius = 15.0f;
}

@end
