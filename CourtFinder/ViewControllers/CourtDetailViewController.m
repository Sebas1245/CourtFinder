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

@end
