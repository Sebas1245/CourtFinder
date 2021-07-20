//
//  FullScreenImagesViewController.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 20/07/21.
//

#import "FullScreenImagesViewController.h"

@interface FullScreenImagesViewController ()
@property (nonatomic, strong) UIScrollView *fullScreenSV;
@property CGFloat viewWidth;
@property CGFloat viewHeight;
@end

@implementation FullScreenImagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewWidth = self.view.frame.size.width;
    self.viewHeight = self.view.frame.size.height;
    self.fullScreenSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 76, self.viewWidth , self.viewHeight)];
    [self.fullScreenSV setPagingEnabled:YES];
    [self setupScrollViewImages];
    self.fullScreenSV.backgroundColor = [UIColor blackColor];
    self.fullScreenSV.contentSize = CGSizeMake(self.viewWidth * self.photos.count, self.viewHeight);
    [self.view addSubview:self.fullScreenSV];
}

-(void)setupScrollViewImages {
    NSLog(@"%lu", (unsigned long)self.photos.count);
    for(int i = 0; i < self.photos.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*self.viewWidth, 0, self.viewWidth, self.viewHeight + 10)];
        imageView.image = self.photos[i];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.fullScreenSV addSubview:imageView];
    }
}

- (IBAction)handleClose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
