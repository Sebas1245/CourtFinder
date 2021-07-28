//
//  CourtDetailViewController.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 16/07/21.
//

#import "CourtDetailViewController.h"
#import "GoogleMapsAPI.h"
#import "Alert.h"
#import "Formatter.h"
#import <Parse/Parse.h>
#import "FullScreenImagesViewController.h"
#import "OptIn.h"

@interface CourtDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@property (weak, nonatomic) IBOutlet UILabel *detailDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailRatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailParkLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailUserCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailOMWButton;
@property (weak, nonatomic) IBOutlet UIPageControl *detailImagesPageControl;
@property int imageBeingDisplayed;
@property BOOL optedIn;
@property PFObject *optIn;
@end

@implementation CourtDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self getOnLoadButtonStatus];
    self.imageBeingDisplayed = 0;
    self.detailOMWButton.layer.cornerRadius = 15.0f;
    [self.detailImageView setImage:self.court.mainPhoto];
    self.detailDistanceLabel.text = [Formatter formattedDistance:self.court.distanceFromUser];
    self.detailParkLabel.text = self.court.name;
    self.detailRatingLabel.text = [Formatter formattedRating:self.court.rating];
    self.detailUserCountLabel.text = [NSString stringWithFormat:@"%d", self.court.players];
    self.detailAddressLabel.text = self.court.address;
    self.detailImagesPageControl.numberOfPages = self.court.otherPhotos.count;
}

- (IBAction)swipeLeftOnPhoto:(id)sender {
    if (self.imageBeingDisplayed < self.court.otherPhotos.count - 1) {
        self.imageBeingDisplayed++;
        [self reflectImageChange];
    }
}

- (IBAction)swipeRightOnPhoto:(id)sender {
    if (self.imageBeingDisplayed > 0) {
        self.imageBeingDisplayed--;
        [self reflectImageChange];
    }
}

- (IBAction)tappedPageDots:(id)sender {
    UIPageControl *pageControl = sender;
    self.imageBeingDisplayed = (int)pageControl.currentPage;
    [self reflectImageChange];
}


- (void)reflectImageChange {
    self.detailImageView.image = self.court.otherPhotos[self.imageBeingDisplayed];
    self.detailImagesPageControl.currentPage = self.imageBeingDisplayed;
}

- (IBAction)tappedOnMyWayBtn:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    __block NSString *alertTitle;
    __block NSString *alertMsg;
    if (self.optedIn) {
        [OptIn deleteOptIn:self.optIn completion:^(BOOL success, NSError * _Nonnull error) {
            if (error != nil) {
                alertMsg = [NSString stringWithFormat:@"Error removing opt in: %@", error.localizedDescription];
                alertTitle = @"Internal server error";
            } else {
                alertTitle = @"Successfully removed";
                alertMsg = @"You have now been removed from the park's headcount";
                self.optedIn = false;
                [self updateOptedInButton];
            }
            [[Alert new] showSuccessAlertOnView:self message:alertMsg title:alertTitle];
        }];
    } else {
        [OptIn createOptInForUser:currentUser courtID:self.court.placeID completion:^(BOOL success, PFObject * _Nonnull newOptIn, NSError * _Nonnull error) {
            if (error != nil) {
                alertTitle = @"Successfully removed";
                alertMsg = @"You have now been removed from the park's headcount";
            } else {
                alertTitle = @"Successfully opted in";
                alertMsg = @"You will now be considered for this park's headcount. Please arrive during the next 15 minutes or you will be removed from the headcount";
                self.optIn = newOptIn;
                self.optedIn = true;
                [self updateOptedInButton];
            }
            [[Alert new] showSuccessAlertOnView:self message:alertMsg title:alertTitle];
        }];
    }
}

- (void)updateOptedInButton {
    if (self.court.distanceFromUser < 100) {
        [self.detailOMWButton setEnabled:false];
        [self.detailOMWButton setTitle:@"Count me in!" forState:UIControlStateDisabled];
        [self.detailOMWButton setBackgroundColor:[UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:0.2]];
        [self.detailOMWButton setTitleColor:[UIColor colorWithRed:0.29 green:0.53 blue:0.91 alpha:0.5]
                                   forState:UIControlStateDisabled];
        return;
    } else {
        if (self.optedIn) {
            [self.detailOMWButton setTitle:@"On my way!" forState:UIControlStateSelected];
            [self.detailOMWButton setBackgroundColor:[UIColor colorWithRed:0.80 green:0.39 blue:0.00 alpha:1.0]];
            [self.detailOMWButton setSelected:true];
        } else {
            [self.detailOMWButton setTitle:@"Count me in!" forState:UIControlStateNormal];
            [self.detailOMWButton setBackgroundColor:[UIColor colorWithRed:1.00 green:0.49 blue:0.00 alpha:1.0]];
            [self.detailOMWButton setSelected:false];
        }
    }
}

- (void)getOnLoadButtonStatus {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [OptIn getOptInForUser:currentUser courtID:self.court.placeID completion:^(BOOL exists, PFObject *optIn, NSError * _Nullable error) {
            if (error != nil) {
                NSString *errMsg = [NSString stringWithFormat:@"Error getting opt in information: %@", error.localizedDescription];
                [[Alert new] showErrAlertOnView:self message:errMsg title:@"Internal server error"];
            } else {
                self.optedIn = exists;
                self.optIn = optIn;
                [self updateOptedInButton];
            }
        }];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FullScreenImagesViewController *fullScreenImagesVC = [segue destinationViewController];
    fullScreenImagesVC.photos = self.court.otherPhotos;
}
@end
