//
//  HighlightsViewController.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 03/08/21.
//

#import "HighlightsViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Highlight.h"
#import <AVKit/AVKit.h>

@interface HighlightsViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIScrollView *fullScreenSV;
@property CGFloat viewWidth;
@property CGFloat viewHeight;
@end

@implementation HighlightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewWidth = self.view.frame.size.width;
    self.viewHeight = self.view.frame.size.height;
    self.fullScreenSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth , self.viewHeight)];
    [self.fullScreenSV setPagingEnabled:YES];
    [self setupHighlightVideosWithCompletion:^(NSError * _Nonnull error, int highlightCount) {
        if (error != nil) {
            // handle the error
        } else {
            self.fullScreenSV.backgroundColor = [UIColor systemBackgroundColor];
            self.fullScreenSV.contentSize = CGSizeMake(self.viewWidth, self.viewHeight * highlightCount);
            [self.view addSubview:self.fullScreenSV];
        }
    }];
}

- (IBAction)tappedUploadButton:(id)sender {
    UIImagePickerController *camera = [UIImagePickerController new];
    camera.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
    camera.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"Entering first if");
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeMovie]) {
            camera.sourceType = UIImagePickerControllerSourceTypeCamera;
        }  else {
            camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    }
    [self presentViewController:camera animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSLog(@"VideoURL = %@", videoURL);
    [Highlight uploadHighlight:videoURL completion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"Successfully uploaded the highlight");
        }
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)setupHighlightVideosWithCompletion:(void(^)(NSError *error, int highlightCount))completion {
    [Highlight getHighlightsWithCompletion:^(NSError * _Nonnull error, NSArray<Highlight *> * _Nonnull highlights) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            completion(error, 0);
        } else {
            int index = 0;
            for (Highlight *highlight in highlights) {
                NSURL *highlightURL = [NSURL URLWithString:highlight.highlightVideo.url];
                AVPlayer *highlightPlayer = [AVPlayer playerWithURL:highlightURL];
                highlightPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                AVPlayerLayer *highlightPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:highlightPlayer];
                highlightPlayerLayer.frame = CGRectMake(0, self.viewHeight * index - 40, self.viewWidth, self.viewHeight-40);
                highlightPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                [self.fullScreenSV.layer addSublayer:highlightPlayerLayer];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(playerItemDidEnd:)
                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                           object:[highlightPlayer currentItem]];
                [highlightPlayer play];
            }
            completion(nil, (int)highlights.count);
        }
    }];
}

- (void)playerItemDidEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    NSLog(@"Stopped playing %@", playerItem.asset);
    [playerItem seekToTime:kCMTimeZero completionHandler:nil];
}
@end
