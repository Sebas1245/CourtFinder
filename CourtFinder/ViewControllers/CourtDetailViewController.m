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
@end

@implementation CourtDetailViewController
int imageBeingDisplayed = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.detailOMWButton.layer.cornerRadius = 15.0f;
    [self.detailImageView setImage:self.court.mainPhoto];
    self.detailDistanceLabel.text = [Formatter formattedDistance:self.court.distanceFromUser];
    self.detailParkLabel.text = self.court.name;
    self.detailRatingLabel.text = [Formatter formattedRating:self.court.rating];
    self.detailAddressLabel.text = self.court.address;
    self.detailImagesPageControl.numberOfPages = self.court.otherPhotos.count;
}

- (IBAction)swipeLeftOnPhoto:(id)sender {
    if (imageBeingDisplayed < self.court.otherPhotos.count - 1) {
        imageBeingDisplayed++;
        [self reflectImageChange];
    }
}

- (IBAction)swipeRightOnPhoto:(id)sender {
    if (imageBeingDisplayed > 0) {
        imageBeingDisplayed--;
        [self reflectImageChange];
    }
}

- (IBAction)tappedPageDots:(id)sender {
    UIPageControl *pageControl = sender;
    imageBeingDisplayed = (int)pageControl.currentPage;
    [self reflectImageChange];
}


- (void)reflectImageChange {
    self.detailImageView.image = self.court.otherPhotos[imageBeingDisplayed];
    self.detailImagesPageControl.currentPage = imageBeingDisplayed;
}

- (IBAction)tappedOnMyWayBtn:(id)sender {
    NSString *headedToPark = [self.detailOMWButton isSelected] ? @"" : self.court.placeID;
    [self updateHeadedToPark:headedToPark];
}

- (void)updateHeadedToPark:(NSString *)headedToPark {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        currentUser[@"headedToPark"] = headedToPark;
        currentUser[@"lastSetHeadedToPark"] = [NSDate date];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                NSString * errMsg = [NSString stringWithFormat:@"Error saving opt in to park: %@", error.localizedDescription];
                [[Alert new] showErrAlertOnView:self message:errMsg title:@"Internal server error"];
            } else {
                NSString *successMsg;
                [self.detailOMWButton setSelected:![self.detailOMWButton isSelected]];
                if (![headedToPark isEqual:@""]) {
                    successMsg = @"You will now be considered for this park's headcount. Please arrive during the next 15 minutes or you will be removed from the headcount";
                } else {
                    successMsg = @"You have now been removed from the park's headcount";
                }
                [[Alert new] showSuccessAlertOnView:self message:successMsg title:@"Updated successfully"];
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
