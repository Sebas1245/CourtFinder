//
//  Highlight.h
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 03/08/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Highlight : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString* highlightID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFFileObject *highlightVideo;
+(void)uploadHighlight:(NSURL *)highlightVideoURL completion:(PFBooleanResultBlock  _Nullable)completion;
+(PFFileObject *)getPFFileFromVideoURL:(NSURL * _Nullable)videoUrl;
+(void)getHighlightsWithCompletion:(void(^)(NSError *error, NSArray <Highlight*> *highlights))completion;
@end

NS_ASSUME_NONNULL_END
