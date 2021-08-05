//
//  Highlight.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 03/08/21.
//

#import "Highlight.h"

@implementation Highlight
@dynamic highlightID;
@dynamic userID;
@dynamic user;
@dynamic highlightVideo;
+ (nonnull NSString *)parseClassName {
    return @"Highlight";
}

+ (void)uploadHighlight:(NSURL *)highlightVideoURL completion: (PFBooleanResultBlock  _Nullable)completion {
    Highlight *newHighlight = [Highlight new];
    newHighlight.highlightVideo = [self getPFFileFromVideoURL:highlightVideoURL];
    newHighlight.user = [PFUser currentUser];
    [newHighlight saveInBackgroundWithBlock:completion];
}

+ (PFFileObject *)getPFFileFromVideoURL: (NSURL * _Nullable)videoUrl {
    // check if image is not nil
    if (!videoUrl) {
        return nil;
    }
    NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
    // get image data and check if that is not nil
    if (!videoData) {
        return nil;
    }
    return [PFFileObject fileObjectWithData:videoData contentType:@"video/mp4"];
}

+ (void)getHighlightsWithCompletion:(void(^)(NSError *error, NSArray <Highlight*> *highlights))completion {
    PFQuery *highlightQuery = [PFQuery queryWithClassName:@"Highlight"];
    [highlightQuery orderByDescending:@"createdAt"];
    [highlightQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        completion(error, objects);
    }];
}
@end
