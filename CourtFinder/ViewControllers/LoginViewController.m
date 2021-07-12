//
//  LoginViewController.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 12/07/21.
//

#import "LoginViewController.h"

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
}

-(void)viewStyling {
    self.loginButton.layer.cornerRadius = 15.0f;
    self.signupButton.layer.cornerRadius = 15.0f;
}

@end
