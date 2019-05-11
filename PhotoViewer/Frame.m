//
//  Frame.m
//  PhotoViewer
//
//  Created by Alexander Bekert on 26/11/13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import "Frame.h"

#define FRAME_HIGHT 60

@implementation Frame

- (id)initWithImage:(NSImage *)newImage
{
    self = [super init];
    if (self) {
        image = newImage;
        
        [self addFrame];
        [self setFrameImage];
    }
    
    return self;
}

- (void)addFrame
{
    frame = [self addChildNodeNamed:@"frame-layer" fromSceneNamed:@"frames"];
}

- (void)setFrameImage
{
    SCNNode *photoNode = [frame childNodeWithName:@"frame" recursively:YES];

    BOOL isVertical = image.size.height > image.size.width;
    if (isVertical) {
        photoNode.scale = SCNVector3Make(1.2, 1, 0.7);
    } else {
        photoNode.scale = SCNVector3Make(0.9, 1, 1);
    }
    
    SCNMaterial *photoMaterial = [photoNode.geometry materialWithName:@"photo"];
    photoMaterial.diffuse.contents = image;
}

- (void)placeImage:(NSImage *)newImage
{
    image = newImage;
    [self setFrameImage];
}

- (void)placeImageWithImagePath:(NSString *)path
{
    image = [[NSImage alloc] initWithContentsOfFile:path];
    [self placeImage:image];
}

- (void)placeImageWithImageURL:(NSURL *)url
{
    image = [[NSImage alloc] initWithContentsOfURL:url];
    [self placeImage:image];
}

#pragma mark Positions

- (SCNVector3)cameraPosition
{
    return SCNVector3Make(self.position.x + 10, self.position.y + 15, self.position.z + 60);
}

- (SCNVector3)spotlightPosition
{
    return SCNVector3Make(self.position.x, self.position.y + 50, self.position.z + 25);
}

#pragma mark - Video

- (id)initWithVideoPlayerItem:(AVPlayerItem *)newPlayerItem
{
    self = [super init];
    if (self) {
        
        playerItem = newPlayerItem;

        [self addFrame];
        [self loadPlayer];
    }
    
    return self;
}

- (void)loadPlayer
{
    NSLog(@"loadPlayer invoked");
    
    startedPlayerLayer = NO;
    
    SCNNode *frameNode = [frame childNodeWithName:@"frame" recursively:YES];
    frameNode.scale = SCNVector3Make(0.8, 1, 1);
    
    player = [AVPlayer playerWithPlayerItem:playerItem];
    
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    SCNNode *photoNode = [frame childNodeWithName:@"frame" recursively:YES];
    SCNMaterial *photoMaterial = [photoNode.geometry materialWithName:@"photo"];
    photoMaterial.diffuse.contents = playerLayer;
    [playerLayer setFrame:CGRectMake(0, 0, 640, 360)];

}

#pragma mark - Camera focus

- (void)putInFocus
{
    if (player) {
        [player play];
    }
    
    SCNNode *photoNode = [frame childNodeWithName:@"frame" recursively:YES];
    SCNMaterial *photoMaterial = [photoNode.geometry materialWithName:@"photo"];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1];
    
    self.position = SCNVector3Make(self.position.x, self.position.y, 20);
    photoMaterial.transparency = 1;
    
    [SCNTransaction commit];
}

- (void)putOutFocus
{
    if (player) {
        [player pause];
    }
    
    SCNNode *photoNode = [frame childNodeWithName:@"frame" recursively:YES];
    SCNMaterial *photoMaterial = [photoNode.geometry materialWithName:@"photo"];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1];
    
    self.position = SCNVector3Make(self.position.x, self.position.y, 0);
    photoMaterial.transparency = 0.5;
    
    [SCNTransaction commit];
}

- (void)removeFromParentNode
{
    [self putOutFocus];
    [super removeFromParentNode];
}

@end
