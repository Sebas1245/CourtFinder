//
//  HighlightsViewController.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 03/08/21.
//

#import "HighlightsViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface HighlightsViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation HighlightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
