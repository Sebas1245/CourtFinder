//
//  HighlightCell.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 04/08/21.
//

#import "HighlightCell.h"

@implementation HighlightCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self layoutIfNeeded];
}

- (void)setHighlight:(Highlight *)highlight {
    _highlight = highlight;
    NSURL *videoURL = [NSURL URLWithString:self.highlight.highlightVideo.url];
    self.highlightPlayer = [[AVPlayer alloc] initWithURL:videoURL];
    self.highlightPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    AVPlayerLayer *highlightPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.highlightPlayer];
    highlightPlayerLayer.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    highlightPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:highlightPlayerLayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.highlightPlayer currentItem]];
    [self.highlightPlayer play];
}

- (void)playerItemDidEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    [playerItem seekToTime:kCMTimeZero completionHandler:nil];
}

@end
