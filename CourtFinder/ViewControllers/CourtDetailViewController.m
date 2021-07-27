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
@end

@implementation CourtDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.optedIn = [self getOnLoadButtonStatus];
    [self updateOptedInButton];
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
    if (currentUser) {
        currentUser[@"headedToPark"] = self.optedIn ? [NSNull new] : self.court.placeID;
        currentUser[@"lastSetHeadedToPark"] = [NSDate date];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                NSString * errMsg = [NSString stringWithFormat:@"Error saving opt in to park: %@", error.localizedDescription];
                [[Alert new] showErrAlertOnView:self message:errMsg title:@"Internal server error"];
            } else {
                NSString *successMsg;
                if (!self.optedIn) {
                    successMsg = @"You will now be considered for this park's headcount. Please arrive during the next 15 minutes or you will be removed from the headcount";
                    self.optedIn = true;
                } else {
                    successMsg = @"You have now been removed from the park's headcount";
                    self.optedIn = false;
                }
                [self updateOptedInButton];
                [[Alert new] showSuccessAlertOnView:self message:successMsg title:@"Updated successfully"];
            }
        }];
    }
}

- (void)updateOptedInButton {
    if (self.optedIn) {
        [self.detailOMWButton setTitle:@"On my way!" forState:UIControlStateSelected];
        [self.detailOMWButton setSelected:true];
    } else {
        [self.detailOMWButton setTitle:@"Count me in!" forState:UIControlStateNormal];
        [self.detailOMWButton setSelected:false];
    }
}

- (BOOL)getOnLoadButtonStatus {
    PFUser *currentUser = [PFUser currentUser];
    if (self.court.distanceFromUser < 100) {
        [self.detailOMWButton setEnabled:false];
        [self.detailOMWButton setBackgroundColor:[UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:0.2]];
        [self.detailOMWButton setTitleColor:[UIColor colorWithRed:0.29 green:0.53 blue:0.91 alpha:0.8]
                                   forState:UIControlStateDisabled];
    }
    return (currentUser[@"headedToPark"] != [NSNull new]);
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FullScreenImagesViewController *fullScreenImagesVC = [segue destinationViewController];
    fullScreenImagesVC.photos = self.court.otherPhotos;
}
@end
