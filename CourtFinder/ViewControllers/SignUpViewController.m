//
//  SignUpViewController.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 12/07/21.
//

#import "SignUpViewController.h"
#import "Alert.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@end

@implementation SignUpViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.signupButton.layer.cornerRadius = 15.0f;
}

- (IBAction)handleCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleSignup:(id)sender {
    PFUser *newUser = [PFUser user];
    newUser.email = self.emailTextField.text;
    newUser.username = self.usernameTextField.text;
    newUser.password = self.passwordTextField.text;
    newUser[@"phone"] = self.phoneTextField.text;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSString *errorMsg = [NSString stringWithFormat:@"There was an error performing signup: %@", error.localizedDescription ];
            [[Alert new] showErrAlertOnView:self message:errorMsg title:@"Sign Up Error"];
        } else {
            [self performSegueWithIdentifier:@"SuccessfulSignin" sender:nil];
        }
    }];
}
@end
