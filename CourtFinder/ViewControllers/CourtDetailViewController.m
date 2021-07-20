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

@interface CourtDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@property (weak, nonatomic) IBOutlet UILabel *detailDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailRatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailParkLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailUserCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailOMWButton;
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
}

- (IBAction)swipeLeftOnPhoto:(id)sender {
    if (imageBeingDisplayed < self.court.otherPhotos.count - 1) {
        imageBeingDisplayed++;
        self.detailImageView.image = self.court.otherPhotos[imageBeingDisplayed];
    }
}

- (IBAction)swipeRightOnPhoto:(id)sender {
    if (imageBeingDisplayed > 0) {
        imageBeingDisplayed--;
        self.detailImageView.image = self.court.otherPhotos[imageBeingDisplayed];
    }
}

- (IBAction)tappedOnMyWayBtn:(id)sender {
    if ([self.detailOMWButton isSelected]) {
        [self updateHeadedToPark:@"" timestamp:nil selectedState:false];
    } else {
        [self updateHeadedToPark:self.court.placeID timestamp:[NSDate now] selectedState:true];
    }
}

-(void)updateHeadedToPark:(NSString *)headedToPark timestamp:(NSDate *)now selectedState:(BOOL) selectedState{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        currentUser[@"headedToPark"] = headedToPark;
        currentUser[@"lastSetHeadedToPark"] = now == nil ? [NSNull new] : now;
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                NSString * errMsg = [NSString stringWithFormat:@"Error saving opt in to park: %@", error.localizedDescription];
                [[Alert new] showErrAlertOnView:self message:errMsg title:@"Internal server error"];
            } else {
                NSString *successMsg;
                [self.detailOMWButton setSelected:selectedState];
                if (selectedState) {
                    successMsg = @"You will now be considered for this park's headcount. Please arrive during the next 15 minutes or you will be removed from the headcount";
                } else {
                    successMsg = @"You have now been removed from the park's headcount";
                }
                [[Alert new] showSuccessAlertOnView:self message:successMsg title:@"Updated successfully"];
            }
        }];
    }
}

@end
