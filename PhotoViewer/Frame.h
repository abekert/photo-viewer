//
//  Frame.h
//  PhotoViewer
//
//  Created by Alexander Bekert on 26/11/13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import "SCNNode+Utils.h"

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, Orientation)
{
    OrientationHorizontal,
    OrientationVertical
};


@interface Frame : SCNNode
{
    NSImage *image;
    SCNNode *frame;
    
    bool startedPlayerLayer;
    AVPlayerItem *playerItem;
    AVPlayer *player;
    AVPlayerLayer *playerLayer;
}

- (id)initWithImage:(NSImage *)image;
- (void)placeImage:(NSImage *)newImage;
- (void)placeImageWithImagePath:(NSString *)path;
- (void)placeImageWithImageURL:(NSURL *)url;

- (SCNVector3)cameraPosition;
- (SCNVector3)spotlightPosition;

- (id)initWithVideoPlayerItem:(AVPlayerItem *)playerItem;

- (void)putInFocus;
- (void)putOutFocus;

@end
