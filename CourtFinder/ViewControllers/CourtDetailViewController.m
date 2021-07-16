//
//  CourtDetailViewController.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 16/07/21.
//

#import "CourtDetailViewController.h"

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.detailImageView setImage:self.court.mainPhoto];
    self.detailDistanceLabel.text = [self formattedDistance:self.court.distanceFromUser];
    self.detailParkLabel.text = self.court.name;
    self.detailRatingLabel.text = [NSString stringWithFormat:@"%@",self.court.rating];
    self.detailAddressLabel.text = self.court.address;
    
}


-(NSString *)formattedDistance:(float)distanceFromUser {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode: NSNumberFormatterRoundDown];
    if (distanceFromUser > 1000) {
        float roundedDistance = round(2.0f * distanceFromUser) / (2.0f * 1000.0f);
        NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithFloat:roundedDistance]];
        return [NSString stringWithFormat:@"%@ km",numberString];
    } else {
        float roundedDistance = round(2.0f * distanceFromUser) / 2.0f;
        NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithFloat:roundedDistance]];
        return [NSString stringWithFormat:@"%@ m",numberString];
    }
}

@end
