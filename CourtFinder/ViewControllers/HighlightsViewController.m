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
#import "HighlightCell.h"

@interface HighlightsViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIScrollView *fullScreenSV;
@property (nonatomic, strong) NSArray <Highlight*> *highlights;
@property (weak, nonatomic) IBOutlet UITableView *highlightTableView;
@property CGFloat viewWidth;
@property CGFloat viewHeight;
@end

@implementation HighlightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.highlightTableView.delegate = self;
    self.highlightTableView.dataSource = self;
    self.highlightTableView.rowHeight = self.view.frame.size.height;
    [self.highlightTableView setPagingEnabled:YES];
    [self fetchHighlights];
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

- (void)fetchHighlights {
    [Highlight getHighlightsWithCompletion:^(NSError * _Nonnull error, NSArray<Highlight *> * _Nonnull highlights) {
        if (error != nil) {
            NSLog(@"error: %@", error.localizedDescription);
        } else {
            self.highlights = highlights;
            NSLog(@"Finished fetching highlights");
            [self.highlightTableView reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.highlights.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HighlightCell *cell = [self.highlightTableView dequeueReusableCellWithIdentifier:@"HighlightTableCell"];
    cell.highlight = self.highlights[indexPath.row];
    return cell;
}
@end
